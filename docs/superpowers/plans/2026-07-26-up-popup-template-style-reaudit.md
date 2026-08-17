# UPPopup Template Style Re-Audit Plan

**Goal:** Reconfirm that Flutter places `UPPopup.customStyle` on the source-equivalent content panel and forwards the separately scoped `overlayStyle` to the source-equivalent visible mask.

**Architecture:** `u-popup.vue` computes `contentStyle` from source background/radii followed by `addStyle(customStyle)` and binds it only to `.u-popup__content`. It independently sends `overlayStyle` to `u-overlay` and initializes that overlay with `duration + 50`. `u-overlay.vue` merges its fixed mask style with that caller style and binds it to its transition root. Flutter keeps these paths separate: its panel decoration contains only popup content, while its local `UPOverlay` receives the popup's `BoxDecoration` overlay style and the source timing offset.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_popup.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare `u-popup.vue` content-panel binding, overlay forwarding, overlay-duration initialization, and `u-overlay.vue` style merge with the Flutter widget tree.
- [x] Confirm `customStyle` belongs to `.u-popup__content`, never to the popup transition, outer trigger, or overlay mask.
- [x] Strengthen the content-panel regression with a caller gradient and border, preserving source-derived bottom-panel radius and transparent material layer.
- [x] Add a failing regression proving that a `BoxDecoration` supplied through `overlayStyle` was not reaching the visible overlay mask.
- [x] Forward Flutter's supported `BoxDecoration` form of `overlayStyle` into the nested `UPOverlay` only.
- [x] Add a failing regression proving that popup's overlay duration omitted the source `+ 50ms` offset, then apply the minimal timing correction.
- [x] Verify popup regressions, static analysis, full suite, and whitespace.
- [x] Record the confirmed panel/mask separation in `docs/gap-matrix.md`.

Verification:
- `flutter test test/widgets_test.dart --name "UPPopup" --reporter expanded` (10 passed)
- `flutter analyze lib/src/widgets/up_popup.dart` (no issues)
- `flutter test --reporter expanded` (741 passed)
- `git diff --check` (clean)

Results:
- The `overlayStyle` regression initially failed with `Actual: <null>` for its expected caller gradient, locating the broken data flow at `UPPopup -> UPOverlay`.
- The overlay-duration regression initially failed with `Expected: <350>, Actual: <300>`, locating the missing source offset in the same nested overlay configuration.
- Both regressions pass after the focused forwarding and timing changes; popup panel styling, overlay styling, and content isolation are covered independently.
