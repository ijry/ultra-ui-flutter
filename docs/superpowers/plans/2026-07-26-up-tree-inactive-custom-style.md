# UPTree Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPTree.customStyle` constructor compatibility without rendering a root decoration absent from the source tree template.

**Architecture:** `u-tree.vue` inherits `customStyle` from the shared `mixin`, but its root binds only class and no style; its local props, computed properties, and child forwarding do not consume it. Flutter retains the API field but returns the source-backed tree column directly, leaving node-level indent and selected-state styling unchanged.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPTree` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-tree\u-tree.vue`.
- Preserve source-backed hierarchy, selection, checkbox cascade, expansion, callbacks, slots, and public methods.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Tree Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_tree.dart` near `UPTreeState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTree` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPTree({List data = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed tree nodes remain mounted.

- [x] **Step 1: Verify source prop consumption**

`u-tree.vue` includes the shared `mixin`, whose global props declare `customStyle`, but its root at lines 1-2 binds no style. The local props, computed properties, and rendered children never use or forward `customStyle`; distinct node styles only compute indent, selected state, disabled opacity, and theme colors.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPTree leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPTree(
          data: [
            {'id': 'root', 'label': 'Root'},
          ],
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

Run: `flutter test test/widgets_test.dart --name "UPTree leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPTreeState.build` wraps the source-backed root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: _buildVisible(),
);
```

- [x] **Step 4: Verify focused tree behavior**

Run: `dart format lib/src/widgets/up_tree.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPTree (checkbox cascade and public methods|renders and resolves parent indeterminate selection|BatchB handleNodeClick/expand/checkbox aliases|BatchF toggle/updateCheckStatus|BatchG initTree/toggleExpand/getNodeByKey|BatchH cloneNodes/getIndentValue|BatchJ toggleCheck|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_tree.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all eight focused widget tests passed. `flutter analyze lib/src/widgets/up_tree.dart` reports one existing `unused_element_parameter` warning for `_TreeNode.indeterminate`, whose constructor argument is unrelated to the removed root decoration and was left unchanged to keep this parity change narrowly scoped.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPTree` retains Flutter `customStyle` API compatibility without rendering it, because its source root never consumes the inherited prop while source-backed tree behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records the batch.

Observed: `flutter test --reporter expanded` passed all 684 tests. The compatibility matrix records batch HE; `git diff --check` reported no whitespace errors.
