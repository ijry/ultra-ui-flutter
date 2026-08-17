# UPReadMore Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPReadMore.customStyle` for API compatibility without rendering it, matching the uView read-more template.

**Architecture:** `u-read-more.vue` has an unstyled root, a content view with local height and indent styles, and a conditional toggle view styled only by its `shadowStyle`. Its default toggle and named toggle slot are independent of the shared mixin prop. Flutter keeps `customStyle` inert so caller decoration cannot leak onto collapsed content, source shadow, default toggle, or custom toggle content.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, collapsed content, source shadow, default toggle, named toggle slot, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient over long-content default-toggle and custom-toggle branches.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and long-content regressions
- `flutter analyze lib/src/widgets/up_read_more.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
