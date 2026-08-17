# UPCropper Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPCropper.customStyle` constructor compatibility without rendering a decoration absent from the source cropper template.

**Architecture:** The source root is an unstyled `u-cropper` view holding avatar, operation, and preview canvases plus its control UI. The source component declares no props section and never references `customStyle`. Flutter retains its optional parameter but returns the source-backed cropper root directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCropper` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-cropper\u-cropper.vue`.
- Preserve source-backed crop layout, canvas gestures, image export, public aliases, and callbacks.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Cropper Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_cropper.dart` near `UPCropperState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCropper` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCropper({String imageSrc = '', dynamic areaWidth, dynamic areaHeight, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed cropper root remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCropper leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: SizedBox(
          height: 360,
          child: UPCropper(
            imageSrc: '',
            areaWidth: 160,
            areaHeight: 160,
            noTab: true,
            customStyle: customStyle,
          ),
        ),
      ),
    ),
  );

  expect(find.byType(UPCropper), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCropper leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCropperState.build` wraps its source-backed cropper root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused cropper behavior**

Run: `dart format lib/src/widgets/up_cropper.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCropper (builds area|leaves source-inactive customStyle unrendered|confirm payload|exportImage with imageProvider|public select/chooseImage aliases|BatchF close/start/preview/getImgData|BatchH move/complete/avatarSrc)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_cropper.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed. `flutter analyze lib/src/widgets/up_cropper.dart` reports only one pre-existing `deprecated_member_use` info at line 303 for `Color.alpha`; no diagnostic is caused by this wrapper removal.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCropper` retains Flutter `customStyle` API compatibility without rendering it, because the source root never consumes the prop.

Observed: `flutter test --reporter expanded` passed all 658 tests. `git diff --check` completed with no whitespace errors.
