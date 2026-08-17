# UPCheckboxGroup Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPCheckboxGroup.customStyle` constructor compatibility without rendering a decoration absent from the source group template.

**Architecture:** The Vue checkbox-group inherits `customStyle` through the shared mixin but its root binds only the group class and placement BEM class; its local props and computed state never consume or forward the style. Flutter keeps the public field while returning only its inherited group scope and source-backed row or column layout.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCheckboxGroup` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-checkbox-group\u-checkbox-group.vue`.
- Preserve source-backed group layout, selection propagation, disabled state, callbacks, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Checkbox-Group Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_checkbox.dart` near `UPCheckboxGroup.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing checkbox tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCheckboxGroup({BoxDecoration? customStyle, List<Widget> children = const [], ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed checkbox children remain mounted.

- [x] **Step 1: Verify source prop consumption**

`u-checkbox-group.vue:1-6` binds only root classes, and neither its props, `parentData`, nor its BEM computation reads or forwards the inherited `customStyle`. This differs from `u-checkbox.vue`, whose per-item `checkboxStyle` explicitly merges its own `customStyle`.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPCheckboxGroup leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPCheckboxGroup(
          customStyle: customStyle,
          children: [
            UPCheckbox(name: 'source-checkbox', label: 'Source checkbox'),
          ],
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

Run: `flutter test test/widgets_test.dart --name "UPCheckboxGroup leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCheckboxGroup.build` wraps the source-backed group in `Container(decoration: customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return _UPCheckboxScope(group: this, child: content);
```

- [x] **Step 4: Verify focused checkbox behavior**

Run: `dart format lib/src/widgets/up_checkbox.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCheckbox(Group multi select|Group leaves source-inactive customStyle unrendered| Batch.*|.*aliases)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_checkbox.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five matching widget tests passed and `flutter analyze lib/src/widgets/up_checkbox.dart` reported no diagnostics.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCheckboxGroup` retains Flutter `customStyle` API compatibility without rendering it, because its source root never consumes the inherited prop while per-item `UPCheckbox.customStyle` remains source-active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records the batch.

Observed: `flutter test --reporter expanded` passed all 686 tests. The compatibility matrix records batch HK; `git diff --check` reported no whitespace errors.
