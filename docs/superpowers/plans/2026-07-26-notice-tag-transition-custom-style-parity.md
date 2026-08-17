# Notice, Tag, and Transition Custom Style Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove Flutter-only `customStyle` rendering from independent notice and tag components, and apply UPTransition custom styles inside the source-equivalent animated root.

**Architecture:** `u-row-notice.vue`, `u-column-notice.vue`, and `u-tag.vue` either declare no local custom style prop or do not bind the inherited shared prop; Flutter retains API fields but must not render them. `u-transition.vue` merges `customStyle` with its runtime `viewStyle` on the same animated root, so Flutter decorates the child before applying animated opacity, translation, and scale.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve all public constructors and `customStyle` fields.
- Match source components under `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components`.
- Preserve notice interactions, tag colors and callbacks, transition modes and lifecycle callbacks.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Independent Source Style Consumers

**Files:**
- Inspect: `components\u-row-notice\u-row-notice.vue` and `props.js`
- Inspect: `components\u-column-notice\u-column-notice.vue` and `props.js`
- Inspect: `components\u-tag\u-tag.vue`
- Inspect: `components\u-transition\u-transition.vue` and `transitionMixin.js`

- [x] **Step 1: Identify source-inactive notice and tag fields**

Both notice templates render their internal content, text, icons, and
animation styles without `customStyle`; their local props objects do not
declare it. `u-tag.vue` binds its computed `style`, which contains only
explicit color, height, padding, radius, and auto-background inputs, and
never merges the shared mixin's `customStyle`.

- [x] **Step 2: Identify the UPTransition style target**

`u-transition.vue` applies `mergeStyle` to its root. `mergeStyle` spreads
`addStyle(customStyle)` before runtime `viewStyle`, so caller decoration is
part of the same node that receives fade, slide, zoom, and timing state.

### Task 2: Add Failing Render Regressions

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`

- [x] **Step 1: Cover source-inactive styles**

Mount `UPRowNotice`, `UPColumnNotice`, and `UPTag` with unique decorations
and assert the caller colors/decorations are absent from the render tree.

Observed before implementation: notice widgets produced matching root
`DecoratedBox` wrappers. UPTag merged the caller color with its source border
and radius, so the regression checks the uniquely supplied color rather than
the complete decoration identity.

- [x] **Step 2: Cover the animated style node**

Mount a hidden `fade-up` `UPTransition` with `customStyle` and assert the
matching style node is a descendant of both `AnimatedSlide` and
`AnimatedOpacity`.

Observed before implementation: the style node was outside `AnimatedSlide`.

### Task 3: Implement Minimal Source-Compatible Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_notice_bar.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_tag.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_transition.dart`

- [x] **Step 1: Remove notice-only wrappers**

Remove only `UPRowNotice` and `UPColumnNotice` root decoration wrappers;
leave `UPNoticeBar`, constructors, fields, scrolling, callbacks, and icons
unchanged.

- [x] **Step 2: Restore source-derived UPTag decoration**

Build the tag decoration only from source-driven tag values: resolved
background color, radius, and border. Preserve direct source props such as
`bgColor`, `color`, `borderColor`, `height`, and `padding`.

- [x] **Step 3: Decorate inside UPTransition animation**

Wrap the transition content in `DecoratedBox` before mode-specific animation
widgets are assembled, then remove the previous outer decoration branches in
both `none` and animated modes.

### Task 4: Verify and Record Parity

**Files:**
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Run focused validation**

Run: `dart format lib/src/widgets/up_notice_bar.dart lib/src/widgets/up_tag.dart lib/src/widgets/up_transition.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UP(RowNotice and UPColumnNotice|Tag|Transition).*customStyle|UPTransition/Collapse/Waterfall BatchR aliases|Batch AO tag badge style parity" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_notice_bar.dart lib/src/widgets/up_tag.dart lib/src/widgets/up_transition.dart`

Observed: notice, tag, transition, and retained interaction/alias regressions
passed; all three analyses reported no diagnostics.

- [x] **Step 2: Run complete validation and record the result**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append the dated compatibility matrix entry for this batch.

Completed: the full suite passed all 702 tests and `git diff --check`
reported no whitespace errors.
