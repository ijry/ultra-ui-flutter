# UPDatetimePicker Boundary and Input Display Re-Audit

**Goal:** Align the datetime picker public boundary helper and built-in input display state with `u-datetime-picker.vue`.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` exposes `getBoundary(type, innerValue)`, returning keys named `minYear` through `minSecond` or `maxYear` through `maxSecond`. Its supplied `innerValue` selects each nested year/month/day boundary branch.
- The source stores `inputValue` separately. `init()` sets it from the controlled value and `confirm()` refreshes it from `innerValue`; `change(e)` deliberately updates only `innerValue`, columns, indexes, and emits `change`.

## Completed Tasks

- [x] Add and observe a failing regression proving Flutter returned generic `year`/`month` boundary fields instead of source-prefixed keys.
- [x] Implement `getBoundary(type, innerValue)` with source-prefixed fields and nested boundary calculation.
- [x] Add and observe a failing integration regression proving an unconfirmed wheel change prematurely updated the default input from `03:04` to `04:04`.
- [x] Keep a distinct built-in input display value, initialized and controlled-value synchronized by source `init` behavior.
- [x] Refresh that display value only on source confirmation paths, while retaining the new wheel selection internally until confirmation.
- [x] Update the existing helper test to assert the source `minYear` key rather than the prior incompatible generic key.

## Verification

```powershell
flutter test test/widgets_test.dart --plain-name "UPDatetimePicker getBoundary returns source-prefixed fields" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPDatetimePicker input keeps its confirmed value while scrolling" --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: both new regressions first failed for their expected incompatible behavior, then passed after the scoped fixes. The focused datetime suite passed 40 tests; the full package suite passed 803 tests; static analysis and whitespace checks were clean. The pre-existing Flutter-specific `setValue()` public callback/display behavior remains outside this source-method audit.
