# UPShortVideo Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPShortVideo.customStyle` constructor compatibility without rendering a decoration absent from the source short-video template and inline props.

**Architecture:** The source root renders the short-video header, tab host, video pager, actions, progress control, and footer. Its inline props define tab and video data/indexes but not `customStyle`; Flutter keeps the optional public parameter while returning the source-backed video UI directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPShortVideo` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-short-video\u-short-video.vue`.
- Preserve source-backed tabs, video host injection, play/pause controls, callbacks, action handlers, progress events, and public aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Short-Video Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_short_video.dart` near `UPShortVideoState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPShortVideo` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPShortVideo({List tabsList = const [], List videoList = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed short-video content remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPShortVideo leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: SizedBox(
          height: 240,
          child: UPShortVideo(
            videoList: [
              {'title': 'video one', 'author': 'up'},
            ],
            customStyle: customStyle,
          ),
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

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPShortVideo leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPShortVideoState.build` wraps its source-backed root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused short-video behavior**

Run: `dart format lib/src/widgets/up_short_video.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPShortVideo (builds tabs|leaves source-inactive customStyle unrendered|like and tab change|videoBuilder host inject|play pause public API|BatchD aliases/play/pause|BatchG onLoadedMetadata/onTimeUpdate)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_short_video.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed and `flutter analyze lib/src/widgets/up_short_video.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPShortVideo` retains Flutter `customStyle` API compatibility without rendering it, because its source root and inline props never consume the prop while source-backed short-video behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GS.

Observed: `flutter test --reporter expanded` passed all 678 tests. The compatibility matrix records batch GS; `git diff --check` reported no whitespace errors.
