# UPView Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPView.customStyle` for API compatibility without rendering it, matching the uView template.

**Architecture:** `u-view.vue` inherits the shared mixin but directly binds its root only to explicit background, text color, flex, size, spacing, and border props. The component defines no separate `props.js`; the local declarations are inside the Vue component. Flutter keeps the shared field inert while rendering those source-owned layout paths and retaining the source's manual-only click handler.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete source root, direct local prop declarations, CSS, click handler, inherited mixin, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across single-child styling and multi-child flex branches while verifying active background, border, and alignment props.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused click-handler, reverse-flex, and inactive-style regressions
- `flutter analyze lib/src/widgets/up_view.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
