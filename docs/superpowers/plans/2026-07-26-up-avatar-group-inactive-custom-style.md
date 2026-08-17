# UPAvatarGroup Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPAvatarGroup.customStyle` constructor compatibility without rendering a decoration that the source avatar-group template never binds.

**Architecture:** `u-avatar-group.vue` includes the shared mixin but its root only contains the avatar item loop. The source applies a fixed `customStyle` string to its internal `up-text` used by the overflow badge, not the shared avatar-group prop. Remove only the Flutter root decoration wrapper and preserve source-backed avatar overlap and overflow behavior.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPAvatarGroup` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-avatar-group\u-avatar-group.vue`.
- Preserve avatar source resolution, size, shape, overlap, max-count, extra-value, and show-more event behavior.
- Do not alter the independent `UPAvatar` component or source's internal `UPText` style in this task.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Avatar-Group Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_avatar_group.dart` near `UPAvatarGroup.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPAvatarGroup` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPAvatarGroup({List urls = const [], dynamic maxCount = 5, bool showMore = true, BoxDecoration? customStyle, VoidCallback? onShowMore})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed overflow badge remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPAvatarGroup leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPAvatarGroup(
          urls: ['a', 'b'],
          maxCount: 1,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('+1'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPAvatarGroup leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPAvatarGroup.build` wraps its root row in `Container(decoration: customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only root wrapper after the source-backed overflow badge mounted.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify focused avatar-group behavior**

Run: `dart format lib/src/widgets/up_avatar_group.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPAvatarGroup (renders more badge|leaves source-inactive customStyle unrendered|BatchF clickHandler)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_avatar_group.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: all three focused widget tests passed and `flutter analyze lib/src/widgets/up_avatar_group.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPAvatarGroup` retains shared `customStyle` for API compatibility but does not render it because the source root template never consumes the prop.

Observed: `flutter test --reporter expanded` passed all 641 tests. `git diff --check` completed with no whitespace errors.
