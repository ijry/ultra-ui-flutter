# UPActionSheet Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPActionSheet.customStyle` for API compatibility without rendering it, as the uView template never binds the shared prop.

**Architecture:** `u-action-sheet.vue` passes popup props to `u-popup` and renders an unstyled `.u-action-sheet` panel, header, description, action cells, and cancellation region. Flutter keeps the constructor field inert: caller decoration must not decorate the popup panel or the generated action content.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source popup, panel, action-cell, and cancellation template nodes with Flutter's widget tree.
- [x] Strengthen the regression to prove a caller gradient is not rendered by the popup panel or action content.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused inactive-style and action behavior regressions, `flutter analyze lib/src/widgets/up_action_sheet.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
