# UPBox Custom Style Root Audit Plan

**Goal:** Verify that `UPBox.customStyle` remains on the source-equivalent `.u-box` root.

**Architecture:** `u-box.vue` applies `addStyle(customStyle)` alongside its root height on the outer flex container that contains all three cells and their gaps. Flutter must place the decoration and fixed height on one root `Container`; an outer decoration around a `SizedBox` incorrectly adds caller border dimensions outside the source root height.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression verifying caller decoration contains all three UPBox regions on the fixed-height root.
- [x] Run the focused regression before production changes and confirm the outer wrapper incorrectly expands an 80px root to 84px with a 2px border.
- [x] Merge the fixed height and caller decoration on one UPBox root container.
- [x] Run the focused regression and analyze `up_box.dart`.
- [x] Run the full test suite and `git diff --check`, then record the audited parity result.

Completed: the focused root regression and
`flutter analyze lib/src/widgets/up_box.dart` completed without diagnostics.
After updating an older UPBox test to select its source cell by decoration
instead of Flutter container order, `flutter test --reporter expanded` passed
all 710 tests and `git diff --check` reported no whitespace errors.
