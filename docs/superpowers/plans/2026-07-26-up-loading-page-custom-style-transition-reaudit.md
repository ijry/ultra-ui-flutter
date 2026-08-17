# UPLoadingPage Custom Style Transition Re-Audit Plan

**Goal:** Reconfirm that Flutter applies `UPLoadingPage.customStyle` to the source-equivalent full-page transition layer without leaking it into loading icon or text children.

**Architecture:** `u-loading-page.vue` passes computed `overlayStyle` to `u-transition`. That object supplies fixed page geometry, `bgColor`, display, and z-index before spreading caller `customStyle` last. Flutter uses `UPOverlay` for the visible global layer and its full-page child `Container` for the transition root. The existing merge suppresses the source color when caller gradient is present because Flutter cannot reliably express the source CSS background-color/gradient composition in one painted decoration.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source transition binding, computed overlay style order, local props, and Flutter overlay/root composition.
- [x] Confirm that caller `customStyle` belongs to the full-page transition root rather than the nested icon or loading text.
- [x] Strengthen the existing gradient and border regression with explicit source `bgColor` and loading-text branches.
- [x] Confirm a caller gradient remains valid on the full-page root while source loading icon/text stay mounted beneath it.
- [x] Run focused loading-page regressions and component analysis without a production code change.
- [x] Record the confirmed source transition-root scope in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPLoadingPage (merges customStyle into its full-page root|source props default iconSize follows fontSize default|source overlayStyle merges custom style|participates in root zIndex ordering)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_loading_page.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPLoadingPage regressions: 4 passed.
- `flutter analyze lib/src/widgets/up_loading_page.dart`: no issues.
- Full Flutter suite: 739 passed.
- `git diff --check`: clean.
