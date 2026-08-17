# UPMessageInput Custom Style Inactive Audit Plan

**Goal:** Preserve the accepted Flutter `UPMessageInput.customStyle` API without rendering it, matching the uView template that does not bind the shared prop.

**Architecture:** `u-message-input.vue` renders its centered `.u-char-box` and `.u-char-flex` layout without a shared-style binding. The hidden input and generated character cells have dedicated source style paths. Flutter therefore retains the constructor field while keeping caller decoration off the layout root and every generated cell.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue message-input layout root, hidden input, cell styles, and Flutter widget tree.
- [x] Strengthen the regression to prove a caller gradient is not rendered on the root or generated cells.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused inactive-style and update-value regressions, `flutter analyze lib/src/widgets/up_message_input.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
