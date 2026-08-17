# UPScrollList Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPScrollList.customStyle` for API compatibility without rendering it, matching the uView scroll-list template.

**Architecture:** `u-scroll-list.vue` inherits the shared mixin, but the root, horizontal scroll view, content row, and optional indicator bind only source-owned classes and dedicated `indicatorStyle`, `barStyle`, and `lineStyle` values. Flutter therefore keeps the shared field inert while its horizontal content, indicator state, edge callbacks, and public scroll controls remain source-backed.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, platform scroll-view branches, content slot, optional indicator, local props, CSS, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across indicator-enabled and indicator-disabled branches while confirming dedicated `indicatorStyle` remains active.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused child-rendering, inactive-style, and edge-event regressions
- `flutter analyze lib/src/widgets/up_scroll_list.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
