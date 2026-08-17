# UPInput Custom Style Visible Root Parity Plan

**Goal:** Preserve caller `UPInput.customStyle` on the source input root containing prefix, field, clear control, password toggle, and suffix content.

**Architecture:** `u-input.vue` deep-merges caller style into `wrapperStyle` on its one `.u-input` root. Flutter already renders its controls on one root container, but must suppress its fallback source color when caller style supplies a gradient, because `BoxDecoration` cannot paint both concurrently.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_input.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue input root, source style merge ordering, visible child controls, and Flutter decoration construction.
- [x] Add a failing gradient regression proving the styled root includes prefix, field, and suffix controls.
- [x] Suppress only the incompatible Flutter fallback color when caller style supplies a gradient.
- [x] Format, run focused tests and analysis, then run the full suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: the new regression initially found the source white fallback color alongside a caller gradient. After clearing only that incompatible color, `dart format`, focused input tests, `flutter analyze lib/src/widgets/up_input.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
