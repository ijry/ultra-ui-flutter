# UPDatetimePicker Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPDatetimePicker.customStyle` for API compatibility without rendering it, matching the uView datetime-picker template.

**Architecture:** `u-datetime-picker.vue` inherits the shared mixin, but its unstyled root only conditionally renders the input trigger and passes explicit source-owned values to nested `u-picker`. It neither binds `customStyle` nor forwards it, so Flutter retains the field but returns the source-backed `UPPicker` directly. The regression uses a distinctive gradient and checks both Flutter decoration representations while exercising the input-trigger and time-second column branches.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare `u-datetime-picker.vue`, `props.js`, source slots, picker forwarding, and Flutter `UPDatetimePickerState.build`.
- [x] Confirm that shared `customStyle` is neither rendered by the source root nor forwarded to the nested picker, while dedicated `maskStyle` remains a separate prop.
- [x] Upgrade the inactive-style regression to use a unique gradient and verify no `DecoratedBox` or `Container` renders it.
- [x] Exercise the active `hasInput` custom trigger, visible toolbar title, confirmation control, and constrained `timesecond` columns.
- [x] Run focused datetime-picker regressions and component analysis without a production code change.
- [x] Record the confirmed source-compatible behavior in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPDatetimePicker (confirms value|leaves source-inactive customStyle unrendered|setValue public API|public confirm getInputValue|BatchG correctValue/getRanges|BatchJ formatter/intercept)" --reporter expanded` (6 passed)
- `flutter analyze lib/src/widgets/up_datetime_picker.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
