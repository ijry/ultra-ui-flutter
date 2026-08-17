# UPCard Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPCard.customStyle` for API compatibility without rendering it, matching the uView card template.

**Architecture:** `u-card.vue` binds source-owned root radius, margin, and shadow fields, and has separate `headStyle`, `bodyStyle`, and `footStyle` paths for child regions. It never binds the shared mixin prop. Flutter must keep that shared field inert so caller decoration cannot leak onto the root card or any head/body/foot content, including supplied slots.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root style map, head/body/foot style paths, slots, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient across custom head, body, and foot content.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and regional-tap regressions
- `flutter analyze lib/src/widgets/up_card.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
