# UPSwipeAction Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPSwipeAction` and `UPSwipeActionItem` `customStyle` constructor compatibility without rendering decorations absent from their source templates.

**Architecture:** The source group root renders only its default slot, while the source item root renders action buttons and the swipeable content. Both use the shared mixin that declares `customStyle` but neither root/template consumes it; Flutter keeps the optional public parameters while returning the source-backed group and item structures directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSwipeAction` and `UPSwipeActionItem` constructors and `customStyle` fields.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-swipe-action\u-swipe-action.vue` and `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-swipe-action-item\u-swipe-action-item.vue`.
- Preserve source-backed group coordination, open/close behavior, drag thresholds, options, callbacks, style maps, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Swipe-Action Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_swipe_action.dart` near `UPSwipeActionState.build` and `UPSwipeActionItemState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSwipeActionItem` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPSwipeAction({List<Widget> children, BoxDecoration? customStyle, ...})` and `UPSwipeActionItem({Widget child, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor APIs; supplied root `customStyle` values produce no matching `DecoratedBox`; source-backed group and item content remain mounted.

- [x] **Step 1: Verify source prop consumption**

Both components inherit the shared `customStyle` prop through `mixin.js`. `u-swipe-action.vue` renders only `<view class="u-swipe-action"><slot></slot></view>`, while `u-swipe-action-item.vue` renders its action/content views without binding the root prop. Neither template imports or calls `addStyle` for the public root prop.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPSwipeAction roots leave source-inactive customStyle unrendered',
    (tester) async {
  const groupStyle = BoxDecoration(color: Color(0xff123456));
  const itemStyle = BoxDecoration(color: Color(0xff654321));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPSwipeAction(
          customStyle: groupStyle,
          children: [
            UPSwipeActionItem(
              customStyle: itemStyle,
              child: SizedBox(height: 48, child: Text('row')),
            ),
          ],
        ),
      ),
    ),
  );

  for (final style in [groupStyle, itemStyle]) {
    expect(
      find.byWidgetPredicate(
        (widget) => widget is DecoratedBox && widget.decoration == style,
      ),
      findsNothing,
    );
  }
});
```

Run: `flutter test test/widgets_test.dart --name "UPSwipeAction roots leave source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because both Flutter build methods wrap their source-backed roots in `Container(decoration: widget.customStyle)`.

Observed: the regression found a matching `DecoratedBox` from the group root wrapper before evaluating the item-root assertion.

- [x] **Step 3: Delete only the Flutter-only decoration wrappers**

```dart
// Keep both `final BoxDecoration? customStyle;` fields and constructor parameters.
return root;
```

- [x] **Step 4: Verify focused swipe-action behavior**

Run: `dart format lib/src/widgets/up_swipe_action.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPSwipeAction(Item opens by show| roots leave source-inactive customStyle unrendered| exposes closeAll and update show| emits source state changes once per transition| drag start closes source sibling immediately|Item uses source option icon and radius styles|Item commits open only after source drag end| programmatic opens do not close source siblings| BatchC setOpendItem/closeHandler|Item BatchI open/close aliases)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_swipe_action.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all ten focused widget tests passed and `flutter analyze lib/src/widgets/up_swipe_action.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that both swipe-action components retain Flutter `customStyle` API compatibility without rendering it, because their source roots and local props never consume the prop while source-backed swipe behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GY.

Observed: `flutter test --reporter expanded` passed all 681 tests. The compatibility matrix records batch GY; `git diff --check` reported no whitespace errors.
