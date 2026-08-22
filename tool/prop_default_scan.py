#!/usr/bin/env python3
"""Compare source prop DEFAULT VALUES against the Dart ports.

The API scanner (coverage_scan.py) only checks that a prop exists. A prop can
exist and still carry the wrong default, which is a visible difference: a size,
spacing, radius, duration or font-size that is off by a few px looks "almost
right" and is exactly the kind of thing that survives a name-based check.

Source of truth: each component's own defaults file (u-button/button.js etc.),
which is what registerComponentProps feeds into props.js.

Emits JSON on stdout:
  {component: {prop: {"source": <literal>, "dart": <literal>|null,
                      "ok": bool|null}}}
`ok` is null when the comparison is not meaningful (a Dart-side expression
rather than a literal), so those are reported separately from real mismatches.
"""
from __future__ import annotations

import json
import os
import re
import sys

SRC = r"D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components"
DST = r"D:\Repos\xyito\open\ultra-ui-flutter\packages\ultra_ui\lib\src\widgets"

# Props whose default is host- or platform-specific and has no Flutter meaning.
SKIP_PROPS = {
    "openType", "formType", "appParameter", "sessionFrom", "sendMessageTitle",
    "sendMessagePath", "sendMessageImg", "showMessageCard", "dataName", "lang",
    "hoverClass", "customClass", "customStyle", "hoverStopPropagation",
    "hoverStartTime", "hoverStayTime",
}

# Deliberate divergences, with the reason. Reported separately from real
# mismatches so they cannot quietly hide a regression.
INTENTIONAL = {
    ("u-calendar", "defaultTime"):
        "Source pads an empty value to 00:00 (parseTimeValue), so '' and "
        "'00:00' are behaviorally identical; the explicit value documents it.",
    ("u-column-notice", "text"):
        "Dart models the absent-text case as null rather than '', which the "
        "widget already treats the same way.",
    ("u-no-network", "image"):
        "Source inlines a base64 PNG. Flutter ships the asset separately, so "
        "embedding a data URL in Dart source would be dead weight.",
    ("u-search", "maxlength"):
        "Source uses the string '-1'; Dart types this as int, and -1 carries "
        "the same 'no limit' meaning.",
}

# Source dir -> Dart class, where the kebab->Pascal rule does not apply.
CLASS_ALIASES = {"u-dragsort": "UPDragSort", "uview-plus": None}

# `key: value,` at one indent level inside the defaults object.
ENTRY = re.compile(r"^\s{8}([A-Za-z_$][\w$]*)\s*:\s*(.+?),?\s*$", re.M)


def expected_class(name: str) -> str | None:
    if name in CLASS_ALIASES:
        return CLASS_ALIASES[name]
    parts = name[2:].split("-")
    return "UP" + "".join(p[:1].upper() + p[1:] for p in parts)


def js_literal(raw: str) -> object | None:
    """Reduce a JS default to a comparable Python value, or None if complex."""
    raw = raw.strip().rstrip(",").strip()
    if raw in ("true", "false"):
        return raw == "true"
    if raw in ("null", "undefined"):
        return None
    if re.fullmatch(r"-?\d+", raw):
        return int(raw)
    if re.fullmatch(r"-?\d*\.\d+", raw):
        return float(raw)
    m = re.fullmatch(r"'([^']*)'|\"([^\"]*)\"", raw)
    if m:
        return m.group(1) if m.group(1) is not None else m.group(2)
    # Arrays, objects, functions, expressions: not comparable here.
    return None


def dart_literal(raw: str) -> object | None:
    raw = raw.strip().rstrip(",").strip()
    if raw in ("true", "false"):
        return raw == "true"
    if raw == "null":
        return None
    if re.fullmatch(r"-?\d+", raw):
        return int(raw)
    if re.fullmatch(r"-?\d*\.\d+", raw):
        return float(raw)
    m = re.fullmatch(r"'([^']*)'|\"([^\"]*)\"", raw)
    if m:
        return m.group(1) if m.group(1) is not None else m.group(2)
    return None


def read(path: str) -> str:
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def source_defaults(comp_dir: str, name: str) -> dict[str, object]:
    """Parse the component's defaults file into {prop: literal}."""
    # The file is named after the component minus the u- prefix, camelCased.
    stem = name[2:]
    camel = re.sub(r"-(\w)", lambda m: m.group(1).upper(), stem)
    for candidate in (f"{camel}.js", f"{stem}.js"):
        path = os.path.join(comp_dir, candidate)
        if os.path.exists(path):
            break
    else:
        return {}

    text = read(path)
    # Body of the single `<name>: { ... }` entry inside `export default {}`.
    out: dict[str, object] = {}
    for prop, raw in ENTRY.findall(text):
        if prop in SKIP_PROPS:
            continue
        value = js_literal(raw)
        if value is None and raw.strip().rstrip(",") not in ("null", "undefined"):
            continue  # not comparable
        out[prop] = value
    return out


def dart_defaults(text: str, cls: str) -> dict[str, object]:
    """Parse `this.<prop> = <literal>,` from the class's constructor."""
    start = text.find(f"class {cls} extends")
    if start < 0:
        return {}
    # Constructor params run to the closing `});` of the const ctor.
    ctor = text.find("({", start)
    if ctor < 0:
        return {}
    end = text.find("});", ctor)
    body = text[ctor:end if end > 0 else ctor + 4000]
    out: dict[str, object] = {}
    # A quoted default may contain commas of its own, e.g.
    # 'rgba(255, 255, 255, 0.35)', so match a full quoted string first and only
    # fall back to "up to the next comma" for bare values.
    value = r"""('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*"|[^,\n]+)"""
    for prop, raw in re.findall(r"this\.(\w+)\s*=\s*" + value, body):
        out[prop] = dart_literal(raw)
    # Params with no default are still declared; record them as absent.
    for prop in re.findall(r"this\.(\w+),", body):
        out.setdefault(prop, "<no-default>")
    return out


def main() -> int:
    report: dict[str, dict] = {}
    mismatches = 0
    compared = 0
    intentional = 0

    for entry in sorted(os.listdir(SRC)):
        if not entry.startswith("u-"):
            continue
        comp_dir = os.path.join(SRC, entry)
        if not os.path.isdir(comp_dir):
            continue
        cls = expected_class(entry)
        if not cls:
            continue

        src_defaults = source_defaults(comp_dir, entry)
        if not src_defaults:
            continue

        # Find the Dart file declaring that class.
        dart_text = ""
        for dart_file in sorted(os.listdir(DST)):
            if not dart_file.endswith(".dart"):
                continue
            text = read(os.path.join(DST, dart_file))
            if re.search(rf"^class {cls} extends", text, re.M):
                dart_text = text
                break
        if not dart_text:
            continue

        dst_defaults = dart_defaults(dart_text, cls)
        entries: dict[str, dict] = {}
        for prop, source_value in src_defaults.items():
            if prop not in dst_defaults:
                continue  # missing props are the API scanner's job
            actual = dst_defaults[prop]
            reason = INTENTIONAL.get((entry, prop))
            if actual == "<no-default>":
                ok = None
            elif actual == source_value:
                ok = True
                compared += 1
            elif reason:
                # Differs on purpose; counted separately so it stays visible
                # without masking a genuine regression.
                ok = None
                intentional += 1
            else:
                ok = False
                compared += 1
                mismatches += 1
            record = {
                "source": source_value,
                "dart": actual,
                "ok": ok,
            }
            if reason:
                record["intentional"] = reason
            entries[prop] = record
        if entries:
            report[entry] = entries

    report["_summary"] = {
        "compared": compared,
        "mismatches": mismatches,
        "intentional": intentional,
        "components": len([k for k in report if k != "_summary"]),
    }
    sys.stdout.reconfigure(encoding="utf-8")
    json.dump(report, sys.stdout, ensure_ascii=False, indent=1)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
