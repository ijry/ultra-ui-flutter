# UPPicker Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts the main `UPPicker.customStyle` API without rendering it, matching the uView picker template.

**Architecture:** `u-picker.vue` inherits the shared mixin, but its wrapper, optional input trigger, popup, toolbar, columns, and loading layer never bind `customStyle`. The popup receives the independent `bgColor` prop and picker-view receives dedicated mask props. Flutter leaves the shared field inert while preserving the source-backed inline popup, toolbar, object/text column rendering, loading overlay, and input-trigger path.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete source wrapper, input trigger/slots, popup, toolbar/slot, picker columns, loading overlay, local props, CSS, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across inline popup, toolbar-right slot, object/text column, loading, and input-trigger branches while verifying active `bgColor` rendering.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused picker confirmation, inactive-style, state-method, and public-alias regressions
- `flutter analyze lib/src/widgets/up_picker.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
