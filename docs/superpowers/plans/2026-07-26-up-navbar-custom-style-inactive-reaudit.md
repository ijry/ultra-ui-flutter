# UPNavbar Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPNavbar.customStyle` for compatibility without rendering it, matching the uView navbar template.

**Architecture:** `u-navbar.vue` applies only computed `navbarInnerStyle` to its inner node, deriving source background from `bgColor` or theme. It does not bind the inherited shared prop. Flutter retains the constructor field while keeping caller decoration off the fixed placeholder, safe-area region, inner navbar, border, and left/center/right content.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, placeholder, inner node, content nodes, and computed background style with Flutter's widget tree.
- [x] Strengthen the regression with fixed placeholder, border, left/right content, and a caller gradient.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused navbar inactive-style and render regressions, `flutter analyze lib/src/widgets/up_navbar.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
