# UPBadge Custom Style Precedence Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve UPBadge custom-style support while matching the Vue template's source style-array precedence.

**Architecture:** `u-badge.vue` applies `[addStyle(customStyle), badgeStyle]` to the badge node. Therefore caller styles can override CSS defaults, but an explicit source `badgeStyle.backgroundColor` from `bgColor` is applied afterward and wins over caller `customStyle.color`. Flutter reconstructs the decoration with this field precedence while retaining caller decoration fields that source `badgeStyle` does not set.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public UPBadge constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-badge\u-badge.vue`.
- Preserve dot/number modes, type styles, offsets, inverted behavior, child positioning, and number formatting.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Source Style Ordering

**Files:**
- Inspect: `components\u-badge\u-badge.vue`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_badge.dart`

- [x] **Step 1: Identify precedence on the source node**

The Vue badge node uses `:style="[addStyle(customStyle), badgeStyle]"`.
`badgeStyle` assigns `backgroundColor` only for an explicit non-inverted
`bgColor`, so that source prop must win over caller `customStyle.color`.

### Task 2: Correct Decoration Merging

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_badge.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Write and confirm the ordering regression**

Mount a badge with conflicting caller `customStyle.color` and source `bgColor`.
Assert the rendered decoration uses the source background color.

Run: `flutter test test/widgets_test.dart --name "UPBadge source badgeStyle overrides customStyle background" --reporter expanded`

Observed before implementation: Flutter rendered the caller color instead of
the source `bgColor`.

- [x] **Step 2: Apply source-field precedence**

Retain caller border, radius, shadow, image, gradient, and blend fields where
source `badgeStyle` has no corresponding assignment. Resolve the decoration
color as explicit source `bgColor`, otherwise caller color, otherwise source
class/default color.

- [x] **Step 3: Run focused verification**

Run: `dart format lib/src/widgets/up_badge.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPBadge (overflow text|source badgeStyle overrides customStyle background)|UPAlert and UPBadge customStyle|Batch AO tag badge style parity" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_badge.dart`

Observed: four focused tests passed and analysis reported no diagnostics.

- [x] **Step 4: Run complete validation and record the result**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append the dated compatibility matrix entry for this batch.

Completed: the full suite passed all 704 tests and `git diff --check`
reported no whitespace errors.
