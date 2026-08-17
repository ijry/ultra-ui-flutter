# UPRadio Custom Style Border Root Parity Plan

**Goal:** Preserve caller `UPRadio.customStyle` on the clipped source radio root while accurately retaining the source column `borderBottom` class behavior.

**Architecture:** `u-radio.vue` deep-merges caller style into `radioStyle` on `.u-radio`, whose stylesheet supplies `overflow: hidden`; with column `borderBottom`, global `.u-border-bottom` uses `!important` to set the bottom border width/style and border color. Flutter will merge that source border effect with caller decoration instead of replacing all caller border sides, then clip the decorated radio root.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_radio.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare Vue `radioStyle`, root overflow, and global `.u-border-bottom` priority with Flutter's current decoration construction.
- [x] Identify that Flutter overwrites all caller border sides for column borders and lacks source root clipping.
- [x] Add a regression proving caller gradient/radius stay on the clipped root while source class border behavior overrides only its intended dimensions/colors.
- [x] Merge source column border fields with caller decoration and enable root clipping without changing selection behavior.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: `dart format`, focused radio style/selection tests, `flutter analyze lib/src/widgets/up_radio.dart`, `flutter test --reporter expanded` (733 passed), and `git diff --check` all passed.
