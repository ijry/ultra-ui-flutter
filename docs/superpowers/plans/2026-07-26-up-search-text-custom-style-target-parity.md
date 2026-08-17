# UPSearch and UPText Custom Style Target Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain UPSearch root styling and restrict UPText decoration to the source value nodes that consume `customStyle`.

**Architecture:** `u-search.vue` applies `addStyle(customStyle)` to `.u-search`, so Flutter's root row decoration remains correct. `u-text.vue` creates `valueStyle` by merging its text fields with `customStyle`, then applies it to the standard text and price-symbol nodes; link mode intentionally supplies only selected value fields to `u-link`. Flutter will decorate regular value and price-symbol/value nodes, remove the outer-row decoration, and leave link mode unstyled by `customStyle`.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public UPSearch and UPText constructors and `customStyle` fields.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-search\u-search.vue` and `components\u-text\u-text.vue`.
- Preserve search interaction, formatted text values, price rendering, icons, links, click behavior, and source aliases.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Source Style Consumers

**Files:**
- Inspect: `components\u-search\u-search.vue`
- Inspect: `components\u-text\u-text.vue`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_search.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_text.dart`

- [x] **Step 1: Confirm UPSearch root binding**

`u-search.vue:1-9` binds `addStyle(customStyle)` after the root margin
style. Flutter decorates its root search row before the outer margin padding,
which targets the same rendered node.

- [x] **Step 2: Confirm UPText value-only binding**

`u-text.vue:10-13` binds `valueStyle` to the price symbol and lines 51-60 bind
it to the ordinary value text. `valueStyle` returns
`deepMerge(style, addStyle(customStyle))`. Link mode at lines 21-28 passes
only `fontWeight`, `wordWrap`, and `fontSize` to `u-link`, so it deliberately
does not forward `customStyle`. Prefix and suffix icons receive `iconStyle`,
not `customStyle`.

### Task 2: Add and Confirm a Failing UPText Regression

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`

- [x] **Step 1: Assert value-node placement**

Mount regular, price, and link UPText instances with the same unique
`BoxDecoration`. Assert only regular value and price symbol/value nodes own
the decoration, while the link text has no ancestor using it.

Run: `flutter test test/widgets_test.dart --name "UPText applies customStyle only to source value nodes" --reporter expanded`

Expected: FAIL because the current Flutter implementation applies the
decoration to each entire outer row, including link mode.

Observed: the regression failed because no value-node keys existed; Flutter
only had the outer-row decoration path.

### Task 3: Implement and Verify

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_text.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Decorate only source value branches**

Add small value-node wrappers for ordinary text, Flutter child content, and
price symbol/value branches when `customStyle` is non-null. Do not wrap link
mode or the outer row.

Implemented: ordinary Flutter text/content is decorated at
`up-text-value`; price mode independently decorates its symbol at
`up-text-price` and its value at `up-text-value`. The outer row and link branch
are undecorated, matching the source node paths.

- [x] **Step 2: Validate and record**

Run: `dart format lib/src/widgets/up_text.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UP(Text.*customStyle|Search action triggers onSearch|Text price mode renders the source formatted value|Text link mode renders source UPLink and isolates its tap)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_text.dart lib/src/widgets/up_search.dart`

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated compatibility matrix entry for UPSearch and UPText.

Observed: the focused search/text tests passed, analysis reported no
diagnostics, the full suite passed all 696 tests, and `git diff --check`
reported no whitespace errors. The compatibility matrix records batch HV.
