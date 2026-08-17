# UPLazyLoad Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPLazyLoad.customStyle` constructor compatibility without rendering a decoration absent from the source lazy-load template and props.

**Architecture:** The source root binds only opacity, border radius, and transition state. It defines all local props inline and does not declare or consume `customStyle`; Flutter keeps the optional parameter but returns its source-backed placeholder or image branch directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPLazyLoad` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-lazy-load\u-lazy-load.vue`.
- Preserve source-backed placeholder, lazy loading, image state, transition, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Lazy-Load Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_lazy_load.dart` near `UPLazyLoadState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPLazyLoad` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPLazyLoad({String image = '', BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed lazy placeholder remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPLazyLoad leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPLazyLoad(
          image: '',
          height: 80,
          width: 80,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPLazyLoad), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPLazyLoad leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPLazyLoadState.build` wraps its source-backed branch in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused lazy-load behavior**

Run: `dart format lib/src/widgets/up_lazy_load.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPLazyLoad (placeholder before load|loadNow public API|BatchD init/loadNow/clickImg|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_lazy_load.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_lazy_load.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPLazyLoad` retains Flutter `customStyle` API compatibility without rendering it, because neither its source root nor inline local props consume the prop while source loading behavior remains active.

Observed: `flutter test --reporter expanded` passed all 666 tests. `git diff --check` reported no whitespace errors.
