# UPNumberBox Custom Style Inactive Audit Plan

**Goal:** Preserve the accepted Flutter `UPNumberBox.customStyle` API without rendering it, matching the uView template that never binds the shared prop.

**Architecture:** `u-number-box.vue` renders a plain `.u-number-box` root with separate button and input style bindings, and does not bind `customStyle` at any level. Flutter keeps the API field for compatibility while leaving the row, button backgrounds, input background, icons, and interaction nodes source-owned.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue number-box template and individual button/input style bindings with Flutter's widget tree.
- [x] Strengthen the regression to prove a caller gradient is not rendered on the root or its generated controls.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused inactive-style and update-value tests, `flutter analyze lib/src/widgets/up_number_box.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
