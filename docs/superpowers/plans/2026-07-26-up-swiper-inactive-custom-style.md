# UPSwiper Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the main `UPSwiper.customStyle` constructor API compatible without rendering a decoration that the source swiper template never binds.

**Architecture:** `u-swiper.vue` includes the shared mixin, which accepts `customStyle`, but its root binds only active `bgColor`, `height`, and `radius` properties. Flutter already renders those source-backed values in its clipped root container. Remove only the main `UPSwiper` outer custom-style wrapper; standalone `UPSwiperIndicator` is a separate component and remains outside this batch.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public main `UPSwiper` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-swiper\u-swiper.vue`.
- Preserve source-backed background, height, radius, loading, page, indicator, and event behavior.
- Do not alter `UPSwiperIndicator` in this task.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Main Swiper Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_swiper.dart` near `UPSwiperState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSwiper` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPSwiper({List<dynamic> list = const [], dynamic bgColor = '#f3f4f6', dynamic height = 130, dynamic radius = 4, BoxDecoration? customStyle})`.
- Produces: unchanged main constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed swiper content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPSwiper leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: SizedBox(
          height: 130,
          child: UPSwiper(
            autoplay: false,
            list: [{'url': ''}],
            customStyle: customStyle,
          ),
        ),
      ),
    ),
  );

  expect(find.byType(UPSwiper), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPSwiper leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because the main Flutter swiper wraps its source-backed clipped root in `Container(decoration: widget.customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only main swiper wrapper.

- [x] **Step 3: Delete only the main Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Do not change UPSwiperIndicator in this task.
// Remove only this final build branch:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}
```

- [x] **Step 4: Verify focused swiper behavior**

Run: `dart format lib/src/widgets/up_swiper.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPSwiper (indicator and click|loading state|leaves source-inactive customStyle unrendered|swipeTo next prev public API|public change clickHandler getSource|BatchE getItemType already public)|Batch BQ swiper circular pages and emits are source aligned" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_swiper.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed and `flutter analyze lib/src/widgets/up_swiper.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that the main `UPSwiper` retains shared `customStyle` for API compatibility but does not render it because the source root consumes only its background, height, and radius styling.

Observed: `flutter test --reporter expanded` passed all 639 tests. `git diff --check` completed with no whitespace errors.
