# UPCalendarStrip Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCalendarStrip.customStyle` constructor compatibility without rendering a decoration absent from the source calendar-strip template.

**Architecture:** The source root `u-calendar-strip` uses its component CSS for background, radius, and margins. Its Vue template dynamically styles only date cells through `dayStyle(item)`, and its props definition contains no `customStyle`. Flutter should retain its field but return the existing collapsed/expanded calendar structures without an additional outer decoration wrapper.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCalendarStrip` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-calendar-strip\u-calendar-strip.vue` and `props.js`.
- Preserve source-backed date selection, month navigation, range handling, full-calendar expansion, gestures, and callback aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Calendar-Strip Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_calendar_strip.dart` near `UPCalendarStripState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCalendarStrip` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCalendarStrip({dynamic value, bool fullCalendar = false, BoxDecoration? customStyle, ValueChanged<DateTime>? onChange})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed collapsed calendar remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCalendarStrip leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCalendarStrip(
          value: '2026-07-01',
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPCalendarStrip), findsOneWidget);
  expect(find.text('1'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCalendarStrip leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCalendarStripState.build` wraps either calendar root branch in `Container(decoration: widget.customStyle)`.

Observed: the collapsed-calendar regression found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused calendar-strip behavior**

Run: `dart format lib/src/widgets/up_calendar_strip.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCalendarStrip (selects day|month switch and expand|public setSelectedDate/setFullVisible/getWeekLabel|BatchG getDateId/dayStyle/scrollToDate|BatchI enabled/touch helpers|BatchK range helpers|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_calendar_strip.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed and `flutter analyze lib/src/widgets/up_calendar_strip.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCalendarStrip` retains Flutter `customStyle` API compatibility without rendering it, because source styles only date cells and the root never consumes the prop.

Observed: `flutter test --reporter expanded` passed all 649 tests and `git diff --check` will be run after the documentation update.
