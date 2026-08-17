# UPCityLocate Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCityLocate.customStyle` constructor compatibility without rendering a decoration absent from the source city-locate template.

**Architecture:** The source root is an unstyled `u-city-locate` view whose child is `up-index-list`. Its inline props declare city data and location settings only, and the template never binds `customStyle`. Flutter should retain its optional field while returning the source-backed index-list root directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCityLocate` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-city-locate\u-city-locate.vue`.
- Preserve source-backed city selection, current-city updates, location success/failure handling, index list content, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align City-Locate Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_city_locate.dart` near `UPCityLocateState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCityLocate` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCityLocate({List indexList, List cityList, bool autoLocate = true, BoxDecoration? customStyle, ValueChanged<Map>? onSelectCity})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed city content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCityLocate leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: SizedBox(
          height: 300,
          child: UPCityLocate(
            autoLocate: false,
            customStyle: customStyle,
          ),
        ),
      ),
    ),
  );

  expect(find.text('北京'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCityLocate leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCityLocateState.build` wraps its source-backed `UPIndexList` root in `Container(decoration: widget.customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused city-locate behavior**

Run: `dart format lib/src/widgets/up_city_locate.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCityLocate (selects city|location handler and fail path|public setCurrentCity location|leaves source-inactive customStyle)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_city_locate.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all four focused widget tests passed and `flutter analyze lib/src/widgets/up_city_locate.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCityLocate` retains Flutter `customStyle` API compatibility without rendering it, because the source root and props never consume the prop.

Observed: `flutter test --reporter expanded` passed all 653 tests. `git diff --check` completed with no whitespace errors.
