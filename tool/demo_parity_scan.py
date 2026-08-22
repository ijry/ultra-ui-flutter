#!/usr/bin/env python3
"""List the demo-section titles of each source demo page next to our port's.

The other scanners check the component API. Nothing compares the *demos*, so a
page can be registered and pass layout tests while covering only half the
variants the source demonstrates — which is what happened to the tree page
(4 sections upstream, 2 here).

This tool deliberately does NOT try to decide whether a page is complete. An
earlier version counted section widgets and was wrong in both directions: pages
group sections through per-page wrappers whose name, call style, and underlying
container all vary (`_ButtonBlock(title:)` over ExampleDemoBlock,
`_CellSection(title:)` over UPCellGroup, `_DividerBlock('...')` positional), and
some pages legitimately merge or split the source's sections. Any count I derived
was a guess dressed up as a measurement.

So: it prints the source's section titles per page, and every literal section
title it can find in ours, and leaves the comparison to a human. Use it as an
index for review, not as a pass/fail gate.
"""
from __future__ import annotations

import io
import os
import re
import sys

SRC_PAGES = r"D:\Repos\xyito\open\uview-plus\src\pages"
OUR_PAGES = r"D:\Repos\xyito\open\ultra-ui-flutter\example\lib\pages"
CATALOG = (
    r"D:\Repos\xyito\open\ultra-ui-flutter\example\lib\routes"
    r"\example_catalog.dart"
)

# Source block titles: <text class="...__title">标题</text>.
#
# The class must *end* at the title suffix: `u-page__item__title__slot-title` is a
# nested element inside a demo, not a section heading, and matching it by prefix
# made the collapse page look like it had 8 sections when it has 5.
SRC_TITLE = re.compile(
    r"""class="[^"]*(?:u-page__item__title|u-demo-block__title)(?:\s[^"]*)?"[^>]*>"""
    r"""\s*([^<{]+?)\s*<""",
    re.S,
)

# Our section titles, in the forms actually used across the example pages: a
# `title:` argument on a section container, the first positional argument of a
# per-page block widget, or the first argument of a per-page `_block(...)` /
# `_section(...)` helper *method* (several pages use a method rather than a
# widget class). All over-match slightly — a UPCell also takes `title:` — which
# is fine for an index meant to be read rather than counted.
OUR_TITLE = re.compile(
    r"(?:ExampleDemoBlock|UPCellGroup|_\w*(?:block|section|group|case|demo))\("
    r"(?:\s*key:[^,]+,)?\s*(?:title:\s*)?'([^']*)'",
    # DOTALL: dart format puts the title on the line after `_block(` whenever the
    # call wraps, so a same-line-only match found nothing on those pages.
    # IGNORECASE: helpers are both methods (`_block`) and widgets (`_CellSection`).
    re.S | re.I,
)

# Blocks fenced by `#ifdef MP-*` / `#ifdef APP-*` compile only for a mini-program
# or the uni-app runtime, so the demos inside them have no Flutter counterpart by
# construction (avatar's 小程序开放能力 shows a WeChat-only open-ability avatar).
# Stripping them keeps the review list to sections that could actually be ported.
PLATFORM_FENCE = re.compile(
    r"<!--\s*#ifdef\s+(?:MP|APP)[^>]*-->.*?<!--\s*#endif\s*-->",
    re.S,
)


def strip_platform_blocks(body: str) -> str:
    return PLATFORM_FENCE.sub("", body)


# id -> our page file, read from the catalog's builder wiring.
ROUTE = re.compile(
    r"id:\s*'([^']*)'.*?builder:\s*_build(\w+)", re.S
)


def our_page_files() -> dict[str, str]:
    """Map route id -> our page source, via the catalog's import + builder."""
    catalog = io.open(CATALOG, encoding="utf-8").read()
    # module name (last path segment) -> import path
    imports = {
        path.split("/")[-1]: path
        for path in re.findall(r"import '\.\./pages/([\w/]+)\.dart';", catalog)
    }
    builders = dict(
        re.findall(
            r"Widget _build(\w+)\(BuildContext context\) =>\s*const (\w+)\(",
            catalog,
        )
    )
    out: dict[str, str] = {}
    for route_id, builder in ROUTE.findall(catalog):
        cls = builders.get(builder)
        if not cls:
            continue
        # ChoosePage -> choose_page
        snake = re.sub(r"(?<!^)(?=[A-Z])", "_", cls).lower()
        path = imports.get(snake)
        if path:
            out[route_id] = os.path.join(OUR_PAGES, *path.split("/")) + ".dart"
    return out


def source_file(route_id: str) -> str | None:
    """componentsD/tree/tree -> src/pages/componentsD/tree/tree.{nvue,vue}."""
    base = os.path.join(SRC_PAGES, *route_id.split("/"))
    for ext in (".nvue", ".vue"):
        if os.path.exists(base + ext):
            return base + ext
    return None


def main() -> int:
    only = sys.argv[1] if len(sys.argv) > 1 else None
    pages = our_page_files()
    checked = 0
    for route_id, our_path in sorted(pages.items()):
        if only and only not in route_id:
            continue
        src_path = source_file(route_id)
        if src_path is None or not os.path.exists(our_path):
            continue
        src = io.open(src_path, encoding="utf-8").read()
        m = re.search(r"<template>(.*)</template>", src, re.S)
        body = strip_platform_blocks(m.group(1) if m else src)
        src_titles = [t.strip() for t in SRC_TITLE.findall(body) if t.strip()]
        if not src_titles:
            continue
        our_titles = OUR_TITLE.findall(io.open(our_path, encoding="utf-8").read())
        checked += 1
        # Titles the source demonstrates that do not appear verbatim in ours.
        absent = [t for t in src_titles if t not in our_titles]
        flag = "  <-- review" if absent else ""
        print(f"\n{route_id}{flag}")
        print(f"  source ({len(src_titles)}): {' | '.join(src_titles)}")
        print(f"  ours   ({len(our_titles)}): {' | '.join(our_titles) or '-'}")
        if absent:
            print(f"  not matched verbatim: {' | '.join(absent)}")
    print(f"\npages listed: {checked}")
    print("Titles differ in wording legitimately; read the lists, do not trust a count.")
    return 0


if __name__ == "__main__":
    # The titles are Chinese; the Windows console default codepage mangles them.
    sys.stdout.reconfigure(encoding="utf-8")
    raise SystemExit(main())
