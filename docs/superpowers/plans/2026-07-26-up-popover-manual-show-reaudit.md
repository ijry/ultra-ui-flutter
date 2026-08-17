# UPPopover Manual Show Re-Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align `UPPopover.show` initialization with the source contract so it controls visibility only when `triggerMode` is `manual`.

**Architecture:** `u-popover.vue` is a thin wrapper over `up-tooltip`, forwarding presentation and trigger props while exposing `open` and `close`. The tooltip source watcher applies `show` only when `triggerMode === 'manual'`; click and long-press modes open through source gesture handlers. Flutter retains the wrapper-owned visibility state, initializes it from `show` only for manual mode, and leaves later manual-mode updates routed through the existing `didUpdateWidget` branch.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPPopover` constructor, `UPPopoverState` APIs, and `UP` component prefix.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-popover\u-popover.vue` and its delegated `u-tooltip.vue` behavior.
- Keep source-inactive `UPPopover.customStyle` and `onUpdateShow` inert.
- Do not commit, reset, clean, or revert existing workspace changes.

---

### Task 1: Restrict Initial `show` to Manual Mode

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_popover.dart:UPPopoverState.initState`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

**Interfaces:**
- Consumes: `UPPopover({bool show = false, String triggerMode = 'click', Widget? trigger, Widget? content, ...})`.
- Produces: initial visibility controlled by `show` only when `triggerMode == 'manual'`; click and long-press retain gesture-driven opening.

- [x] **Step 1: Compare the delegated source visibility flow**

`u-popover.vue` forwards `show` and `triggerMode` to `up-tooltip`. `u-tooltip.vue` watches `show`, but calls `open` or `close` only inside `if (this.triggerMode === 'manual')`; click and long-press use their respective handlers. The Popover root itself has no `customStyle` binding, while its trigger/content slots are forwarded to Tooltip.

- [x] **Step 2: Write the failing behavior regression**

```dart
testWidgets('UPPopover ignores show outside manual trigger mode',
    (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPPopover(
          show: true,
          triggerMode: 'click',
          trigger: Text('click-controlled trigger'),
          content: Text('click-controlled content'),
        ),
      ),
    ),
  );

  expect(find.text('click-controlled trigger'), findsOneWidget);
  expect(find.text('click-controlled content'), findsNothing);
});
```

Run: `flutter test test/widgets_test.dart --name "UPPopover ignores show outside manual trigger mode" --reporter expanded`

Observed before the change: FAIL, because the content was present immediately. The failure established that `initState` applied `show` before checking the source's manual-mode condition.

- [x] **Step 3: Apply the minimal initialization correction**

Set initial state with:

```dart
visible = widget.triggerMode == 'manual' && widget.show;
```

Leave `didUpdateWidget` unchanged because it already conditions external `show` changes on manual mode.

- [x] **Step 4: Verify source-adjacent behavior**

Run: `flutter test test/widgets_test.dart --name "UPPopover (ignores show outside manual trigger mode|content opens on click|manual show is controlled|manual trigger does not open|open close toggle public API|keeps source customStyle and update:show inactive)" --reporter expanded`

Result: 6 passed.

Run: `flutter analyze lib/src/widgets/up_popover.dart`

Result: no issues.

- [x] **Step 5: Verify suite and record parity**

Run: `flutter test --reporter expanded`

Result: 742 passed.

Run: `git diff --check`

Expected: no whitespace errors.

## Plan Self-Review

- Source coverage: the plan covers the Popover-to-Tooltip visibility data flow, manual-only condition, click/long-press preservation, and the existing inactive wrapper API paths.
- Placeholder scan: no placeholders or deferred implementation steps remain.
- Type consistency: `show` remains `bool`, `triggerMode` remains `String`, and the existing `visible` state remains the only visibility field.
