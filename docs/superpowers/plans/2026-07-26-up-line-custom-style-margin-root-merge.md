# UPLine Custom Style Margin Root Merge Plan

**Goal:** Align `UPLine.customStyle` with the source line root so caller decoration does not cover the source margin area.

**Architecture:** `u-line.vue` deep-merges caller style into `lineStyle`, where `margin`, length, border, and custom fields live on one `.u-line` node. Flutter will keep margin outside the decorated line root, placing caller decoration around the source-sized line before applying `Padding` for the CSS margin.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_layout.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression proving caller decoration covers the 100px line root and not its 20px horizontal margins.
- [x] Run the regression before the production change and confirm the existing wrapper decorates the margin area.
- [x] Move the custom decoration inside the source margin wrapper while retaining line length, hairline, and dashed behavior.
- [x] Format, run focused verification, and analyze `up_layout.dart`.
- [x] Run the full test suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Completed: the new margin-root regression, existing margin shorthand and
dashed-line regressions, and `flutter analyze lib/src/widgets/up_layout.dart`
completed without diagnostics. `flutter test --reporter expanded` passed all
712 tests, and `git diff --check` reported no whitespace errors.
