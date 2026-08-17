# UPLoadingIcon Custom Style Root Re-Audit Plan

**Goal:** Reconfirm that Flutter applies `UPLoadingIcon.customStyle` to the source-equivalent `.u-loading-icon` root, containing both spinner and optional text.

**Architecture:** `u-loading-icon.vue` explicitly binds `addStyle(customStyle)` on its outer conditional root. The spinner and optional text use their own source color, size, mode, timing, and layout props. Flutter mirrors that scope through an optional outer decorated `Container` around the generated spinner/text body.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root binding, visibility branch, spinner node, optional text node, and Flutter body wrapper.
- [x] Confirm that caller `customStyle` belongs to the outer loading-icon root and not to its spinner or text children.
- [x] Upgrade the root regression to use a distinctive gradient and border.
- [x] Exercise the vertical text layout while verifying the decorated root contains both `CustomPaint` and text.
- [x] Confirm Flutter's generated `DecoratedBox` is the single descendant paint node for the decorated root `Container`, not an additional caller-style target.
- [x] Run focused loading-icon regressions and component analysis without a production code change.
- [x] Record the confirmed source root scope in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPLoadingIcon applies customStyle to its source root" --reporter expanded`
- `flutter analyze lib/src/widgets/up_loading_icon.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPLoadingIcon regression: 1 passed.
- `flutter analyze lib/src/widgets/up_loading_icon.dart`: no issues.
- Full Flutter suite: 739 passed.
- `git diff --check`: clean.
