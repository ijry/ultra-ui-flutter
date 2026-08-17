# UPCountDown Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPCountDown.customStyle` constructor compatibility without rendering a decoration absent from the source countdown template.

**Architecture:** The source root is an unstyled `u-count-down` view which renders a slot or formatted text. Its local props declare only time, format, autoStart, and millisecond; the source template never consumes `customStyle`. Flutter retains the optional parameter but returns the source-backed text root directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCountDown` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-count-down\u-count-down.vue` and `props.js`.
- Preserve source-backed timing, formatting, start/reset, and callback behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Count-Down Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_count_down.dart` near `UPCountDownState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCountDown` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCountDown({dynamic time = 0, String format = 'HH:mm:ss', BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed countdown text remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCountDown leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCountDown(
          time: 3661000,
          autoStart: false,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('01:01:01'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCountDown leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCountDownState.build` wraps its source-backed text root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused countdown behavior**

Run: `dart format lib/src/widgets/up_count_down.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCountDown (formats remaining time|leaves source-inactive customStyle unrendered|public setRemainTime getRemainTime|BatchI tick aliases)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_count_down.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_count_down.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCountDown` retains Flutter `customStyle` API compatibility without rendering it, because the source root and local props never consume the prop.

Observed: `flutter test --reporter expanded` passed all 656 tests. `git diff --check` completed with no whitespace errors.
