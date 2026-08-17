# UPCheckbox and UPIcon Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that per-item `UPCheckbox.customStyle` and `UPIcon.customStyle` remain rendered because their sources actively consume them.

**Architecture:** The Vue checkbox computes `checkboxStyle` by deep-merging per-item custom style with its layout padding before binding it to the row. The Vue icon applies `addStyle(customStyle)` directly to the image or text glyph node; Flutter retains decoration on the equivalent checkbox row and icon content root without removing these source-active style paths.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPCheckbox` and `UPIcon` constructors and `customStyle` fields.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-checkbox\u-checkbox.vue` and `components\u-icon\u-icon.vue`.
- Preserve source-backed check state, placement, borders, callbacks, icon glyph/image, label, and click behavior.
- Do not remove source-active custom style bindings.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Checkbox and Icon Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_checkbox.dart` near `UPCheckbox.build`
- Inspect: `packages/ultra_ui/lib/src/widgets/up_icon.dart` near `UPIcon.build`
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPCheckbox({BoxDecoration? customStyle, ...})` and `UPIcon({BoxDecoration? customStyle, ...})`.
- Produces: unchanged APIs and rendered custom style on their source-backed item or glyph paths.

- [x] **Step 1: Inspect source style bindings**

`u-checkbox.vue:180-191` returns `deepMerge(style, addStyle(this.customStyle))` from `checkboxStyle`, which the row binds at line 4. `u-icon.vue:7-19` binds `addStyle(customStyle)` to both image and text-glyph branches.

- [x] **Step 2: Compare the Flutter implementations**

`UPCheckbox.build` applies the decoration to the interactive checkbox row and preserves its source border-bottom path. `UPIcon.build` decorates the icon content path while leaving the label layout and click wrapper independent, which corresponds to the source applying style to glyph/image rather than the outer label container.

- [x] **Step 3: Retain implementation and record source parity**

No widget change is required. Removing either decoration would regress active source style consumption.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exceptions.
