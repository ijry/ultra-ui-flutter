# UPPickerData Model Value Re-Audit

**Goal:** Match the exact `modelValue` watcher branches in the source `u-picker-data` wrapper.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker-data\u-picker-data.vue` uses `if (this.modelValue)` in both `created` and its `modelValue` watcher. Under the declared string/number prop type, zero and an empty string take the `clear()` branch.
- For a truthy value, the source iterates options and changes `current`/`defaultIndex` only when an item matches `valueKey`. A truthy value absent from options leaves any previous wrapper label and index intact.

## Completed Tasks

- [x] Add and observe a failing regression showing Flutter rendered the configured zero option although source truthiness clears a numeric zero model value.
- [x] Add and observe a failing regression showing Flutter cleared a previous label/index for an unmatched truthy model value whereas the source preserves them.
- [x] Port the source falsey branch for null, false, empty strings, zero, and NaN number values.
- [x] Restrict truthy model synchronization to actual option matches; preserve established current/default-index state for unmatched values.
- [x] Preserve configured value/label confirmation, options-column propagation, close/cancel behavior, trigger cover, and model aliases.

## Verification

Focused regressions:

```powershell
flutter test test/widgets_test.dart --name UPPicker --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
```

Observed: 33 UPPicker/UPPickerData tests and 26 UPDatetimePicker tests passed.

```powershell
dart format lib/src/widgets/up_picker.dart lib/src/widgets/up_datetime_picker.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_picker.dart
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: formatting and analysis clean; all 789 tests passed; final diff check recorded with this batch.
