# UPIndexList Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPIndexList.customStyle` for API compatibility without rendering it, matching the uView index-list template.

**Architecture:** `u-index-list.vue` inherits the shared mixin but binds the root only to its own scroll-content, letter-rail, and touch-indicator paths. Its local props define colors, index data, sticky behavior, navigation height, bottom safety, and item margin, but no source template node binds `customStyle`. Flutter leaves the field inert while preserving source header/footer content, object index labels, rail selection, and the touch indicator.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, scroll-view, header/footer slots, letter rail, transition-wrapped indicator, local props, CSS, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across object index labels, header/footer content, and the active touch-indicator branch.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused anchor-rendering, object-index, touch-helper, navigation, and inactive-style regressions
- `flutter analyze lib/src/widgets/up_index_list.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
