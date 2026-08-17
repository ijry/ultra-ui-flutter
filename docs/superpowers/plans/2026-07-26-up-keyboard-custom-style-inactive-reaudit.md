# UPKeyboard Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPKeyboard.customStyle` for API compatibility without rendering it, matching the uView keyboard template.

**Architecture:** `u-keyboard.vue` inherits the shared mixin but supplies its nested popup only with source-computed `popupStyle`; the caller's shared `customStyle` is not bound. Its content branches are an optional toolbar plus number/card or car keyboard. Flutter keeps the compatible field inert while preserving the source popup background, slot content, toolbar controls, card X key, and car keyboard.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source popup root, computed popupStyle, toolbar/slot branches, number/card and car keyboard branches, local props, CSS, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across the card toolbar/slot and no-toolbar car-keyboard branches while verifying the active popup background.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused keyboard display, inactive-style, overlay-close, and public-control regressions
- `flutter analyze lib/src/widgets/up_keyboard.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
