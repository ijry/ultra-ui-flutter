# UPPicker and UPDatetimePicker Template Reactivity Re-Audit

**Goal:** Align the Flutter picker wrappers with the explicit template bindings, data shapes, formatting paths, and controlled-visibility behavior in `uview-plus`.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker\u-picker.vue` reads object labels strictly from `keyName` and values strictly from `valueName`; `changeHandler` reports the first index differing from `lastIndex`, and overlay close emits `update:show(false)` when enabled.
- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker-data\u-picker-data.vue` renders a disabled `up-input` with an absolute click cover, passes `[options]` as the picker columns, binds only `confirm`, `cancel`, and `close`, and implements `close()` as an outward event without changing local `show`.
- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` forwards toolbar slots and input props through its nested picker, restores controlled values when opened, accepts source time strings, and applies `formatter(type, value)` to generated columns.

## Completed Tasks

- [x] Keep UPPicker object label/value lookup strict to `keyName`/`valueName` and report the source first-unconfirmed `columnIndex`.
- [x] Forward `toolbarBottom`, preserve an externally controlled `show: true` after an overlay-close request, and retain the source `update:show(false)` notification.
- [x] Make UPPickerData confirmation consume raw picker items while emitting `valueKey`, use one `[options]` column, and render the source disabled-input defaults.
- [x] Replace the wrapper-only trigger detector with a source-equivalent topmost click cover, so the disabled Flutter `TextField` cannot prevent picker opening.
- [x] Keep UPPickerData local `show` unchanged for `close` and ignore unbound nested picker `update:show` events; cancel and confirm retain their source-local closing behavior.
- [x] Forward UPDatetimePicker toolbar content and merged input props, avoid duplicate close updates, and restore controlled values on external reopening.
- [x] Parse source `time`/`timesecond` strings, use `minSecond` for an omitted time-second field, and constrain values to the configured time range.
- [x] Expose and apply public `formatter(type, value)` to filtered generated values, index resolution, and selected-value composition.

## Verification

Focused regressions:

```powershell
flutter test test/widgets_test.dart --name UPPicker --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
```

Observed: 30 UPPicker/UPPickerData tests and 25 UPDatetimePicker tests passed.

```powershell
dart format lib/src/widgets/up_picker.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_picker.dart
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: formatting and analysis clean; all 785 tests passed; final diff check recorded with this batch.
