# UPMessageInput Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPMessageInput.customStyle` constructor compatibility without rendering a decoration absent from the source message-input template and local props.

**Architecture:** The source root contains the hidden number input and generated code cells. Its inline local props define code-input behavior but not `customStyle`; Flutter keeps the optional parameter and returns the source-backed gesture and cell layout directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPMessageInput` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-message-input\u-message-input.vue`.
- Preserve source-backed input, code cell modes, focus, breathing cursor, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Message-Input Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_message_input.dart` near `UPMessageInputState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPMessageInput` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPMessageInput({dynamic value = '', BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed code-cell content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPMessageInput leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPMessageInput(value: '12', customStyle: customStyle),
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

Run: `flutter test test/widgets_test.dart --name "UPMessageInput leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPMessageInputState.build` wraps its source-backed code-cell layout in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return body;
```

- [x] **Step 4: Verify focused message-input behavior**

Run: `dart format lib/src/widgets/up_message_input.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPMessageInput (finishes at maxlength|onUpdateValue and customStyle|public setValue clear focus|public getVal|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_message_input.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_message_input.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPMessageInput` retains Flutter `customStyle` API compatibility without rendering it, because neither its source root nor inline local props consume the prop while source code-entry behavior remains active.

Observed: `flutter test --reporter expanded` passed all 667 tests. `git diff --check` reported no whitespace errors.
