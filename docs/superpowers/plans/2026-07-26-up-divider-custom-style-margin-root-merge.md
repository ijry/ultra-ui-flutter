# UPDivider Custom Style Margin Root Merge Plan

**Goal:** Align `UPDivider.customStyle` with the source divider root so caller decoration does not cover the divider's CSS margin.

**Architecture:** `u-divider.vue` binds `addStyle(customStyle)` to `.u-divider`, whose own stylesheet supplies `margin: 15px 0`. Flutter will apply the caller decoration to the row root and place its `Padding` margin outside that root, preserving source text, dot, slot, line placement, and click behavior.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_layout.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression proving caller decoration covers divider content but not the source 15px vertical margins.
- [x] Run the regression before the production change and confirm the existing wrapper decorates the margin area.
- [x] Move the custom decoration inside the source margin wrapper while retaining click and line/text placement.
- [x] Format, run focused verification, and analyze `up_layout.dart`.
- [x] Run the full test suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Completed: the new margin-root regression and existing click, line-position, and
slot regressions completed successfully, and `flutter analyze
lib/src/widgets/up_layout.dart` reported no diagnostics. `flutter test
--reporter expanded` passed all 713 tests, and `git diff --check` reported no
whitespace errors.
