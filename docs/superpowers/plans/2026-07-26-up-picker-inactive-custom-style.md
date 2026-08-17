# UPPicker Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the main `UPPicker.customStyle` constructor API compatible without rendering a decoration that the source picker template never binds.

**Architecture:** `u-picker.vue` includes the shared mixin, so it accepts `customStyle`, but its root contains the input trigger and `u-popup` without a custom-style binding. It has independent active style APIs such as `bgColor` and `maskStyle`. Remove only the main `UPPicker` Flutter decoration wrapper; `UPPickerColumn` and `UPPickerData` are separate Flutter shells and remain outside this batch.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public main `UPPicker` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker\u-picker.vue`.
- Preserve picker popup, input trigger, toolbar, model update, event, `bgColor`, and `maskStyle` behavior.
- Do not alter `UPPickerColumn` or `UPPickerData` in this task.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Main UPPicker Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_picker.dart:422-521`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPPicker` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPPicker({bool show = false, bool pageInline = false, List columns = const [], dynamic bgColor = '', dynamic maskStyle, BoxDecoration? customStyle, void Function(List values, List indexes)? onConfirm})`.
- Produces: unchanged main constructor API; supplied `customStyle` produces no matching `DecoratedBox`; picker options, confirm behavior, and active popup styling remain unchanged.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPPicker leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPPicker(
          show: true,
          pageInline: true,
          columns: [
            ['选项'],
          ],
          customStyle: customStyle,
        ),
      ),
    ),
  );
  expect(find.text('选项'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPPicker leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because the main `UPPicker` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the main Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Do not change UPPickerColumn or UPPickerData in this task.
// Remove only this main UPPicker build branch:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}
```

- [x] **Step 4: Verify picker behavior**

Run:

```powershell
dart format lib/src/widgets/up_picker.dart test/widgets_test.dart
flutter test test/widgets_test.dart --name "UPPicker (confirm returns values|leaves source-inactive customStyle unrendered|exposes source-compatible state methods|public open confirm cancel aliases)" --reporter expanded
flutter analyze lib/src/widgets/up_picker.dart
```

Observed: all four focused tests and static analysis pass.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that main `UPPicker` retains the shared `customStyle` prop for API compatibility but does not render it because the source template never binds that prop.

Observed: `flutter test --reporter expanded` passes all 635 tests and `git diff --check` passes.
