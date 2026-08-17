# UPFormItem Custom Style Body Root Parity Plan

**Goal:** Apply caller `UPFormItem.customStyle` only to the source-equivalent form body, excluding error content and the optional lower line.

**Architecture:** `u-form-item.vue` renders the outer `.u-form-item` as a column; its inner `.u-form-item__body` owns the caller style and 10px vertical padding, while the error slot and `u-line` are following siblings. Flutter will preserve the existing form layout and interaction handler while moving the decorated container to the matching inner body node.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_form.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue form-item template and stylesheet with the Flutter widget hierarchy.
- [x] Add a failing regression that distinguishes the styled body from the sibling error text and lower line.
- [x] Move the decorated/padded Flutter container to the source-equivalent body node.
- [x] Format, run focused tests and analysis, then run the full suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: the new regression initially found the error message inside the caller decoration. After moving the body root, `dart format`, focused form-item tests, `flutter analyze lib/src/widgets/up_form.dart`, `flutter test --reporter expanded` (736 passed), and `git diff --check` all passed.
