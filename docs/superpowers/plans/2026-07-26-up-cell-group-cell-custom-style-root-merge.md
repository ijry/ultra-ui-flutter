# UPCellGroup And UPCell Custom Style Root Merge Plan

**Goal:** Render `UPCellGroup.customStyle` and `UPCell.customStyle` on the same visible roots that their uView templates style.

**Architecture:** `u-cell-group.vue` applies `[groupStyle, addStyle(customStyle)]` to its outer `.u-cell-group`, including the optional title and the cell wrapper. Flutter will decorate one outer root around both regions and merge caller fields with the source card background. `u-cell.vue` styles its outer `.u-cell` while its body is transparent; Flutter will retain the root decoration but make the internal fallback background transparent when caller decoration is present, so root colors and gradients remain visible behind the body and divider.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_cell.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source group and cell root style bindings with the Flutter widget tree.
- [x] Identify the group-title exclusion, caller-gradient/default-color conflict, and opaque cell-body mismatch.
- [x] Add regressions proving group decoration contains its title and cell-root gradients remain visible behind the body.
- [x] Merge group decoration fields on one outer root and make a styled cell body transparent.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check` (720 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
