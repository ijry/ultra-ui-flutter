# UPPopup Custom Style Panel Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply `UPPopup.customStyle` to the source-equivalent content panel in both page-inline and overlay display modes.

**Architecture:** `u-popup.vue` computes `contentStyle` by merging `addStyle(customStyle)` with panel background, radii, safe-area, and sizing rules, then binds it directly to `.u-popup__content`. Flutter now decorates the panel subtree rather than the outer stack containing overlay and animations, which also makes page-inline behavior use the same custom-style path.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPPopup` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-popup\u-popup.vue`.
- Preserve source-backed overlay, animation, modes, sizing, safe-area, gesture, close controls, callbacks, and model aliases.
- Apply caller decoration to content, not to the outer overlay/animation tree.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Move Popup Style to the Content Panel

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_popup.dart` near `UPPopupState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing popup tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPPopup({bool show = false, bool pageInline = false, BoxDecoration? customStyle, ...})`.
- Produces: an identically decorated source content panel in page-inline and normal overlay modes.

- [x] **Step 1: Verify source style target and ordering**

`u-popup.vue:31-35` binds `contentStyle` to `.u-popup__content`. `contentStyle` at lines 188-213 derives background, radii, safe-area sizing, and then `deepMerge(style, addStyle(this.customStyle))`; it does not decorate the outer trigger, overlay, or transition stack.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPPopup applies customStyle to the source content panel',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPPopup(
          show: true,
          pageInline: true,
          customStyle: customStyle,
          child: Text('styled popup panel'),
        ),
      ),
    ),
  );

  final panel = find.byKey(const ValueKey('up-popup-panel'));
  expect(
    find.ancestor(
      of: panel,
      matching: find.byWidgetPredicate(
        (widget) => widget is DecoratedBox && widget.decoration == customStyle,
      ),
    ),
    findsOneWidget,
  );
});
```

Run: `flutter test test/widgets_test.dart --name "UPPopup applies customStyle to the source content panel" --reporter expanded`

Expected: FAIL because Flutter decorates only the non-inline outer tree and not the content panel.

Observed: the page-inline panel contained no matching `DecoratedBox`.

- [x] **Step 3: Decorate the shared panel subtree**

Wrap the `up-popup-panel` content subtree with `Container(decoration: widget.customStyle, ...)`, and remove the old decoration around the entire normal-mode lifecycle and overlay stack.

- [x] **Step 4: Verify focused popup behavior**

Run: `dart format lib/src/widgets/up_popup.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPPopup (shows child when open|.*customStyle.*|.*aliases|.*overlay.*|applies customStyle to the source content panel)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_popup.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: the focused popup tests passed. The visible-panel regression verifies
the merged background, border, source-derived radius, and transparent material
layer; `flutter analyze lib/src/widgets/up_popup.dart` reported no diagnostics.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPPopup.customStyle` is now attached to the source-equivalent content panel in both page-inline and normal modes.

Expected: full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records the batch.

Observed: the full suite passed all 689 tests before the final equivalent
explicit-decoration construction cleanup; the focused regression and component
analysis passed again afterward. The compatibility matrix records batch HR.
