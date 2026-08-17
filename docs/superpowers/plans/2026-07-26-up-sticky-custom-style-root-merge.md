# UPSticky Custom Style Root Merge Plan

**Goal:** Merge `UPSticky.customStyle` and source background onto the same outer sticky root without a Flutter-only child background covering caller gradients and radii.

**Architecture:** `u-sticky.vue` applies `deepMerge(addStyle(customStyle), style)` to outer `.u-sticky`, while its inner `.u-sticky__content` becomes fixed only in the JavaScript sticky fallback. Flutter will build one source-root decoration from source `bgColor` plus caller fields, and place the normal/fixed placeholder content directly inside it. It will not apply the custom decoration to the fixed Overlay content, because source JS mode fixes only the inner content node.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_sticky.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare Vue outer root and fixed inner content styles with Flutter's placeholder and Overlay tree.
- [x] Identify that the Flutter-only inner `ColoredBox` obscures caller root gradients and radii in normal layout.
- [x] Add a regression proving caller decoration and source background are merged on one sticky root with no inner background cover.
- [x] Merge caller decoration fields into the outer root while keeping the fixed Overlay content unstyled.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check` (725 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
