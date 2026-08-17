# UPCollapse Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPCollapse.customStyle` and `UPCollapseItem.customStyle` without rendering them, while preserving the source-active `cellCustomStyle` path.

**Architecture:** `u-collapse.vue` renders an unstyled root with source-owned border lines. `u-collapse-item.vue` renders an unstyled item root and forwards its distinct `cellCustomStyle` prop to `u-cell`. Flutter keeps both inherited `customStyle` constructor fields inert, but must continue applying `cellCustomStyle` only to the header cell root and keep caller decoration away from expanded content and separators.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the collapse/item source roots, generated lines, expanded content, and cellCustomStyle forwarding with Flutter's widget tree.
- [x] Strengthen the regression using separate gradients for parent/item inactive styles and source-active cellCustomStyle; exercise the expanded content path.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused collapse inactive-style and toggle regressions, `flutter analyze lib/src/widgets/up_collapse.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
