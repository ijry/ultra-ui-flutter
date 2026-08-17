# UPTable2 Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPTable2.customStyle` for API compatibility without rendering it, matching the uView table2 template.

**Architecture:** `u-table2.vue` declares its own local props and its root binds only the `border` class. The scroll region, header, rows, and optional fixed-column layer bind source-owned geometry and cell styles; none consume or forward `customStyle`. Flutter keeps the compatible field while returning the source-backed table root with its independent border and scroll overlays.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root, local props, nested row forwarding, fixed-column overlay bindings, and Flutter table tree.
- [x] Confirm that `customStyle` is neither declared, bound, nor forwarded in the source component.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert that neither `DecoratedBox` nor `Container` renders it.
- [x] Exercise source-visible table behavior with a border, fixed-left column, header, and row values while caller decoration stays absent.
- [x] Run focused table2 regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPTable2 (renders rows|leaves source-inactive customStyle unrendered|BatchG selectChildren/getSortIcon|fixed-left columns stay visible after horizontal scroll|fixedHeader keeps header visible while body scrolls)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_table2.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPTable2 regressions: 5 passed.
- `flutter analyze lib/src/widgets/up_table2.dart`: no issues.
- Full Flutter suite: 738 passed.
- `git diff --check`: clean.
