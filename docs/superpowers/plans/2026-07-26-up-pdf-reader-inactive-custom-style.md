# UPPdfReader Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPPdfReader.customStyle` constructor compatibility without rendering a decoration absent from the source PDF-reader template and local props.

**Architecture:** The source root binds only `height`, and its local props define only `src`, `height`, and `baseUrl`. Flutter retains the optional public parameter but returns its source-backed reader directly without an extra root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPPdfReader` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-pdf-reader\u-pdf-reader.vue` and `props.js`.
- Preserve source-backed PDF target resolution, height, viewer injection, callbacks, toolbar behavior, and public lifecycle controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align PDF-Reader Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_pdf_reader.dart` near `UPPdfReaderState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPPdfReader` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPPdfReader({String src = '', dynamic height, String baseUrl = '', BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed reader content remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPPdfReader leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPPdfReader(customStyle: customStyle),
      ),
    ),
  );

  expect(find.byType(UPPdfReader), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPPdfReader leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPPdfReaderState.build` wraps the source-backed reader in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused PDF-reader behavior**

Run: `dart format lib/src/widgets/up_pdf_reader.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPPdfReader (empty shows placeholder|leaves source-inactive customStyle unrendered|empty placeholder fits a constrained viewport|load callback|viewerBuilder host inject|BatchE load/reload shells)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_pdf_reader.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_pdf_reader.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPPdfReader` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source-backed PDF behavior remains active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GN.

Observed: `flutter test --reporter expanded` passed all 673 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GN.
