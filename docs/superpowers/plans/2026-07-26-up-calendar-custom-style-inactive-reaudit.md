# UPCalendar Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPCalendar.customStyle` for API compatibility without rendering it, matching the uView calendar template.

**Architecture:** `u-calendar.vue` inherits the shared mixin, but delegates popup chrome to `u-popup` and renders an unstyled `u-calendar` root. Its only inline styles set the source-derived calendar-list height, and its nested header, month, confirmation button, and time-picker receive explicit source-owned props. Flutter retains the compatible field while returning its `UPPopup` root without a caller decoration.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the complete source template, props, mixin inheritance, inline-style targets, popup forwarding, and Flutter calendar build tree.
- [x] Confirm that shared `customStyle` is neither bound at the source root nor forwarded to `u-popup`, header, month, confirmation, or time-picker nodes.
- [x] Upgrade the inactive-style regression to use a distinctive gradient and assert no `DecoratedBox` or `Container` renders it.
- [x] Exercise the active page-inline `range` and `boundary` branches, title, week header, range labels, and confirmation button.
- [x] Run focused calendar regressions and component analysis without a production code change.
- [x] Record the source-compatible no-production-change conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPCalendar (select and confirm|minDate disables earlier days|range select and confirm|public prev next today setSelected|BatchC getConfirmValue/monthSelected/close/init|BatchH subtitle/selectedChange|BatchI month/date helpers|BatchJ setMonth/time helpers|BatchK range helpers|leaves source-inactive customStyle unrendered)" --reporter expanded` (10 passed)
- `flutter analyze lib/src/widgets/up_calendar.dart` (one pre-existing `unused_field` warning for the source API-shell `_innerFormatter` at line 704)
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
