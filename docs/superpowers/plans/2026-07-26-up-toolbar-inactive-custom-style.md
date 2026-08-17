# UPToolbar Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPToolbar.customStyle` source-port API-compatible without rendering a decoration that the uview-plus toolbar template never consumes.

**Architecture:** `u-toolbar.vue` includes the shared mixin, so it accepts `customStyle`, but the root toolbar view binds only touch prevention and visibility. Its nested text nodes bind their own colors. Keep the Dart field and constructor parameter, remove only the Flutter-only decoration wrapper, and protect the behavior with a `DecoratedBox` regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPToolbar` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-toolbar\u-toolbar.vue`.
- Preserve source-backed visibility, cancel/confirm events, title, colors, and `rightSlot` behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPToolbar Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_toolbar.dart:42-104`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPToolbar` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPToolbar({bool show = true, String cancelText = '取消', String confirmText = '确认', String title = '', bool rightSlot = false, Widget? right, BoxDecoration? customStyle, VoidCallback? onCancel, VoidCallback? onConfirm})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; cancel/confirm and right-slot behaviors remain unchanged.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPToolbar leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(body: UPToolbar(customStyle: customStyle)),
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

Run: `flutter test test/widgets_test.dart --name "UPToolbar leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because `UPToolbar` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify toolbar behavior**

Run:

```powershell
dart format lib/src/widgets/up_toolbar.dart test/widgets_test.dart
flutter test test/widgets_test.dart --name "UPToolbar (confirm callback|rightSlot hides source default confirm without content|leaves source-inactive customStyle unrendered|BatchD cancel/confirm)" --reporter expanded
flutter analyze lib/src/widgets/up_toolbar.dart
```

Observed: all four focused tests and static analysis pass.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that `UPToolbar` retains the shared `customStyle` prop for API compatibility but does not render it because its source template never binds that prop.

Observed: `flutter test --reporter expanded` passes all 633 tests and `git diff --check` passes.
