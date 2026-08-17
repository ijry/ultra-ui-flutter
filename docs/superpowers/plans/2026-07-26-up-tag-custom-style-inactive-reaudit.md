# UPTag Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPTag.customStyle` only for API compatibility without rendering it, matching the uView tag template.

**Architecture:** `u-tag.vue` derives the visible tag body from its local `style` computed value and wraps it in a source transition. It inherits the shared prop but never binds `customStyle`. Flutter retains the constructor field while keeping caller decoration off both the animated wrapper and visible tag body.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source transition, tag wrapper, tag body, and local `style` binding with Flutter's widget tree.
- [x] Strengthen the regression to prove a caller gradient is not rendered by the transition wrapper or tag body.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused inactive-style and render regressions, `flutter analyze lib/src/widgets/up_tag.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
