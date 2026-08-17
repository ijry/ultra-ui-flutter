# UPPicker Immediate Change Re-Audit

**Goal:** Honor the source `immediateChange` picker-view timing contract in Flutter wheel selection events.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker\u-picker.vue` binds `:immediateChange="immediateChange"` directly to `picker-view` and emits through `changeHandler`.
- The prop controls when native wheel selection changes become observable, not how confirm, cancel, index updates, or public imperative calls work.

## Completed Tasks

- [x] Add and observe a failing real-wheel gesture regression: `immediateChange: false` emitted `onChange` before scrolling ended.
- [x] Keep each wheel's selected index and `currentActiveValue` up to date while it scrolls.
- [x] Cache the final changed column when immediate changes are disabled.
- [x] Emit exactly the final source-style values/indexes/column on the wheel's `ScrollEndNotification`.
- [x] Preserve immediate default behavior and retain immediate command semantics for the public `changeHandler` API.
- [x] Preserve confirm/cancel, input state, datetime-picker integration, masks, columns, and model callbacks.

## Verification

Focused regression command:

```powershell
flutter test test/widgets_test.dart --name "UPPicker (defers change until wheel scrolling ends|confirm returns values|public open confirm cancel aliases|exposes source-compatible state methods)|UPDatetimePicker (confirms value|narrows date columns to active boundaries|rebuilds boundaries after a date selection|BatchG correctValue/getRanges)" --reporter expanded
```

Observed: 8 passed.

```powershell
flutter analyze lib/src/widgets/up_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: analysis clean; all 755 tests pass; diff check is recorded with this batch after it completes.
