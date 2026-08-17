# UPCode Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPCode.customStyle` for API compatibility without rendering it, matching the logic-only uView verification-code component.

**Architecture:** `u-code.vue` inherits the shared mixin but contains an empty root view and explicitly documents that its behavior is implemented in JavaScript rather than its template. Its local props and timer methods never consume or forward `customStyle`. Flutter retains the compatible field on the stateful countdown helper while returning `SizedBox.shrink()` and preserving lifecycle callbacks, controller APIs, and keep-running storage.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source logic-only template, local props, lifecycle, timer methods, shared mixin behavior, and Flutter widget implementation.
- [x] Confirm that shared `customStyle` is not bound or forwarded and that the source component intentionally supplies no visual content.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise source start text, controller start, countdown text, reset text, and availability state in the same test.
- [x] Run focused code regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPCode (emits change text|leaves source-inactive customStyle unrendered|keepRunning resumes after rebuild|start reset public API|BatchD start/reset/changeEvent|Input/UPCode/UPCropper BatchJ shells)" --reporter expanded` (5 passed)
- `flutter analyze lib/src/widgets/up_code.dart` (no issues)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
