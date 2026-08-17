# UPBox Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPBox.customStyle` remains rendered because the source box applies it to its root.

**Architecture:** The Vue box root binds its height and `addStyle(customStyle)` in one style array. Flutter retains `customStyle` as the external root decoration around the source-backed fixed-height two-column box layout; the caller style remains separate from individual cell backgrounds and border radii.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPBox` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-box\u-box.vue`.
- Preserve source-backed height, gap, backgrounds, corner radii, default slots, and cell content.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Box Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_box.dart` near `UPBox.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPBox` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPBox({BoxDecoration? customStyle, dynamic height = '160px', ...})`.
- Produces: unchanged API and a root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The source root at `u-box.vue:2` explicitly binds a style array containing `{height: height}` and `addStyle(customStyle)`.

- [x] **Step 2: Compare the Flutter root implementation**

`UPBox.build` creates the source-backed fixed-height row, then applies `Container(decoration: customStyle, child: root)` when the public decoration is supplied. Individual cell colors and border radii remain separate, matching the source root-style merge.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the Flutter root decoration would regress the source's explicit `addStyle(customStyle)` behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
