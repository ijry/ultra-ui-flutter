# UPTable Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPTable.customStyle` for API compatibility without rendering it, matching the uView table template.

**Architecture:** `u-table.vue` inherits the shared mixin but binds the root only to computed `tableStyle`, which owns the table's left/top borders and background color. It renders its default slot only while its local `show` flag is true and does not merge or forward the shared caller style. Flutter keeps the compatible field inert while retaining the source-owned table decoration and child table hierarchy.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source template, local props, computed `tableStyle`, shared mixin behavior, and Flutter table tree.
- [x] Confirm that the shared `customStyle` prop is not bound or forwarded while source `borderColor`, `bgColor`, alignment, padding, and cell styling remain active.
- [x] Upgrade the inactive-style test to use a distinctive gradient and assert neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise header/cell layout and verify active table background plus left border rendering.
- [x] Run focused table regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPTable (renders header and cells|leaves source-inactive customStyle unrendered|BatchF change shell)" --reporter expanded` (3 passed)
- `flutter analyze lib/src/widgets/up_table.dart` (no issues)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
