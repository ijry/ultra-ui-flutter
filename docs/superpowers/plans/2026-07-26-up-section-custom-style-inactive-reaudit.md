# UPSection Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPSection.customStyle` for API compatibility without rendering it, consistent with the uView module's lack of a section render component.

**Architecture:** The source `u-section` directory contains only `section.js`, which declares defaults and no Vue template or local custom-style prop. Flutter supplies a native section presentation for title, accent line, subtitle, and arrow, but must not invent a shared-style binding that has no source counterpart.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Verify the source module contains defaults only and no Vue render tree or custom-style binding.
- [x] Strengthen the regression with a caller gradient while mounting title, accent line, subtitle, and arrow branches.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and title regressions
- `flutter analyze lib/src/widgets/up_section.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
