# UPCanvas Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the Flutter `UPCanvas.customStyle` constructor API compatible without rendering a decoration absent from the source canvas template.

**Architecture:** `u-canvas.vue` declares its own canvas props and binds its root solely to the active calculated width and height. It has neither a shared mixin nor a `customStyle` prop. Flutter already renders the source-backed dimensions, pointer handlers, repaint boundary, and `bgColor` paint surface. Remove only its added outer decoration wrapper.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCanvas` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-canvas\u-canvas.vue`.
- Preserve dimensions, background paint, pointer callbacks, controller, drawing, repaint-boundary, and export behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Canvas Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_canvas.dart` near `UPCanvasState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCanvas` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPCanvas({dynamic width = 300, dynamic height = 300, String bgColor = '#ffffff', BoxDecoration? customStyle, UPCanvasController? controller})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed canvas surface remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPCanvas leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCanvas(
          width: 120,
          height: 80,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(find.byType(UPCanvas), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPCanvas leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPCanvasState.build` wraps its source-backed listener and repaint boundary in `Container(decoration: widget.customStyle)`.

Observed: the test found one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only canvas wrapper after the canvas surface mounted.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}
```

- [x] **Step 4: Verify focused canvas behavior**

Run: `dart format lib/src/widgets/up_canvas.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPCanvas (builds surface|leaves source-inactive customStyle unrendered|draw path and measureText|linear gradient fillRect|drawImage from putImage|public clear refresh via State|BatchG getWidth/callContext|BatchI export/touch shells)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_canvas.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: the eight canvas-focused widget tests passed, but analysis initially reported five pre-existing deprecated `Color.opacity/red/green/blue` accesses in the untouched `rgba` helper. Those accesses were migrated equivalently to normalized `.a/.r/.g/.b` channels and validated by the existing helper tests; the expanded eleven-test focused run passed and `flutter analyze lib/src/widgets/up_canvas.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPCanvas` retains its Flutter `customStyle` constructor parameter for compatibility but does not render it because the source component declares and consumes no such prop.

Observed: `flutter test --reporter expanded` passed all 643 tests. `git diff --check` completed with no whitespace errors.
