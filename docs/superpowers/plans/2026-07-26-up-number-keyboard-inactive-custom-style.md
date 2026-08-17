# UPNumberKeyboard Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPNumberKeyboard.customStyle` constructor compatibility without rendering a decoration absent from the source number-keyboard template and local props.

**Architecture:** The source root renders the number-key wrappers and backspace button, while local props define only `mode`, `dotDisabled`, and `random`. Flutter retains the optional public parameter but returns the source-backed keyboard directly, without adding a root decoration that does not exist in the Vue component.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPNumberKeyboard` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-number-keyboard\u-number-keyboard.vue` and `props.js`.
- Preserve source-backed item styles, randomized ordering, backspace behavior, callbacks, and public method aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Number-Keyboard Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_number_keyboard.dart` near `UPNumberKeyboardState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPNumberKeyboard` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPNumberKeyboard({String mode = 'number', bool dotDisabled = false, bool random = false, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed keyboard buttons remain mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPNumberKeyboard leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPNumberKeyboard(customStyle: customStyle),
      ),
    ),
  );

  expect(find.text('1'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPNumberKeyboard leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPNumberKeyboardState.build` wraps the source-backed keyboard in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused number-keyboard behavior**

Run: `dart format lib/src/widgets/up_number_keyboard.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPNumberKeyboard (change and backspace|public input backspace|public keyboardClick aliases|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_number_keyboard.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_number_keyboard.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPNumberKeyboard` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source-backed item styles and keyboard behavior remain active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GL.

Observed: `flutter test --reporter expanded` passed all 671 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GL.
