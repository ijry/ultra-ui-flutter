# UPPagination Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPPagination.customStyle` constructor compatibility without rendering a decoration absent from the source pagination template and inline local props.

**Architecture:** The source root is an unstyled pagination view. Its inline props define paging, button, size, layout, and visibility controls, but not `customStyle`; Flutter keeps the optional public parameter while returning the source-backed `Wrap` without an extra root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPPagination` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-pagination\u-pagination.vue`.
- Preserve source-backed navigation, displayed pages, total and size layouts, button styling, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Pagination Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_pagination.dart` near `UPPaginationState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPPagination` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPPagination({int currentPage = 1, int pageSize = 10, int total = 0, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed pagination controls remain mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPPagination leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPPagination(total: 20, customStyle: customStyle),
      ),
    ),
  );

  expect(find.text('1'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPPagination leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPPaginationState.build` wraps its source-backed `Wrap` in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return body;
```

- [x] **Step 4: Verify focused pagination behavior**

Run: `dart format lib/src/widgets/up_pagination.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPPagination (current change|sizes and total layout|goTo next prev public API|public handleSizeChange onConfirmPage|source navigation layout and size semantics|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_pagination.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_pagination.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPPagination` retains Flutter `customStyle` API compatibility without rendering it, because its source root and inline props never consume the prop while source-backed pagination behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GM.

Observed: `flutter test --reporter expanded` passed all 672 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GM.
