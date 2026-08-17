# UPNumberBox Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPNumberBox.customStyle` constructor compatibility without rendering a decoration absent from the source number-box template and local props.

**Architecture:** The source root contains the minus button, input, and plus button. Its local props define control and input styling but not `customStyle`; the only template custom style is the source-active `iconStyle` passed to internal icon widgets. Flutter keeps the optional root parameter but returns its source-backed row directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPNumberBox` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-number-box\u-number-box.vue` and `props.js`.
- Preserve source-backed buttons, input, disabled state, long press, icon style, callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Number-Box Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_number_box.dart` near `UPNumberBoxState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPNumberBox` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPNumberBox({dynamic value = 0, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed numeric controls remain mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPNumberBox leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPNumberBox(
          value: 2,
          min: 0,
          max: 5,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPNumberBox), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPNumberBox leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPNumberBoxState.build` wraps its source-backed controls in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return body;
```

- [x] **Step 4: Verify focused number-box behavior**

Run: `dart format lib/src/widgets/up_number_box.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPNumberBox (increases value|emits plus and detail payload|onUpdateValue and customStyle|public setValue plus minus init|BatchB check/emitChange/longPress|BatchH format/isDisabled/add|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_number_box.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all seven focused widget tests passed and `flutter analyze lib/src/widgets/up_number_box.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPNumberBox` retains Flutter `customStyle` API compatibility without rendering it, because its source root and local props never consume the prop while its separate internal `iconStyle` remains active.

Observed: `flutter test --reporter expanded` passed all 670 tests. `git diff --check` reported no whitespace errors.
