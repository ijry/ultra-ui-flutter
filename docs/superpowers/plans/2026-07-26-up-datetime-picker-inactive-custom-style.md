# UPDatetimePicker Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPDatetimePicker.customStyle` constructor compatibility without rendering a decoration absent from the source datetime-picker template.

**Architecture:** The source root is an unstyled `u-datetime-picker` view which conditionally renders the input trigger and passes source-declared props to its internal `u-picker`. The local prop set provides `inputProps`, mask props, and picker configuration, but not `customStyle`. Flutter retains the optional parameter while returning the source-backed `UPPicker` root directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPDatetimePicker` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` and `props.js`.
- Preserve source-backed input trigger, popup lifecycle, date columns, formatter, callbacks, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Datetime-Picker Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_datetime_picker.dart` near `UPDatetimePickerState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPDatetimePicker` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPDatetimePicker({bool show = false, String mode = 'datetime', BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed picker content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPDatetimePicker leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPDatetimePicker(
          show: true,
          mode: 'date',
          value: 1704153600000,
          customStyle: customStyle,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('确认'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPDatetimePicker leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPDatetimePickerState.build` wraps its source-backed `UPPicker` root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused datetime-picker behavior**

Run: `dart format lib/src/widgets/up_datetime_picker.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPDatetimePicker (confirms value|leaves source-inactive customStyle unrendered|setValue public API|public confirm getInputValue|BatchG correctValue/getRanges|BatchJ formatter/intercept)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_datetime_picker.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_datetime_picker.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPDatetimePicker` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop.

Observed: `flutter test --reporter expanded` passed all 659 tests. `git diff --check` completed with no whitespace errors.
