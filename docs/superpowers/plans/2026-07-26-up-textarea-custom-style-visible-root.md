# UPTextarea Custom Style Visible Root Parity Plan

**Goal:** Preserve caller `UPTextarea.customStyle` on the single source textarea root, including both the editable field and optional count indicator.

**Architecture:** `u-textarea.vue` deep-merges source textarea defaults and caller style onto one `.u-textarea` root. Flutter already uses one root container, but it must suppress a source fallback color when caller decoration provides a gradient because `BoxDecoration` cannot paint `color` and `gradient` together; all other caller fields remain on that same root.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_textarea.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue textarea root, default style merge ordering, count node, and Flutter decoration construction.
- [x] Add a failing gradient regression proving the styled root includes the field and count indicator.
- [x] Suppress only the incompatible Flutter source color when caller style supplies a gradient.
- [x] Format, run focused tests and analysis, then run the full suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: the new regression initially found the source white fallback color alongside a caller gradient. After clearing only that incompatible color, `dart format`, focused textarea tests, `flutter analyze lib/src/widgets/up_textarea.dart`, `flutter test --reporter expanded` (737 passed), and `git diff --check` all passed.
