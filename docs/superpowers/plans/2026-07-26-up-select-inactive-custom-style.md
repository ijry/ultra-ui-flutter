# UPSelect Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPSelect.customStyle` constructor compatibility without rendering a decoration absent from the source select template and inline props.

**Architecture:** The source root renders a select trigger, an optional source-active overlay using `overlayStyle`, and the options panel. Its inline props never declare `customStyle`; Flutter keeps the optional public parameter but returns the source-backed trigger without an extra root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSelect` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-select\u-select.vue`.
- Preserve source-backed overlay style, trigger and panel positioning, options, selection callbacks, disabled state, slots, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Select Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_select.dart` near `UPSelectState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSelect` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPSelect({List options = const [], BoxDecoration? customStyle, Map overlayStyle = const {}, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed select trigger remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPSelect leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPSelect(
          label: '城市',
          options: [
            {'id': 1, 'name': '北京'},
          ],
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('城市'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPSelect leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPSelectState.build` wraps its source-backed trigger in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return body;
```

- [x] **Step 4: Verify focused select behavior**

Run: `dart format lib/src/widgets/up_select.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPSelect (opens options|leaves source-inactive customStyle unrendered|selects option and closes|disabled does not open|uses an anchored page overlay outside clipped parents|public open close toggle|BatchB overlayClick/selectItem|BatchH resolved styles/open)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_select.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all eight focused widget tests passed and `flutter analyze lib/src/widgets/up_select.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPSelect` retains Flutter `customStyle` API compatibility without rendering it, because its source root and inline props never consume the prop while source-backed select and `overlayStyle` behavior remain active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GR.

Observed: `flutter test --reporter expanded` passed all 677 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GR.
