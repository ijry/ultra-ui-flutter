# UPFloatButton Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPFloatButton.customStyle` constructor compatibility without rendering a decoration absent from the source float-button template.

**Architecture:** The source root is a fixed-position `u-float-button` view whose inline styling consumes top, bottom, right, button dimensions, colors, and border colors. Its inline prop definition omits `customStyle`. Flutter retains the optional constructor parameter but returns its source-backed `Positioned` root directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPFloatButton` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-float-button\u-float-button.vue`.
- Preserve source-backed fixed positioning, menu lifecycle, item callbacks, colors, slots, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Float-Button Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_float_button.dart` near `UPFloatButtonState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPFloatButton` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPFloatButton({bool isMenu = false, List list = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed positioned button remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPFloatButton leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: Stack(
          children: [
            UPFloatButton(
              isMenu: true,
              customStyle: customStyle,
              list: [{'name': 'map'}],
            ),
          ],
        ),
      ),
    ),
  );

  expect(find.byType(UPFloatButton), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPFloatButton leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPFloatButtonState.build` wraps its source-backed `Positioned` root in `Container(decoration: widget.customStyle)`.

Observed: the wrapper rendered one matching `DecoratedBox` and caused Flutter's `Incorrect use of ParentDataWidget` assertion, because it placed the `Positioned` root below `Container` instead of directly below `Stack`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused float-button behavior**

Run: `dart format lib/src/widgets/up_float_button.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPFloatButton (toggles menu|leaves source-inactive customStyle unrendered|open close public API|BatchD itemClick/clickHandler)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_float_button.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_float_button.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPFloatButton` retains Flutter `customStyle` API compatibility without rendering it, because the source root and inline prop definition never consume the prop.

Observed: `flutter test --reporter expanded` passed all 661 tests. `git diff --check` completed with no whitespace errors.
