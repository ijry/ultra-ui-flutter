# UPCircleProgress Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCircleProgress.customStyle` source-port API-compatible without rendering a decoration that the uview-plus circle-progress template never consumes.

**Architecture:** `u-circle-progress.vue` includes the shared mixin, so it accepts `customStyle`, but its template binds styles only to the left and right circle border-color nodes. It never merges the shared style into its root. Keep the Dart field and constructor parameter, remove only the Flutter-only decoration wrapper, and protect the behavior with a `DecoratedBox` regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPCircleProgress` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-circle-progress\u-circle-progress.vue`.
- Preserve Flutter circle rendering, source border-color helpers, percentage behavior, child rendering, and public methods.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPCircleProgress Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_circle_progress.dart:67-105`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCircleProgress` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPCircleProgress({dynamic percentage = 30, dynamic width = 100, dynamic borderWidth = 5, dynamic activeColor, dynamic inactiveColor, Widget? child, BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; current Flutter circle and source helper APIs remain unchanged.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPCircleProgress leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCircleProgress(percentage: 40, customStyle: customStyle),
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

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCircleProgress leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because `UPCircleProgress` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  body = Container(decoration: customStyle, child: body);
}
```

- [x] **Step 4: Verify circle behavior**

Run:

```powershell
dart format lib/src/widgets/up_circle_progress.dart test/widgets_test.dart
flutter test test/widgets_test.dart --name "UPCircleProgress (renders child|leaves source-inactive customStyle unrendered|BatchF init/getProgress)" --reporter expanded
flutter analyze lib/src/widgets/up_circle_progress.dart
```

Observed: all three focused tests and static analysis pass.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that `UPCircleProgress` retains the shared `customStyle` prop for API compatibility but does not render it because its source template never binds that prop.

Observed: `flutter test --reporter expanded` passes all 632 tests and `git diff --check` passes.
