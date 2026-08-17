# UPReadMore Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPReadMore.customStyle` constructor compatibility without rendering a decoration absent from the source read-more template and local props.

**Architecture:** The source root renders content and the optional toggle, with local props defining content measurement and toggle presentation. It never declares or binds `customStyle`; Flutter keeps the optional public parameter but returns the source-backed body without an extra root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPReadMore` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-read-more\u-read-more.vue` and `props.js`.
- Preserve source-backed content measurement, shadow style, expand/collapse behavior, callbacks, slots, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Read-More Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_read_more.dart` near `UPReadMoreState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPReadMore` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPReadMore({dynamic showHeight = 400, BoxDecoration? customStyle, required Widget child, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed content remains mounted.

- [x] **Step 1: Write the failing widget regression**

```dart
testWidgets('UPReadMore leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPReadMore(
          customStyle: customStyle,
          child: Text('内容'),
        ),
      ),
    ),
  );

  expect(find.text('内容'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPReadMore leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPReadMoreState.build` wraps its source-backed body in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return body;
```

- [x] **Step 4: Verify focused read-more behavior**

Run: `dart format lib/src/widgets/up_read_more.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPReadMore (shows toggle for long content|leaves source-inactive customStyle unrendered|toggle open/close events|measures keyed content without duplicating it|shadow does not add layout height before toggle|open close public API|BatchB toggleReadMore|BatchF init/getContentHeight)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_read_more.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all eight focused widget tests passed and `flutter analyze lib/src/widgets/up_read_more.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPReadMore` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source-backed measurement and toggle behavior remain active.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records batch GP.

Observed: `flutter test --reporter expanded` passed all 675 tests and `git diff --check` reported no whitespace errors. The compatibility matrix records batch GP.
