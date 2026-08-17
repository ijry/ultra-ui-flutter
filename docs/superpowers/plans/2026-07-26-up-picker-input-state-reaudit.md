# UPPicker Input State Re-Audit

**Goal:** Match source `u-picker` input-trigger visibility and confirmed-label behavior when `hasInput` is enabled.

**Source evidence:**

- `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-picker\u-picker.vue` shows its popup with `show || (hasInput && showByClickInput)`.
- The source input wrapper toggles `showByClickInput`, while external `show` remains an independent visibility input.
- Its default read-only `up-input` displays `inputLabel`: labels for confirmed object `modelValue` values, or slash-joined confirmed primitive `modelValue` values. Pending wheel selection uses a separate `inputValue` computed property and is not displayed until confirmation.

## Completed Tasks

- [x] Add and verify source-compatible external `show` behavior with `hasInput`.
- [x] Add and observe a failing custom-trigger toggle regression.
- [x] Add and observe a failing confirmed object-model label regression because Flutter omitted the default `UPInput`.
- [x] Separate external, command-driven, and input-trigger visibility state.
- [x] Render the source-equivalent default read-only `UPInput`, merging the input prop defaults before caller overrides.
- [x] Derive its label from confirmed `modelValue`/`value`, including object `valueName` to `keyName` label lookup.
- [x] Verify both custom and built-in trigger toggle paths.
- [x] Preserve immediate-change timing, column state, confirmation, cancellation, callbacks, masks, and datetime-picker integration.

## Verification

Focused regression command:

```powershell
flutter test test/widgets_test.dart --name "UPPicker (hasInput still respects external show|input trigger toggles only its local popup state|input label displays confirmed modelValue|built-in input trigger toggles its popup|confirm returns values|public open confirm cancel aliases|defers change until wheel scrolling ends)" --reporter expanded
```

Observed: 7 passed.

```powershell
flutter analyze lib/src/widgets/up_picker.dart
flutter test --reporter expanded
git diff --check
```

Observed: analysis clean; all 759 tests passed; `git diff --check` clean.
