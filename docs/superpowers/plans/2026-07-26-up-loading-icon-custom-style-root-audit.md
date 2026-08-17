# UPLoadingIcon Custom Style Root Audit Plan

**Goal:** Verify that `UPLoadingIcon.customStyle` remains on the source-equivalent `.u-loading-icon` root.

**Architecture:** `u-loading-icon.vue` binds `addStyle(customStyle)` only to its outer flex root, which contains both the spinner and optional text. Flutter's optional decorated `Container` wraps the same spinner/text body; no production hierarchy change is needed if a regression verifies that scope.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression verifying caller decoration contains both spinner and text on the loading-icon root.
- [x] Run the focused regression and analyze `up_loading_icon.dart`.
- [x] Run the full test suite and `git diff --check`, then record the audited parity result.

Completed: the focused widget regression and
`flutter analyze lib/src/widgets/up_loading_icon.dart` completed without
diagnostics. `flutter test --reporter expanded` passed all 709 tests, and
`git diff --check` reported no whitespace errors.
