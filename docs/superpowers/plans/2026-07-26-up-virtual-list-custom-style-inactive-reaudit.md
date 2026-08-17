# UPVirtualList Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts the compatible `UPVirtualList.customStyle` field without rendering it, matching the source component which does not declare such a prop.

**Architecture:** `u-virtual-list.vue` owns local props only. Its root binds a source-derived height, its scroll view binds `scrollTop`, and item/placeholder nodes bind source virtualization geometry. No source node binds or forwards `customStyle`. Flutter keeps the extra constructor field for package API consistency while returning the source-backed `LayoutBuilder`, sized list, and item subtrees directly.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, local props, scroll container, item slot, and placeholder bindings with Flutter's list tree.
- [x] Confirm that the source neither imports a shared style mixin nor declares, binds, or forwards `customStyle`.
- [x] Upgrade the regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise source-visible fixed item height, visible-item metadata, and slot rendering while caller decoration stays absent.
- [x] Run focused virtual-list regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPVirtualList (builds visible items|passes source virtual item metadata and keyField|keeps source fixed item height|source helpers derive from scrollTop props|ignores undeclared source customStyle)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_virtual_list.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPVirtualList regressions: 5 passed.
- `flutter analyze lib/src/widgets/up_virtual_list.dart`: no issues.
- Full Flutter suite: 738 passed.
- `git diff --check`: clean.
