# UPCheckbox Custom Style Border Root Parity Plan

**Goal:** Preserve caller `UPCheckbox.customStyle` on the clipped source checkbox root while accurately retaining source column `borderBottom` class behavior.

**Architecture:** `u-checkbox.vue` deep-merges caller style into `checkboxStyle` on `.u-checkbox`, whose stylesheet sets `overflow: hidden`; for column groups, the global `.u-border-bottom` class applies an important 0.5px solid lower border and theme border color. Flutter will keep all caller decoration fields on the same root, merge the source class border priority with caller border sides, and enable clipping.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_checkbox.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue checkbox root, computed style, overflow, and shared border utility with Flutter's decoration construction.
- [x] Add a failing regression for a column group checkbox with caller gradient, border, and radius.
- [x] Merge the source column border effect with caller decoration and clip the source root.
- [x] Format, run focused tests and analysis, then run the full suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: the new regression initially failed because the source root used `Clip.none`. After the focused repair, `dart format`, the checkbox root-style and group event tests, `flutter analyze lib/src/widgets/up_checkbox.dart`, `flutter test --reporter expanded` (735 passed), and `git diff --check` all passed.
