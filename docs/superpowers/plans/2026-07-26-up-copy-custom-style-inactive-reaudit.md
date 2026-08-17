# UPCopy Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPCopy.customStyle` for API compatibility without rendering it, matching the uView copy component.

**Architecture:** `u-copy.vue` declares only `content`, `alertStyle`, and `notice` locally. Its root view binds only `handleClick` and renders either the default copy label or the supplied slot. It does not inherit the shared mixin and has no style binding, so Flutter retains the compatible field but returns the gesture path without a caller decoration.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete source template, local props, copy handlers, slot fallback, and Flutter copy widget tree.
- [x] Confirm that `customStyle` is neither declared by the source component nor bound or forwarded from its root.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise the active custom-slot child and click behavior with a deterministic clipboard channel mock, asserting both copied text and success callback.
- [x] Run focused copy regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPCopy (renders child|leaves source-inactive customStyle unrendered|copies content|rejects source falsey content|BatchD handleClick|BatchJ success fail shells)" --reporter expanded` (6 passed)
- `flutter analyze lib/src/widgets/up_copy.dart` (no issues)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
