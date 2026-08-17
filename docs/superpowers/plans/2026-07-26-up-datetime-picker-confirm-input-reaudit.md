# UPDatetimePicker Confirm and Input Re-Audit

**Goal:** Align datetime-picker input-trigger interaction and confirmation lifecycle with the source wrapper methods and nested picker template.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` places an input cover over the default input and makes `onShowByClickInput()` depend only on the datetime picker `disabled` prop. Input-level disabled state from `inputPropsInner` affects presentation but not that cover's opening behavior.
- Source `confirm()` emits the model value and `confirm`, updates its input display/`showByClickInput` state when applicable, and does not call `close()` or emit `close`.
- The nested source `<u-picker>` binds `@confirm="confirm"`, so toolbar confirmation must also clear the datetime wrapper's `showByClickInput` state; otherwise the expression controlling nested picker visibility remains true.

## Completed Tasks

- [x] Verify that the default datetime input remains openable when `inputProps.disabled` is true and the component-level `disabled` prop is false.
- [x] Add and observe a failing command-confirm regression proving Flutter incorrectly emitted `close` through the overlay-close path.
- [x] Stop command `confirm()` from calling the overlay-close method; it now emits only source-compatible confirmation/value events and clears local input visibility.
- [x] Add and observe a failing nested-picker-confirm regression proving toolbar confirmation left the wrapper input popup visible.
- [x] Clear `showByClickInput` in the nested picker confirmation binding without forwarding a close event.
- [x] Preserve cancel, overlay close, controlled show, value composition, formatters, masks, and input-prop rendering.

## Verification

Focused regressions:

```powershell
flutter test test/widgets_test.dart --name UPPicker --reporter expanded
flutter test test/widgets_test.dart --name UPDatetimePicker --reporter expanded
```

Observed: 33 UPPicker/UPPickerData tests and 29 UPDatetimePicker tests passed.

```powershell
dart format lib/src/widgets/up_picker.dart lib/src/widgets/up_datetime_picker.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_picker.dart
flutter analyze lib/src/widgets/up_datetime_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: formatting and analysis clean; all 792 tests passed; final diff check recorded with this batch.
