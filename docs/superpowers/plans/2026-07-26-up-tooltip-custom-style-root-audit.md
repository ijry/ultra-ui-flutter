# UPTooltip Custom Style Root Audit Plan

**Goal:** Preserve `UPTooltip.customStyle` on the source-equivalent outer tooltip root in both hidden-trigger and visible-popup states.

**Architecture:** `u-tooltip.vue` binds `addStyle(customStyle)` only to `.u-tooltip`; the trigger wrapper and positioned transition/popup have independent source styles. Flutter already wraps each rendered root branch with the caller decoration, so this batch adds regression coverage without changing production code.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue root binding with trigger and transition style scopes, then inspect both Flutter build branches.
- [x] Confirm Flutter applies the caller decoration to the outer root in both branches and does not pass it to the bubble positioning path.
- [x] Add a regression that verifies hidden and visible roots retain the caller decoration and include the source trigger/popup content.
- [x] Run formatting, focused tooltip tests, analysis, the complete package suite, and `git diff --check`.
- [x] Record the confirmed source scope in `docs/gap-matrix.md`.

Verification: `dart format`, focused tooltip style/interaction tests, `flutter analyze lib/src/widgets/up_tooltip.dart`, `flutter test --reporter expanded` (728 passed), and `git diff --check` all passed.
