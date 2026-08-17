# UPBackTop Custom Style Root Merge Plan

**Goal:** Merge `UPBackTop.customStyle` into the source-equivalent back-to-top content root without retaining Flutter-incompatible default color alongside a caller gradient.

**Architecture:** `u-back-top.vue` gives the fixed position and fade animation to `u-transition`, then applies `[contentStyle]` to its inner `.u-back-top` view. `contentStyle` deep-merges the source radius with caller style. Flutter will keep positioning and transitions outside the decorated 40px content node, then merge every `BoxDecoration` field on that content node; caller gradient suppresses the source gray color because Flutter decorations cannot contain both.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_back_top.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source transition root, content root, and caller style precedence with Flutter's widget tree.
- [x] Identify the gradient conflict caused by retaining default color in `BoxDecoration.copyWith`.
- [x] Add a regression proving caller gradient and border apply to the 40px content root without an exception.
- [x] Merge decoration fields on the content root while suppressing default color for caller gradients.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check` (718 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
