# UPSelect Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPSelect.customStyle` for API compatibility without rendering it, matching the uView select template.

**Architecture:** `u-select.vue` inherits the shared mixin but renders an unstyled root. It owns select label, overlay, and option-panel styles through source-specific computed values and explicit `overlayStyle`; it declares props inline, without a `props.js`, and never consumes shared `customStyle`. Flutter retains the compatible field while returning its source-backed anchored trigger and overlay panel directly.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source template, inline props, overlay and option-panel bindings, shared mixin behavior, and Flutter select tree.
- [x] Confirm that shared caller `customStyle` is not bound or forwarded, while dedicated `overlayStyle` and source-owned label/panel styles remain separate.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise border label, selected-label display, numeric option width, overlay panel, selection callbacks, and panel close behavior.
- [x] Run focused select regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPSelect (opens options|leaves source-inactive customStyle unrendered|selects option and closes|disabled does not open|uses an anchored page overlay outside clipped parents|public open close toggle|BatchB overlayClick/selectItem|BatchH resolved styles/open)" --reporter expanded` (8 passed)
- `flutter analyze lib/src/widgets/up_select.dart` (no issues)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
