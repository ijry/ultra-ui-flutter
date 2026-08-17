# UPUpload Custom Style Root Audit Plan

**Goal:** Preserve `UPUpload.customStyle` on the source-equivalent outer upload root containing the preview-wrap and add trigger.

**Architecture:** `u-upload.vue` binds `addStyle(customStyle)` to `.u-upload`, whose child `.u-upload__wrap` owns wrapping previews and the picker button. Flutter already decorates a container outside its equivalent `Wrap`, so this batch locks that scope with a regression and makes no production change.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source `.u-upload` root binding with the nested `.u-upload__wrap` layout and inspect Flutter's decorated `Wrap` root.
- [x] Confirm the caller decoration encloses all Flutter preview and picker children without leaking into per-preview style nodes.
- [x] Add a regression proving caller decoration contains a source-equivalent preview and add button.
- [x] Run formatting, focused upload tests, analysis, the complete package suite, and `git diff --check`.
- [x] Record the confirmed source scope in `docs/gap-matrix.md`.

Verification: `dart format`, focused upload style/preview tests, `flutter analyze lib/src/widgets/up_upload.dart`, `flutter test --reporter expanded` (729 passed), and `git diff --check` all passed.
