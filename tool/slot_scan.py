#!/usr/bin/env python3
"""Compare source component slots against Dart builder/slot parameters.

coverage_scan.py checks props, emits, and methods. It never checked *slots*, so
a component could score 100% there while offering no way to replace the piece of
markup the source lets you replace. Writing the demo pages surfaced this: the
u-cate-tab demo uses the `itemList` slot, which had no Dart equivalent even
though the component scanned as fully covered.

A slot maps to a Dart `Widget Function(...)` parameter (conventionally
`<name>Builder`) or a `Widget?` parameter (`<name>Slot`), or — for the default
slot — to `child`. Naming is a heuristic, so this proves absence, not
correctness: a reported miss is a real gap, but a reported hit only means
something plausibly-named exists.
"""
from __future__ import annotations

import io
import os
import re
import sys

SRC = r"D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components"
DART = r"D:\Repos\xyito\open\ultra-ui-flutter\packages\ultra_ui\lib\src\widgets"

SLOT = re.compile(r"<slot\b([^>]*)>", re.S)
SLOT_NAME = re.compile(r"""\bname\s*=\s*["']([^"']+)["']""")
# v-slot / #name usages are consumers, not declarations, so they are not scanned.

# Components whose Dart class name is not the mechanical camel-case of the source
# name.
CLASS_OVERRIDES = {
    # u-dragsort's Dart class is UPDragSort, not UPDragsort: the port splits the
    # compound word the source ran together. Naming it here keeps that spelling
    # difference from being reported as a missing component.
    "u-dragsort": "UPDragSort",
}

# Slots whose Dart parameter is deliberately named something else. Each entry is
# "<component>:<slot>" -> Dart parameter name, so the mapping is explicit and a
# rename on either side shows up as a miss rather than being silently accepted.
ALIASES = {
    # u-cate-tab's `pageItem` slot renders one child row and `tabItem` renders
    # one left-hand tab; the Dart names drop the redundant "page"/"tab" prefix
    # because the parameter types already say which is which.
    "u-cate-tab:pageItem": "itemBuilder",
    "u-cate-tab:tabItem": "tabBuilder",
}


def dart_class(name: str) -> str:
    """u-cate-tab -> UPCateTab."""
    if name in CLASS_OVERRIDES:
        return CLASS_OVERRIDES[name]
    parts = [p for p in name.split("-") if p and p not in ("u", "up")]
    return "UP" + "".join(p[:1].upper() + p[1:] for p in parts)


def class_index() -> dict[str, str]:
    """Map every UP* class to the body of its declaring file.

    Resolving by class name rather than by filename matters: several components
    are declared alongside a relative (UPCellGroup lives in up_cell.dart), so a
    file-per-component lookup reports them as unported when they are not.
    """
    out: dict[str, str] = {}
    for fn in os.listdir(DART):
        if not fn.endswith(".dart"):
            continue
        text = io.open(os.path.join(DART, fn), encoding="utf-8").read()
        for cls in re.findall(r"^class (UP\w+)", text, re.M):
            out.setdefault(cls, text)
    return out


def camel(slot: str) -> str:
    """right-top -> rightTop; keeps already-camel names as-is."""
    bits = re.split(r"[-_]", slot)
    return bits[0] + "".join(b[:1].upper() + b[1:] for b in bits[1:])


def source_slots(comp_dir: str) -> set[str]:
    out: set[str] = set()
    for fn in os.listdir(comp_dir):
        if not fn.endswith((".vue", ".nvue")):
            continue
        text = io.open(os.path.join(comp_dir, fn), encoding="utf-8").read()
        # Only the <template> block declares slots; script strings may mention them.
        m = re.search(r"<template>(.*)</template>", text, re.S)
        body = m.group(1) if m else text
        for attrs in SLOT.findall(body):
            nm = SLOT_NAME.search(attrs)
            out.add(nm.group(1) if nm else "default")
    return out


def main() -> int:
    classes = class_index()
    total = missing = 0
    rows: list[tuple[str, list[str]]] = []
    for name in sorted(os.listdir(SRC)):
        comp_dir = os.path.join(SRC, name)
        if not os.path.isdir(comp_dir):
            continue
        slots = source_slots(comp_dir)
        if not slots:
            continue
        dart = classes.get(dart_class(name))
        if dart is None:
            rows.append((name, sorted(slots) + ["<no dart class>"]))
            missing += len(slots)
            total += len(slots)
            continue
        gaps: list[str] = []
        for slot in sorted(slots):
            total += 1
            alias = ALIASES.get(f"{name}:{slot}")
            if alias:
                ok = re.search(r"\bthis\.%s\b" % re.escape(alias), dart)
            elif slot == "default":
                # The default slot is `child` for a single-child widget,
                # `children` for a group, or an itemBuilder where the source
                # repeats the slot per row.
                ok = re.search(
                    r"\bthis\.(child|children|itemBuilder|contentBuilder)\b", dart
                )
            else:
                c = camel(slot)
                # Builder / Slot / Widget suffix, or the bare camel name.
                ok = re.search(
                    r"\bthis\.(%s(Builder|Slot|Widget)?)\b" % re.escape(c),
                    dart,
                    re.I,
                )
            if not ok:
                gaps.append(slot)
                missing += 1
        if gaps:
            rows.append((name, gaps))

    print(f"slots compared: {total}, unmatched: {missing}")
    for name, gaps in rows:
        print(f"  {name}: {', '.join(gaps)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
