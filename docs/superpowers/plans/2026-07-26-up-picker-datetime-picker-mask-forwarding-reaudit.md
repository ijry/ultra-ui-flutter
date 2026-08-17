# UPPicker and UPDatetimePicker Mask Forwarding Re-Audit

**Goal:** Align Flutter picker wheel masks and datetime-picker template forwarding with `uview-plus`.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker\u-picker.vue` binds `mask-class` and `mask-style="maskStyleInner"` on `picker-view`, not the toolbar or popup.
- The same source computes `maskStyleInner` from explicit `maskStyle`, or from the dark-theme default; it does not derive it from `overlayOpacity`.
- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-datetime-picker\u-datetime-picker.vue` manages its own `hasInput` trigger and sends only `toolbarRightSlot`, `maskClass`, and `resolvedMaskStyle` to nested `u-picker`.

## Completed Tasks

- [x] Add and observe failing widget regressions for wheel mask rendering, mask viewport scope, datetime toolbar-slot forwarding, mask forwarding, dark default masking, and input-trigger toggling.
- [x] Make `UPPicker.maskStyleInner` source-compatible: explicit `maskStyle` or no value, never popup `overlayOpacity`.
- [x] Render supported Flutter `BoxDecoration`, `Color`, or simple color-map wheel masks in an `IgnorePointer` layer limited to the wheel viewport.
- [x] Keep the source dark-theme fallback when no mask style is explicitly supplied.
- [x] Make `UPDatetimePicker` own its `hasInput` trigger and `showByClickInput` state rather than forwarding those props to `UPPicker`.
- [x] Forward source-explicit `toolbarRightSlot`, `maskClass`, and `resolvedMaskStyle` to the nested picker.
- [x] Keep `maskClass` as a compatible string API. Flutter has no CSS selector engine, so it cannot apply class-only styling; behavior and supported native style values remain observable through the wheel mask layer.

## Verification

Focused regression command:

```powershell
flutter test test/widgets_test.dart --name "UPPicker (confirm returns values|renders supplied maskStyle above its wheels|constrains its maskStyle to the wheel viewport|leaves source-inactive customStyle unrendered|exposes source-compatible state methods|public open confirm cancel aliases)|UPDatetimePicker (confirms value|keeps its dark default wheel mask|forwards toolbarRightSlot to its picker|forwards wheel mask props to its picker|input trigger toggles its popup|leaves source-inactive customStyle unrendered|setValue public API|public confirm getInputValue|BatchG correctValue/getRanges|BatchJ formatter/intercept)" --reporter expanded
```

Observed: 16 passed.

```powershell
flutter analyze lib/src/widgets/up_picker.dart lib/src/widgets/up_datetime_picker.dart
```

Observed: no issues.

```powershell
flutter test --reporter expanded
git diff --check
```

Observed: all 750 tests pass; `git diff --check` is clean.
