# UPAlbum Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPAlbum.customStyle` constructor compatibility without rendering a root decoration absent from the source album template.

**Architecture:** The source root is an unstyled `u-album` view. Its only `customStyle` occurrence belongs to the internal `up-text` used for the overflow counter and is a fixed source literal, not an album prop. Flutter should retain its public field while returning the same empty and populated album structures without wrapping either in `Container(decoration: widget.customStyle)`.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPAlbum` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-album\u-album.vue` and `props.js`.
- Preserve source-backed image layout, overflow counter, preview behavior, auto-wrap, and album-width callback behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Album Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_album.dart` near `UPAlbumState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPAlbum` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPAlbum({List urls = const [], dynamic maxCount = 9, BoxDecoration? customStyle, void Function(String src, int index)? onPreview})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox` for empty and populated albums; source-backed image and overflow content remain mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPAlbum leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: Column(
          children: [
            UPAlbum(customStyle: customStyle),
            UPAlbum(
              urls: ['a.png'],
              customStyle: customStyle,
            ),
          ],
        ),
      ),
    ),
  );

  expect(find.byType(UPAlbum), findsNWidgets(2));
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPAlbum leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPAlbumState.build` creates `Container(decoration: widget.customStyle)` for both empty and populated album paths.

Observed: the test found two `DecoratedBox` instances carrying `customStyle`, one from each Flutter-only album wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrappers**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
if (list.isEmpty) return const SizedBox.shrink();

// Return the existing source-backed `body` directly.
return body;
```

- [x] **Step 4: Verify focused album behavior**

Run: `dart format lib/src/widgets/up_album.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPAlbum (renders images placeholders|showMore and preview callback|previewHandler public API|BatchD getSrc/onPreviewTap|BatchH showUrls/imageStyle|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_album.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_album.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPAlbum` retains shared `customStyle` for API compatibility but does not render it because the source album root never consumes the prop. Clarify that the source's internal overflow-text literal `customStyle` is unrelated.

Observed: `flutter test --reporter expanded` passed all 647 tests and `git diff --check` will be run after the documentation update.
