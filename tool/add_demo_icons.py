#!/usr/bin/env python3
"""Add the source's per-entry demo icon to example_preview_catalog.dart.

The uview-plus demo list shows a PNG per row, resolved as
`/static/uview/demo/<icon>.png` from components.config.js / template.config.js.
Our catalog had no icon field, so the list rendered as plain text.

This reads the source configs, maps each demo path to its icon name, and injects
a matching `icon:` argument into every ExamplePreviewRoute. Run it again after
adding routes; it is idempotent (entries that already carry an icon are skipped).
"""
from __future__ import annotations

import io
import re
import sys

SRC = r"D:\Repos\xyito\open\uview-plus\src\pages\example"
CATALOG = (
    r"D:\Repos\xyito\open\ultra-ui-flutter\example\lib\routes"
    r"\example_preview_catalog.dart"
)
ICON_DIR = (
    r"D:\Repos\xyito\open\ultra-ui-flutter\example\assets\uview\demo\icons"
)

# path -> icon, from the two source config files.
ENTRY = re.compile(
    r"path:\s*'([^']*)'\s*,\s*icon:\s*'([^']*)'", re.S
)


def source_icons() -> dict[str, str]:
    out: dict[str, str] = {}
    for name in ("components.config.js", "template.config.js"):
        try:
            text = io.open(f"{SRC}\\{name}", encoding="utf-8").read()
        except OSError:
            continue
        for path, icon in ENTRY.findall(text):
            # Configs use a leading slash; our sourcePath does not.
            key = path.lstrip("/")
            out[key] = icon
            # template.config.js sometimes gives a bare name ("order") where our
            # sourcePath is the full route ("pages/template/order/index"), so
            # index by the last meaningful segment too.
            leaf = key.split("/")[-1]
            if leaf in ("index", ""):
                parts = [x for x in key.split("/") if x not in ("index", "")]
                leaf = parts[-1] if parts else key
            out.setdefault(f"@leaf:{leaf}", icon)
    return out


def main() -> int:
    icons = source_icons()
    if not icons:
        print("no icons parsed from source configs", file=sys.stderr)
        return 1

    import os

    available = {
        f[:-4] for f in os.listdir(ICON_DIR) if f.endswith(".png")
    }

    text = io.open(CATALOG, encoding="utf-8").read()
    added = 0
    missing_icon: list[str] = []
    no_asset: list[str] = []

    def inject(match: re.Match[str]) -> str:
        nonlocal added
        block = match.group(0)
        source_path = match.group(1)
        if "icon:" in block:
            return block
        icon = icons.get(source_path)
        if icon is None:
            # Fall back to the route's own leaf segment.
            parts = [x for x in source_path.split("/") if x not in ("index", "")]
            if parts:
                icon = icons.get(f"@leaf:{parts[-1]}")
        if icon is None:
            missing_icon.append(source_path)
            return block
        if icon not in available:
            no_asset.append(f"{source_path} -> {icon}")
            return block
        added += 1
        # Insert after sourcePath so the argument order reads consistently.
        return block.replace(
            f"sourcePath: '{source_path}',",
            f"sourcePath: '{source_path}',\n      icon: '{icon}',",
            1,
        )

    # One ExamplePreviewRoute(...) literal at a time.
    pattern = re.compile(
        r"ExamplePreviewRoute\(\s*sourcePath: '([^']*)'.*?\)", re.S
    )
    text = pattern.sub(inject, text)

    io.open(CATALOG, "w", encoding="utf-8", newline="\n").write(text)
    print(f"icons added: {added}")
    if missing_icon:
        print(f"no icon in source config ({len(missing_icon)}):")
        for p in missing_icon:
            print("  ", p)
    if no_asset:
        print(f"icon named but asset absent ({len(no_asset)}):")
        for p in no_asset:
            print("  ", p)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
