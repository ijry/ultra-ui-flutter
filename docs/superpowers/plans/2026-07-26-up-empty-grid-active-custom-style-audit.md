# UPEmpty and UPGrid Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPEmpty`, `UPGrid`, and `UPGridItem` retain their source-active `customStyle` rendering.

**Architecture:** The Vue empty state deep-merges caller style into `emptyStyle`; the Vue grid and grid item similarly merge it into their root alignment and item-style computations. Flutter retains caller decorations at the corresponding roots while preserving intrinsic margins, grid layout, backgrounds, borders, and callbacks.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPEmpty`, `UPGrid`, and `UPGridItem` constructors and `customStyle` fields.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-empty\u-empty.vue`, `components\u-grid\u-grid.vue`, and `components\u-grid-item\u-grid-item.vue`.
- Preserve source-backed empty content, grid alignment, columns, cell styles, borders, interactions, and callbacks.
- Do not remove source-active custom style bindings.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Empty and Grid Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_empty.dart` near `UPEmpty.build`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_grid.dart` near `UPGrid.build` and `UPGridItem.build`
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPEmpty({BoxDecoration? customStyle, ...})`, `UPGrid({BoxDecoration? customStyle, ...})`, and `UPGridItem({BoxDecoration? customStyle, ...})`.
- Produces: unchanged APIs and rendered source-backed custom style on the relevant roots.

- [x] **Step 1: Inspect source root style bindings**

`u-empty.vue` binds `emptyStyle`, which deep-merges `addStyle(customStyle)` with margin top. `u-grid.vue` returns `deepMerge(style, addStyle(customStyle))` from `gridStyle`; `u-grid-item.vue` does the same in `itemStyle` after establishing its background and width.

- [x] **Step 2: Compare the Flutter implementations**

`UPEmpty.build`, `UPGrid.build`, and `UPGridItem.build` apply the caller decoration at their corresponding rendered content roots. Grid item decoration preserves its default background and optional border when caller fields do not override them, matching source merge behavior.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing these Flutter decorations would regress explicit source custom-style merge behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exceptions.
