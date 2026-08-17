# UPLink Custom Style Root Audit Plan

**Goal:** Verify that `UPLink.customStyle` remains attached to the source-equivalent text root and overrides intrinsic link style fields in source order.

**Architecture:** `u-link.vue` renders a single `text.u-link` node with the style array `[linkStyle, addStyle(customStyle)]`. Flutter renders a single `Text` inside a non-visual gesture handler and uses `TextStyle.merge(customStyle)`, which applies the caller style after the intrinsic style. No production change is required when the regression confirms this mapping.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root and style-array precedence with Flutter's rendered text and `TextStyle.merge` order.
- [x] Add and run a regression proving caller color and font size override source `linkStyle` on the one visible text node.
- [x] Run focused verification, `flutter analyze`, and `git diff --check`.
- [x] Run the full package test suite (717 tests green) and record the resolved parity rule in `docs/gap-matrix.md`.
