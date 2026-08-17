# UPDatetimePicker Input Event Timing Re-Audit

**Goal:** Align `UPDatetimePicker` `onInput` timing with the source `u-datetime-picker` event contract.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` updates `innerValue`, columns, and emits only `change` from `change(e)`.
- Its `confirm()` emits the model update and `input` event before emitting `confirm`. The nested `<u-picker>` template binds `@confirm="confirm"`, so toolbar and public command confirmation share this commit boundary.

## Completed Tasks

- [x] Add and observe a failing regression showing that wheel changes incorrectly invoked `onInput` before confirmation.
- [x] Add and observe a failing regression showing that public command `confirm()` omitted `onInput`.
- [x] Keep nested picker wheel changes limited to internal value/column synchronization and the source `{ value, mode }` `onChange` payload.
- [x] Emit `onInput` from nested toolbar confirmation after model-value callbacks.
- [x] Emit `onInput` from public command confirmation after model-value callbacks.
- [x] Preserve input-popup close state, confirmation payloads, controlled visibility, and all unrelated picker events.

## Verification

```powershell
flutter test test/widgets_test.dart --plain-name "UPDatetimePicker emits input only on confirmation" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPDatetimePicker command confirmation emits input" --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: both tests first failed for their expected pre-fix behavior, then passed after the minimal event-boundary fix. This audit covers nested wheel and confirmation paths only; the pre-existing Flutter-specific `setValue()` callback contract remains outside its scope. The focused datetime suite passed 38 tests; full package suite passed 801 tests; static analysis and diff whitespace checks were clean.
