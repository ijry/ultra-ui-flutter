# UPDropdown Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPDropdown.customStyle` for API compatibility without rendering it, matching the uView dropdown templates.

**Architecture:** `u-dropdown.vue` inherits the shared mixin but does not bind `customStyle` to its root menu, content layer, popup, or mask. Its child item template uses only local option and color paths. Flutter keeps the shared field inert so caller decoration cannot leak onto the menu, active overlay, mask, popup panel, or option rows.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source menu/content/popup/mask bindings, child item options, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient while mounting an open menu, selected option, disabled item, overlay, and mask.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and option-selection regressions
- `flutter analyze lib/src/widgets/up_dropdown.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
