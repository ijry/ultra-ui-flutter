# UPSticky Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPSticky.customStyle` remains rendered because the source sticky component explicitly merges it into its root style.

**Architecture:** The Vue root binds its `style` computed value. That computed value returns `deepMerge(addStyle(this.customStyle), style)`, where `style` also supplies sticky positioning and background behavior; Flutter retains its root `Container(decoration: widget.customStyle, child: root)` around the source-backed sticky surface.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSticky` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-sticky\u-sticky.vue`.
- Preserve source-backed sticky position, placeholder, background, z-index, callbacks, and public controls.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Sticky Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_sticky.dart` near `UPStickyState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSticky` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPSticky({required Widget child, BoxDecoration? customStyle, ...})`.
- Produces: unchanged API and an active root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The root at `u-sticky.vue:2-5` binds `style`. Its computed property at `u-sticky.vue:62-72` merges `addStyle(this.customStyle)` with sticky positioning and `bgColor`, proving that the inherited mixin prop is source-rendered.

- [x] **Step 2: Compare the Flutter root implementation**

`UPStickyState.build` retains `Container(decoration: widget.customStyle, child: root)` around the root sticky surface. Existing widget coverage mounts a sticky component with a non-null `customStyle` while exercising pinning and public-state behavior.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the wrapper would regress the source's explicit root style merge.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
