# UPPickerColumn and UPPickerData Inactive Custom Style Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve UPPickerColumn and UPPickerData `customStyle` constructor compatibility without rendering a style that their independent uView sources do not consume.

**Architecture:** `u-picker-column.vue` imports the shared mixin but its template contains no style binding, while `u-picker-data.vue` declares only picker data props and neither imports the mixin nor declares/binds `customStyle`. Flutter retains public fields for compatibility with the port's established API but removes only the Flutter-only decoration wrappers.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public UPPickerColumn and UPPickerData constructors and `customStyle` fields.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker-column\u-picker-column.vue` and `components\u-picker-data\u-picker-data.vue`.
- Preserve picker trigger, options, default indices, popup, confirm/cancel/close callbacks, and model aliases.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Independent Source Components

**Files:**
- Inspect: `components\u-picker-column\u-picker-column.vue` and `props.js`
- Inspect: `components\u-picker-data\u-picker-data.vue`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_picker.dart`

- [x] **Step 1: Verify UPPickerColumn source usage**

`u-picker-column.vue` renders only `<picker-view-column><view
class="u-picker-column"></view></picker-view-column>`. Its local props object
is empty; the shared mixin declares `customStyle`, but the template has no
style binding that consumes it.

- [x] **Step 2: Verify UPPickerData source usage**

`u-picker-data.vue` renders its trigger and nested `up-picker` with no style
binding. It does not import the shared mixin and its local props include only
model/value/title/options key configuration, so it has no source
`customStyle` prop or consumer.

### Task 2: Remove Flutter-Only Decorations

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_picker.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Write and confirm inactive-style regressions**

Mount each widget with a unique `BoxDecoration` and assert no matching
`DecoratedBox` is rendered.

Run: `flutter test test/widgets_test.dart --name "UPPicker(Column|Data) leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because both Flutter shells currently wrap their roots with the
caller decoration.

Confirmed before the implementation change: both regressions found their
matching `DecoratedBox` wrappers.

- [x] **Step 2: Delete only decoration wrappers**

Remove the `UPPickerColumn` and `UPPickerData` custom-style wrapper blocks.
Leave their constructor parameters and fields untouched.

- [x] **Step 3: Verify and record source parity**

Run: `dart format lib/src/widgets/up_picker.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPPicker(Column|Data).*customStyle|BatchS residual aliases" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_picker.dart`

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated compatibility matrix entry documenting the independent source
component results.

Completed: focused inactive-style and residual-alias tests passed, `flutter
analyze lib/src/widgets/up_picker.dart` passed, the complete suite passed with
698 tests, and `git diff --check` reported no whitespace errors.
