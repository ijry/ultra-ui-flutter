# UPMarkdown Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPMarkdown.customStyle` constructor compatibility without rendering a style absent from the source markdown component API and template.

**Architecture:** `up-markdown.vue` declares only markdown-specific props and renders a classed root containing `up-parse`; it neither imports the shared mixin nor declares or binds `customStyle`. Flutter retains its public compatibility field but returns the source-backed parse widget directly without an extra root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPMarkdown` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-markdown\u-markdown.vue`.
- Preserve source-backed Markdown parsing, theme, code blocks, parse forwarding, and load/ready/image/link/play/error callbacks.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Markdown Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_markdown.dart` near `UPMarkdown.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing Markdown tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPMarkdown({String content = '', BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed parse content remains mounted.

- [x] **Step 1: Verify source prop consumption**

`up-markdown.vue` declares only `content`, `previewImg`, `copyLink`, `domain`, `showLineNumber`, and `theme`. It does not include the shared mixin, does not declare `customStyle`, and its classed root has no style binding.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPMarkdown leaves undeclared source customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPMarkdown(
          content: 'source markdown',
          customStyle: customStyle,
        ),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

Run: `flutter test test/widgets_test.dart --name "UPMarkdown leaves undeclared source customStyle unrendered" --reporter expanded`

Expected: FAIL because Flutter wrapped the source-backed parse root in `Container(decoration: customStyle)`.

Observed: the regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
return UPParse(...);
```

- [x] **Step 4: Verify focused Markdown behavior**

Run: `dart format lib/src/widgets/up_markdown.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPMarkdown|UPParse|Markdown leaves undeclared source customStyle unrendered" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_markdown.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all thirteen matching widget tests passed. `flutter analyze lib/src/widgets/up_markdown.dart` reports one existing `unused_local_variable` warning for `cells`, unrelated to the removed root decoration and left unchanged to keep this parity change narrowly scoped.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPMarkdown` retains Flutter `customStyle` API compatibility without rendering it because the source does not declare or consume it.

Expected: the full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records the batch.

Observed: `flutter test --reporter expanded` passed all 688 tests. The compatibility matrix records batch HP; `git diff --check` reported no whitespace errors.
