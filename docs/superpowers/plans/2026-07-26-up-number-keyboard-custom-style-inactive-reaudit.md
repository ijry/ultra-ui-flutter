# UPNumberKeyboard Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPNumberKeyboard.customStyle` for API compatibility without rendering it, matching the uView number-keyboard template.

**Architecture:** `u-number-keyboard.vue` inherits the shared mixin but its root, numeric key wrappers, item-style rules, and backspace button bind no `customStyle`. The local props define only mode, dot visibility, and randomized order. Flutter keeps the shared field inert while preserving the default dot key, dot-disabled wide zero key, card-mode X key, and source-owned gray backspace key.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, generated key list, item width rule, gray-key rule, backspace behavior, local props, CSS, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across default numeric, dot-disabled, and card-mode key branches while verifying source-owned key dimensions and gray backgrounds.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused number-keyboard interaction, public-method, alias, and inactive-style regressions
- `flutter analyze lib/src/widgets/up_number_keyboard.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
