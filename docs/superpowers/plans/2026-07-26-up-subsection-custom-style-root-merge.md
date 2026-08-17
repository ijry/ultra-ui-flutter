# UPSubsection Custom Style Root Merge Plan

**Goal:** Merge `UPSubsection.customStyle` with source wrapper fields on one clipped subsection root, so caller decoration remains visible behind the active bar and items.

**Architecture:** `u-subsection.vue` applies `[addStyle(customStyle), wrapperStyle]` to outer `.u-subsection`; its button-mode wrapper background comes after caller style, while the source class supplies radius and overflow clipping. Flutter will create one root `Container` for the fixed height, padding, stack, caller decoration, source button background, radius, and clipping. The caller gradient suppresses source color only because Flutter `BoxDecoration` cannot paint both, corresponding to CSS's visible gradient layer.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_subsection.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source outer wrapper style order, class radius/overflow, and child bar/items with Flutter's nested decorations.
- [x] Identify that the Flutter inner background hides caller decoration and separates root clipping from caller radii.
- [x] Add a regression proving caller gradient, border, radius, and clipping share the visible subsection root.
- [x] Merge source and caller decorations on one clipped root while retaining source button background precedence for plain colors.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: `dart format`, focused subsection tests, `flutter analyze lib/src/widgets/up_subsection.dart`, `flutter test --reporter expanded` (726 passed), and `git diff --check` all passed.
