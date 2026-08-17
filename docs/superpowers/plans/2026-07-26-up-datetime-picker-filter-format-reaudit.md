# UPDatetimePicker Filter and Format Re-Audit

**Goal:** Make generated datetime-picker columns honor source `filter(type, values)` and make the built-in date input honor source `format`.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` applies `filter(type, values)` to each generated source column in `getOriginColumns()` before `updateColumns()` formats the values.
- Its `getInputValue(newValue)` uses the explicit `format` for date-based modes, while `time` and `timesecond` keep their raw time value.

## Completed Tasks

- [x] Add and observe a failing regression proving an hour-column filter was retained but not applied to Flutter picker columns.
- [x] Add and observe a failing regression proving a `DD/MM/YYYY` date input format was ignored.
- [x] Apply `filter` to each generated year, month, day, hour, minute, and second list before columns are selected.
- [x] Recompute each default index against the filtered column values so a removed selected value safely resolves to index zero, as in the source's `Math.max(0, findIndex(...))` path.
- [x] Rebuild columns when any source range boundary or `filter` callback identity changes.
- [x] Render explicit date format strings with the supported Day.js-compatible numeric tokens: `YYYY`, `YY`, `MM`, `M`, `DD`, `D`, `HH`, `H`, `mm`, `m`, `ss`, and `s`.
- [x] Preserve source time and time-second input display behavior and all existing confirmation, model, formatter, and mask forwarding paths.

## Verification

Focused regression command:

```powershell
flutter test test/widgets_test.dart --name "UPDatetimePicker (filters generated columns by type|formats its built-in date input value|confirms value|input trigger toggles its popup|setValue public API|public confirm getInputValue|BatchG correctValue/getRanges|BatchJ formatter/intercept)" --reporter expanded
```

Observed: 8 passed.

```powershell
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: analysis clean; all 752 tests pass; diff check is recorded with this batch after it completes.
