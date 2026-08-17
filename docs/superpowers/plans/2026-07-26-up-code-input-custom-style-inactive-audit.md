# UPCodeInput Custom Style Inactive Audit Plan

**Goal:** Preserve the accepted Flutter `UPCodeInput.customStyle` API without rendering it, matching the uView template that does not bind the shared prop.

**Architecture:** `u-code-input.vue` has an unstyled layout root with independently styled code cells, cursor, line, and hidden input. Flutter retains the API field but must not apply it to the root or any generated code cell, leaving each cell's source border and mode styling intact.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue code-input root, cell style bindings, cursor, hidden input, and Flutter widget tree.
- [x] Strengthen the regression to prove a caller gradient is not rendered on the root or code cells.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: focused inactive-style and behavior regressions passed; `flutter analyze lib/src/widgets/up_code_input.dart` reported no issues; `flutter test --reporter expanded` passed 738 tests; `git diff --check` passed.
