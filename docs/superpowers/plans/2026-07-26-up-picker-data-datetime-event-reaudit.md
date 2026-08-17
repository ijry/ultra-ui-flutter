# UPPickerData and UPDatetimePicker Event Re-Audit

**Goal:** Align picker-data watcher scope and datetime-picker event emission with the source component templates and methods.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker-data\u-picker-data.vue` watches only `modelValue`; it has no `options` watcher. Replacing options therefore changes the nested picker column but does not recompute the wrapper's already displayed label or default index.
- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` declares only `close`, `cancel`, `confirm`, `change`, and `update:modelValue` emits. Its nested picker template binds `@close`, `@cancel`, `@confirm`, and `@change`, but does not bind `@update:show`.
- The source `setFormatter(e)` stores `innerFormatter` only. Columns and indexes are rebuilt by the existing `init`, value, props, and open paths rather than immediately by `setFormatter`.

## Completed Tasks

- [x] Add and observe a failing replacement-options regression proving Flutter recomputed a picker-data label where the Vue component does not.
- [x] Restrict UPPickerData resynchronization to changes of its effective model value; options continue reaching the nested picker without resetting wrapper state.
- [x] Confirm the command-style datetime `setFormatter` path matches source delayed-rebuild behavior and retain it without adding an unsupported immediate refresh.
- [x] Add and observe a failing datetime command regression proving `open()` and `close()` emitted unsupported `update:show` callbacks.
- [x] Stop forwarding nested or command-style show updates from UPDatetimePicker, while retaining its Dart callback parameter as a source-inactive compatibility no-op.
- [x] Preserve source close/cancel/confirm/change/model-value events, controlled `show`, has-input local visibility, and all existing picker column behavior.

## Verification

Focused regressions:

```powershell
flutter test test/widgets_test.dart --name UPPicker --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
```

Observed: 31 UPPicker/UPPickerData tests and 26 UPDatetimePicker tests passed.

```powershell
dart format lib/src/widgets/up_picker.dart lib/src/widgets/up_datetime_picker.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_picker.dart
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: formatting and analysis clean; all 787 tests passed; final diff check recorded with this batch.
