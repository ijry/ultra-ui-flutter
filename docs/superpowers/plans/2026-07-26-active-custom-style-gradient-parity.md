# Active Custom Style Gradient Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow source-active `customStyle` gradients on Flutter-rendered component roots without retaining an incompatible default `BoxDecoration.color`.

**Architecture:** The uView source receives CSS-style maps, where a caller gradient/background image can coexist with or replace source background color. Flutter `BoxDecoration` rejects non-null `color` together with `gradient`, so components must resolve their source default color only when caller style has no gradient. Source ordering remains component-specific: input, textarea, gap, status bar, alert, and notify apply caller style after defaults; loadmore applies its explicit `bgColor` in a later style-array object but caller gradient remains the visible background layer.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public constructors and source-active `customStyle` fields.
- Match component sources under `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components`.
- Preserve source colors, borders, radii, padding, dimensions, interactions, callbacks, and aliases outside gradient conflict handling.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Source Style Consumers and Ordering

**Files:**
- Inspect: `u-alert\u-alert.vue`
- Inspect: `u-input\u-input.vue`
- Inspect: `u-textarea\u-textarea.vue`
- Inspect: `u-gap\u-gap.vue`
- Inspect: `u-notify\u-notify.vue`
- Inspect: `u-status-bar\u-status-bar.vue`
- Inspect: `u-loadmore\u-loadmore.vue`

- [x] **Step 1: Identify active caller style paths**

Alert applies `addStyle(customStyle)` directly. Input, textarea, gap, and
status bar deep-merge caller styles after their computed defaults. Notify
applies `addStyle(customStyle)` after its optional source background object.
Loadmore applies caller style first and its explicit source `bgColor` object
afterward; a caller CSS gradient remains the visible background layer.

- [x] **Step 2: Identify the Flutter incompatibility**

The Flutter implementations use `BoxDecoration.copyWith` while setting a
non-null default color. When caller `customStyle.gradient` is non-null, this
creates the invalid Flutter combination of `color` and `gradient` on the same
`BoxDecoration`.

### Task 2: Add Failing Gradient Regression

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`

- [x] **Step 1: Mount every source-active component with a gradient**

Use distinct, non-null linear gradients for `UPAlert`, `UPInput`,
`UPTextarea`, `UPGap`, `UPNotify`, `UPStatusBar`, and `UPLoadmore`. Assert the
widget tree pumps without a Flutter decoration assertion and that all supplied
gradients appear in rendered decorations.

Run: `flutter test test/widgets_test.dart --name "source-active customStyle gradients render without color conflicts" --reporter expanded`

Observed: the Flutter SDK used by this repository accepted all seven
color-plus-gradient decorations. Each uniquely supplied gradient appeared in
one rendered `DecoratedBox`, so no implementation change is warranted for
this hypothesis.

### Task 3: Resolve Color/Gradient Conflicts

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_alert.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_input.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_textarea.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_layout.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_notify.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_status_bar.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_loadmore.dart`

- [x] **Step 1: Keep source default color only without a caller gradient**

No change required: the focused regression verified the current seven source
active roots render gradients without an assertion or missing decoration.

- [x] **Step 2: Preserve component-specific source ordering**

No source ordering changed because the proposed compatibility issue did not
reproduce in this Flutter environment.

### Task 4: Verify and Record Parity

**Files:**
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Run focused verification**

Run: `dart format test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "source-active customStyle gradients render without color conflicts|UP(Alert|Input|Textarea|Gap|Notify|StatusBar|Loadmore).*customStyle" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_alert.dart lib/src/widgets/up_input.dart lib/src/widgets/up_textarea.dart lib/src/widgets/up_layout.dart lib/src/widgets/up_notify.dart lib/src/widgets/up_status_bar.dart lib/src/widgets/up_loadmore.dart`

The regression itself passed before a production edit was needed. Component
analysis and complete validation are deferred until the next code-changing
batch, because this audit modified only the test file.

- [ ] **Step 2: Run complete validation and record result**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append the dated compatibility matrix entry for this batch.
