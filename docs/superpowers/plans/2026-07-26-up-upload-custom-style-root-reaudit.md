# UPUpload Custom Style Root Re-Audit Plan

**Goal:** Reconfirm that Flutter applies `UPUpload.customStyle` to the source-equivalent outer upload root without overriding source-owned preview and picker styling.

**Architecture:** `u-upload.vue` explicitly binds `:style="[addStyle(customStyle)]"` on `.u-upload`; its nested `.u-upload__wrap` owns previews, status overlays, delete controls, trigger slots, and the default picker button. Flutter mirrors this by placing the caller decoration outside the internal `Wrap`, allowing all source children to remain separately styled and interactive.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete source root binding, preview/trigger branches, local props, and Flutter decorated `Wrap` root.
- [x] Confirm the active caller style belongs to the outer upload container, not to individual previews, status overlays, delete controls, or picker button.
- [x] Strengthen the root-style regression with a distinctive gradient, border, and radius.
- [x] Exercise successful image preview, uploading and failed file status overlays, default add button, and choose callback inside the decorated root.
- [x] Investigate the focused-test layout failure: root cause was a test-only `48x40` card constraint too small for source-like icon/text columns; retain production code and set the test to `80x80`.
- [x] Run focused upload regressions and component analysis without a production code change.
- [x] Record the confirmed source root scope in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPUpload (renders add button|keeps customStyle on its outer upload root|delete and callbacks|auto upload driver|BatchH onBeforeRead/popupShow|BatchI afterRead/toast|BatchL format helpers)" --reporter expanded` (4 matched tests passed)
- `flutter analyze lib/src/widgets/up_upload.dart` (no issues)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
