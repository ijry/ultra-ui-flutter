# UPFloatButton Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPFloatButton.customStyle` for API compatibility without rendering it, matching the uView float-button template.

**Architecture:** `u-float-button.vue` inherits the shared mixin but binds only local fixed offsets and individual main/list button colors, dimensions, and borders. Its default list and named list slot are independent of `customStyle`. Flutter keeps the shared field inert so caller decoration cannot leak onto the positioned trigger, expanded item circles, or custom list-slot content.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source fixed root, main button, expanded list items, list slot, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient across open default-list and custom-list-slot branches.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `flutter test --reporter expanded` - 738 passed.
- `git diff --check` - passed with no output.
