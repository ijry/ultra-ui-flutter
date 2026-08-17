# UPLoadingIcon, UPList, and UPNoticeBar Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that loading, list, and notice-bar public `customStyle` paths remain rendered when source templates actively consume them.

**Architecture:** The Vue loading root binds `addStyle(customStyle)`, list merges it into `listStyle`, and the main notice bar merges it after its resolved background. Flutter retains caller decoration on their corresponding roots; nested notice renderer fields remain separate component contracts and do not change this parent-root conclusion.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPLoadingIcon`, `UPList`, and `UPNoticeBar` constructors and `customStyle` fields.
- Match their corresponding Vue components under `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components`.
- Preserve source-backed animation, scrolling, styling, content, close/click callbacks, and public controls.
- Do not remove source-active custom style bindings.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Loading, List, and Notice Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_loading_icon.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_list.dart`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_notice_bar.dart`
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes the public `customStyle` fields for the listed components.
- Produces unchanged APIs and rendered source-backed custom style at the applicable component root.

- [x] **Step 1: Inspect source style bindings**

`u-loading-icon.vue:1-6` binds `addStyle(customStyle)`. `u-list.vue` deep-merges it into `listStyle`. `u-notice-bar.vue:1-8` applies it after the resolved background color in the main notice root.

- [x] **Step 2: Compare Flutter rendering paths**

Flutter retains decorations on the loading root, scrolling list container, and main notice root. The main notice root preserves its resolved background when caller style has no color, matching source array order; nested row/column notice widget fields are independent of the parent public prop.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing these decorations would regress explicit source custom-style use.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exceptions.
