# UPEmpty Custom Style Root Audit Plan

**Goal:** Verify that `UPEmpty.customStyle` and source `marginTop` remain attached to the source-equivalent visible empty-state root.

**Architecture:** `u-empty.vue` binds `[emptyStyle]` to a single `.u-empty` view; `emptyStyle` merges caller style and source `marginTop`. CSS margin is outside root painting. Flutter renders one `Container` with the caller decoration and an external `margin`, containing the icon, text, and optional child. No production change is required when the regression confirms this mapping.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, style merge order, and CSS margin behavior with Flutter's root container.
- [x] Add and run a regression proving caller decoration and source margin share the one empty root.
- [x] Run focused and full package verification, `flutter analyze`, and `git diff --check` (721 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
