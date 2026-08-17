# UPTabsItem Inactive Custom Style Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve the UPTabsItem `customStyle` constructor compatibility field without rendering a style that its independent uView component does not consume.

**Architecture:** `u-tabs-item.vue` renders only its default slot inside `swiper-item`. It imports the shared mixin, which exposes `customStyle`, but the template never binds it. Flutter keeps the port API intact and returns the child directly instead of introducing a Flutter-only decoration wrapper.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public UPTabsItem constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-tabs-item\u-tabs-item.vue`.
- Preserve child rendering and existing UPTabsItem API aliases.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify the Independent Source Component

**Files:**
- Inspect: `components\u-tabs-item\u-tabs-item.vue` and `props.js`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_tabs.dart`

- [x] **Step 1: Verify source style consumption**

`u-tabs-item.vue` renders `<swiper-item><slot /></swiper-item>`. Its local
props object is empty. The component imports the shared mixin, but its
template contains no `customStyle`, `addStyle`, or other style binding, so the
inherited field has no source render consumer.

### Task 2: Remove the Flutter-Only Decoration

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_tabs.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Write and confirm the inactive-style regression**

Mount `UPTabsItem` with a unique `BoxDecoration`, retain a visible child, and
assert that no matching `DecoratedBox` is rendered.

Run: `flutter test test/widgets_test.dart --name "UPTabsItem leaves source-inactive customStyle unrendered" --reporter expanded`

Observed before the implementation change: the test failed because
`UPTabsItem.build` wrapped its child in a matching `Container`.

- [x] **Step 2: Delete only the decoration wrapper**

Return the child or an empty box directly. Keep the existing constructor
parameter and public field unchanged.

- [x] **Step 3: Verify and record source parity**

Run: `dart format lib/src/widgets/up_tabs.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPTabs(Item)? leaves source-inactive customStyle unrendered|UPTabsItem/UPSwiperIndicator BatchM aliases" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_tabs.dart`

Focused tests passed three cases and analysis reported no diagnostics. The
complete suite passed all 699 tests and `git diff --check` reported no
whitespace errors.
