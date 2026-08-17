# UPActionSheetData Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPActionSheetData.customStyle` constructor compatibility without rendering a decoration absent from its separate source template.

**Architecture:** `u-action-sheet-data.vue` renders an unstyled root view containing a trigger and a nested action sheet. It declares only model, title, description, option, and key props; it neither declares nor consumes `customStyle`. Flutter should preserve its existing host-compatible optional field but return the source-backed trigger/action-sheet column directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPActionSheetData` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-action-sheet-data\u-action-sheet-data.vue`.
- Preserve source-backed trigger rendering, option selection, model updates, and nested action-sheet behavior.
- Do not modify `UPActionSheet` in this batch.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Action-Sheet-Data Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_action_sheet.dart` near `UPActionSheetDataState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPActionSheet` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPActionSheetData({dynamic modelValue = '', String title = '', List options = const [], BoxDecoration? customStyle, ValueChanged<dynamic>? onUpdateModelValue})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed trigger remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPActionSheetData leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPActionSheetData(
          title: '请选择',
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('请选择'), findsWidgets);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPActionSheetData leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPActionSheetDataState.build` wraps its trigger/action-sheet column in `Container(decoration: widget.customStyle)`.

Observed: after changing the title assertion to `findsWidgets` because the source-shaped trigger and nested sheet both display the title, the test found one `DecoratedBox` carrying `customStyle` from the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused data-selector behavior**

Run: `dart format lib/src/widgets/up_action_sheet.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPActionSheetData leaves source-inactive customStyle unrendered|UPCascader/Checkbox/StatusBar/Data shells BatchS residual aliases" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_action_sheet.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: both focused widget tests passed and `flutter analyze lib/src/widgets/up_action_sheet.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPActionSheetData` retains Flutter `customStyle` API compatibility without rendering it, because its separate source template never declares or consumes the prop.

Observed: `flutter test --reporter expanded` passed all 648 tests and `git diff --check` will be run after the documentation update.
