# UPSteps Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPSteps.customStyle` for API compatibility without rendering it, matching the uView steps template.

**Architecture:** `u-steps.vue` renders only an unstyled direction root and its child slot. `u-steps-item.vue` builds source-owned marker, connector line, and content nodes, binding only its local `itemStyle` and computed line/content styles. Flutter keeps the parent shared-style field inert so caller decoration does not leak onto direction layout, markers, lines, or step content.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source steps root, item marker/line/content nodes, and their local style bindings with Flutter's widget tree.
- [x] Strengthen the regression using a caller gradient with vertical, dot, error, and icon branches mounted.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
