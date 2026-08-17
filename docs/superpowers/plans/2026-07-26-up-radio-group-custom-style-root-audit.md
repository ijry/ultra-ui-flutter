# UPRadioGroup Custom Style Root Audit Plan

**Goal:** Verify that caller `UPRadioGroup.customStyle` decorates the source-equivalent group root without changing group layout or radio selection behavior.

**Architecture:** `u-radio-group.vue` merges `gap` and `customStyle` into one `.u-radio-group` root, then applies its row-wrap or column-flex layout to the slot children. Flutter already wraps the scoped row `Wrap` or column `Column` in the caller decoration; this audit adds regression coverage for both layouts rather than adding an unsafe universal replacement for source `flex: 1`.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue root template, `radioGroupStyle`, stylesheet, and Flutter widget tree.
- [x] Add column and row regressions proving one caller decoration root contains every radio and the source-owned layout/gap node.
- [x] Run focused style and event tests to confirm the regression coverage passes without a production change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Format, analyze the related widget module, run the full test suite, and run `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused root-style and update-value tests, `flutter analyze lib/src/widgets/up_radio.dart`, `flutter test --reporter expanded` (734 passed), and `git diff --check` all passed.
