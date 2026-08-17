# UPCountDown Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPCountDown.customStyle` for API compatibility without rendering it, matching the uView countdown template.

**Architecture:** `u-count-down.vue` renders an unstyled root `view`; its default-slot fallback is a text node with only source-owned CSS typography. Flutter therefore retains the shared-style field but must not apply caller decoration to either its countdown root or formatted text output.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source countdown root, default-slot fallback text, props, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient and verify it cannot reach a visible root or text wrapper.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and formatting regressions
- `flutter analyze lib/src/widgets/up_count_down.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
