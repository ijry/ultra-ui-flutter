# UPTable2 Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPTable2.customStyle` constructor compatibility without rendering a decoration absent from the source table root and local props.

**Architecture:** The source root renders the table container with a `border` class, scroll region, headers, rows, and optional fixed-column overlay. It neither imports the shared mixin nor declares or binds `customStyle`; Flutter keeps the optional public parameter while returning the source-backed table root directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPTable2` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-table2\u-table2.vue`.
- Preserve source-backed borders, scrolling, headers, rows, sorting, selection, trees, fixed columns, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Table2 Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_table2.dart` near `UPTable2State.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTable2` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPTable2({List columns = const [], List data = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed table content remains mounted.

- [x] **Step 1: Verify source prop consumption**

`u-table2.vue` uses local `props` rather than the shared style mixin. Its root binds only the table border class, and a source-wide search finds no `customStyle` prop, binding, or `addStyle` invocation.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPTable2 leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPTable2(
          customStyle: customStyle,
          columns: [
            {'key': 'name', 'title': 'Name', 'width': 100},
          ],
          data: [
            {'id': 1, 'name': 'Row'},
          ],
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

Run: `flutter test test/widgets_test.dart --name "UPTable2 leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPTable2State.build` wraps the source-backed table root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused table behavior**

Run: `dart format lib/src/widgets/up_table2.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPTable2 (renders rows|leaves source-inactive customStyle unrendered|selection sort tree public API|BatchD initDefaultExpandAll/getSortValueBy|BatchG selectChildren/getSortIcon|fixed-left columns stay visible after horizontal scroll|fixedHeader keeps header visible while body scrolls)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_table2.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed and `flutter analyze lib/src/widgets/up_table2.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPTable2` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source-backed table behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch HA.

Observed: `flutter test --reporter expanded` passed all 682 tests. The compatibility matrix records batch HA; `git diff --check` reported no whitespace errors.
