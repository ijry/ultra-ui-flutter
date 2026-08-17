# UPScrollList Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPScrollList.customStyle` constructor compatibility without rendering a decoration absent from the source scroll-list template and local props.

**Architecture:** The source root contains the horizontal scroll view and optional indicator. Its local props define indicator dimensions, colors, and `indicatorStyle`, but not `customStyle`; Flutter keeps the optional public parameter while returning the source-backed list directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPScrollList` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-scroll-list\u-scroll-list.vue` and `props.js`.
- Preserve source-backed scrolling, indicator styles, edge callbacks, content rendering, and public scroll controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Scroll-List Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_scroll_list.dart` near `UPScrollListState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPScrollList` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPScrollList({List<Widget> children, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed scroll content remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPScrollList leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPScrollList(
          customStyle: customStyle,
          children: [SizedBox(width: 80, height: 40, child: Text('A'))],
        ),
      ),
    ),
  );

  expect(find.text('A'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPScrollList leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPScrollListState.build` wraps its source-backed list in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused scroll-list behavior**

Run: `dart format lib/src/widgets/up_scroll_list.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPScrollList (renders children|leaves source-inactive customStyle unrendered|emits edge events once per edge|scroll public API|BatchD scroll handlers|preserves source scroll event data)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_scroll_list.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_scroll_list.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPScrollList` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source-backed scrolling and indicator behavior remain active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GQ.

Observed: `flutter test --reporter expanded` passed all 676 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GQ.
