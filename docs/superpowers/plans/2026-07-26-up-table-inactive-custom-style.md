# UPTable Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPTable.customStyle` source-port API-compatible without rendering a decoration that the source table template never binds.

**Architecture:** `u-table.vue` accepts shared mixin props but binds its root only to computed `tableStyle`, which contains the active table border and background values. Flutter already renders this inner table style from `borderColor` and `bgColor`. Remove only the additional Flutter custom-style wrapper and protect the boundary with a `DecoratedBox` regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPTable` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-table\u-table.vue`.
- Preserve source-backed `tableStyle`, borders, background, header/cell layout, and `change` helper behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPTable Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_table.dart:63-90`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTable` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPTable({dynamic borderColor = '#e4e7ed', dynamic bgColor = '#ffffff', List<UPTr> children = const [], BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source active table border/background behavior remains unchanged.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPTable leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPTable(
          customStyle: customStyle,
          children: [
            UPTr(children: [UPTd(child: Text('单元格'))]),
          ],
        ),
      ),
    ),
  );
  expect(find.text('单元格'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPTable leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because `UPTable` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Preserve the internal table container that renders source tableStyle.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify table behavior**

Run:

```powershell
dart format lib/src/widgets/up_table.dart test/widgets_test.dart
flutter test test/widgets_test.dart --name "UPTable (renders header and cells|leaves source-inactive customStyle unrendered|BatchF change shell)" --reporter expanded
flutter analyze lib/src/widgets/up_table.dart
```

Observed: all three focused tests and static analysis pass.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that `UPTable` retains the shared `customStyle` prop for API compatibility but does not render it because the source template binds only computed `tableStyle`.

Observed: `flutter test --reporter expanded` passed all 636 tests. `git diff --check` completed with no whitespace errors.
