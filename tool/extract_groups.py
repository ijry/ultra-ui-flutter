#!/usr/bin/env python3
"""Extract the uview-plus demo group -> component mapping.

Mirrors src/pages/example/components.config.js so the Flutter progress doc can
present components in the same order the source demo shows them.
"""
from __future__ import annotations

import json
import re

CONFIG = (
    r"D:\Repos\xyito\open\uview-plus\src\pages\example\components.config.js"
)
OUT = r"D:\Repos\xyito\open\ultra-ui-flutter\.scan\groups.json"

ENTRY = re.compile(
    r"path:\s*'([^']*)'\s*,\s*icon:\s*'[^']*'\s*,\s*title:\s*'([^']*)'", re.S
)

def main() -> None:
    text = open(CONFIG, encoding="utf-8").read()
    groups: dict[str, list[dict[str, str]]] = {}
    chunks = re.split(r"groupName:", text)[1:]
    for chunk in chunks:
        name = re.match(r"\s*'([^']+)'", chunk).group(1)
        entries = [
            {"path": p, "title": t} for p, t in ENTRY.findall(chunk)
        ]
        groups[name] = entries

    total = sum(len(v) for v in groups.values())
    for name, entries in groups.items():
        print(name, len(entries))
    print("total", total)
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(groups, fh, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
