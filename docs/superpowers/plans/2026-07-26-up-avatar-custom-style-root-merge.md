# UPAvatar Custom Style Root Merge Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Merge UPAvatar `customStyle` into the source-equivalent avatar root instead of rendering it on a Flutter-only outer wrapper.

**Architecture:** `u-avatar.vue` applies default background, dimensions, and shape plus `addStyle(customStyle)` to the same `.u-avatar` node. Flutter now constructs one decoration that begins with source background/shape and overlays caller decoration fields on the visible sized avatar container. The external wrapper is removed, ensuring caller colors, borders, gradients, shadows, and radii apply to the node that clips avatar content.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve UPAvatar public constructor, callbacks, image/text/icon behavior, and host helpers.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-avatar\u-avatar.vue`.
- Preserve source sizing, shape, background selection, random color, and clipping behavior.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify the Source Style Target

**Files:**
- Inspect: `components\u-avatar\u-avatar.vue`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_avatar.dart`

- [x] **Step 1: Identify same-node source merge**

The Vue root `.u-avatar` binds an inline map for background/size and then
`addStyle(customStyle)` in the same style array. Its image/text/icon content
is nested inside that root.

### Task 2: Merge the Flutter Decoration on the Visible Root

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_avatar.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Write and confirm a visible-root regression**

Mount a text avatar with caller color and border, then assert one rendered
decoration contains those fields together with a non-null source radius.

Run: `flutter test test/widgets_test.dart --name "UPAvatar merges customStyle into its source root" --reporter expanded`

Observed before implementation: no decorated node contained both caller
fields and the source root radius because Flutter used two nested containers.

- [x] **Step 2: Build a merged root decoration**

Create source background and radius first, overlay non-null caller decoration
fields on the sized avatar container, and remove the Flutter-only outer
wrapper. When caller gradient is present, omit the color field to match the
existing Flutter decoration convention for visible custom-style roots.

- [x] **Step 3: Run focused verification**

Run: `dart format lib/src/widgets/up_avatar.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPAvatar (text and click|icon mode|merges customStyle into its source root|BatchE init/isImg/clickHandler|exposes source MP and image-path helpers)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_avatar.dart`

Observed: five focused tests passed and analysis reported no diagnostics.

- [x] **Step 4: Run complete validation and record the result**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append the dated compatibility matrix entry for this batch.

Completed: the full suite passed all 706 tests and `git diff --check`
reported no whitespace errors.
