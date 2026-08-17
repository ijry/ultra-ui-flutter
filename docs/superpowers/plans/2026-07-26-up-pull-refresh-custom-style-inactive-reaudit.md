# UPPullRefresh Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts the compatible `UPPullRefresh.customStyle` field without rendering it, matching the source pull-refresh template.

**Architecture:** `u-pull-refresh.vue` declares local pull, scroll, and load-more props. Its root listens to touch events; the refresh indicator, translated content wrapper, optional scroll view, and optional load-more component use source-owned state and explicit props. It neither declares nor forwards `customStyle`. Flutter retains the compatible field while building the source-backed gesture, indicator, translated body, and optional load-more paths directly.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, indicator branches, translated content, scroll wrapper, load-more binding, and Flutter implementation.
- [x] Confirm that the source neither declares, binds, nor forwards `customStyle`.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise source pull text, child content, and load-more configuration while caller decoration stays absent.
- [x] Run focused pull-refresh regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPPullRefresh (builds child|keeps source initial refreshing watcher idle|resetRefresh only resets source distances|accepts source touch events while scrolled|ignores touch end without a source touch start|uses loadmoreProps for status and child props|does not forward loadmore child taps|uses source pull text and ignores customStyle)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_pull_refresh.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPPullRefresh regressions: 8 passed.
- `flutter analyze lib/src/widgets/up_pull_refresh.dart`: no issues.
- Full Flutter suite: 738 passed.
- `git diff --check`: clean.
