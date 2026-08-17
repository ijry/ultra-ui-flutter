# UPSlider Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPSlider.customStyle` remains rendered because the source slider explicitly applies it at its root.

**Architecture:** The Vue root binds `:style="[addStyle(customStyle), {width: vertical ? addUnit(this.blockSize): ''}]"`. Flutter retains its root `Container(decoration: widget.customStyle, child: slider)` so the public style API affects the same root-level slider surface before the source `length` constraint is applied.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSlider` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-slider\u-slider.vue`.
- Preserve source-backed vertical layout, range mode, track and block styling, interactions, callbacks, and value aliases.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Slider Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_slider.dart` near `UPSliderState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near `UPSlider change vs changing and customStyle`
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPSlider({dynamic value = 0, BoxDecoration? customStyle, ...})`.
- Produces: unchanged API and an active root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The source root at `u-slider.vue:2-5` explicitly merges `addStyle(customStyle)` into its style binding. `customStyle` is inherited from `mixin.js`, so it is both public and source-rendered.

- [x] **Step 2: Compare the Flutter root implementation**

`UPSliderState.build` wraps the generated slider with `Container(decoration: widget.customStyle, child: slider)` when present, matching the source root-level style application. Existing widget coverage mounts the component with a non-null `customStyle` while exercising value events.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the wrapper would regress the source's explicit `addStyle(customStyle)` behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
