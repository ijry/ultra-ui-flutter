# UPActionSheetData Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPActionSheetData.customStyle` for compatibility without rendering it, matching its separate uView template.

**Architecture:** `u-action-sheet-data.vue` declares no `customStyle` prop and renders an unstyled root containing a trigger and nested action sheet. Flutter preserves the optional constructor field while keeping caller decoration off the trigger root and nested popup panel.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the independent source root, trigger, cover, and nested action-sheet template nodes with Flutter's widget tree.
- [x] Strengthen the regression to show a caller gradient does not render on the trigger or nested popup panel.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused inactive-style and model-alias regressions, `flutter analyze lib/src/widgets/up_action_sheet.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
