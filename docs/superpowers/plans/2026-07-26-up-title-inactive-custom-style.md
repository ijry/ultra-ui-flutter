# UPTitle Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `UPTitle` retain its Flutter `customStyle` API parameter without rendering a decoration absent from the uview-plus source template.

**Architecture:** `u-title.vue` defines neither component props nor the global uview mixin, and its root `<view>` never merges `customStyle`. Preserve the Flutter constructor field for source-port API stability, remove only the wrapping decoration, and prove the absence of that node with a widget test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve `UP` component names and public Flutter constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-title\u-title.vue` template behavior.
- Use `apply_patch` for manual edits and do not alter unrelated untracked workspace files.
- Do not commit, reset, clean, or revert workspace changes.

---

### Task 1: Align UPTitle Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_title.dart:20-54`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTitle` tests
- Modify: `docs/gap-matrix.md` append the verified batch record

**Interfaces:**
- Consumes: `const UPTitle({Widget? prefix, Widget? child, String text = '', BoxDecoration? customStyle})`.
- Produces: unchanged constructor API; `customStyle` does not create a `DecoratedBox` in the rendered tree.

- [ ] **Step 1: Write the failing widget test**

```dart
testWidgets('UPTitle leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPTitle(text: '标题', customStyle: customStyle),
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

- [ ] **Step 2: Run the test and verify the current implementation fails**

Run: `flutter test test/widgets_test.dart --plain-name "UPTitle leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: fail because `UPTitle` currently wraps its row in `Container(decoration: customStyle)`.

- [ ] **Step 3: Remove the non-source decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this rendering branch:
if (customStyle != null) {
  body = Container(decoration: customStyle, child: body);
}
```

- [ ] **Step 4: Verify the focused and full suites**

Run:

```powershell
dart format lib/src/widgets/up_title.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_title.dart
flutter test test/widgets_test.dart --plain-name "UPTitle leaves source-inactive customStyle unrendered" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPTitle renders text" --reporter expanded
flutter test --reporter expanded
```

Expected: all commands succeed; the existing title slot and intrinsic-width tests remain green.

- [ ] **Step 5: Document the verified source parity**

Append to `docs/gap-matrix.md` a dated batch record explaining that `UPTitle.customStyle` remains a Flutter API compatibility parameter but is inert because `u-title.vue` neither declares the global mixin nor merges that style.

