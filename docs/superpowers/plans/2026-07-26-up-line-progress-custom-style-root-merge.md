# UPLineProgress Custom Style Root Merge Plan

**Goal:** Merge `UPLineProgress.customStyle` into the source-equivalent clipped progress root.

**Architecture:** `u-line-progress.vue` applies caller style to the same `.u-line-progress` node that owns the default 100px radius and `overflow: hidden`; the inactive track and active segment are its children. Flutter will merge caller decoration fields with that source root geometry on one clipping `Container`, so caller backgrounds, borders, gradients, shadows, and radii are not hidden behind an outer decoration wrapper.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_line_progress.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Add a widget regression proving caller decoration and clipping live on the same progress root.
- [x] Run the regression before the production change and confirm the outer `DecoratedBox` has no source-root clipping container.
- [x] Merge source radius and caller decoration fields on one clipped root while retaining track, active segment, text, and from-right behavior.
- [x] Format, run focused verification, and analyze `up_line_progress.dart`.
- [x] Run the full test suite and `git diff --check` (716 tests green).
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.
