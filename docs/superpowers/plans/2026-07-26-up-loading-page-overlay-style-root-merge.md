# UPLoadingPage Overlay Style Root Merge Plan

**Goal:** Merge `UPLoadingPage.customStyle` into its source-equivalent full-page transition root without retaining a Flutter-incompatible default background color under a caller gradient.

**Architecture:** `u-loading-page.vue` gives `overlayStyle` to its `u-transition`; the computed style contains fixed full-page geometry and a source background, then spreads caller style last. Flutter uses `UPOverlay` for page-level visibility/z-index and a full-page child `Container` for that transition root. The container decoration will merge caller fields after the source background while suppressing the source color when a caller gradient exists.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_loading_page.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source `u-transition` overlay root and style precedence with Flutter's overlay child container.
- [x] Identify the default-background/caller-gradient conflict in `BoxDecoration.copyWith`.
- [x] Add a regression proving caller gradient and border render on the full-page loading root without an exception.
- [x] Merge all caller decoration fields after the source background on that root.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check` (722 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
