# UPNavbarMini Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPNavbarMini.customStyle` constructor compatibility without rendering a decoration that the source navbar-mini template never binds.

**Architecture:** `u-navbar-mini.vue` includes the shared mixin, so it accepts `customStyle`, but its root binds only `customClass`; its content node actively uses `height` and `bgColor`. Remove the single Flutter-only outer decoration wrapper and add a regression that proves the source-backed icon/content layout remains mounted.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPNavbarMini` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-navbar-mini\u-navbar-mini.vue`.
- Preserve existing Flutter navbar-mini height, background, status-bar, slots, click aliases, and auto-back behavior.
- Do not change unrelated source-default or `customClass` parity gaps in this task.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Navbar-Mini Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_navbar_mini.dart:65-109`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near the existing `UPNavbarMini` widget test
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPNavbarMini({bool fixed = true, bool safeAreaInsetTop = true, dynamic bgColor, dynamic height, BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPNavbarMini leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPNavbarMini(
          fixed: false,
          safeAreaInsetTop: false,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPIcon), findsNWidgets(2));
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPNavbarMini leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because the Flutter build wraps the source-backed content in `Container(decoration: customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify focused navbar-mini behavior**

Run: `dart format lib/src/widgets/up_navbar_mini.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPNavbarMini (renders icons area|leaves source-inactive customStyle unrendered|BatchI left/home click)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_navbar_mini.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: all three focused widget tests passed and `flutter analyze lib/src/widgets/up_navbar_mini.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPNavbarMini` retains shared `customStyle` for API compatibility but does not render it because the source template binds `customClass`, `height`, and `bgColor` instead.

Observed: `flutter test --reporter expanded` passed all 638 tests. `git diff --check` completed with no whitespace errors.
