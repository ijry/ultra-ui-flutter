# UPRate Custom Style Root Audit Plan

**Goal:** Verify that `UPRate.customStyle` remains attached to the source-equivalent outer rate root containing its touch content and all stars.

**Architecture:** `u-rate.vue` binds caller style to outer `.u-rate`; its inner `.u-rate__content` owns gesture handling and item generation. Flutter decorates one outer container around the gesture detector and generated star row. No production change is required when the regression confirms this scope.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source outer rate root and inner gesture/content node with the Flutter widget tree.
- [x] Add and run a regression proving the caller decoration contains all source star content.
- [x] Run focused and full package verification, `flutter analyze`, and `git diff --check` (724 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
