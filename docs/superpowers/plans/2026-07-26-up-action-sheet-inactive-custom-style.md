# UPActionSheet Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPActionSheet.customStyle` constructor compatibility without rendering a decoration absent from the source action-sheet template.

**Architecture:** The source action sheet passes popup inputs to `u-popup` and renders its header, description, item list, and optional cancellation region without binding `customStyle` anywhere. Flutter already maps those source-backed regions through `UPPopup`; remove only the outer Flutter `Container` placed around that popup. `UPActionSheetData` is a separate source component and remains outside this batch.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPActionSheet` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-action-sheet\u-action-sheet.vue`.
- Preserve source-backed popup behavior, title and description rendering, action selection, cancellation, loading/disabled actions, and update-show callbacks.
- Do not modify `UPActionSheetData` in this batch.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Main Action-Sheet Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_action_sheet.dart` near `UPActionSheetState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPActionSheet` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPActionSheet({bool show = false, List<dynamic> actions = const [], String title = '', String description = '', String cancelText = '', BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; popup and source-backed action contents remain mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPActionSheet leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPActionSheet(
          show: true,
          actions: [{'name': '操作'}],
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('操作'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPActionSheet leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPActionSheetState.build` wraps its source-backed `UPPopup` in `Container(decoration: widget.customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}
```

- [x] **Step 4: Verify focused action-sheet behavior**

Run: `dart format lib/src/widgets/up_action_sheet.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPActionSheet (loading disabled and update show|closeHandler honors source overlay guard|only shows the source header divider for a description|public open close selectHandler|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_action_sheet.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_action_sheet.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPActionSheet` retains shared `customStyle` for API compatibility but does not render it because the source action-sheet template never consumes that prop. State that `UPActionSheetData` was intentionally outside the batch.

Observed: `flutter test --reporter expanded` passed all 646 tests and `git diff --check` will be run after the documentation update.
