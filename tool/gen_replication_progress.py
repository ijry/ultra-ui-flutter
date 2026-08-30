#!/usr/bin/env python3
"""Generate the uView Plus -> Flutter replication inventory.

The repository has two useful, but different, inventories: ``pages.json`` is
the upstream registration source while ``example_catalog.dart`` is the set of
routes that can actually be opened in Flutter.  This script keeps both views
in one generated document and fails fast when either registry contains a
duplicate route.  It intentionally uses small text parsers instead of a JS or
Dart runtime so it can run in CI without installing the upstream toolchain.
"""
from __future__ import annotations

import argparse
import datetime as _datetime
import json
import os
import re
import subprocess
from pathlib import Path
from typing import Iterable, Mapping, Sequence


STATUS_DONE = "✅ 已复刻"
STATUS_PARTIAL = "🟡 部分"
STATUS_TODO = "⛔ 未复刻"
STATUS_EXTRA = "🆕 Flutter 扩展"
STATUS_UNREGISTERED = "ℹ️ 未注册源码"

GROUP_ORDER = ("main", "componentsA", "componentsB", "componentsC", "componentsD", "template")

# Components whose demo page represents more than the last path segment.  The
# mapping mirrors the source demo's intent and is also used for the reverse
# "关联演示" column in the component table.
PAGE_TO_COMPONENTS = {
    "color": [],
    "layout": ["u-row", "u-col"],
    "progress": ["u-line-progress", "u-circle-progress"],
    "keyboard": ["u-keyboard", "u-number-keyboard", "u-car-keyboard"],
    "tabbar2": ["u-tabbar"],
    "indexList2": ["u-index-list"],
    "table2": ["u-table2"],
}

CHILD_OF = {
    "u-action-sheet-data": "u-action-sheet",
    "u-avatar-group": "u-avatar",
    "u-cell-group": "u-cell",
    "u-checkbox-group": "u-checkbox",
    "u-col": "u-row",
    "u-collapse-item": "u-collapse",
    "u-column-notice": "u-notice-bar",
    "u-dropdown-item": "u-dropdown",
    "u-form-item": "u-form",
    "u-grid-item": "u-grid",
    "u-index-anchor": "u-index-list",
    "u-index-item": "u-index-list",
    "u-list-item": "u-list",
    "u-picker-column": "u-picker",
    "u-picker-data": "u-picker",
    "u-radio-group": "u-radio",
    "u-row-notice": "u-notice-bar",
    "u-steps-item": "u-steps",
    "u-swipe-action-item": "u-swipe-action",
    "u-swiper-indicator": "u-swiper",
    "u-tabbar-item": "u-tabbar",
    "u-tabs-item": "u-tabs",
    "u-td": "u-table",
    "u-th": "u-table",
    "u-tr": "u-table",
}

EMULATION_NOTES = {
    "u-pdf-reader": "宿主通过 `viewerBuilder` 注入真实 PDF 视图",
    "u-short-video": "宿主通过 `videoBuilder` 注入播放器",
    "u-city-locate": "宿主通过 `locationHandler` 替代 `uni.getLocation`",
    "u-no-network": "宿主拥有真实连通性检测",
    "u-canvas": "Flutter `CustomPainter` 替代 uni canvas context",
    "u-dragsort": "`direction=all` 用受约束网格 + 长按拖拽替代 `movable-view` 绝对定位",
    "u-select": "根 Overlay 锚定面板替代绝对定位 DOM 层叠",
    "u-cate-tab": "`follow` 用滚动位置跟踪替代 IntersectionObserver",
    "u-table2": "固定表头/左固定列用 Flutter 滚动裁剪覆盖层替代 CSS sticky",
    "u-guide": "`zIndex` 保留；真正全局固定层叠需状态保持 portal",
    "u-calendar-strip": "滑动手势用月份按钮模拟",
    "u-parse": "HTML 子集渲染为 Flutter 组件树，无 CSS 引擎；NVUE web-view/JSBridge 内部方法不适用",
    "u-qrcode": "Flutter `CustomPainter` 声明式重绘替代 Vue canvas watcher 队列；保留源码空值语义",
    "u-markdown": "Markdown → HTML 后交由 UPParse 渲染（与源码同架构）",
    "u-root-toast-host": "替代 `uni.$u.setRootToastRef`，注册全局 toast/notify 宿主",
    "u-novel-reader": "分页测量用源码 measure-adapter 启发式宽度；持久化经宿主钩子；CSS computed 映射为 Flutter 主题与布局对象",
}

SLOT_ALIASES = {
    "u-cate-tab:pageItem": "itemBuilder",
    "u-cate-tab:tabItem": "tabBuilder",
    "u-tree:default": "nodeBuilder",
}


def _read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def _strip_js_comments(text: str) -> str:
    """Remove JS comments while retaining quoted strings and newlines."""
    out: list[str] = []
    quote: str | None = None
    escaped = False
    line_comment = False
    block_comment = False
    i = 0
    while i < len(text):
        c = text[i]
        n = text[i + 1] if i + 1 < len(text) else ""
        if line_comment:
            if c == "\n":
                line_comment = False
                out.append(c)
            else:
                out.append(" ")
            i += 1
            continue
        if block_comment:
            if c == "*" and n == "/":
                block_comment = False
                out.extend((" ", " "))
                i += 2
            else:
                out.append("\n" if c == "\n" else " ")
                i += 1
            continue
        if quote is not None:
            out.append(c)
            if escaped:
                escaped = False
            elif c == "\\":
                escaped = True
            elif c == quote:
                quote = None
            i += 1
            continue
        if c in ("'", '"', "`"):
            quote = c
            out.append(c)
            i += 1
            continue
        if c == "/" and n == "/":
            line_comment = True
            out.extend((" ", " "))
            i += 2
            continue
        if c == "/" and n == "*":
            block_comment = True
            out.extend((" ", " "))
            i += 2
            continue
        out.append(c)
        i += 1
    return "".join(out)


def _remove_trailing_commas(text: str) -> str:
    """Remove commas before a closing JSON container outside strings."""
    out: list[str] = []
    quote: str | None = None
    escaped = False
    i = 0
    while i < len(text):
        c = text[i]
        if quote is not None:
            out.append(c)
            if escaped:
                escaped = False
            elif c == "\\":
                escaped = True
            elif c == quote:
                quote = None
            i += 1
            continue
        if c in ("'", '"'):
            # pages.json uses double quotes; accepting single quotes makes this
            # helper useful for small fixture files too.
            quote = c
            out.append(c)
            i += 1
            continue
        if c == ",":
            j = i + 1
            while j < len(text) and text[j].isspace():
                j += 1
            if j < len(text) and text[j] in "}]":
                i += 1
                continue
        out.append(c)
        i += 1
    return "".join(out)


def _json5_text(text: str) -> str:
    return _remove_trailing_commas(_strip_js_comments(text))


def _clean_path(path: str) -> str:
    path = path.strip().replace("\\", "/")
    path = path.lstrip("/")
    return re.sub(r"/+", "/", path)


def _route_id(path: str) -> str:
    path = _clean_path(path)
    return path[6:] if path.startswith("pages/") else path


def _title_from_page(page: Mapping[str, object]) -> str:
    style = page.get("style")
    if isinstance(style, Mapping):
        value = style.get("navigationBarTitleText")
        if isinstance(value, str):
            return value
    return ""


def _check_unique(items: Sequence[Mapping[str, object]], key: str, label: str) -> None:
    seen: set[str] = set()
    for item in items:
        value = str(item.get(key, ""))
        if value in seen:
            raise ValueError(f"duplicate {label}: {value}")
        seen.add(value)


def load_pages_json(path: str | os.PathLike[str]) -> list[dict[str, str]]:
    """Flatten root pages and sub-package pages from the JSON5-like file."""
    raw = json.loads(_json5_text(_read(Path(path))))
    routes: list[dict[str, str]] = []
    for page in raw.get("pages", []):
        if not isinstance(page, Mapping) or not page.get("path"):
            continue
        routes.append(
            {
                "path": _clean_path(str(page["path"])),
                "id": _route_id(str(page["path"])),
                "group": "main",
                "title": _title_from_page(page),
            }
        )
    for package in raw.get("subPackages", []):
        if not isinstance(package, Mapping):
            continue
        root = _clean_path(str(package.get("root", "")))
        group = root.rsplit("/", 1)[-1] if root else ""
        for page in package.get("pages", []):
            if not isinstance(page, Mapping) or not page.get("path"):
                continue
            full = f"{root}/{_clean_path(str(page['path']))}" if root else str(page["path"])
            routes.append(
                {
                    "path": _clean_path(full),
                    "id": _route_id(full),
                    "group": group,
                    "title": _title_from_page(page),
                }
            )
    _check_unique(routes, "path", "source route")
    return routes


def _quoted_field(text: str, name: str) -> str:
    match = re.search(
        rf"\b{re.escape(name)}\s*:\s*(['\"])(.*?)\1", text, re.S
    )
    return match.group(2).strip() if match else ""


def _bare_field(text: str, name: str) -> str:
    match = re.search(rf"\b{re.escape(name)}\s*:\s*([A-Za-z0-9_]+)", text)
    return match.group(1) if match else ""


def _group_field(text: str) -> str:
    match = re.search(
        r"\bgroup\s*:\s*(?:ExampleRouteGroup\.)?([A-Za-z0-9_]+)", text
    )
    return match.group(1) if match else ""


def _balanced_calls(text: str, token: str) -> list[str]:
    """Extract balanced constructor calls, ignoring parentheses in strings."""
    calls: list[str] = []
    # A lookup helper such as ``findExampleRoute(`` contains the constructor
    # token as a suffix; require a token boundary so it is not parsed as an
    # empty constructor call.
    for match in re.finditer(r"(?<![A-Za-z0-9_])" + re.escape(token), text):
        open_at = match.end() - 1
        depth = 0
        quote: str | None = None
        escaped = False
        for i in range(open_at, len(text)):
            c = text[i]
            if quote is not None:
                if escaped:
                    escaped = False
                elif c == "\\":
                    escaped = True
                elif c == quote:
                    quote = None
                continue
            if c in ("'", '"', "`"):
                quote = c
                continue
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    calls.append(text[match.start() : i + 1])
                    break
    return calls


def _pascal_from_snake(stem: str) -> str:
    return "".join(part[:1].upper() + part[1:] for part in stem.split("_") if part)


def parse_flutter_catalog(path: str | os.PathLike[str]) -> list[dict[str, object]]:
    """Parse route entries and resolve each builder to its imported page file."""
    catalog_path = Path(path)
    text = _read(catalog_path)
    imports: dict[str, str] = {}
    for match in re.finditer(r"import\s+['\"]\.\./pages/([^'\"]+\.dart)['\"]", text):
        rel = match.group(1).replace("\\", "/")
        imports[_pascal_from_snake(Path(rel).stem)] = f"example/lib/pages/{rel}"

    builders: dict[str, str] = {}
    builder_pattern = re.compile(
        r"Widget\s+(_build\w+)\s*\([^)]*\)\s*=>\s*(?:const\s+)?([A-Za-z_]\w*)\s*\(",
        re.S,
    )
    for match in builder_pattern.finditer(text):
        builders[match.group(1)] = match.group(2)
    # A block-bodied builder is uncommon, but resolving it costs little and
    # keeps the parser honest for future catalog entries.
    for match in re.finditer(
        r"Widget\s+(_build\w+)\s*\([^)]*\)\s*\{(.*?)\n\s*\}", text, re.S
    ):
        if match.group(1) in builders:
            continue
        cls = re.search(r"(?:return\s+)?(?:const\s+)?([A-Za-z_]\w*)\s*\(", match.group(2))
        if cls:
            builders[match.group(1)] = cls.group(1)

    routes: list[dict[str, object]] = []
    for call in _balanced_calls(text, "ExampleRoute("):
        source_path = _clean_path(_quoted_field(call, "sourcePath"))
        route_id = _quoted_field(call, "id") or _route_id(source_path)
        builder = _bare_field(call, "builder")
        page_class = builders.get(builder, "")
        routes.append(
            {
                "id": route_id,
                "source_path": source_path,
                "title": _quoted_field(call, "title"),
                "group": _group_field(call),
                "builder": builder,
                "page_class": page_class or "—",
                "page_file": imports.get(page_class, "—"),
                "available": True,
            }
        )
    _check_unique(routes, "id", "Flutter route")
    _check_unique(routes, "source_path", "Flutter source path")
    return routes


def parse_source_manifest(path: str | os.PathLike[str]) -> list[dict[str, str]]:
    """Parse the optional generated Dart manifest used by route tests."""
    text = _read(Path(path))
    routes: list[dict[str, str]] = []
    for call in _balanced_calls(text, "ExampleSourceRoute("):
        source_path = _clean_path(_quoted_field(call, "sourcePath"))
        # The class declaration itself contains ``ExampleSourceRoute(`` with
        # a named-parameter brace, but it is not an inventory entry.
        if not source_path:
            continue
        routes.append(
            {
                "id": _quoted_field(call, "id") or _route_id(source_path),
                "source_path": source_path,
                "title": _quoted_field(call, "title"),
                "group": _group_field(call),
            }
        )
    _check_unique(routes, "id", "source manifest route")
    return routes


def parse_demo_config(path: str | os.PathLike[str], *, template: bool = False) -> list[dict[str, str]]:
    """Parse visible demo entries from components.config.js/template.config.js."""
    text = _strip_js_comments(_read(Path(path)))
    matches = list(re.finditer(r"\bgroupName\s*:\s*(['\"])(.*?)\1", text, re.S))
    entries: list[dict[str, str]] = []
    for index, group_match in enumerate(matches):
        start = group_match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        chunk = text[start:end]
        # Config entries are deliberately simple objects. Restricting the
        # match to one object prevents a title from leaking into the next row.
        for obj in re.findall(r"\{(.*?)\}", chunk, re.S):
            raw_path = _quoted_field(obj, "path")
            if not raw_path:
                continue
            title = _quoted_field(obj, "title")
            icon = _quoted_field(obj, "icon")
            path_value = normalize_demo_path(raw_path, template=template)
            entries.append(
                {
                    "path": path_value,
                    "raw_path": raw_path,
                    "group": group_match.group(2).strip(),
                    "title": title,
                    "icon": icon,
                }
            )
    _check_unique(entries, "path", "demo config route")
    return entries


def normalize_demo_path(raw_path: str, *, template: bool = False) -> str:
    path = _clean_path(raw_path)
    if path.startswith("pages/"):
        return path
    if template:
        # The template config uses short names for index pages (coupon,
        # submitBar, comment, ...), while two entries already contain a full
        # pages/ path.
        if path.endswith("/index"):
            return f"pages/template/{path}"
        return f"pages/template/{path}/index"
    return path


def _source_component_names(source_components_dir: Path | None) -> list[str]:
    if source_components_dir is None or not source_components_dir.is_dir():
        return []
    return sorted(
        entry.name
        for entry in source_components_dir.iterdir()
        if entry.is_dir() and entry.name.startswith("u-")
    )


def _normal_component_key(name: str) -> str:
    return re.sub(r"[^a-z0-9]", "", name.lower().removeprefix("u"))


def component_names_for_demo(path: str, available: Iterable[str]) -> list[str]:
    """Return source component names represented by one demo route."""
    available_list = list(available)
    route_id = _route_id(path)
    leaf = route_id.rsplit("/", 1)[-1]
    if leaf in PAGE_TO_COMPONENTS:
        return [name for name in PAGE_TO_COMPONENTS[leaf] if name in available_list]
    exact = f"u-{leaf}"
    if exact in available_list:
        return [exact]
    key = _normal_component_key(leaf)
    matches = [name for name in available_list if _normal_component_key(name) == key]
    return matches[:1]


def _source_slots(component_dir: Path) -> list[str]:
    slots: set[str] = set()
    for file in component_dir.iterdir() if component_dir.is_dir() else []:
        if file.suffix not in (".vue", ".nvue"):
            continue
        text = _read(file)
        # Greedy matching mirrors the source slot scanner: component files can
        # contain nested template blocks, and the first closing tag is not
        # necessarily the end of the component template.
        template = re.search(r"<template>(.*)</template>", text, re.S)
        body = template.group(1) if template else text
        for attrs in re.findall(r"<slot\b([^>]*)>", body, re.S):
            match = re.search(r"\bname\s*=\s*['\"]([^'\"]+)['\"]", attrs)
            slots.add(match.group(1) if match else "default")
    return sorted(slots)


def _camel_slot(slot: str) -> str:
    bits = re.split(r"[-_]", slot)
    return bits[0] + "".join(bit[:1].upper() + bit[1:] for bit in bits[1:])


def _slot_compatibility(
    name: str,
    entry: Mapping[str, object],
    source_components_dir: Path | None,
    dart_widgets_dir: Path | None,
) -> tuple[int, int, list[str]] | None:
    if source_components_dir is None:
        return None
    slots = _source_slots(source_components_dir / name)
    if not slots:
        return None
    dart_file = str(entry.get("dart_file") or "")
    dart_class = str(entry.get("dart_class") or "")
    if not dart_file or not dart_widgets_dir or not dart_class:
        return 0, len(slots), slots
    dart_path = dart_widgets_dir / dart_file
    text = _read(dart_path)
    missing: list[str] = []
    for slot in slots:
        alias = SLOT_ALIASES.get(f"{name}:{slot}")
        if alias:
            found = re.search(rf"\bthis\.{re.escape(alias)}\b", text)
        elif slot == "default":
            found = re.search(r"\bthis\.(child|children|itemBuilder|contentBuilder)\b", text)
        else:
            camel = _camel_slot(slot)
            found = re.search(rf"\bthis\.{re.escape(camel)}(?:Builder|Slot|Widget)?\b", text, re.I)
        if not found:
            missing.append(slot)
    return len(slots) - len(missing), len(slots), missing


def _fraction(total: object, missing: object) -> str:
    try:
        total_int = int(total)
        missing_int = len(missing) if isinstance(missing, (list, tuple, set)) else int(missing)
    except (TypeError, ValueError):
        return "—"
    return "—" if total_int == 0 else f"{max(total_int - missing_int, 0)}/{total_int}"


def _component_status(entry: Mapping[str, object], slot_missing: Sequence[str] = ()) -> str:
    if not entry.get("dart_file"):
        return STATUS_TODO
    missing = sum(
        len(entry.get(key, []))
        for key in ("missing_props", "missing_emits", "missing_methods")
    ) + len(slot_missing)
    return STATUS_DONE if missing == 0 else STATUS_PARTIAL


def _display_path(path: str | os.PathLike[str] | None, repo_root: Path | None = None) -> str:
    if not path:
        return "—"
    value = Path(path)
    if repo_root is not None:
        try:
            value = value.resolve().relative_to(repo_root.resolve())
        except (OSError, ValueError):
            pass
    return str(value).replace("\\", "/")


def _component_note(name: str, entry: Mapping[str, object], slot_missing: Sequence[str], has_demo: bool) -> str:
    bits: list[str] = []
    if name in EMULATION_NOTES:
        bits.append(EMULATION_NOTES[name])
    if not has_demo:
        bits.append("未在 components.config.js 中出现")
    if entry.get("excluded_methods"):
        excluded = ", ".join(f"`{value}`" for value in entry["excluded_methods"])
        bits.append(f"按平台差异排除内部方法：{excluded}")
    for label, key in (("props", "missing_props"), ("emits", "missing_emits"), ("methods", "missing_methods")):
        values = list(entry.get(key, []))
        if values:
            shown = ", ".join(f"`{value}`" for value in values[:4])
            suffix = f" 等 {len(values)} 项" if len(values) > 4 else ""
            bits.append(f"缺 {label}：{shown}{suffix}")
    if slot_missing:
        bits.append("缺 slot：" + ", ".join(f"`{value}`" for value in slot_missing))
    if not entry.get("dart_file"):
        bits.insert(0, "待实现")
    return "；".join(bits) if bits else "API 静态扫描全覆盖"


def _test_files(root: Path | None, needles: Sequence[str]) -> list[str]:
    if root is None or not root.is_dir():
        return []
    result: list[str] = []
    for path in sorted(root.rglob("*.dart")):
        text = _read(path)
        if any(needle and needle in text for needle in needles):
            result.append(str(path).replace("\\", "/"))
    return result


def _format_tests(paths: Sequence[str], repo_root: Path | None = None, fallback: str = "未发现直接测试") -> str:
    if not paths:
        return fallback
    shown = [_display_path(path, repo_root) for path in paths[:3]]
    suffix = f" 等 {len(paths)} 个" if len(paths) > 3 else ""
    return ", ".join(f"`{path}`" for path in shown) + suffix


def build_component_inventory(
    coverage: Mapping[str, Mapping[str, object]],
    demo_groups: Mapping[str, Sequence[Mapping[str, str]]] | Sequence[Mapping[str, str]],
    *,
    source_component_names: Sequence[str] | None = None,
    source_components_dir: str | os.PathLike[str] | None = None,
    dart_widgets_dir: str | os.PathLike[str] | None = None,
    component_test_root: str | os.PathLike[str] | None = None,
    repo_root: str | os.PathLike[str] | None = None,
) -> list[dict[str, object]]:
    """Build one record for every real upstream component."""
    source_dir = Path(source_components_dir) if source_components_dir else None
    dart_dir = Path(dart_widgets_dir) if dart_widgets_dir else None
    repo = Path(repo_root) if repo_root else None
    names = set(name for name in coverage if name != "uview-plus" and not name.startswith("_"))
    names.update(name for name in (source_component_names or []) if name != "uview-plus")
    ordered: list[str] = []
    component_to_group: dict[str, str] = {}
    component_to_demos: dict[str, list[str]] = {}

    if isinstance(demo_groups, Mapping):
        group_entries = [(str(group), list(entries)) for group, entries in demo_groups.items()]
    else:
        group_entries = [("演示目录", list(demo_groups))]
    for group, entries in group_entries:
        for demo in entries:
            path = str(demo.get("path", ""))
            for name in component_names_for_demo(path, names):
                if name not in ordered:
                    ordered.append(name)
                component_to_group.setdefault(name, group)
                component_to_demos.setdefault(name, []).append(_route_id(path))
    for name in sorted(names):
        if name not in ordered:
            ordered.append(name)
    # Child widgets inherit their parent's visible demo group when they have no
    # standalone entry, matching the indentation in component-progress.md.
    for child, parent in CHILD_OF.items():
        if child in names and child not in component_to_group and parent in component_to_group:
            component_to_group[child] = component_to_group[parent]
            component_to_demos.setdefault(child, list(component_to_demos.get(parent, [])))

    records: list[dict[str, object]] = []
    for name in ordered:
        raw = dict(coverage.get(name, {}))
        slot_result = _slot_compatibility(name, raw, source_dir, dart_dir)
        slot_matched = slot_total = 0
        slot_missing: list[str] = []
        if slot_result:
            slot_matched, slot_total, slot_missing = slot_result
        dart_file = raw.get("dart_file")
        if dart_file and dart_dir is not None:
            dart_file_display = _display_path(dart_dir / str(dart_file), repo)
        else:
            dart_file_display = str(dart_file) if dart_file else "—"
        tests = _test_files(
            Path(component_test_root) if component_test_root else None,
            [str(raw.get("dart_class") or ""), name],
        )
        props = _fraction(raw.get("props_total", 0), raw.get("missing_props", []))
        emits = _fraction(raw.get("emits_total", 0), raw.get("missing_emits", []))
        methods = _fraction(raw.get("methods_total", 0), raw.get("missing_methods", []))
        slots = _fraction(slot_total, slot_missing) if slot_result else "—"
        record = {
            "group": component_to_group.get(name, "未在演示分组中出现"),
            "name": name,
            "source_path": f"src/uni_modules/uview-plus/components/{name}",
            "dart_class": raw.get("dart_class") or "—",
            "dart_file": dart_file_display,
            "status": _component_status(raw, slot_missing),
            "interface": "完整" if _component_status(raw, slot_missing) == STATUS_DONE else "部分",
            "props": props,
            "emits": emits,
            "methods": methods,
            "slots": slots,
            "demos": ", ".join(f"`{value}`" for value in component_to_demos.get(name, [])) or "—",
            "tests": _format_tests(tests, repo),
            "notes": _component_note(name, raw, slot_missing, name in component_to_group),
            "slot_missing": slot_missing,
        }
        records.append(record)
    return records


def _source_file_for_route(path: str, upstream_root: Path | None) -> str:
    if upstream_root is None:
        return "—"
    relative = _route_id(path)
    base = upstream_root / "src" / "pages" / Path(*relative.split("/"))
    for suffix in (".nvue", ".vue", ".js"):
        candidate = base.with_suffix(suffix)
        if candidate.is_file():
            return _display_path(candidate, upstream_root)
    return "—"


def _source_file_map(source_routes: Sequence[Mapping[str, str]], upstream_root: Path | None) -> dict[str, str]:
    return {str(route["path"]): _source_file_for_route(str(route["path"]), upstream_root) for route in source_routes}


def _demo_lookup(entries: Sequence[Mapping[str, str]]) -> dict[str, Mapping[str, str]]:
    lookup: dict[str, Mapping[str, str]] = {}
    for entry in entries:
        path = _clean_path(str(entry.get("path", "")))
        if path:
            lookup[path] = entry
    return lookup


def _route_test_label(
    route: Mapping[str, object],
    example_test_root: Path | None,
    repo_root: Path | None,
) -> str:
    if not route.get("flutter_route"):
        return "—"
    needles = [str(route.get("flutter_route") or ""), str(route.get("flutter_page_class") or "")]
    direct = _test_files(example_test_root, needles)
    baseline: list[str] = []
    if example_test_root:
        for name in ("route_catalog_test.dart", "page_layout_test.dart", "example_app_test.dart"):
            candidate = example_test_root / name
            if candidate.is_file():
                baseline.append(str(candidate))
    return _format_tests(direct or baseline, repo_root, fallback="未发现路由测试")


def build_page_inventory(
    source_routes: Sequence[Mapping[str, object]],
    flutter_routes: Sequence[Mapping[str, object]],
    *,
    upstream_root: str | os.PathLike[str] | None = None,
    demo_entries: Sequence[Mapping[str, str]] | None = None,
    component_names: Sequence[str] = (),
    example_test_root: str | os.PathLike[str] | None = None,
    repo_root: str | os.PathLike[str] | None = None,
    source_manifest: Sequence[Mapping[str, object]] | None = None,
) -> list[dict[str, object]]:
    """Merge source and Flutter routes, preserving source order then extras."""
    source = [dict(route) for route in source_routes]
    flutter = [dict(route) for route in flutter_routes]
    # Normalize callers that use source_path for both inventories.
    for route in source:
        route["path"] = _clean_path(str(route.get("path") or route.get("source_path") or ""))
    for route in flutter:
        route["source_path"] = _clean_path(str(route.get("source_path") or route.get("path") or ""))
    _check_unique(source, "path", "source route")
    _check_unique(flutter, "id", "Flutter route")
    _check_unique(flutter, "source_path", "Flutter source path")
    source_by_path = {str(route["path"]): route for route in source}
    flutter_by_path = {str(route["source_path"]): route for route in flutter}
    demos = _demo_lookup(list(demo_entries or []))
    manifest_paths = {str(route.get("source_path") or route.get("path")) for route in (source_manifest or [])}
    upstream = Path(upstream_root) if upstream_root else None
    repo = Path(repo_root) if repo_root else None
    test_root = Path(example_test_root) if example_test_root else None

    records: list[dict[str, object]] = []
    for route in source:
        path = str(route["path"])
        match = flutter_by_path.get(path)
        demo = demos.get(path)
        source_file = _source_file_for_route(path, upstream)
        associated = component_names_for_demo(path, component_names)
        if match is None:
            status = STATUS_TODO
            route_compatibility = "缺少 Flutter 路由"
            flutter_route = "—"
            flutter_file = "—"
            flutter_class = "—"
        else:
            status = STATUS_DONE if match.get("available", True) and match.get("page_file", "—") != "—" else STATUS_PARTIAL
            route_compatibility = "同名路由" if status == STATUS_DONE else "路由已注册但页面类不完整"
            flutter_route = str(match.get("id") or _route_id(path))
            flutter_file = str(match.get("page_file") or "—")
            flutter_class = str(match.get("page_class") or "—")
        notes: list[str] = []
        if not demo:
            notes.append("已注册但未列入可见演示目录")
        if source_manifest is not None and path not in manifest_paths:
            notes.append("未进入 Flutter source manifest")
        if source_file == "—":
            notes.append("未找到对应上游页面文件")
        if match is None:
            notes.insert(0, "待实现 Flutter 路由")
        record = {
            "group": str(route.get("group") or (match or {}).get("group") or ""),
            "path": path,
            "id": _route_id(path),
            "title": str(route.get("title") or (match or {}).get("title") or ""),
            "source_file": source_file,
            "config_group": str(demo.get("group")) if demo else "—",
            "config_title": str(demo.get("title")) if demo else "—",
            "flutter_route": flutter_route,
            "flutter_page_file": flutter_file,
            "flutter_page_class": flutter_class,
            "status": status,
            "route_compatibility": route_compatibility,
            "components": ", ".join(f"`{name}`" for name in associated) or "—",
            "tests": _route_test_label(
                {"flutter_route": flutter_route if match else "", "flutter_page_class": flutter_class},
                test_root,
                repo,
            ),
            "notes": "；".join(notes),
        }
        records.append(record)

    source_paths = set(source_by_path)
    for route in flutter:
        path = str(route["source_path"])
        if path in source_paths:
            continue
        records.append(
            {
                "group": str(route.get("group") or ""),
                # Keep the Flutter path visible even though it is not present
                # in the upstream registry; the status column carries the
                # source-of-truth distinction.
                "path": path,
                "id": str(route.get("id") or _route_id(path)),
                "title": str(route.get("title") or ""),
                "source_file": "—",
                "config_group": "—",
                "config_title": "—",
                "flutter_route": str(route.get("id") or _route_id(path)),
                "flutter_page_file": str(route.get("page_file") or "—"),
                "flutter_page_class": str(route.get("page_class") or "—"),
                "status": STATUS_EXTRA,
                "route_compatibility": "仅 Flutter 注册",
                "components": ", ".join(
                    f"`{name}`" for name in component_names_for_demo(path, component_names)
                ) or "—",
                "tests": _route_test_label(
                    {
                        "flutter_route": str(route.get("id") or ""),
                        "flutter_page_class": str(route.get("page_class") or ""),
                    },
                    test_root,
                    repo,
                ),
                "notes": "Flutter 侧新增页面；上游 pages.json 未注册",
            }
        )
    return records


def find_unregistered_source_files(
    upstream_root: str | os.PathLike[str],
    source_routes: Sequence[Mapping[str, object]],
) -> list[dict[str, str]]:
    root = Path(upstream_root)
    pages_root = root / "src" / "pages"
    registered = {_route_id(str(route.get("path") or route.get("source_path") or "")) for route in source_routes}
    result: list[dict[str, str]] = []
    if not pages_root.is_dir():
        return result
    for path in sorted(pages_root.rglob("*")):
        if not path.is_file() or path.suffix not in (".nvue", ".vue", ".js"):
            continue
        relative = path.relative_to(pages_root).with_suffix("")
        key = str(relative).replace("\\", "/")
        if key in registered:
            continue
        relative_to_root = str(path.relative_to(root)).replace("\\", "/")
        if path.name == "u-city-select.vue":
            reason = "页面内部辅助组件"
        elif path.name == "index.nvue" and path.parent.name == "douyin":
            reason = "pages.json 中已注释的页面"
        elif path.suffix == ".js" and path.parent.name == "example":
            reason = "演示配置文件"
        elif path.suffix == ".js":
            reason = "模板数据/脚本辅助文件"
        else:
            reason = "源码存在但未注册为路由"
        result.append({"path": relative_to_root, "status": STATUS_UNREGISTERED, "reason": reason})
    return result


def _aggregate(components: Sequence[Mapping[str, object]], key: str) -> tuple[int, int]:
    total = covered = 0
    for component in components:
        value = str(component.get(key, "—"))
        if value == "—" or "/" not in value:
            continue
        left, right = value.split("/", 1)
        try:
            covered += int(left)
            total += int(right)
        except ValueError:
            continue
    return covered, total


def _cell(value: object) -> str:
    text = "" if value is None else str(value)
    return text.replace("|", "\\|").replace("\r", "").replace("\n", " ").strip()


def _table(headers: Sequence[str], rows: Iterable[Sequence[object]]) -> list[str]:
    lines = ["| " + " | ".join(_cell(header) for header in headers) + " |"]
    lines.append("| " + " | ".join("---" for _ in headers) + " |")
    for row in rows:
        values = list(row)
        if len(values) < len(headers):
            values.extend([""] * (len(headers) - len(values)))
        lines.append("| " + " | ".join(_cell(value) for value in values[: len(headers)]) + " |")
    return lines


def render_markdown(inventory: Mapping[str, object]) -> str:
    """Render a deterministic Markdown report from an inventory dictionary."""
    components = list(inventory.get("components", []))
    pages = list(inventory.get("pages", []))
    unregistered = list(inventory.get("unregistered_source_files", []))
    summary = dict(inventory.get("summary", {}))
    source_components = summary.get("source_components", len(components))
    pages_json_routes = summary.get("pages_json_routes", sum(1 for page in pages if page.get("path") != "—"))
    flutter_routes = summary.get("flutter_routes", sum(1 for page in pages if page.get("flutter_route") != "—"))
    manifest_routes = summary.get("flutter_source_manifest_routes", "未提供")
    source_missing = sum(1 for page in pages if page.get("status") == STATUS_TODO)
    flutter_extra = sum(1 for page in pages if page.get("status") == STATUS_EXTRA)
    done_components = sum(1 for component in components if component.get("status") == STATUS_DONE)
    partial_components = sum(1 for component in components if component.get("status") == STATUS_PARTIAL)
    todo_components = sum(1 for component in components if component.get("status") == STATUS_TODO)
    props = _aggregate(components, "props")
    emits = _aggregate(components, "emits")
    methods = _aggregate(components, "methods")
    slots = _aggregate(components, "slots")
    generated = summary.get("generated_date") or _datetime.date.today().isoformat()
    source_revision = summary.get("source_revision", "未记录")

    lines = [
        "# uView Plus → Flutter 复刻总进度",
        "",
        "本文件由 `tool/gen_replication_progress.py` 生成，汇总上游组件目录、`pages.json` 注册页、",
        "演示目录和 Flutter `exampleRoutes`。请勿手工修改表格；更新代码或上游后重新生成。",
        "",
        f"- 生成日期：`{generated}`",
        f"- 上游版本：`{source_revision}`",
        "- 上游目录：`uview-plus/src`",
        "- Flutter 目标：`packages/ultra_ui` 与 `example`",
        "",
        "## 总览",
        "",
    ]
    lines.extend(
        _table(
            ("指标", "数值"),
            (
                ("上游真实组件总数", source_components),
                ("✅ 已复刻组件", done_components),
                ("🟡 部分组件", partial_components),
                ("⛔ 未复刻组件", todo_components),
                ("上游 pages.json 注册路由", pages_json_routes),
                ("Flutter catalog 路由", flutter_routes),
                ("Flutter source manifest 路由", manifest_routes),
                ("源路由待实现", source_missing),
                ("Flutter 扩展路由", flutter_extra),
                ("props 接口覆盖", f"{props[0]}/{props[1]}"),
                ("emits 接口覆盖", f"{emits[0]}/{emits[1]}"),
                ("methods + computed 覆盖", f"{methods[0]}/{methods[1]}"),
                ("slots 接口覆盖", f"{slots[0]}/{slots[1]}" if slots[1] else "未扫描"),
                ("未注册上游源码文件", len(unregistered)),
            ),
        )
    )
    lines.extend(
        [
            "",
            "### 状态与兼容性口径",
            "",
            "- ✅ 已复刻：Flutter 类/页面存在，静态接口扫描的 props、emits、methods 和 slots 全覆盖。",
            "- 🟡 部分：存在 Flutter 实现，但仍有接口缺口或无法解析到可打开的页面类。",
            "- ⛔ 未复刻：上游已注册，Flutter catalog 尚无对应路由。",
            "- 🆕 Flutter 扩展：Flutter 有页面，但上游 `pages.json` 没有同名注册项。",
            "- 接口兼容性按名称和公开参数静态比对；它不能替代行为、布局、动画和平台能力测试。",
            "- 平台专属能力（canvas、播放器、定位、PDF、全局 portal 等）在组件备注中注明宿主注入或 Flutter 等价实现。",
            "",
            "## 组件清单",
            "",
        ]
    )
    component_rows = []
    for component in components:
        component_rows.append(
            (
                component.get("group", ""),
                f"`{component.get('name', '')}`",
                f"`{component.get('source_path', '')}`",
                f"`{component.get('dart_class', '—')}`",
                f"`{component.get('dart_file', '—')}`",
                component.get("status", ""),
                component.get("interface", ""),
                component.get("props", "—"),
                component.get("emits", "—"),
                component.get("methods", "—"),
                component.get("slots", "—"),
                component.get("demos", "—"),
                component.get("tests", "未扫描"),
                component.get("notes", ""),
            )
        )
    lines.extend(
        _table(
            (
                "分组", "上游组件", "上游路径", "Flutter 类", "Flutter 文件", "状态",
                "接口兼容性", "props", "emits", "methods", "slots", "关联演示", "测试/验证", "备注",
            ),
            component_rows,
        )
    )
    lines.extend(["", "## 演示页面清单", ""])
    lines.extend(
        [
            "页面表以 `pages.json` 为主序；末尾追加仅存在于 Flutter catalog 的扩展页。",
            "`演示目录` 反映 `components.config.js` / `template.config.js` 的可见列表，因此注册页和可见演示页的数量可能不同。",
            "",
        ]
    )
    page_rows = []
    for page in pages:
        page_rows.append(
            (
                page.get("group", ""),
                f"`{page.get('path', '—')}`",
                f"`{page.get('source_file', '—')}`",
                page.get("config_group", "—"),
                page.get("config_title", "—"),
                f"`{page.get('flutter_route', '—')}`",
                f"`{page.get('flutter_page_file', '—')}`",
                page.get("status", ""),
                page.get("route_compatibility", ""),
                page.get("components", "—"),
                page.get("tests", "未发现路由测试"),
                page.get("notes", ""),
            )
        )
    lines.extend(
        _table(
            (
                "分组", "上游 route/path", "上游页面文件", "演示目录", "演示标题", "Flutter route",
                "Flutter 页面文件", "状态", "路由兼容性", "关联组件", "测试/验证", "备注",
            ),
            page_rows,
        )
    )
    lines.extend(["", "## 未注册上游文件", ""])
    lines.append("这些文件位于上游 `src/pages`，但不是 `pages.json` 的有效注册路由；保留在附录以免把辅助文件误报为缺失页面。")
    lines.append("")
    lines.extend(
        _table(
            ("上游文件", "状态", "判定"),
            ((item.get("path", ""), item.get("status", STATUS_UNREGISTERED), item.get("reason", "")) for item in unregistered),
        )
    )
    lines.extend(
        [
            "",
            "## 生成与验证",
            "",
            "```powershell",
            "python tool/coverage_scan.py > .scan/cov.json",
            "python tool/extract_groups.py",
            "python tool/gen_replication_progress.py",
            "python -m unittest tool/test_gen_replication_progress.py -v",
            "flutter test packages/ultra_ui/test",
            "flutter test example/test",
            "git diff --check",
            "```",
            "",
            "相关 API 明细见 [`docs/component-progress.md`](component-progress.md)，缺口与平台差异见 [`docs/gap-matrix.md`](gap-matrix.md)。",
            "",
        ]
    )
    return "\n".join(lines)


def _git_revision(upstream_root: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "-C", str(upstream_root), "rev-parse", "--short", "HEAD"],
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError:
        return "未记录"
    return result.stdout.strip() or "未记录"


def _load_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def _default_paths(repo_root: Path, upstream_root: Path) -> dict[str, Path]:
    return {
        "coverage": repo_root / ".scan" / "cov.json",
        "groups": repo_root / ".scan" / "groups.json",
        "pages": upstream_root / "src" / "pages.json",
        "components_config": upstream_root / "src" / "pages" / "example" / "components.config.js",
        "template_config": upstream_root / "src" / "pages" / "example" / "template.config.js",
        "catalog": repo_root / "example" / "lib" / "routes" / "example_catalog.dart",
        "source_manifest": repo_root / "example" / "lib" / "routes" / "example_source_manifest.dart",
        "source_components": upstream_root / "src" / "uni_modules" / "uview-plus" / "components",
        "dart_widgets": repo_root / "packages" / "ultra_ui" / "lib" / "src" / "widgets",
        "component_tests": repo_root / "packages" / "ultra_ui" / "test",
        "example_tests": repo_root / "example" / "test",
        "output": repo_root / "docs" / "replication-progress.md",
    }


def generate(args: argparse.Namespace) -> dict[str, object]:
    repo_root = Path(args.repo_root).resolve()
    upstream_root = Path(args.upstream_root).resolve()
    defaults = _default_paths(repo_root, upstream_root)
    paths = {key: Path(getattr(args, key) or value) for key, value in defaults.items()}
    coverage = _load_json(paths["coverage"])
    groups_json = _load_json(paths["groups"]) if paths["groups"].is_file() else {}
    config_entries = parse_demo_config(paths["components_config"])
    template_entries = parse_demo_config(paths["template_config"], template=True)
    all_demo_entries = config_entries + template_entries
    source_routes = load_pages_json(paths["pages"])
    flutter_routes = parse_flutter_catalog(paths["catalog"])
    source_manifest = parse_source_manifest(paths["source_manifest"]) if paths["source_manifest"].is_file() else None
    component_names = _source_component_names(paths["source_components"])
    components = build_component_inventory(
        coverage,
        groups_json or {"演示目录": config_entries},
        source_component_names=component_names,
        source_components_dir=paths["source_components"],
        dart_widgets_dir=paths["dart_widgets"],
        component_test_root=paths["component_tests"],
        repo_root=repo_root,
    )
    pages = build_page_inventory(
        source_routes,
        flutter_routes,
        upstream_root=upstream_root,
        demo_entries=all_demo_entries,
        component_names=component_names,
        example_test_root=paths["example_tests"],
        repo_root=repo_root,
        source_manifest=source_manifest,
    )
    unregistered = find_unregistered_source_files(upstream_root, source_routes)
    inventory = {
        "components": components,
        "pages": pages,
        "unregistered_source_files": unregistered,
        "summary": {
            "source_components": len(component_names) or len(components),
            "pages_json_routes": len(source_routes),
            "flutter_routes": len(flutter_routes),
            "flutter_source_manifest_routes": len(source_manifest) if source_manifest is not None else "未提供",
            "generated_date": _datetime.date.today().isoformat(),
            "source_revision": _git_revision(upstream_root),
        },
    }
    paths["output"].parent.mkdir(parents=True, exist_ok=True)
    paths["output"].write_text(render_markdown(inventory), encoding="utf-8", newline="\n")
    return inventory


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    repo_default = Path(__file__).resolve().parents[1]
    upstream_default = Path(os.environ.get("UVIEW_PLUS_ROOT", str(repo_default.parent / "uview-plus")))
    parser.add_argument("--repo-root", default=str(repo_default))
    parser.add_argument("--upstream-root", default=str(upstream_default))
    for name in (
        "coverage", "groups", "pages", "components_config", "template_config", "catalog",
        "source_manifest", "source_components", "dart_widgets", "component_tests", "example_tests", "output",
    ):
        parser.add_argument(f"--{name.replace('_', '-')}", dest=name)
    args = parser.parse_args(argv)
    inventory = generate(args)
    summary = inventory["summary"]
    print(
        "wrote replication progress: "
        f"{summary['source_components']} components, "
        f"{summary['pages_json_routes']} source routes, "
        f"{summary['flutter_routes']} Flutter routes"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
