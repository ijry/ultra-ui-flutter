# UPSwitch Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPSwitch.customStyle` remains rendered because the source switch explicitly merges it into its root style.

**Architecture:** The Vue root binds `:style="[switchStyle, addStyle(customStyle)]"`. Flutter retains its root `Container(decoration: widget.customStyle, child: switchBody)` so the public style API affects the same switch surface alongside its source-computed dimensions and state styles.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPSwitch` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-switch\u-switch.vue`.
- Preserve source-backed switch dimensions, active/inactive state, loading, disabled state, callbacks, and aliases.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Switch Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_switch.dart` near `UPSwitchState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPSwitch` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPSwitch({dynamic value = false, BoxDecoration? customStyle, ...})`.
- Produces: unchanged API and an active root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The root at `u-switch.vue:2-7` explicitly merges `switchStyle` and `addStyle(customStyle)`. The component imports `addStyle`, and the public style prop is therefore source-rendered.

- [x] **Step 2: Compare the Flutter root implementation**

`UPSwitchState.build` retains `Container(decoration: widget.customStyle, child: switchBody)` around the source-backed switch root. Existing coverage mounts a switch with non-null `customStyle` while exercising active and asynchronous behavior.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the decoration would regress the source root style merge.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
