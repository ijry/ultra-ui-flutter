# UPRate, UPRadio, UPRadioGroup, and UPSafeBottom Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that source-active `customStyle` paths in UPRate, UPRadio, UPRadioGroup, and UPSafeBottom remain rendered.

**Architecture:** The Vue sources bind each component's `customStyle` to its rendered root, either directly or after merging intrinsic layout fields. Flutter keeps the matching root decoration paths, so no API or rendering removal is appropriate.

**Tech Stack:** Flutter, Dart.

## Global Constraints

- Preserve all public constructors and `customStyle` fields.
- Match the corresponding components under `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components`.
- Preserve component interactions, model aliases, layout, and source-backed styles.
- Do not remove source-active custom style bindings.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Inspect Vue Style Consumers

**Files:**
- Inspect: `components\u-rate\u-rate.vue`
- Inspect: `components\u-radio\u-radio.vue`
- Inspect: `components\u-radio-group\u-radio-group.vue`
- Inspect: `components\u-safe-bottom\u-safe-bottom.vue`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_rate.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_radio.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_safe_bottom.dart`
- Modify: `docs/gap-matrix.md` append the audit record

- [x] **Step 1: Verify source bindings**

`u-rate.vue:1-7` binds `addStyle(customStyle)` to the rendered `.u-rate` root.
`u-radio.vue` returns `deepMerge(style, addStyle(this.customStyle))` from
`radioStyle`, then binds it to the rendered radio root. `u-radio-group.vue`
returns `deepMerge({ gap: addUnit(gap) }, addStyle(customStyle))` as
`radioGroupStyle`, bound to its group root. `u-safe-bottom.vue` merges
platform height with `addStyle(customStyle)` in `style`, bound directly to its
safe-area root.

- [x] **Step 2: Compare Flutter render targets**

`UPRate` decorates its root rate body. `UPRadio` decorates the item row after
building its source-derived placement and border-bottom layout; `UPRadioGroup`
decorates the group root after its row/column arrangement and gap behavior.
`UPSafeBottom` decorates the height-bearing safe-area root. These targets
match the source nodes that consume the prop.

- [x] **Step 3: Retain implementation and record parity**

No component change is required. Removing any of the four Flutter decoration
paths would contradict an explicit Vue root style binding.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry
documenting the source-active style paths.
