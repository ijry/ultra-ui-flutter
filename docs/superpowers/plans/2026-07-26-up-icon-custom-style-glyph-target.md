# UPIcon Custom Style Glyph Target Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep UPIcon `customStyle` source-active while applying it only to the source-equivalent icon glyph or image node.

**Architecture:** In `u-icon.vue`, `addStyle(customStyle)` is present only on the image and font-icon text nodes. The label is a sibling under `.u-icon` and must remain outside that style target. Flutter decorates `iconChild` before building the label Row/Column, preserving gesture handling and label layout outside the decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve UPIcon public constructor, callbacks, glyph/image selection, labels, and layout modes.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-icon\u-icon.vue`.
- Keep source-active `customStyle`; do not remove the public field.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Source Style Target

**Files:**
- Inspect: `components\u-icon\u-icon.vue`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_icon.dart`

- [x] **Step 1: Identify glyph/image-only bindings**

The Vue image branch uses `[imgStyle, addStyle(customStyle)]` and the font
glyph branch uses `[iconStyle, addStyle(customStyle)]`. The optional label
text is a sibling node without the caller style binding.

### Task 2: Move the Flutter Decoration to the Glyph

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_icon.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Write and confirm the node-target regression**

Mount an icon with a label and a unique decoration. Assert that the decoration
exists but the label is not its descendant.

Run: `flutter test test/widgets_test.dart --name "UPIcon applies customStyle to the source glyph, not its label" --reporter expanded`

Observed before implementation: the label descended from the Flutter-only
outer decorated container.

- [x] **Step 2: Decorate iconChild before label composition**

Wrap only `iconChild` in `DecoratedBox` when `customStyle` is non-null, then
delete the outer root decoration branch. Keep the gesture and translated
Row/Column container unchanged.

- [x] **Step 3: Run focused verification**

Run: `dart format lib/src/widgets/up_icon.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPIcon (builds font glyph|applies customStyle to the source glyph, not its label)|UPCheckbox.*customStyle|Batch HL" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_icon.dart`

Observed: four focused tests passed and analysis reported no diagnostics.

- [x] **Step 4: Run complete validation and record the result**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append the dated compatibility matrix entry for this batch.

Completed: the full suite passed all 707 tests and `git diff --check`
reported no whitespace errors.
