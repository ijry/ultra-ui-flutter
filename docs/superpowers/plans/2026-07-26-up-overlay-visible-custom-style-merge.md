# UPOverlay Visible Custom Style Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Merge `UPOverlay.customStyle` into the source-equivalent visible mask decoration rather than placing it behind an independently painted black mask.

**Architecture:** `u-overlay.vue` builds its fixed geometry and default translucent black background in `overlayStyle`, then returns `deepMerge(style, addStyle(customStyle))` and supplies the merged result to the rendered transition root. Flutter will derive the default mask `BoxDecoration`, overlay non-null caller fields in source order, and paint that merged decoration on the tappable visible mask node.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPOverlay` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-overlay\u-overlay.vue`.
- Preserve root-overlay ordering, opacity defaults, transition, click handling, child slot, and z-index behavior.
- Do not add a second black mask after caller `customStyle` overrides the background.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Merge the Visible Mask Decoration

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_overlay.dart` near `_UPOverlayState._buildLayer`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPOverlay` widget tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPOverlay({bool show = false, dynamic opacity = 0.5, BoxDecoration? customStyle, ...})`.
- Produces: a visible mask whose default translucent black decoration is overridden only by non-null caller decoration fields.

- [x] **Step 1: Verify source style target and merge order**

`u-overlay.vue:1-8` passes `overlayStyle` as the transition root's `custom-style`. `overlayStyle` at lines 35-45 creates the fixed-mask geometry and `rgba(0, 0, 0, opacity)` background, then returns `deepMerge(style, addStyle(this.customStyle))`; caller background fields therefore replace the default mask background on the visible node.

- [x] **Step 2: Identify the Flutter mismatch**

`_UPOverlayState._buildLayer` currently wraps the transition with `Container(decoration: customStyle)`, then paints an independent inner `ColoredBox` using the default translucent black. The caller decoration is behind that black layer rather than merged with it, so a custom color or gradient is visually altered instead of replacing the source background.

- [x] **Step 3: Write and confirm the failing visible-mask regression**

Mount `UPOverlay(show: true, rootOverlay: false)` with a caller color and border. Assert that the keyed visible mask is a `DecoratedBox` containing the caller fields, and that no separate default `ColoredBox` remains.

Run: `flutter test test/widgets_test.dart --name "UPOverlay merges customStyle into the visible mask" --reporter expanded`

Expected: FAIL because no keyed merged mask exists and the current implementation still paints the separate black `ColoredBox`.

Observed: the regression failed because the current tree contained no
`up-overlay-mask` node, confirming that the visible mask did not own the
merged decoration.

- [x] **Step 4: Paint the merged decoration on the mask**

Create a source-default translucent-black `BoxDecoration`, overlay the supported caller `BoxDecoration` fields, and replace the inner `ColoredBox` with a keyed `DecoratedBox` using the merged decoration. Remove the outer custom-style wrapper.

Implemented: `_buildLayer` now constructs `maskDecoration` and paints it on
the keyed, tappable mask `DecoratedBox`. The caller color, border, gradient,
image, radius, shadow, blend mode, and shape are merged in source override
order; no independent default black mask remains.

- [x] **Step 5: Verify behavior and record source parity**

Run: `dart format lib/src/widgets/up_overlay.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPOverlay (show and click|orders shown masks by numeric zIndex|BatchD clickHandler|merges customStyle into the visible mask)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_overlay.dart`

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry recording the visible-mask merge behavior.

Expected: focused and full tests pass, analysis has no diagnostics, and no whitespace errors are reported.

Observed: the four focused overlay tests passed, `flutter analyze
lib/src/widgets/up_overlay.dart` reported no diagnostics, and the full suite
passed all 690 tests before the final whitespace check. The compatibility
matrix records batch HS.
