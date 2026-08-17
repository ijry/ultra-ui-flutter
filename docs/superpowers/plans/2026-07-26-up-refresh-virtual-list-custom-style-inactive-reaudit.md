# UPRefreshVirtualList Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts the compatible `UPRefreshVirtualList.customStyle` field without rendering or forwarding it, matching the source composition template.

**Architecture:** `u-refresh-virtual-list.vue` declares only its local data and virtualization props. Its entire template forwards explicit values to `u-pull-refresh` and `u-virtual-list`, including refresh state, threshold, list data, item geometry, scroll position, and handlers. It does not declare or forward `customStyle`. Flutter preserves its compatible extra field while constructing the source-equivalent refresh and virtual-list composition directly.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source composition, local props, nested component parameter forwarding, and Flutter wrapper tree.
- [x] Confirm that the source neither declares nor forwards `customStyle` to pull-refresh or virtual-list children.
- [x] Upgrade the regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise the nested refresh wrapper, virtual items, source metadata, and refresh event while caller decoration stays absent.
- [x] Run focused refresh-virtual-list regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPRefreshVirtualList (builds items|handleRefresh updates source state first|keeps source pull-refresh scroll wrapper|ignores undeclared source customStyle)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_refresh_virtual_list.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPRefreshVirtualList regressions: 4 passed.
- `flutter analyze lib/src/widgets/up_refresh_virtual_list.dart`: no issues.
- Full Flutter suite: 738 passed.
- `git diff --check`: clean.
