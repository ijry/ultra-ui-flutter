# UPCell Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPCell` and `UPCellGroup` retain their source-active root `customStyle` rendering.

**Architecture:** The Vue cell root binds `addStyle(customStyle)` directly, while the cell-group root combines its computed theme background `groupStyle` with `addStyle(customStyle)`. Flutter applies the provided decoration to the cell root and overlays non-null group decoration fields over the group card background, preserving the source ordering and keeping row content, borders, and interaction behavior independent.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCell`/`UPCellGroup` constructors and `customStyle` fields.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-cell\u-cell.vue` and `components\u-cell-group\u-cell-group.vue`.
- Preserve source-backed cell slots, label/value/icon styles, links, interactions, group title, and borders.
- Do not remove source-active custom style bindings.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Cell and Cell-Group Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_cell.dart` near `UPCell.build` and `UPCellGroup.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing cell tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPCell({BoxDecoration? customStyle, ...})` and `UPCellGroup({BoxDecoration? customStyle, ...})`.
- Produces: unchanged APIs and root decorations whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style bindings**

`u-cell.vue:2` binds `[addStyle(customStyle)]` on the cell root. `u-cell-group.vue:2` binds `[groupStyle, addStyle(customStyle)]`, so caller fields apply after the theme-derived group background.

- [x] **Step 2: Compare the Flutter root implementations**

`UPCell.build` applies `customStyle` at its root around the material interaction structure. `UPCellGroup.build` starts with the source theme card background and overlays caller color and border fields, retaining the base background when a caller supplies unrelated decoration fields.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing either Flutter decoration would regress an explicit source `addStyle(customStyle)` binding.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
