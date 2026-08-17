# UPSearch Custom Style Root Audit Plan

**Goal:** Preserve `UPSearch.customStyle` on the source-equivalent search root while keeping its `margin` outside that decoration and content appearance on the internal field node.

**Architecture:** `u-search.vue` applies root inline margin first and `addStyle(customStyle)` to `.u-search`; `.u-search__content` separately owns the input background, border, radius, and overflow. Flutter already places a decorated search row inside outer margin padding, with the input field decoration inside the row, so this batch adds regression coverage only.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source root margin/custom-style binding with the separate content decoration and inspect Flutter's row, padding, and field structure.
- [x] Confirm caller decoration is on the row root before Flutter's outer margin padding, while background/border/radius remain on the field container.
- [x] Add a regression proving the decorated root contains both field and action without moving root decoration into the field.
- [x] Run formatting, focused search tests, analysis, the complete package suite, and `git diff --check`.
- [x] Record the confirmed source scope in `docs/gap-matrix.md`.

Verification: `dart format`, focused search style/interaction tests, `flutter analyze lib/src/widgets/up_search.dart`, `flutter test --reporter expanded` (730 passed), and `git diff --check` all passed.
