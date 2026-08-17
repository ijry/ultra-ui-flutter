# UPPagination Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPPagination.customStyle` as a compatible extra API without rendering it, matching the source pagination component.

**Architecture:** `u-pagination.vue` neither imports the shared mixin nor declares a `customStyle` prop. Its template applies only local button background/border fields and renders pager, total, sizes, and next/previous controls. Flutter keeps its compatibility field inert so caller decoration cannot leak onto any pagination layout or control.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source prop declaration and all rendered pagination branches with Flutter's widget tree.
- [x] Strengthen the regression with a caller gradient across pager, total, sizes, and custom previous/next labels.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and page-change regressions
- `flutter analyze lib/src/widgets/up_pagination.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
