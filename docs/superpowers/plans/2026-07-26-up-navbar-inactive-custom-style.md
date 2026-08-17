# UPNavbar Inactive Custom Style Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain the UPNavbar `customStyle` API field without rendering it where the independent uView navbar source does not consume it.

**Architecture:** `u-navbar.vue` binds only `navbarInnerStyle` to `.u-navbar__inner`. Its computed value consists solely of `navbarBgColor`; local `props.js` does not declare `customStyle`, and the shared mixin field is never merged into the template. Flutter keeps the compatibility field but derives its container only from source background, border, fixed placeholder, and safe-area rules.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public UPNavbar constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-navbar\u-navbar.vue` and `props.js`.
- Preserve background, border, safe-area, fixed placeholder, slots, click behavior, and title styling.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Source Style Consumption

**Files:**
- Inspect: `components\u-navbar\u-navbar.vue` and `props.js`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_navbar.dart`

- [x] **Step 1: Verify the source root style**

The Vue template applies `navbarInnerStyle` only to `.u-navbar__inner`.
`navbarInnerStyle()` returns `{ background: navbarBgColor }`; neither that
computed value nor the local props object includes `customStyle`.

### Task 2: Remove Flutter-Only Decoration Overrides

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_navbar.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Write and confirm the inactive-style regression**

Mount UPNavbar with a unique caller color and assert no `DecoratedBox` uses
that color.

Run: `flutter test test/widgets_test.dart --name "UPNavbar leaves source-inactive customStyle unrendered" --reporter expanded`

Observed before implementation: the unique color appeared in the Flutter
navbar root decoration.

- [x] **Step 2: Remove only caller-style overrides**

Delete the `customStyle` color, border, radius, shadow, gradient, and image
overrides from the navbar's source-derived `BoxDecoration`. Retain the field,
source `bgColor`, and optional source bottom border.

- [x] **Step 3: Run focused verification**

Run: `dart format lib/src/widgets/up_navbar.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPNavbar( renders title| leaves source-inactive customStyle unrendered| title number and customStyle)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_navbar.dart`

Observed: all three focused tests passed and analysis reported no diagnostics.

- [x] **Step 4: Run complete validation and record the result**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append the dated compatibility matrix entry for this batch.

Completed: the full suite passed all 703 tests and `git diff --check`
reported no whitespace errors.
