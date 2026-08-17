# UPForm Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPForm.customStyle` constructor compatibility without rendering a root decoration absent from the source form template.

**Architecture:** `u-form.vue` inherits `customStyle` through the shared mixin but its root consists only of a `u-form` class and default slot; its local props and computed state never consume or forward it. Flutter retains the public field and returns its inherited form scope around the source-backed child column without adding a root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPForm` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-form\u-form.vue`.
- Preserve source-backed validation, rules, reset/clear methods, field coordination, labels, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Form Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_form.dart` near `UPFormState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPForm` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPForm({BoxDecoration? customStyle, required List<Widget> children, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed form children remain mounted.

- [x] **Step 1: Verify source prop consumption**

`u-form.vue:1-4` renders only the form root class and default slot. Although the shared mixin exposes `customStyle`, the local props, watchers, computed state, and form-item coordination never consume or forward it. `UPFormItem` is a separate component and has its own source style path.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPForm leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPForm(
          customStyle: customStyle,
          children: [SizedBox(height: 20)],
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

Run: `flutter test test/widgets_test.dart --name "UPForm leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPFormState.build` wraps the source-backed child column in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
child: Column(children: widget.children),
```

- [x] **Step 4: Verify focused form behavior**

Run: `dart format lib/src/widgets/up_form.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPForm( Item)?|Batch.*form|UPForm leaves source-inactive customStyle unrendered" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_form.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all twelve matching widget tests passed and `flutter analyze lib/src/widgets/up_form.dart` reported no diagnostics.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPForm` retains Flutter `customStyle` API compatibility without rendering it, because its source root never consumes the inherited prop while `UPFormItem` remains separately source-active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records the batch.

Observed: `flutter test --reporter expanded` passed all 687 tests. The compatibility matrix records batch HM; `git diff --check` reported no whitespace errors.
