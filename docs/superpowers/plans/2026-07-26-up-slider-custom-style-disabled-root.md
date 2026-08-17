# UPSlider Custom Style Disabled Root Parity Plan

**Goal:** Keep `UPSlider.customStyle` on the source-equivalent outer slider root when disabled, while applying disabled opacity only to the internal interactive slider surface.

**Architecture:** `u-slider.vue` binds `addStyle(customStyle)` to `.u-slider`; its disabled class is attached to nested `.u-slider-inner`, where stylesheet opacity is defined. Flutter will preserve caller decoration outside the disabled `Opacity` and apply opacity only to the generated Material slider/value content, matching the source node boundary.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_slider.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source root custom-style binding with the nested disabled class and inspect Flutter's outer opacity wrapper.
- [x] Identify that Flutter currently dims caller root decoration even though source applies opacity only to the inner slider node.
- [x] Add a regression proving disabled caller decoration remains outside the opacity layer while the slider content is inside it.
- [x] Move Flutter's disabled opacity beneath the caller root decoration without altering length, vertical, range, value, or callback behavior.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: `dart format`, focused slider style/event tests, `flutter analyze lib/src/widgets/up_slider.dart`, `flutter test --reporter expanded` (731 passed), and `git diff --check` all passed.
