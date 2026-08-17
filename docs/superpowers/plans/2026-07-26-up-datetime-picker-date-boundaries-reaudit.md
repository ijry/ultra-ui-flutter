# UPDatetimePicker Date Boundary Re-Audit

**Goal:** Constrain Flutter datetime-picker date columns to the source `minDate`/`maxDate` hierarchy and rebuild those constraints after a wheel selection.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` computes date-mode ranges through `getBoundary('min', innerValue)` and `getBoundary('max', innerValue)`.
- The source applies limits in order: year, month, date, hour, minute, then second. A lower-level range narrows only while all earlier parts equal the relevant boundary.
- Its `change()` path corrects the composed date to the configured range and calls `updateColumnValue()`, causing constrained columns to rebuild after every selection.

## Completed Tasks

- [x] Add and observe a failing `datetime` regression proving a May 10 through May 20 range incorrectly exposed every month and day.
- [x] Add and observe a failing selection regression proving choosing the maximum date incorrectly retained hours after the configured maximum hour.
- [x] Clamp date-mode initial, updated, and programmatic values to `minDate`/`maxDate`.
- [x] Port the source's hierarchical minimum/maximum boundary calculation for date columns.
- [x] Apply the active boundaries before filter processing and default-index resolution.
- [x] Rebuild constrained columns after date composition so selecting a boundary day narrows later hour/minute/second wheels.
- [x] Preserve independent `time` and `timesecond` min/max ranges, filter behavior, input formatting, callbacks, and popup behavior.

## Verification

Focused regression command:

```powershell
flutter test test/widgets_test.dart --name "UPDatetimePicker (narrows date columns to active boundaries|rebuilds boundaries after a date selection|filters generated columns by type|confirms value|setValue public API|public confirm getInputValue|BatchG correctValue/getRanges|BatchJ formatter/intercept)" --reporter expanded
```

Observed: 8 passed.

```powershell
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: analysis clean; all 754 tests pass; diff check is recorded with this batch after it completes.
