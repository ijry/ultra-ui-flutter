# UPCarKeyboard Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCarKeyboard.customStyle` constructor compatibility without rendering a decoration absent from the source car-keyboard template.

**Architecture:** `u-car-keyboard.vue` includes the shared mixin but its root keyboard view has only touch handling and the source keyboard layout. The shared `customStyle` prop is never bound. Flutter already renders source-backed key groups, Chinese/English mode selection, auto-change, and the backspace timer. Remove only the Flutter outer decoration wrapper.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCarKeyboard` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-car-keyboard\u-car-keyboard.vue`.
- Preserve source-backed keyboard groups, input emission, language switching, random-key behavior, auto-change, and backspace timer behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Car-Keyboard Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_car_keyboard.dart` near `UPCarKeyboardState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCarKeyboard` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCarKeyboard({bool random = false, bool autoChange = false, BoxDecoration? customStyle, ValueChanged<dynamic>? onChange, VoidCallback? onBackspace})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed keyboard mode/content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCarKeyboard leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCarKeyboard(customStyle: customStyle),
      ),
    ),
  );

  expect(find.text('京'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCarKeyboard leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCarKeyboardState.build` wraps its source-backed keyboard root in `Container(decoration: widget.customStyle)`.

Observed: the default Chinese key group mounted and the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only keyboard wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}
```

- [x] **Step 4: Verify focused car-keyboard behavior**

Run: `dart format lib/src/widgets/up_car_keyboard.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCarKeyboard (public input mode switch|public carInputClick mode aliases|leaves source-inactive customStyle unrendered)|UPNoNetwork/UPLink/UPCarKeyboard BatchJ shells" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_car_keyboard.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_car_keyboard.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCarKeyboard` retains shared `customStyle` for API compatibility but does not render it because the source root keyboard template never consumes the prop.

Observed: `flutter test --reporter expanded` passed all 644 tests. `git diff --check` completed with no whitespace errors.
