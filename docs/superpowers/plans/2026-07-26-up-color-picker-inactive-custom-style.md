# UPColorPicker Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPColorPicker.customStyle` constructor compatibility without rendering a decoration absent from the source color-picker template.

**Architecture:** The source root is an unstyled `up-color-picker` view containing a color trigger and `up-popup`. Its inline style bindings cover the trigger, gradients, color controls, and preview elements; its only inline `props` block omits `customStyle`. Flutter retains the optional parameter but returns the source-backed overlay root unchanged.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPColorPicker` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-color-picker\u-color-picker.vue`.
- Preserve source-backed popup lifecycle, color selection, gradients, callbacks, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Color-Picker Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_color_picker.dart` near `UPColorPickerState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPColorPicker` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPColorPicker({String modelValue = '#ff0000', bool show = false, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed popup content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPColorPicker leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPColorPicker(show: true, customStyle: customStyle),
      ),
    ),
  );

  expect(find.text('选择颜色'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPColorPicker leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPColorPickerState.build` wraps its source-backed overlay root in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused color-picker behavior**

Run: `dart format lib/src/widgets/up_color_picker.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPColorPicker (shows hex|leaves source-inactive customStyle unrendered|gradient mode emits css|setSV and setHue public API|public open close setValue gradient)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_color_picker.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed. `flutter analyze lib/src/widgets/up_color_picker.dart` reports only three pre-existing `deprecated_member_use` infos at lines 531-533 for `Color.red`, `Color.green`, and `Color.blue`; no diagnostics are caused by this wrapper removal.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPColorPicker` retains Flutter `customStyle` API compatibility without rendering it, because its source root and props never consume the prop.

Observed: `flutter test --reporter expanded` passed all 655 tests. `git diff --check` completed with no whitespace errors.
