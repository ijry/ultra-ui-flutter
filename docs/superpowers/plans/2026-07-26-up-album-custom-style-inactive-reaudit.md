# UPAlbum Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPAlbum.customStyle` for API compatibility without rendering it, matching the uView album template.

**Architecture:** `u-album.vue` inherits the shared mixin but has an unstyled root and styles only its rows, image wrappers, images, and internal overflow counter. The source's sole `customStyle` use is a fixed literal on the nested overflow `up-text`, not the album caller prop. Flutter preserves the compatible field while returning its empty and populated source-backed album paths directly.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete source template, props, row/image/overflow styles, shared mixin behavior, and Flutter album tree.
- [x] Confirm that shared caller `customStyle` is absent from every source root and child binding; distinguish the internal fixed overflow-text style.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise empty, fixed-row overflow, preview callback, `+N` counter, and auto-wrap branches.
- [x] Run focused album regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPAlbum (renders images placeholders|showMore and preview callback|previewHandler public API|BatchD getSrc/onPreviewTap|BatchH showUrls/imageStyle|leaves source-inactive customStyle unrendered)" --reporter expanded` (6 passed)
- `flutter analyze lib/src/widgets/up_album.dart` (no issues)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
