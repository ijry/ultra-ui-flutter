# UPUpload Active Custom Style Audit Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify that `UPUpload.customStyle` remains rendered because the source upload applies it to its root.

**Architecture:** The Vue upload root binds `:style="[addStyle(customStyle)]"`, with the public prop supplied by the common mixin. Flutter places `widget.customStyle` around its equivalent upload root `Wrap`, while preview, file-picker, upload state, popup, and callback paths remain independent from the root decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPUpload` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-upload\u-upload.vue`.
- Preserve source-backed preview, picker, upload state, popup, callbacks, file-list mutation helpers, and public controls.
- Do not remove a source-active custom style binding.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Upload Shared-Style Rendering

**Files:**
- Inspect: `packages/ultra_ui/lib/src/widgets/up_upload.dart` near `UPUploadState.build`
- Inspect: `packages/ultra_ui/test/widgets_test.dart` near existing `UPUpload` tests
- Modify: `docs/gap-matrix.md` append the audit record

**Interfaces:**
- Consumes: `UPUpload({BoxDecoration? customStyle, List fileList = const [], ...})`.
- Produces: unchanged API and a root decoration whenever `customStyle` is supplied.

- [x] **Step 1: Inspect source root style binding**

The source root at `u-upload.vue:2` explicitly binds `[addStyle(customStyle)]`. `customStyle` is provided by the shared common mixin; upload-specific `props.js` defines the component's upload options and does not override or disable that inherited prop.

- [x] **Step 2: Compare the Flutter root implementation**

`UPUploadState.build` creates the source-backed `Wrap` and applies `Container(decoration: widget.customStyle, child: root)` when supplied. The decoration is independent from preview cards, choose-file trigger, upload progress, and popup behavior, matching the source root binding.

- [x] **Step 3: Retain implementation and record source parity**

No widget or regression-test change is required. Removing the Flutter root decoration would regress the source's explicit `addStyle(customStyle)` behavior.

Run: `git diff --check`

Expected: no whitespace errors and a dated compatibility-matrix entry documenting the source-active exception.
