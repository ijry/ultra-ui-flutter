# UPAvatar Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPAvatar.customStyle` remains rendered because the source avatar applies it to its root.

**Architecture:** The Vue avatar root combines its own size and background style with `addStyle(customStyle)`. Flutter keeps `customStyle` as the outer decoration around the source-backed, clickable avatar body, separating caller-provided root decoration from the avatar's intrinsic circular or square clipping and image/text/icon rendering.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPAvatar` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-avatar\u-avatar.vue`.
- Preserve source-backed size, shape, image/text/icon modes, random background, click callback, and image fallback behavior.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Avatar Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_avatar.dart` near `UPAvatar.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPAvatar` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPAvatar({BoxDecoration? customStyle, ...})`.
- Produces: unchanged API and a root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The source root in `u-avatar.vue:2-10` explicitly includes `addStyle(customStyle)` in its style array beside its dynamic width, height, and background color.

- [x] **Step 2: Compare the Flutter root implementation**

`UPAvatar.build` creates the source-backed gesture and clipped intrinsic avatar body, then applies `Container(decoration: customStyle, child: body)` at the root. This keeps external caller decoration distinct from intrinsic shape clipping, as in the source root-style merge.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing the outer Flutter decoration would regress the source's explicit `addStyle(customStyle)` behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
