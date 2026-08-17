# UPSubsection Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPSubsection.customStyle` remains rendered because the source subsection component explicitly applies it at its root.

**Architecture:** The Vue root binds `:style="[addStyle(customStyle), wrapperStyle]"`. Flutter retains its root `DecoratedBox` so the public style API affects the same subsection wrapper independently of source-backed mode, colors, and sliding-bar layout.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSubsection` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-subsection\u-subsection.vue`.
- Preserve source-backed button/subsection modes, colors, sliding bar, disabled state, callbacks, and public controls.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Subsection Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_subsection.dart` near `UPSubsectionState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSubsection` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPSubsection({List list = const [], BoxDecoration? customStyle, ...})`.
- Produces: unchanged API and an active root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The root at `u-subsection.vue:2-7` explicitly merges `addStyle(customStyle)` with `wrapperStyle`. The component imports `addStyle` and the shared mixin, making the prop source-rendered.

- [x] **Step 2: Compare the Flutter root implementation**

`UPSubsectionState.build` retains `DecoratedBox(decoration: widget.customStyle!, child: body)` around the source-backed wrapper. Existing coverage mounts a subsection with non-null `customStyle` while exercising update aliases.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the decoration would regress the source root style merge.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
