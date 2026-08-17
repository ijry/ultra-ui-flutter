# UPIndexList Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPIndexList.customStyle` constructor compatibility without rendering a root decoration absent from the source index-list template.

**Architecture:** The source index-list root contains scroll content, an index-letter rail, and a touch indicator. Its local props define colors, letters, sticky behavior, navigation height, bottom safety, and margins, but not `customStyle`; Flutter keeps the optional parameter and returns the source-backed stack directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPIndexList` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-index-list\u-index-list.vue` and `props.js`.
- Preserve source-backed scroll content, letter rail, touch selection, indicator, navigation, and callbacks.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Index-List Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_index_list.dart` near `UPIndexListState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPIndexList` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPIndexList({List indexList = const [], List<UPIndexItem> children = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed index list content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPIndexList leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: SizedBox(
          height: 300,
          child: UPIndexList(
            customStyle: customStyle,
            indexList: ['A'],
            children: [
              UPIndexItem(
                anchor: UPIndexAnchor(text: 'A'),
                children: [Text('Apple')],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  expect(find.text('Apple'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPIndexList leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPIndexListState.build` wraps its source-backed stack in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused index-list behavior**

Run: `dart format lib/src/widgets/up_index_list.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPIndexList (renders anchors|renders anchors and letters|object anchor text|jumpTo public API|BatchB uIndexList/touch helpers|BatchF init/scrollHandler/setValueForTouch|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_index_list.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed and `flutter analyze lib/src/widgets/up_index_list.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPIndexList` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source scroll, index-letter, and touch-indicator rendering remains active.

Observed: `flutter test --reporter expanded` passed all 664 tests. `git diff --check` reported no whitespace errors.
