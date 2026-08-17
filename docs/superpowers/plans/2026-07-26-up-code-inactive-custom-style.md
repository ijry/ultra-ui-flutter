# UPCode Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCode.customStyle` constructor compatibility without rendering a decoration absent from the source `u-code` template.

**Architecture:** The Vue component is a logic-only `<view class="u-code">` and its local props declare countdown inputs only; it neither declares nor binds `customStyle`. Flutter should continue exposing its existing optional field for callers, but `UPCodeState.build` should return the logic-only empty widget without a Flutter-only wrapper.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCode` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-code\u-code.vue` and `props.js`.
- Preserve source-backed countdown callbacks, reset/start behavior, and keep-running storage behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Logic-Only Code Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_code.dart` near `UPCodeState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCode` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCode({dynamic seconds = 60, String startText = '获取验证码', String changeText = 'X秒重新获取', String endText = '重新获取', bool keepRunning = false, String uniqueKey = '', BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; logic-only widget remains mounted and emits normal countdown changes.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCode leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(body: UPCode(customStyle: customStyle)),
    ),
  );

  expect(find.byType(UPCode), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCode leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCodeState.build` wraps its `SizedBox.shrink()` in `Container(decoration: widget.customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
@override
Widget build(BuildContext context) => const SizedBox.shrink();
```

- [x] **Step 4: Verify focused code behavior**

Run: `dart format lib/src/widgets/up_code.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCode (emits change text|keepRunning resumes after rebuild|start reset public API|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_code.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_code.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCode` retains the Flutter `customStyle` API but does not render it because the source component is logic-only and never consumes that prop.

Observed: `flutter test --reporter expanded` passed all 645 tests and `git diff --check` completed with no whitespace errors.
