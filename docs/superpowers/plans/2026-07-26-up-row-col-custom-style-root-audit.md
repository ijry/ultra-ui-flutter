# UPRow And UPCol Custom Style Root Audit Plan

**Goal:** Keep `UPRow.customStyle` and `UPCol.customStyle` on their source-equivalent roots, including UPCol's grid offset geometry.

**Architecture:** `u-row.vue` merges caller style directly into its flex row root; Flutter's existing decorated outer root has the same visible scope. `u-col.vue` merges caller style with its width, gutter padding, and `margin-left` offset on one column root; Flutter must apply caller decoration after the offset has positioned that root, not around an offset wrapper.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_layout.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression proving UPCol decoration starts at its source offset, and that UPRow decoration contains the row children.
- [x] Run the UPCol regression before production changes and confirm the outer wrapper paints through the offset space.
- [x] Move UPCol caller decoration onto the positioned grid column while retaining width, gutter, negative offset, and clicks.
- [x] Format, run focused verification, and analyze `up_layout.dart`.
- [x] Run the full test suite and `git diff --check`.
- [x] Record the audited and resolved parity rules in `docs/gap-matrix.md`.

Completed: the UPCol offset regression, existing positive/negative offset and
layout regressions, and the independent UPRow root-scope regression passed.
`flutter analyze lib/src/widgets/up_layout.dart` reported no diagnostics.
`flutter test --reporter expanded` passed all 715 tests, and `git diff --check`
reported no whitespace errors.
