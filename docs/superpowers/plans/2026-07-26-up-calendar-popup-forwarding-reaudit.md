# UPCalendar Popup Forwarding Re-Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve the source calendar's explicit `u-popup` chrome and overlay forwarding in Flutter.

**Architecture:** `u-calendar.vue` renders an unstyled calendar body inside `u-popup`, forwarding `overlayStyle`, `safeAreaInsetTop`, `safeAreaInsetBottom`, popup timing/opacity/z-index, and `closeable="!pageInline"`. Flutter builds the same calendar body through `UPPopup`; its shared `customStyle` remains inert because the source root does not bind it. This change only restores the missing explicit popup arguments.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCalendar` and `UPPopup` APIs and the `UP` component prefix.
- Keep `UPCalendar.customStyle` source-inactive and unrendered.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-calendar\u-calendar.vue`.
- Do not commit, reset, clean, or revert existing workspace changes.

---

### Task 1: Forward Calendar Popup Chrome

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_calendar.dart:UPCalendarState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

**Interfaces:**
- Consumes: `UPCalendar({dynamic overlayStyle, bool safeAreaInsetTop = false, bool pageInline = false, ...})`.
- Produces: a nested `UPPopup` that receives the source overlay style, top safe-area flag, and non-inline close affordance.

- [x] **Step 1: Compare source popup forwarding**

The first `u-popup` in `u-calendar.vue` explicitly receives `overlayStyle`, `safeAreaInsetTop`, `safeAreaInsetBottom`, `closeable="!pageInline"`, and the other source popup props. Flutter's `UPCalendarState.build` already forwarded the common values but omitted those three explicit properties.

- [x] **Step 2: Add and run failing regressions**

```dart
testWidgets('UPCalendar forwards overlayStyle to its source popup mask',
    (tester) async {
  const gradient = LinearGradient(
    colors: [Color(0xff123456), Color(0xff654321)],
  );
  const overlayStyle = BoxDecoration(gradient: gradient);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPCalendar(show: true, monthNum: 1, overlayStyle: overlayStyle),
      ),
    ),
  );

  final mask = find.byKey(const ValueKey('up-overlay-mask'));
  final decoration = tester.widget<DecoratedBox>(mask).decoration
      as BoxDecoration;
  expect(decoration.gradient, gradient);
});
```

```dart
testWidgets('UPCalendar forwards source popup chrome props',
    (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPCalendar(show: true, monthNum: 1, safeAreaInsetTop: true),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (widget) => widget is UPIcon && widget.name == 'close',
    ),
    findsOneWidget,
  );
});
```

Run: `flutter test test/widgets_test.dart --name "UPCalendar (forwards overlayStyle to its source popup mask|forwards source popup chrome props)" --reporter expanded`

Observed before the change: the mask gradient was `null`, and the normal calendar popup had no close icon. These failures identify missing values at the `UPCalendar -> UPPopup` boundary.

- [x] **Step 3: Apply the minimal forwarding change**

Pass these source-equivalent arguments to the existing `UPPopup` constructor:

```dart
overlayStyle: widget.overlayStyle,
safeAreaInsetTop: widget.safeAreaInsetTop,
closeable: !widget.pageInline,
```

- [x] **Step 4: Verify focused Calendar behavior**

Run: `flutter test test/widgets_test.dart --name "UPCalendar (forwards overlayStyle to its source popup mask|forwards source popup chrome props|select and confirm|leaves source-inactive customStyle unrendered|BatchC getConfirmValue/monthSelected/close/init|BatchH subtitle/selectedChange|BatchI month/date helpers|BatchJ setMonth/time helpers|BatchK range helpers)" --reporter expanded`

Result: 9 passed.

Run: `flutter analyze lib/src/widgets/up_calendar.dart`

Result: it reports only the previously documented `_innerFormatter` unused-field warning at line 704; no diagnostic was introduced by this change.

- [x] **Step 5: Verify suite and record parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Update `docs/gap-matrix.md` with the actual full-suite count and the source popup-forwarding conclusion.

Result: `flutter test --reporter expanded` passed 744 tests. `git diff --check` completed without whitespace errors.

## Plan Self-Review

- Source coverage: explicit Calendar-to-Popup forwarding and deliberately inactive calendar `customStyle` are covered independently.
- Placeholder scan: all behavioral changes, commands, and verification results are explicit.
- Type consistency: `overlayStyle` remains dynamic at the Calendar API and is consumed by the already supported Popup overlay bridge; the safety and inline flags remain booleans.
