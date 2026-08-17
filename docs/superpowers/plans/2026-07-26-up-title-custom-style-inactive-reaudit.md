# UPTitle Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPTitle.customStyle` for API compatibility without rendering it, matching the standalone uView title template.

**Architecture:** `u-title.vue` defines no local props and imports no shared mixin. Its root row has only a named `prefix` slot, a default prefix fallback, and a default content slot; it has no `customStyle`, right-slot, or divider binding. Flutter retains the compatible field but leaves it inert while preserving the default prefix/text path and custom prefix/default-content slots.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete standalone source component, root row, default prefix fallback, named prefix slot, default slot, CSS, and Flutter widget tree.
- [x] Strengthen the caller-style regression with a distinctive gradient across both default and custom-prefix/default-content slot paths.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused title rendering, default-slot color, intrinsic-width, and inactive-style regressions
- `flutter analyze lib/src/widgets/up_title.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
