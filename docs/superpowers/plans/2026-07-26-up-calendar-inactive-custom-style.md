# UPCalendar Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCalendar.customStyle` constructor compatibility without rendering a decoration absent from the source calendar template.

**Architecture:** The source calendar template passes popup and calendar props to its internal nodes, with inline styling limited to the scroll/month container height. Its props definition contains no `customStyle` binding. Flutter should retain its public optional field while returning the existing `UPPopup` root directly, preserving both inline and popup calendar behavior.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCalendar` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-calendar\u-calendar.vue` and `props.js`.
- Preserve source-backed date selection, confirmation, range rules, navigation, popup behavior, inline rendering, and callback aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Calendar Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_calendar.dart` near `UPCalendarState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCalendar` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCalendar({bool show = false, bool pageInline = false, String mode = 'single', BoxDecoration? customStyle, ValueChanged<List<DateTime>>? onConfirm})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed inline calendar remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCalendar leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCalendar(
          show: true,
          pageInline: true,
          showConfirm: false,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPCalendar), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCalendar leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCalendarState.build` wraps its source-backed `UPPopup` root in `Container(decoration: widget.customStyle)`.

Observed: the inline-calendar regression found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused calendar behavior**

Run: `dart format lib/src/widgets/up_calendar.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCalendar (select and confirm|minDate disables earlier days|range select and confirm|public prev next today setSelected|BatchC getConfirmValue/monthSelected/close/init|BatchH subtitle/selectedChange|BatchI month/date helpers|BatchJ setMonth/time helpers|BatchK range helpers|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_calendar.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all ten focused widget tests passed. `flutter analyze lib/src/widgets/up_calendar.dart` retained one pre-existing unrelated warning at line 704: private `_innerFormatter` is written by the source alias `setFormatter` but never read. This batch does not modify that residual API shell.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCalendar` retains Flutter `customStyle` API compatibility without rendering it, because source style bindings target internal scroll/month containers rather than the calendar root.

Observed: `flutter test --reporter expanded` passed all 650 tests. `flutter analyze lib/src/widgets/up_calendar.dart` retains the pre-existing `_innerFormatter` warning documented in Step 4; `git diff --check` will be run after the documentation update.
