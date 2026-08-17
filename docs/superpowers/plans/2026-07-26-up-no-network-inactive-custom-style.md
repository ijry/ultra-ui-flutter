# UPNoNetwork Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPNoNetwork.customStyle` constructor compatibility without rendering a decoration absent from the source no-network component's public props and root template.

**Architecture:** The source passes a fixed internal style to `u-overlay` for its white centered offline panel. Its local props do not declare public `customStyle`; Flutter retains the optional parameter but returns the source-backed white overlay and retry content directly.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPNoNetwork` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-no-network\u-no-network.vue` and `props.js`.
- Preserve source-backed white overlay, image, tips, retry button, connectivity callbacks, and public controls.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align No-Network Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_no_network.dart` near `UPNoNetworkState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPNoNetwork` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPNoNetwork({bool show = true, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed offline tips remain mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPNoNetwork leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPNoNetwork(show: true, customStyle: customStyle),
      ),
    ),
  );

  await tester.pump();
  expect(find.text('哎呀，网络信号丢失'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPNoNetwork leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPNoNetworkState.build` wraps its source-backed offline stack in `Container(decoration: widget.customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return root;
```

- [x] **Step 4: Verify focused no-network behavior**

Run: `dart format lib/src/widgets/up_no_network.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPNoNetwork (retry and disconnect callback|show hide public API|public settings aliases|BatchD show/hide/emitEvent|leaves source-inactive customStyle unrendered)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_no_network.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_no_network.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPNoNetwork` retains Flutter `customStyle` API compatibility without rendering it, because the source passes only an internal literal style to `u-overlay` and its local props never declare the public prop.

Observed: `flutter test --reporter expanded` passed all 669 tests. `git diff --check` reported no whitespace errors.
