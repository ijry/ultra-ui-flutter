# UPGrid Custom Style Root Audit Plan

**Goal:** Verify that `UPGrid.customStyle` remains on the source-equivalent `.u-grid` root.

**Architecture:** `u-grid.vue` deep-merges `customStyle` into `gridStyle` on its sole grid root, which contains every grid item. Flutter's optional decorated `Container` wraps the scope and layout as one visible root without adding clipping or an independent size constraint, so its decoration scope is equivalent; no production hierarchy change is required if a regression confirms it.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression verifying caller decoration contains all grid items on the grid root.
- [x] Run the focused regression and analyze `up_grid.dart`.
- [x] Run the full test suite and `git diff --check`, then record the audited parity result.

Completed: the focused root regression and
`flutter analyze lib/src/widgets/up_grid.dart` completed without diagnostics.
`flutter test --reporter expanded` passed all 711 tests, and
`git diff --check` reported no whitespace errors.
