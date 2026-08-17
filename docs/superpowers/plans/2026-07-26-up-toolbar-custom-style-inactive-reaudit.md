# UPToolbar Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPToolbar.customStyle` for API compatibility without rendering it, matching the uView toolbar template.

**Architecture:** `u-toolbar.vue` renders an unstyled root and left/right wrapper views. Its only inline style bindings are local cancel and confirm text colors; the right slot replaces the default confirmation wrapper. Flutter keeps the shared-style field inert so caller decoration cannot leak onto the toolbar root, action controls, title, or supplied right-slot content.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source toolbar root, action wrappers, title, right-slot branch, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient across default-confirm and right-slot branches.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style, confirm, and right-slot regressions
- `flutter analyze lib/src/widgets/up_toolbar.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
