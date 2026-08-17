# UPSignature Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPSignature.customStyle` constructor compatibility without rendering a decoration absent from the source signature template and inline props.

**Architecture:** The source root contains the signature canvas wrapper and optional toolbar. Its inline props define canvas dimensions, background, brush configuration, and toolbar visibility but not `customStyle`; Flutter keeps the optional public parameter while returning the source-backed signature UI directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSignature` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-signature\u-signature.vue`.
- Preserve source-backed canvas, `bgColor`, toolbar, drawing, export, callbacks, brush settings, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Signature Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_signature.dart` near `UPSignatureState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSignature` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPSignature({dynamic width = 300, dynamic height = 200, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed signature canvas remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPSignature leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPSignature(
          width: 200,
          height: 120,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byKey(const ValueKey('sig-canvas')), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPSignature leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPSignatureState.build` wraps its source-backed root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Remove Flutter SDK color-channel deprecations**

```dart
final red = (color.r * 255).round().clamp(0, 255).toInt();
final green = (color.g * 255).round().clamp(0, 255).toInt();
final blue = (color.b * 255).round().clamp(0, 255).toInt();
```

Use the current Flutter `Color.r`, `Color.g`, and `Color.b` channels when forming the existing RGB hex string so component analysis remains diagnostic-free without changing its output.

- [x] **Step 5: Verify focused signature behavior**

Run: `dart format lib/src/widgets/up_signature.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPSignature (builds canvas|leaves source-inactive customStyle unrendered|export and toolbar|public clearCanvas alias|public touch and selectColor aliases|BatchG resolveStrokeColor/getCanvasPoint)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_signature.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_signature.dart` reported no issues.

- [x] **Step 6: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPSignature` retains Flutter `customStyle` API compatibility without rendering it, because its source root and inline props never consume the prop while source-backed canvas and toolbar behavior remain active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GT.

Observed: `flutter test --reporter expanded` passed all 679 tests. The compatibility matrix records batch GT; `git diff --check` reported no whitespace errors.
