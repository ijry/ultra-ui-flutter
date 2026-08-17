# UPKeyboard Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPKeyboard.customStyle` constructor compatibility without rendering a decoration absent from the source keyboard component's public props and root template.

**Architecture:** The source keyboard's root is `u-popup`, which receives its own computed `popupStyle` background. The component-local props do not declare public `customStyle`; Flutter retains the compatibility parameter but returns the source-backed popup directly, preserving the separate popup background behavior.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPKeyboard` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-keyboard\u-keyboard.vue` and `props.js`.
- Preserve source-backed popup background, overlay, keyboard modes, tooltips, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Keyboard Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_keyboard.dart` near `UPKeyboardState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPKeyboard` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPKeyboard({bool show = false, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed keyboard popup remains mounted with its own background style.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPKeyboard leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPKeyboard(show: true, customStyle: customStyle),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('数字键盘'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPKeyboard leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPKeyboardState.build` wraps its source-backed `UPPopup` in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused keyboard behavior**

Run: `dart format lib/src/widgets/up_keyboard.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPKeyboard (shows tips|overlay close updates show|public open close change backspace|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_keyboard.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_keyboard.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPKeyboard` retains Flutter `customStyle` API compatibility without rendering it, because its source component passes only its internally computed `popupStyle` to `u-popup` and its local props never declare the public prop.

Observed: `flutter test --reporter expanded` passed all 665 tests. `git diff --check` reported no whitespace errors.
