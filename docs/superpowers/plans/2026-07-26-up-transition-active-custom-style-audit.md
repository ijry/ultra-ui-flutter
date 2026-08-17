# UPTransition Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPTransition.customStyle` remains rendered because the source transition merges it into its root style.

**Architecture:** The Vue `mergeStyle` computed property combines `addStyle(customStyle)` with transition-specific `viewStyle`, and the template applies that result to the transition root. Flutter applies `widget.customStyle` at the equivalent root in both the `mode == 'none'` and animated build paths, so the API and visual contract remain aligned without a widget change.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPTransition` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-transition\u-transition.vue`.
- Preserve source-backed animation mode, duration, visibility, transform, opacity, callbacks, and child behavior.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Transition Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_transition.dart` near `UPTransitionState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTransition` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPTransition({BoxDecoration? customStyle, String mode = 'fade', ...})`.
- Produces: unchanged API and a root decoration whenever `customStyle` is supplied in either non-animated or animated transition mode.

- [x] **Step 1: Inspect source root style binding**

The `mergeStyle` computed property in `u-transition.vue` explicitly merges `addStyle(customStyle)` with `viewStyle`, and the template applies `mergeStyle` to the root transition node.

- [x] **Step 2: Compare the Flutter root implementation**

`UPTransitionState.build` uses `widget.customStyle` at the root in the `mode == 'none'` path and in the normal animated path. The animation-specific transform and opacity remain independent from the public root decoration, matching the source separation.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing either Flutter root decoration would regress the source's explicit merged `customStyle` behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
