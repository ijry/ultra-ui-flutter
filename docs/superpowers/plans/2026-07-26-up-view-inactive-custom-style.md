# UPView Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPView.customStyle` constructor compatibility without rendering a decoration that the source view template never binds.

**Architecture:** `u-view.vue` includes the shared mixin but its root `view` binds only declared layout properties: background color, text color, flex direction/alignment, dimensions, spacing, and border color. Flutter already maps those active properties in its internal container. Remove only the additional Flutter custom-style wrapper and preserve the existing layout/content API surface.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPView` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-view\u-view.vue`.
- Preserve active background, color, flex, sizing, padding, margin, and border behavior.
- Do not alter broader source slot/content or click-binding parity in this task.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align View Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_view.dart` near `UPView.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPView` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPView({Widget? child, List<Widget> children = const [], dynamic backgroundColor = '', dynamic borderColor = '', BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed container layout remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPView leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPView(
          width: 80,
          height: 20,
          backgroundColor: '#abcdef',
          customStyle: customStyle,
          child: Text('view-style'),
        ),
      ),
    ),
  );

  expect(find.text('view-style'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPView leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPView.build` wraps its active layout container in `Container(decoration: customStyle)`.

Observed: the initial 20px-high fixture overflowed its source-style default text column, so the fixture height was raised to 40px. The rerun failed only at the intended assertion after finding one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and the constructor parameter.
// Remove only this trailing build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify focused view behavior**

Run: `dart format lib/src/widgets/up_view.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPView (retains source manual click handler only|honors reverse flex directions|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_view.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: all three focused widget tests passed and `flutter analyze lib/src/widgets/up_view.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPView` retains shared `customStyle` for API compatibility but does not render it because the source template binds only its explicit layout style properties.

Observed: `flutter test --reporter expanded` passed all 640 tests. `git diff --check` completed with no whitespace errors.
