# UPGuide Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPGuide.customStyle` constructor compatibility without rendering a decoration absent from the source guide template.

**Architecture:** The source conditionally renders an `up-guide` root with a source-active `zIndex` binding. Its local props provide list, once persistence, labels, `bgColor`, and `zIndex`, but not `customStyle`. Flutter retains the optional parameter but returns the source-backed guide page directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPGuide` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-guide\u-guide.vue` and `props.js`.
- Preserve source-backed z-index, page content, navigation, once persistence, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Guide Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_guide.dart` near `UPGuideState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPGuide` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPGuide({bool show = false, List list = const [], bool once = true, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed guide content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPGuide leaves source-inactive customStyle unrendered',
    (tester) async {
  UPGuide.clearRemembered();
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPGuide(
          show: true,
          once: false,
          customStyle: customStyle,
          list: [
            {'title': '欢迎', 'desc': '第一页'},
          ],
        ),
      ),
    ),
  );

  expect(find.text('欢迎'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPGuide leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPGuideState.build` wraps its source-backed guide page in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return page;
```

- [x] **Step 4: Verify focused guide behavior**

Run: `dart format lib/src/widgets/up_guide.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPGuide (shows first page|leaves source-inactive customStyle unrendered|reset clears resolved persisted storage key|once remembers key|open close reset public API|public bootstrap onSkip isLastPage)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_guide.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_guide.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPGuide` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while source `zIndex` rendering remains active.

Observed: `flutter test --reporter expanded` passed all 663 tests. `git diff --check` reported no whitespace errors.
