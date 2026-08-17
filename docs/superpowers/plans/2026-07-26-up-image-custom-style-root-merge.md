# UPImage Custom Style Root Merge Implementation Plan

**Goal:** Align `UPImage.customStyle` with uView's single `.u-image` root so caller decoration, source size, radius, and clipping share one visible node.

**Architecture:** `u-image.vue` deep-merges `customStyle` into `wrapStyle` and binds the result to the sized, overflow-controlling `.u-image` root. Flutter will use a single sized `Container` as that root, merge source corner geometry with non-null caller decoration fields, and clip its image/loading/error child only where the Vue root would hide overflow.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_image.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression that proves caller color, border, and radius live on the fixed-size, clipping `UPImage` root.
- [x] Run the regression before the production change and confirm the current outer-wrapper implementation fails it.
- [x] Merge source radius and caller decoration fields on the sized image root; retain source overflow rules for clipping.
- [x] Format, run the focused test, analyze `up_image.dart`, run the full test suite, and run `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Completed: `dart format`, the focused widget regression, and
`flutter analyze lib/src/widgets/up_image.dart` completed without diagnostics.
`flutter test --reporter expanded` passed all 708 tests, and
`git diff --check` reported no whitespace errors.
