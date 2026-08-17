# UPCascader Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `UPCascader.customStyle` constructor compatibility without rendering a decoration absent from the source cascader template.

**Architecture:** The source component declares its props inline and its root is `up-popup`. Template style bindings are limited to the cascading area transform, pane widths, and computed `levelPaneStyle`; neither the source props nor root consume `customStyle`. Flutter should retain the optional field but return the existing source-backed popup directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCascader` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-cascader\u-cascader.vue`.
- Preserve source-backed popup lifecycle, data levels, tab navigation, selection, auto-close, confirm/cancel callbacks, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Cascader Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_cascader.dart` near `UPCascaderState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCascader` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCascader({bool show = false, List data = const [], List value = const [], BoxDecoration? customStyle, ValueChanged<List>? onConfirm})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed level content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCascader leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCascader(
          show: true,
          data: [
            {'value': 'zhejiang', 'label': '浙江'},
          ],
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.text('浙江'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCascader leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCascaderState.build` wraps its source-backed `UPPopup` root in `Container(decoration: widget.customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused cascader behavior**

Run: `dart format lib/src/widgets/up_cascader.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCascader (builds with data|autoClose leaf|open confirm and setValue|public getSelectedValues/setDefaultValue/handleConfirm|BatchG initLevelList/emitChange/toFatherIndex|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_cascader.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all six focused widget tests passed and `flutter analyze lib/src/widgets/up_cascader.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCascader` retains Flutter `customStyle` API compatibility without rendering it, because source style bindings target only hierarchy panes and the root popup never consumes the prop.

Observed: `flutter test --reporter expanded` passed all 651 tests and `git diff --check` will be run after the documentation update.
