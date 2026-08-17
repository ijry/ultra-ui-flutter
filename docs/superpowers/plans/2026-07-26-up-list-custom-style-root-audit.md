# UPList Custom Style Root Audit Plan

**Goal:** Verify that `UPList.customStyle` remains attached to the source-equivalent scroll root and shares its configured dimensions.

**Architecture:** `u-list.vue` binds computed `listStyle` to the one `scroll-view` root. The style includes source width/height, then deep-merges caller style. Flutter uses a single sized `Container` with the caller decoration around its `ListView`, so the decoration and scroll viewport occupy the same root. No production change is required when the regression confirms this mapping.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare source `scroll-view` style binding and computed dimensions with Flutter's decorated scroll viewport container.
- [x] Add and run a regression proving caller decoration and source dimensions share the list root.
- [x] Run focused and full package verification, `flutter analyze`, and `git diff --check` (723 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
