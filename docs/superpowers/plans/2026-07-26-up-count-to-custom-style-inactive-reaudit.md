# UPCountTo Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPCountTo.customStyle` for API compatibility without rendering it, matching the uView number-animation template.

**Architecture:** `u-count-to.vue` renders one text node whose inline style contains only its local `fontSize`, `fontWeight`, and `color` props. The shared mixin `customStyle` prop is never bound. Flutter keeps the accepted field inert so caller decoration cannot wrap or alter the displayed number.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source text node, its local inline style map, inherited props, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient and verify it cannot reach the animated number.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and completion regressions
- `flutter analyze lib/src/widgets/up_count_to.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
