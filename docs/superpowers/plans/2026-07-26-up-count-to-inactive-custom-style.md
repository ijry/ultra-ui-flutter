# UPCountTo Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPCountTo.customStyle` constructor compatibility without rendering a decoration absent from the source count-to template.

**Architecture:** The source renders one `u-count-num` text node with inline font size, weight, and color. Its local props define the animation and text properties only; neither it nor the template consumes `customStyle`. Flutter retains the optional parameter but returns its source-backed text directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCountTo` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-count-to\u-count-to.vue` and `props.js`.
- Preserve source-backed count animation, formatting, lifecycle, and end callback behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Count-To Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_count_to.dart` near `UPCountToState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCountTo` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCountTo({dynamic startVal = 0, dynamic endVal = 0, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed display text remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCountTo leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCountTo(
          startVal: 0,
          endVal: 100,
          autoplay: false,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('0'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCountTo leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCountToState.build` wraps its source-backed text root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused count-to behavior**

Run: `dart format lib/src/widgets/up_count_to.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCountTo (reaches end value|leaves source-inactive customStyle unrendered|stop and resume|public formatNumber count destroyed|BatchH countDown/easingFn|BatchJ callback/clearTimeout)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_count_to.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_count_to.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCountTo` retains Flutter `customStyle` API compatibility without rendering it, because the source text root and local props never consume the prop.

Observed: `flutter test --reporter expanded` passed all 657 tests. `git diff --check` completed with no whitespace errors.
