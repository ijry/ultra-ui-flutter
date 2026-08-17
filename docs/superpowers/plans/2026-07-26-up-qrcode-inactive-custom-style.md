# UPQrcode Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPQrcode.customStyle` source-port API-compatible without rendering a decoration that the uview-plus QR-code template never consumes.

**Architecture:** `u-qrcode.vue` declares its props directly and does not import the shared uview mixin. Its root view binds only `useRootHeightAndWidth` dimensions. Keep the Dart field and constructor parameter for compatibility, remove only the Flutter-only decoration wrapper, and protect that behavior with a `DecoratedBox` regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPQrcode` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-qrcode\u-qrcode.vue`.
- Preserve source-backed QR matrix generation, canvas behavior, callback aliases, colors, and root-size behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPQrcode Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_qrcode.dart:260-301`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPQrcode` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPQrcode({String cid = '', dynamic size = 200, bool show = true, String val = '', BoxDecoration? customStyle, ValueChanged<String>? onComplete, ValueChanged<dynamic>? onPreview, ValueChanged<dynamic>? onResult, ValueChanged<dynamic>? onLongpressCallback})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; matrix generation and canvas callback APIs remain unchanged.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPQrcode leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPQrcode(val: 'hello', customStyle: customStyle),
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

Run: `flutter test test/widgets_test.dart --name "UPQrcode leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because `UPQrcode` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify QR behavior**

Run:

```powershell
dart format lib/src/widgets/up_qrcode.dart test/widgets_test.dart
flutter test test/widgets_test.dart --name "UPQrcode (builds matrix|leaves source-inactive customStyle unrendered|BatchE makeCode/save/preview shells)" --reporter expanded
flutter analyze lib/src/widgets/up_qrcode.dart
```

Observed: all three focused tests pass. Static analysis reports only existing retained-source-alias warnings for `_clearCode` and `_saveCode`; this batch leaves those compatibility methods unchanged.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that `UPQrcode` retains `customStyle` for Flutter API compatibility but does not render it because `u-qrcode.vue` declares no shared mixin or root custom-style binding.

Observed: `flutter test --reporter expanded` passes all 631 tests and `git diff --check` passes.
