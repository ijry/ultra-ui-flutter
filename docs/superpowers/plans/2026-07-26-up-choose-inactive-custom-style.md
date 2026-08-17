# UPChoose Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPChoose.customStyle` source-port API-compatible without rendering a decoration that the uview-plus choose template never consumes.

**Architecture:** `u-choose.vue` explicitly declares its choose props and has no shared mixin. Its root `scroll-view` binds only horizontal-scroll state and source layout classes. Keep the Dart field and constructor parameter, remove only the Flutter-only decoration wrapper, and pin the behavior with a `DecoratedBox` regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPChoose` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-choose\u-choose.vue`.
- Preserve source-backed options, modelValue, customClick, item layout, wrap, and callback behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPChoose Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_choose.dart:132-143`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPChoose` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `const UPChoose({List options = const [], dynamic value, dynamic modelValue, String type = 'radio', dynamic itemWidth = 'auto', dynamic itemHeight = '50px', dynamic itemPadding = '8px', String labelName = 'title', String valueName = 'value', bool customClick = false, bool wrap = true, BoxDecoration? customStyle, ValueChanged<dynamic>? onUpdateModelValue})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; `change`, `customClick`, and model update behavior remain unchanged.

- [ ] **Step 1: Add the failing widget test**

```dart
testWidgets('UPChoose leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPChoose(
          options: ['甲'],
          customStyle: customStyle,
        ),
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

- [ ] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --plain-name "UPChoose leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: failure because `UPChoose` currently wraps the wrap/scroll root in `Container(decoration: customStyle)`.

- [ ] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [ ] **Step 4: Verify selection and layout behavior**

Run:

```powershell
dart format lib/src/widgets/up_choose.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_choose.dart
flutter test test/widgets_test.dart --plain-name "UPChoose leaves source-inactive customStyle unrendered" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPChoose changes index" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPChoose customClick and modelValue alias" --reporter expanded
flutter test --reporter expanded
```

Expected: all commands pass; only unsupported outer styling disappears.

- [ ] **Step 5: Record source parity**

Append a dated `docs/gap-matrix.md` entry noting that `UPChoose` retains `customStyle` for Flutter API compatibility but does not render it because `u-choose.vue` declares no shared mixin or `customStyle` template binding.

