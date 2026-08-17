# UPPicker Reactivity and Payload Re-Audit

**Goal:** Align Flutter `UPPicker` updates, selection payloads, overlay-close behavior, and theme rendering with the source `u-picker` template and methods.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker\u-picker.vue` deep-watches `columns`, `defaultIndex`, and `modelValue`. The source replaces changed columns without resetting indexes, applies `defaultIndex` before an effective `modelValue`, and applies later watcher updates independently.
- The source `setColumnValues` resets indexes after its recorded `columnIndex`, the last wheel column changed by `changeHandler`, rather than after the replaced column.
- Source `closeHandler` returns without events or state changes unless `closeOnClickOverlay` is true. Source `onShowByClickInput` checks only picker `disabled`, while `inputProps.disabled` remains an input rendering prop.
- Source `change` and `confirm` emit original selected column items. `update:modelValue` uses the separate `inputValue` mapping that extracts each object item's `valueName`.
- Source wheel items use `$u-main-color`, and the loading cover uses `--up-card-bg-color`; both resolve from the active theme.

## Completed Tasks

- [x] Add and observe a failing deep in-place `columns` mutation regression.
- [x] Snapshot and deep-compare reactive list/map props so Flutter detects nested source-style updates, while a `columns` update preserves the current selection.
- [x] Add and observe a failing `closeHandler` regression for disabled overlay closing, then gate that public handler on `closeOnClickOverlay`.
- [x] Add and observe a failing initial `modelValue` versus `defaultIndex` precedence regression, then make a matched controlled value override the initial default.
- [x] Add and observe a failing later `defaultIndex` update regression, then model source watcher ordering: a default-index-only update applies directly, and a simultaneous effective-value update applies afterward.
- [x] Add and observe a failing cascade regression, then reset `setColumnValues` indexes after the last changed wheel column.
- [x] Add and observe a failing input-prop disabled regression, then keep trigger interaction controlled by picker `disabled` while passing merged input props to `UPInput`.
- [x] Add and observe a failing dark-theme rendering regression, then bind wheel text and loading-cover colors to `UPThemeTokens.mainColor` and `cardBgColor`.
- [x] Add and observe a failing object-column confirmation regression, then preserve raw selected items for `onChange`/`onConfirm` while emitting `valueName` model values only through update callbacks.
- [x] Preserve input labels, masks, immediate-change timing, cancellation, public state methods, popup behavior, and datetime-picker composition.

## Verification

Focused regression command:

```powershell
flutter test test/widgets_test.dart --name "UPPicker (confirm keeps item payload separate from model values|defers change until wheel scrolling ends|hasInput still respects external show|input trigger toggles only its local popup state|input label displays confirmed modelValue|built-in input trigger toggles its popup|syncs deep columns updates without resetting indexes|closeHandler ignores disabled overlay close|modelValue overrides defaultIndex when it matches|setColumnValues resets columns after last change|applies later defaultIndex updates over modelValue|inputProps disabled does not disable its trigger|uses theme colors for wheel content and loading|renders supplied maskStyle above its wheels|constrains its maskStyle to the wheel viewport|leaves source-inactive customStyle unrendered|public open confirm cancel aliases|exposes source-compatible state methods)" --reporter expanded
```

Observed: 18 passed.

```powershell
dart format lib/src/widgets/up_picker.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: formatting and analysis clean; all 766 tests passed; `git diff --check` clean.
