# UPCateTab Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCateTab.customStyle` constructor compatibility without rendering a decoration absent from the source cate-tab template.

**Architecture:** The source root `u-cate-tab` dynamically applies only `height`. Its menu and item nodes use their own source classes and event paths, and no source prop or template binding references `customStyle`. Flutter should retain the optional API field while returning its existing source-backed two-pane layout directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCateTab` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-cate-tab\u-cate-tab.vue`.
- Preserve source-backed height, category selection, right-pane scrolling, item rendering, model aliases, and menu helper APIs.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Cate-Tab Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_cate_tab.dart` near `UPCateTabState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCateTab` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCateTab({dynamic height = 300, List tabList = const [], BoxDecoration? customStyle, ValueChanged<int>? onChange})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed tab content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCateTab leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCateTab(
          height: 180,
          tabList: [
            {
              'name': '分类',
              'children': [
                {'name': '项目'},
              ],
            },
          ],
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('分类'), findsWidgets);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCateTab leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCateTabState.build` wraps its two-pane root in `Container(decoration: widget.customStyle)`.

Observed: after changing the source-shaped category label assertion to `findsWidgets` because Flutter renders it in both menu and content contexts, the test found one `DecoratedBox` carrying `customStyle` from the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused cate-tab behavior**

Run: `dart format lib/src/widgets/up_cate_tab.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCateTab (switches tab|switchMenu public API|follow scroll synchronizes source scroll snapshots|BatchI menu helpers|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_cate_tab.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_cate_tab.dart` reported no issues. The new test advances 120ms to allow the existing follow-mode scroll-reset timer to complete before disposal.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCateTab` retains Flutter `customStyle` API compatibility without rendering it, because the source root consumes only active height styling.

Observed: `flutter test --reporter expanded` passed all 652 tests and `git diff --check` will be run after the documentation update.
