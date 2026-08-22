#!/usr/bin/env python3
"""Generate docs/component-progress.md from live scan data.

Inputs (produced by the sibling tools):
  .scan/cov.json     - per-component props/emits/methods coverage vs the Dart port
  .scan/groups.json  - the uview-plus demo's own group -> component ordering

The doc is generated rather than hand-maintained so the numbers cannot drift
away from the code. Re-run after any porting batch:

  python tool/coverage_scan.py > .scan/cov.json
  python tool/extract_groups.py
  python tool/gen_progress_doc.py
"""
from __future__ import annotations

import json
import os
import re

ROOT = r"D:\Repos\xyito\open\ultra-ui-flutter"
COV = os.path.join(ROOT, ".scan", "cov.json")
GROUPS = os.path.join(ROOT, ".scan", "groups.json")
OUT = os.path.join(ROOT, "docs", "component-progress.md")

# Demo path -> source component dir. The demo groups pages, not components, so a
# page can cover several components (Layout -> row/col/gap/line, Progress ->
# line+circle progress). Only entries needing a non-obvious mapping are listed.
PAGE_TO_COMPONENTS = {
    "color": [],  # palette page, not a component
    "layout": ["u-row", "u-col"],
    "progress": ["u-line-progress", "u-circle-progress"],
    "loading-icon": ["u-loading-icon"],
    "loading-page": ["u-loading-page"],
    "keyboard": ["u-keyboard", "u-number-keyboard", "u-car-keyboard"],
    "datetimePicker": ["u-datetime-picker"],
    "numberBox": ["u-number-box"],
    "actionSheet": ["u-action-sheet"],
    "noticeBar": ["u-notice-bar"],
    "swipeAction": ["u-swipe-action"],
    "floatButton": ["u-float-button"],
    "pullRefresh": ["u-pull-refresh"],
    "scrollList": ["u-scroll-list"],
    "noNetwork": ["u-no-network"],
    "cateTab": ["u-cate-tab"],
    "shortVideo": ["u-short-video"],
    "navbarMini": ["u-navbar-mini"],
    "indexList": ["u-index-list"],
    "backTop": ["u-back-top"],
    "codeInput": ["u-code-input"],
    "readMore": ["u-read-more"],
    "lazyLoad": ["u-lazy-load"],
    "colorPicker": ["u-color-picker"],
    "goodsSku": ["u-goods-sku"],
    "cityLocate": ["u-city-locate"],
    "pdfReader": ["u-pdf-reader"],
    "novelReader": ["u-novel-reader"],
    "virtualList": ["u-virtual-list"],
    "countDown": ["u-count-down"],
    "countTo": ["u-count-to"],
    "dragsort": ["u-dragsort"],
    "cropper": ["u-cropper"],
    "table2": ["u-table2"],
    "tabsPro": ["u-tabs-pro"],
}

# Sub-components rendered inside a parent's file, grouped under that parent.
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

# Behavior that cannot be 1:1 on Flutter and the reason. Keep one short line.
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
    "u-parse": "HTML 子集渲染为 Flutter 组件树，无 CSS 引擎",
    "u-markdown": "Markdown → HTML 后交由 UPParse 渲染（与源码同架构）",
    "u-root-toast-host": "替代 `uni.$u.setRootToastRef`，注册全局 toast/notify 宿主",
    "u-novel-reader": "分页测量用源码 measure-adapter 启发式宽度；持久化经宿主钩子",
}

STATUS_DONE = "✅ 已复刻"
STATUS_PARTIAL = "🟡 部分"
STATUS_TODO = "⛔ 未复刻"


def load() -> tuple[dict, dict]:
    with open(COV, encoding="utf-8") as fh:
        cov = json.load(fh)
    with open(GROUPS, encoding="utf-8") as fh:
        groups = json.load(fh)
    return cov, groups


def page_key(path: str) -> str:
    return path.rstrip("/").rsplit("/", 1)[-1]


def kebab(name: str) -> str:
    return "u-" + re.sub(r"(?<!^)(?=[A-Z])", "-", name).lower()


def components_for(path: str) -> list[str]:
    key = page_key(path)
    if key in PAGE_TO_COMPONENTS:
        return PAGE_TO_COMPONENTS[key]
    return [kebab(key)]


def pct(total: int, missing: int) -> str:
    if total == 0:
        return "—"
    return f"{total - missing}/{total}"


def status_of(entry: dict) -> str:
    if not entry.get("dart_file"):
        return STATUS_TODO
    gaps = (
        len(entry["missing_props"])
        + len(entry["missing_emits"])
        + len(entry["missing_methods"])
    )
    return STATUS_DONE if gaps == 0 else STATUS_PARTIAL


def note_for(name: str, entry: dict) -> str:
    bits: list[str] = []
    if name in EMULATION_NOTES:
        bits.append(EMULATION_NOTES[name])
    if not entry.get("dart_file"):
        bits.insert(0, "**待实现**")
        return "；".join(bits)
    gaps: list[str] = []
    for label, key in (
        ("props", "missing_props"),
        ("emits", "missing_emits"),
        ("methods", "missing_methods"),
    ):
        vals = entry[key]
        if vals:
            shown = ", ".join(f"`{v}`" for v in vals[:4])
            more = f" 等 {len(vals)}" if len(vals) > 4 else ""
            gaps.append(f"缺 {label}: {shown}{more}")
    bits.extend(gaps)
    return "；".join(bits) if bits else "接口与样式对齐"


def rows_for(names: list[str], cov: dict, seen: set[str]) -> list[str]:
    out: list[str] = []
    for name in names:
        entry = cov.get(name)
        if entry is None or name in seen:
            continue
        seen.add(name)
        cls = entry.get("dart_class") or "—"
        out.append(
            "| `{src}` | `{cls}` | {st} | {p} | {e} | {m} | {note} |".format(
                src=name,
                cls=cls,
                st=status_of(entry),
                p=pct(entry["props_total"], len(entry["missing_props"])),
                e=pct(entry["emits_total"], len(entry["missing_emits"])),
                m=pct(entry["methods_total"], len(entry["missing_methods"])),
                note=note_for(name, entry),
            )
        )
        # Emit the parent's sub-components right after it.
        for child, parent in CHILD_OF.items():
            if parent == name and child not in seen and child in cov:
                seen.add(child)
                centry = cov[child]
                out.append(
                    "| `{src}` | `{cls}` | {st} | {p} | {e} | {m} | {note} |".format(
                        src="↳ " + child,
                        cls=centry.get("dart_class") or "—",
                        st=status_of(centry),
                        p=pct(
                            centry["props_total"], len(centry["missing_props"])
                        ),
                        e=pct(
                            centry["emits_total"], len(centry["missing_emits"])
                        ),
                        m=pct(
                            centry["methods_total"],
                            len(centry["missing_methods"]),
                        ),
                        note=note_for(child, centry),
                    )
                )
    return out


HEADER = (
    "| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |\n"
    "|---|---|---|---|---|---|---|"
)


def main() -> None:
    cov, groups = load()
    seen: set[str] = {"uview-plus"}
    body: list[str] = []

    for group, entries in groups.items():
        names: list[str] = []
        for entry in entries:
            for name in components_for(entry["path"]):
                if name in cov and name not in names:
                    names.append(name)
        rows = rows_for(names, cov, seen)
        if not rows:
            continue
        body.append(f"\n## {group}\n")
        body.append(HEADER)
        body.extend(rows)

    leftovers = [n for n in sorted(cov) if n not in seen]
    if leftovers:
        body.append("\n## 未在演示分组中出现的组件\n")
        body.append(HEADER)
        body.extend(rows_for(leftovers, cov, seen))

    total = len(cov) - 1  # exclude the uview-plus aggregate entry
    done = sum(
        1
        for n, e in cov.items()
        if n != "uview-plus" and status_of(e) == STATUS_DONE
    )
    partial = sum(
        1
        for n, e in cov.items()
        if n != "uview-plus" and status_of(e) == STATUS_PARTIAL
    )
    todo = sum(
        1
        for n, e in cov.items()
        if n != "uview-plus" and status_of(e) == STATUS_TODO
    )

    def agg(key: str, tkey: str) -> tuple[int, int]:
        t = sum(e[tkey] for n, e in cov.items() if n != "uview-plus")
        m = sum(len(e[key]) for n, e in cov.items() if n != "uview-plus")
        return t - m, t

    pk, pt = agg("missing_props", "props_total")
    ek, et = agg("missing_emits", "emits_total")
    mk, mt = agg("missing_methods", "methods_total")

    head = f"""# Ultra UI Flutter 复刻进度

源码：uview-plus（`src/uni_modules/uview-plus`） · 目标包：`packages/ultra_ui` · 组件前缀 `UP*`

> 本文档由 `tool/gen_progress_doc.py` 生成，数据来自对源码 `props.js` / `.vue`
> 的 props、emits、methods 静态扫描与 Dart 侧符号比对。请勿手工编辑；改动代码后重新生成：
>
> ```bash
> python tool/coverage_scan.py > .scan/cov.json
> python tool/extract_groups.py
> python tool/gen_progress_doc.py
> ```
>
> 本表只覆盖 **API 面**（props / emits / methods 是否存在）。**配色一致性**由另一个
> 独立脚本核对 —— 它解析源码 `libs/css/theme-vars-core.scss` 的 CSS 变量，与
> `UPThemeTokens` 的 light / dark 双色板逐项比对：
>
> ```bash
> python tool/theme_parity_scan.py   # 期望 mismatches 0、unmapped 为空
> ```
>
> 该脚本只能证明 token 取值一致，不能证明组件读了正确的 token；后者由
> `packages/ultra_ui/test/theme_parity_test.dart` 断言。
>
> **prop 默认值**由第三个脚本核对 —— 本表只看 prop 是否存在，存在但默认值写错
> （尺寸、间距、时长差几个单位）是名称比对查不出的：
>
> ```bash
> python tool/prop_default_scan.py   # 期望 mismatches 0
> ```
>
> 刻意不同的默认值（如源码内联 base64 图片、`'-1'` 字符串 vs Dart int）在脚本里
> 逐条注明原因并单独计数，不会掩盖真实回归。

## 总览

| 指标 | 数值 |
|---|---|
| 源组件总数 | {total} |
| {STATUS_DONE} | {done} |
| {STATUS_PARTIAL} | {partial} |
| {STATUS_TODO} | {todo} |
| props 覆盖 | {pk}/{pt} |
| emits 覆盖 | {ek}/{et} |
| methods + computed 覆盖 | {mk}/{mt} |

### 状态含义

- {STATUS_DONE}：Flutter 类存在，且扫描到的 props / emits / methods 全部有对应符号
- {STATUS_PARTIAL}：Flutter 类存在，但仍有未覆盖的源码成员（见备注）
- {STATUS_TODO}：尚无对应 Flutter 类

### 扫描口径与已知误差

- `props` 列排除纯宿主属性（`customClass`、`openType`、`sendMessage*`、`lang` 等），
  它们在 Flutter 无对应语义。
- `methods` 列同时统计源码 `methods` 与 `computed`，因为该移植把 computed 也作为
  公开 API 暴露以保持调用兼容。
- 比对基于符号名（含 `snake_case`、`onXxx` 事件前缀等价形式），因此**只能证明缺失，
  不能证明行为正确**。行为与样式一致性由 `packages/ultra_ui/test` 的用例保证。
- `UPNovelReader` 的 4 个子面板（toolbar/catalog/settings/content）在本移植中是私有
  Flutter widget，其内部 handler 与 style computed 未作为公开 API 暴露，因此计入缺失。
  这与其它组件“computed 也公开”的取向不同，是有意的取舍：这些成员属于子组件实现细节，
  而非 `u-novel-reader` 的对外接口。核心算法（分页/测量/持久化）已在
  `test/novel_reader_core_test.dart` 中对齐真实源码 JS 输出。
- 其余少量缺失是**源码为绕开 Vue / 小程序限制而存在的胶水代码**，在 Flutter 无对应
  语义，刻意不实现：
  - `u-swipe-action.parentData` / `u-list-item.resize`：源码注释说明其用于「子组件
    无法实时监听父组件参数变化」，Flutter 的 InheritedWidget 与 build 机制天然解决。
  - `u-popup.emitClose`：源码用一次性标记抑制 watcher 重复补发 `close`；本移植的
    close 路径本就只发一次。
  - `_set` / `_hook` / `_onMessage` / `_empty` / `_queueMakeCode` 等下划线前缀成员：
    源码内部实现细节，非对外接口。
- 分组与排序镜像源码 `src/pages/example/components.config.js`，
  子组件缩进显示在父组件下方。
"""

    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(head)
        fh.write("\n".join(body))
        fh.write("\n")
    print(f"wrote {OUT}: {total} components, {done} done, {partial} partial, {todo} todo")


if __name__ == "__main__":
    main()
