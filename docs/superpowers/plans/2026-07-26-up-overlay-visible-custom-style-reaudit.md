# UPOverlay Visible Custom Style Re-Audit Plan

**Goal:** Reconfirm that Flutter merges `UPOverlay.customStyle` onto the source-equivalent visible mask while preserving independent source overlay behavior.

**Architecture:** `u-overlay.vue` passes computed `overlayStyle` to its transition root. The computed style defines fixed geometry, z-index, and opacity-derived black background before deep-merging `addStyle(customStyle)`, so caller fields apply to the visible mask. Flutter builds a keyed tappable mask `DecoratedBox`, merging caller decoration fields onto the source base decoration; any optional child remains a sibling above the mask, matching the source slot layering.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source transition binding, computed deep-merge ordering, click handling, slot layer, and Flutter mask construction.
- [x] Confirm caller `customStyle` belongs to the visible mask and is distinct from the source computed `overlayStyle` API.
- [x] Upgrade the visible-mask regression to use a distinctive gradient and border.
- [x] Exercise source mask/slot sibling layering and opacity configuration while caller decoration stays on the keyed mask.
- [x] Run focused overlay regressions and component analysis without a production code change.
- [x] Record the confirmed visible-mask scope in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPOverlay (show and click|merges customStyle into the visible mask|orders shown masks by numeric zIndex|BatchD clickHandler)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_overlay.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPOverlay regressions: 4 passed.
- `flutter analyze lib/src/widgets/up_overlay.dart`: no issues.
- Full Flutter suite: 739 passed.
- `git diff --check`: clean.
