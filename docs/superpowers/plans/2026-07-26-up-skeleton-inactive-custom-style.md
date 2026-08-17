# UPSkeleton Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPSkeleton.customStyle` constructor compatibility without rendering a decoration absent from the source skeleton template and its active mixins.

**Architecture:** The source root renders either the skeleton placeholder layout or its child slot. The shared mixin declares `customStyle` as an API prop but does not render it, and `u-skeleton.vue` does not use the style-merging mixin or bind `customStyle`; Flutter keeps the optional public parameter while returning the source-backed skeleton layout directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSkeleton` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-skeleton\u-skeleton.vue`, `props.js`, and `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\libs\mixin\mixin.js`.
- Preserve source-backed loading transitions, avatar, title, rows, dimensions, animation, child slot, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Skeleton Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_skeleton.dart` near `UPSkeletonState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSkeleton` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPSkeleton({bool loading = true, int rows = 0, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed skeleton content remains mounted.

- [x] **Step 1: Verify source prop consumption**

`mixin.js` exposes the shared `customStyle` prop, but only `style.js` merges it into a computed style. `u-skeleton.vue` includes `mpMixin`, `mixin`, and local `props`, not `style`, and its root/template never binds `customStyle`.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPSkeleton leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPSkeleton(rows: 2, customStyle: customStyle),
      ),
    ),
  );

  expect(find.byType(UPSkeleton), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

Run: `flutter test test/widgets_test.dart --name "UPSkeleton leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPSkeletonState.build` wraps the source-backed body in `DecoratedBox(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return body;
```

- [x] **Step 4: Verify focused skeleton behavior**

Run: `dart format lib/src/widgets/up_skeleton.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPSkeleton (loading and content switch|leaves source-inactive customStyle unrendered|and UPSteps customStyle|public show hide animate|BatchE init alias)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_skeleton.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_skeleton.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPSkeleton` retains Flutter `customStyle` API compatibility without rendering it, because its source root and active mixins never consume the prop while source-backed skeleton behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GU.

Observed: `flutter test --reporter expanded` passed all 680 tests. The compatibility matrix records batch GU; `git diff --check` reported no whitespace errors.
