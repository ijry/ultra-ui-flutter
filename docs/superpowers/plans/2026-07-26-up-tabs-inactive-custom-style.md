# UPTabs Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPTabs.customStyle` constructor compatibility without rendering a decoration absent from the source tabs root and local props.

**Architecture:** The source root renders the tabs wrapper with `customClass` and a shape-mode class. It inherits `customStyle` through the shared mixin but does not bind it; internal icon, item, badge, active, and inactive style props remain separately source-backed. Flutter keeps the optional public parameter while returning the source-backed tabs structure directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPTabs` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-tabs\u-tabs.vue`.
- Preserve source-backed tabs, shape modes, item/icon styles, badges, line animation, callbacks, slots, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Tabs Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_tabs.dart` near `UPTabsState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTabs` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPTabs({List list = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed tabs remain mounted.

- [x] **Step 1: Verify source prop consumption**

`u-tabs.vue` includes the shared mixin but its root at lines 2-3 binds only `customClass` and `shapeModeClass`. It never binds `customStyle`; the `addStyle` calls in this template apply distinct internal props such as `iconStyle`, `itemStyle`, `activeStyle`, and `inactiveStyle`.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPTabs leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPTabs(list: ['A', 'B'], customStyle: customStyle),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

Run: `flutter test test/widgets_test.dart --name "UPTabs leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPTabsState.build` wraps the source-backed root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused tabs behavior**

Run: `dart format lib/src/widgets/up_tabs.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPTabs (changes index|leaves source-inactive customStyle unrendered|disabled item and longPress|shapeMode capsule builds|left right iconStyle and empty badge|setCurrent public API|public clickHandler resize init|BatchF getAllItemRect/setLineLeft|BatchH showLine/itemComputedStyle)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_tabs.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all nine focused widget tests passed and `flutter analyze lib/src/widgets/up_tabs.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPTabs` retains Flutter `customStyle` API compatibility without rendering it, because its source root never consumes the prop while source-backed tabs behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch HB.

Observed: `flutter test --reporter expanded` passed all 683 tests. The compatibility matrix records batch HB; `git diff --check` reported no whitespace errors.
