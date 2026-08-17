# UPCopy Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the Flutter `UPCopy.customStyle` parameter API-compatible without rendering a decoration absent from the uview-plus source component.

**Architecture:** `u-copy.vue` declares only `content`, `alertStyle`, and `notice`, and its root `<view>` binds only the click handler. Preserve the Flutter field and constructor argument, remove its decoration wrapper, and use a widget test that identifies the exact `BoxDecoration` instance.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPCopy` constructor compatibility and existing copy interactions.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-copy\u-copy.vue`.
- Use `apply_patch` for manual file changes; do not edit unrelated workspace files.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPCopy Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_copy.dart:80-90`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCopy` tests
- Modify: `docs/gap-matrix.md` append the validated compatibility record

**Interfaces:**
- Consumes: `const UPCopy({dynamic content = '', String alertStyle = 'toast', String notice = '复制成功', VoidCallback? onSuccess, Widget? child, BoxDecoration? customStyle})`.
- Produces: the same constructor API; a supplied `customStyle` does not create a matching `DecoratedBox`; `handleClick` behavior remains unchanged.

- [ ] **Step 1: Write the failing widget test**

```dart
testWidgets('UPCopy leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCopy(content: 'copy', customStyle: customStyle),
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

Run: `flutter test test/widgets_test.dart --plain-name "UPCopy leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: fail because `UPCopy` wraps its gesture detector in `Container(decoration: customStyle)`.

- [ ] **Step 3: Remove only the non-source decoration branch**

```dart
// Retain the customStyle field and constructor parameter.
// Remove only this branch from build:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [ ] **Step 4: Verify focused and complete behavior**

Run:

```powershell
dart format lib/src/widgets/up_copy.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_copy.dart
flutter test test/widgets_test.dart --plain-name "UPCopy leaves source-inactive customStyle unrendered" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPCopy renders child" --reporter expanded
flutter test --reporter expanded
```

Expected: all commands pass; copy action behavior is unaffected because the `GestureDetector` remains the root render path.

- [ ] **Step 5: Document the source parity**

Append a dated `docs/gap-matrix.md` entry explaining that `UPCopy` keeps the Flutter `customStyle` parameter but does not render it because `u-copy.vue` declares no global mixin and does not merge that style.

