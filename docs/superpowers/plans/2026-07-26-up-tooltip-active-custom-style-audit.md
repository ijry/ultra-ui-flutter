# UPTooltip Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPTooltip.customStyle` remains rendered because the source tooltip explicitly applies it to its root.

**Architecture:** The Vue root binds `:style="[addStyle(customStyle)]"`. It separately applies its internally computed `tooltipStyleCpu` to the transition used for positioned popup content; Flutter retains public root decoration in both hidden-trigger and visible-tooltip branches while preserving the popup-specific positioning path.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPTooltip` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-tooltip\u-tooltip.vue`.
- Preserve source-backed trigger, overlay, popup positioning, copy/buttons, singleton semantics, callbacks, and public controls.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Tooltip Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_tooltip.dart` near `UPTooltipState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPTooltip` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPTooltip({required dynamic text, BoxDecoration? customStyle, ...})`.
- Produces: unchanged API and an active root decoration whenever `customStyle` is supplied, whether the popup is visible or hidden.

- [x] **Step 1: Inspect source root style binding**

The root at `u-tooltip.vue:2-5` explicitly binds `addStyle(customStyle)`. The separate transition style at lines 27-36 derives from the internal `tooltipStyleCpu`, not from the public root prop.

- [x] **Step 2: Compare the Flutter root implementation**

`UPTooltipState.build` applies its root `Container(decoration: widget.customStyle, ...)` in both branches. Its popup position calculation remains separate, matching the source's distinction between root external styling and computed popup positioning.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the root decoration would regress the source's explicit `addStyle(customStyle)` behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
