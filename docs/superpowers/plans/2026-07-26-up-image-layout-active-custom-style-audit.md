# UPImage and Layout Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that image, line-progress, and layout primitives retain their source-active `customStyle` rendering.

**Architecture:** The Vue image, gap, line, row, and column components merge caller style into their computed root style; line-progress and divider bind it explicitly on their roots. Flutter keeps decorations at the equivalent render nodes while preserving the intrinsic geometry, borders, clipping, interaction, and content paths of each primitive.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPImage`, `UPLineProgress`, `UPGap`, `UPLine`, `UPDivider`, `UPRow`, and `UPCol` constructors and `customStyle` fields.
- Match their corresponding Vue components under `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components`.
- Preserve source-backed image state, progress geometry, layout alignment, gutters, line styles, divider content, and callbacks.
- Do not remove source-active custom style bindings.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Image and Layout Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_image.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_line_progress.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_layout.dart`
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes the public `customStyle` fields for the listed components.
- Produces unchanged APIs and source-backed custom style decoration at each component's applicable root or content node.

- [x] **Step 1: Inspect source style bindings**

`u-image.vue:159-189` deep-merges `addStyle(customStyle)` into `wrapStyle`. `u-line-progress.vue:2-5` and `u-divider.vue:1-5` bind `addStyle(customStyle)` directly. `u-gap.vue`, `u-line.vue`, `u-row.vue`, and `u-col.vue` deep-merge it into their respective computed styles.

- [x] **Step 2: Compare Flutter rendering paths**

Flutter applies caller decoration at the corresponding image body, progress root, and layout primitive roots. Existing root calculations preserve image sizing/clipping, progress border radius, gap geometry, line border behavior, divider content, and row/column alignment independent from the caller decoration.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing any of these decorations would regress explicit source style bindings.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exceptions.
