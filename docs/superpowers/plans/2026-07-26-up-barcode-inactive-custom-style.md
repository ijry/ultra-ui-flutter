# UPBarcode Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPBarcode.customStyle` source-port API-compatible without rendering a decoration that the uview-plus barcode template never consumes.

**Architecture:** `u-barcode.vue` declares its barcode props locally and does not import the shared mixin. Its conditional root `view` has no style binding. Keep the Dart field and constructor parameter for compatibility, remove only its Flutter-only decoration wrapper, and protect that behavior with a `DecoratedBox` regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPBarcode` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-barcode\u-barcode.vue`.
- Preserve source-backed rendering, module encoding, canvas behavior, and callbacks.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPBarcode Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_barcode.dart:205-272`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPBarcode` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPBarcode({String value = '', String? text, dynamic width = 200, dynamic height = 100, BoxDecoration? customStyle, ValueChanged<Object>? onError, ValueChanged<Map>? onRendered})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; barcode labels and module encoder behavior remain unchanged.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPBarcode leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPBarcode(value: '12345678', customStyle: customStyle),
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

Run: `flutter test test/widgets_test.dart --name "UPBarcode leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because `UPBarcode` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify barcode behavior**

Run:

```powershell
dart format lib/src/widgets/up_barcode.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_barcode.dart
flutter test test/widgets_test.dart --name "UPBarcode (renders value text|leaves source-inactive customStyle unrendered|CODE128 paints modules|CODE39 paints)" --reporter expanded
flutter test test/widgets_test.dart --name "UPBarcode CODE39 and EAN modules" --reporter expanded
```

Observed: all five focused tests and static analysis pass.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that `UPBarcode` retains `customStyle` for Flutter API compatibility but does not render it because `u-barcode.vue` declares no shared mixin or root style binding.

Observed: `flutter test --reporter expanded` passes all 630 tests and `git diff --check` passes.
