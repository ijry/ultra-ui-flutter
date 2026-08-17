# UPDatetimePicker Controlled Value and Event Re-Audit

**Goal:** Match source datetime-picker controlled-value fallback, normalization, internal wheel state, and emitted event payloads.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` clears `showByClickInput` when external `show` becomes false, and calls `correctValue` for initial, model-value, props, and external-open reinitialization.
- Source `correctValue` falls back to `minDate` for invalid date-mode values and to padded `minHour`/`minMinute`/`minSecond` strings for empty time modes. It normalizes and returns a value; it does not mutate picker state itself.
- Source `change` writes the normalized selection into `innerValue`, rebuilds columns, and emits `{ value, mode }`. Source `confirm` emits the same object payload while `update:modelValue` carries the raw normalized value.

## Completed Tasks

- [x] Add and observe a failing external-hide regression proving local has-input visibility survived a controlled `show: false` update.
- [x] Clear local `showByClickInput` on an external true-to-false show transition.
- [x] Add and observe a failing empty-time initialization regression proving Flutter selected system time instead of the configured minimum.
- [x] Route controlled initialization, props/value updates, external reopening, and public `init` through the source fallback policy: empty date values use `minDate`; empty time values use configured minimum parts.
- [x] Add and observe a failing public `correctValue()` return regression, then make it source-compatible and pure: dates return clamped timestamps, time modes return padded range-limited strings.
- [x] Add and observe failing nested picker change/confirm payload regressions, then emit `{ value, mode }` while preserving raw `onUpdateValue`/`onUpdateModelValue` values.
- [x] Synchronize Flutter datetime `current` and regenerated columns after a nested picker wheel change, matching source `innerValue`/`updateColumnValue` behavior.
- [x] Preserve command `setValue` compatibility behavior, close/cancel/input behavior, formatters, boundary constraints, masks, and filtered columns.

## Verification

Focused regressions:

```powershell
flutter test test/widgets_test.dart --name UPPicker --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
```

Observed: 33 UPPicker/UPPickerData tests and 36 UPDatetimePicker tests passed.

```powershell
dart format lib/src/widgets/up_picker.dart lib/src/widgets/up_datetime_picker.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_picker.dart
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: formatting and analysis clean; all 799 tests passed; final diff check recorded with this batch.
