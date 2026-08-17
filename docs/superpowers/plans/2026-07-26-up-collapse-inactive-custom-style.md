# UPCollapse Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCollapse` and `UPCollapseItem` shared `customStyle` constructor APIs compatible without adding decorations that their source templates never bind.

**Architecture:** Both Vue components include the shared mixin, which declares `customStyle`, but neither root template binds it. `u-collapse.vue` renders only its optional `u-line` and slot; `u-collapse-item.vue` sends its distinct `cellCustomStyle` to `u-cell` and leaves its own root unstyled. Remove only the two Flutter-only outer decoration branches and protect each with a focused widget regression.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPCollapse` and `UPCollapseItem` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-collapse\u-collapse.vue` and `components\u-collapse-item\u-collapse-item.vue`.
- Preserve source-backed border, expansion, animation, events, child rendering, and `cellCustomStyle` behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Collapse Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_collapse.dart:229-252,444-507`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near the existing `UPCollapse` widget test
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCollapse({List<Widget> children, BoxDecoration? customStyle, bool border = true})` and `UPCollapseItem({BoxDecoration? customStyle, dynamic cellCustomStyle})`.
- Produces: unchanged constructors; either shared `customStyle` produces no matching `DecoratedBox`; active cell styling and collapse operation remain unchanged.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCollapse leaves source-inactive customStyle unrendered',
    (tester) async {
  const parentStyle = BoxDecoration(color: Color(0xff123456));
  const itemStyle = BoxDecoration(color: Color(0xff654321));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCollapse(
          customStyle: parentStyle,
          children: [
            UPCollapseItem(
              title: '折叠标题',
              customStyle: itemStyle,
              child: Text('折叠内容'),
            ),
          ],
        ),
      ),
    ),
  );

  expect(find.text('折叠标题'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == parentStyle,
    ),
    findsNothing,
  );
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == itemStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCollapse leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCollapseState.build` and `UPCollapseItem.build` each wrap their root in `Container(decoration: customStyle)`.

Observed: the test failed at the parent assertion after finding one `DecoratedBox` with `parentStyle`, confirming the Flutter-only parent wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrappers**

```dart
// Preserve both public `customStyle` fields and constructor parameters.
// Preserve the UPCollapseItem cellCustomStyle decoration path.
// Remove only these trailing build branches:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}

if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify focused collapse behavior**

Run: `dart format lib/src/widgets/up_collapse.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCollapse (toggles panel|leaves source-inactive customStyle unrendered|open close public API|BatchF init/onChange|BatchI click/queryRect)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_collapse.dart`

Expected: all focused tests pass and analysis has no new diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_collapse.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that both collapse constructors retain shared `customStyle` for API compatibility but do not render it because neither Vue root template consumes it, while `UPCollapseItem.cellCustomStyle` remains active.

Observed: `flutter test --reporter expanded` passed all 637 tests. `git diff --check` completed with no whitespace errors.
