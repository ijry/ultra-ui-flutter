#!/usr/bin/env python3
"""Scan uview-plus source components and report Flutter port coverage.

Emits JSON on stdout:
  { component: {props: [...], emits: [...], methods: [...],
                dart_file: str|None, missing_props: [...],
                missing_emits: [...], missing_methods: [...]} }
"""
from __future__ import annotations

import json
import os
import re
import sys

SRC = r"D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components"
DST = r"D:\Repos\xyito\open\ultra-ui-flutter\packages\ultra_ui\lib\src\widgets"

# Source-only names that have no meaningful Flutter counterpart.
HOST_ONLY_PROPS = {
    "customClass", "customStyle", "hoverClass", "openType", "sendMessageTitle",
    "sendMessagePath", "sendMessageImg", "appParameter", "showMessageCard",
    "sessionFrom", "lang", "groupId", "dataName", "scope",
}


def snake(name: str) -> str:
    s = re.sub(r"(?<!^)(?=[A-Z])", "_", name)
    return s.lower()


def read(path: str) -> str:
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def source_component_dirs() -> list[str]:
    out = []
    for entry in sorted(os.listdir(SRC)):
        if entry.startswith("u-") and os.path.isdir(os.path.join(SRC, entry)):
            out.append(entry)
    return out


PROP_KEY = re.compile(r"^[ \t]{2,}([A-Za-z_$][\w$]*)\s*:\s*\{", re.M)
EMITS_ARR = re.compile(r"emits\s*:\s*\[([^\]]*)\]", re.S)
DEFINE_EMITS = re.compile(r"defineEmits\s*\(\s*\[([^\]]*)\]", re.S)
METHOD_DEF = re.compile(r"^[ \t]{2,}([A-Za-z_$][\w$]*)\s*\(([^)\n]*)\)\s*\{", re.M)
COMPUTED_BLOCK = re.compile(r"\n\s*computed\s*:\s*\{", re.S)
METHODS_BLOCK = re.compile(r"\n\s*methods\s*:\s*\{", re.S)


def brace_slice(text: str, start: int) -> str:
    """Return the balanced-brace body beginning at the '{' at/after start."""
    i = text.find("{", start)
    if i < 0:
        return ""
    depth = 0
    for j in range(i, len(text)):
        c = text[j]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return text[i + 1 : j]
    return text[i + 1 :]


def collect_props(comp_dir: str) -> list[str]:
    names: set[str] = set()
    props_js = os.path.join(comp_dir, "props.js")
    text = read(props_js)
    if text:
        body = brace_slice(text, text.find("props:"))
        names |= set(PROP_KEY.findall(body))
    # Inline props in the .vue file (components without props.js).
    for vue in vue_files(comp_dir):
        vtext = read(vue)
        idx = vtext.find("props:")
        if idx >= 0:
            names |= set(PROP_KEY.findall(brace_slice(vtext, idx)))
        for m in re.finditer(r"defineProps\s*\(", vtext):
            names |= set(PROP_KEY.findall(brace_slice(vtext, m.end() - 1)))
    return sorted(n for n in names if n not in HOST_ONLY_PROPS)


def vue_files(comp_dir: str) -> list[str]:
    base = os.path.basename(comp_dir)
    main = os.path.join(comp_dir, base + ".vue")
    files = [main] if os.path.exists(main) else []
    for entry in sorted(os.listdir(comp_dir)):
        p = os.path.join(comp_dir, entry)
        if entry.endswith(".vue") and p not in files:
            files.append(p)
    return files


def collect_emits(comp_dir: str) -> list[str]:
    names: set[str] = set()
    for vue in vue_files(comp_dir):
        text = read(vue)
        for pat in (EMITS_ARR, DEFINE_EMITS):
            for m in pat.finditer(text):
                for raw in m.group(1).split(","):
                    raw = raw.strip().strip("'\"")
                    if raw and not raw.startswith("//"):
                        names.add(raw)
    return sorted(names)


JS_BUILTINS = {
    "if", "for", "while", "switch", "catch", "function", "return", "else",
    "try", "do", "default", "case", "typeof", "new", "delete", "in", "of",
    "setTimeout", "setInterval", "clearTimeout", "clearInterval",
    "then", "map", "filter", "forEach", "reduce", "constructor",
}


def collect_methods(comp_dir: str) -> list[str]:
    names: set[str] = set()
    for vue in vue_files(comp_dir):
        text = read(vue)
        for blk in (METHODS_BLOCK, COMPUTED_BLOCK):
            m = blk.search(text)
            if not m:
                continue
            body = brace_slice(text, m.end() - 1)
            for mm in METHOD_DEF.finditer(body):
                nm = mm.group(1)
                if nm not in JS_BUILTINS:
                    names.add(nm)
    return sorted(names)


def dart_index() -> dict[str, str]:
    """Map lowered widget class name -> dart file path."""
    index: dict[str, str] = {}
    for entry in sorted(os.listdir(DST)):
        if not entry.endswith(".dart"):
            continue
        path = os.path.join(DST, entry)
        text = read(path)
        for m in re.finditer(r"^class\s+(UP\w+)", text, re.M):
            index.setdefault(m.group(1), path)
    return index


# Source dir names whose Flutter class does not follow the kebab->Pascal rule.
CLASS_ALIASES = {
    "u-dragsort": "UPDragSort",
    "uview-plus": None,
}


def expected_class(source_name: str) -> str | None:
    if source_name in CLASS_ALIASES:
        return CLASS_ALIASES[source_name]
    parts = source_name[2:].split("-")
    return "UP" + "".join(p[:1].upper() + p[1:] for p in parts)


def main() -> int:
    classes = dart_index()
    # Cache file text so member lookups are cheap.
    file_text: dict[str, str] = {}
    report: dict[str, dict] = {}

    for name in source_component_dirs():
        comp_dir = os.path.join(SRC, name)
        cls = expected_class(name)
        path = classes.get(cls) if cls else None
        text = ""
        if path:
            if path not in file_text:
                file_text[path] = read(path)
            text = file_text[path]

        props = collect_props(comp_dir)
        emits = collect_emits(comp_dir)
        methods = collect_methods(comp_dir)

        def present(member: str, kind: str) -> bool:
            if not text:
                return False
            snk = snake(member)
            cands = {member, snk}
            if kind == "emit":
                # update:modelValue -> onUpdateModelValue (preserve inner caps)
                segs = [s for s in re.split(r"[-:.]", member) if s]
                pascal = "".join(s[:1].upper() + s[1:] for s in segs)
                cands |= {"on" + pascal, "on" + member[:1].upper() + member[1:]}
            for c in cands:
                if re.search(r"\b" + re.escape(c) + r"\b", text):
                    return True
            return False

        report[name] = {
            "dart_class": cls if path else None,
            "dart_file": os.path.basename(path) if path else None,
            "props_total": len(props),
            "emits_total": len(emits),
            "methods_total": len(methods),
            "missing_props": [p for p in props if not present(p, "prop")],
            "missing_emits": [e for e in emits if not present(e, "emit")],
            "missing_methods": [m for m in methods if not present(m, "method")],
        }

    json.dump(report, sys.stdout, ensure_ascii=False, indent=1)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
