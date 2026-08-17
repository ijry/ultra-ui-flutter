# UPPoster Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPPoster.customStyle` constructor compatibility without rendering a decoration absent from the source poster template and inline props.

**Architecture:** The source poster template renders only its hidden canvas and QR-code helpers, and its inline props define only `json`. Flutter retains the optional public parameter but returns its source-backed poster directly without adding a root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPPoster` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-poster\u-poster.vue`.
- Preserve source-backed JSON rendering, canvas/export flow, image and QR-code helpers, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Poster Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_poster.dart` near `UPPosterState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPPoster` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPPoster({Map json = const {}, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed poster content remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPPoster leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPPoster(
          json: {'css': {'width': '120px', 'height': '80px'}},
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPPoster), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPPoster leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPPosterState.build` wraps its source-backed poster in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused poster behavior**

Run: `dart format lib/src/widgets/up_poster.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPPoster (builds from json|leaves source-inactive customStyle unrendered|export with image and qrcode views|exportImage generate aliases|BatchH getTextStyle/generateQRCode)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_poster.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_poster.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPPoster` retains Flutter `customStyle` API compatibility without rendering it, because its source root and inline props never consume the prop while source-backed poster behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GO.

Observed: `flutter test --reporter expanded` passed all 674 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GO.
