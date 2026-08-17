# UPLoadmore Custom Style Root Re-Audit Plan

**Goal:** Reconfirm that Flutter applies `UPLoadmore.customStyle` to the source-equivalent root while preserving source-owned background, spacing, text, loading icon, and line behavior.

**Architecture:** `u-loadmore.vue` explicitly binds `addStyle(customStyle)` as the first source root style, followed by local `bgColor`, margin, and height values. Its nested line, text, icon, and click branches own independent source behavior. Flutter mirrors the root scope by retaining the caller decoration on the outer `Container` while merging the dedicated `bgColor` base; the caller gradient remains on the generated `DecoratedBox` and source background remains available on the `Container`.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root style array, shared mixin props, nested line/text/icon branches, and Flutter root decoration.
- [x] Confirm that caller `customStyle` belongs to the outer `.u-loadmore` equivalent, not to text, icon, or line children.
- [x] Add a distinctive gradient regression that verifies caller gradient and source `bgColor` coexist on the root decoration path.
- [x] Exercise source loading text, line branch, click semantics, dot text, and public load-more aliases.
- [x] Investigate the Flutter decoration merge behavior: the focused regression confirms `BoxDecoration` retains caller gradient while the root container retains the source background color, so no production change is required.
- [x] Run focused loadmore regressions and component analysis without a production code change.
- [x] Record the confirmed source root scope in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPLoadmore (loading text|keeps source customStyle on its root|source only binds loadmore tap to status text|nomore dot uses source glyph|BatchG loadMore)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_loadmore.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPLoadmore regressions: 5 passed.
- `flutter analyze lib/src/widgets/up_loadmore.dart`: no issues.
- Full Flutter suite: 739 passed.
- `git diff --check`: clean.
