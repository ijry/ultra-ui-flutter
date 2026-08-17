# UPSwitch Custom Style Root Merge Plan

**Goal:** Merge `UPSwitch.customStyle` with the source-computed switch decoration on one clipped, sized switch root.

**Architecture:** `u-switch.vue` applies `:style="[switchStyle, addStyle(customStyle)]"` to `.u-switch`, so caller styles follow the source-computed background and border color while the root CSS owns its pill radius and `overflow: hidden`. Flutter will retain the animated source root and merge caller decoration fields into its `AnimatedContainer`; caller gradient suppresses the source color because Flutter cannot paint both in one `BoxDecoration`.

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_switch.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare `u-switch.vue` root style-array ordering, class clipping, and existing Flutter wrapper structure.
- [x] Identify that Flutter's outer caller-only decoration hides beneath a separate opaque source switch body and does not share root clipping or dimensions.
- [x] Add a regression proving caller gradient, border, radius, source size, and clipping share the root switch surface.
- [x] Merge source and caller decorations on the animated switch root, preserving caller precedence for color, border, radius, image, shadow, blend mode, and shape.
- [x] Format, run focused tests and analysis, then run the full test suite and `git diff --check`.
- [x] Record the resolved parity rule in `docs/gap-matrix.md`.

Verification: `dart format`, focused switch style/interaction tests, `flutter analyze lib/src/widgets/up_switch.dart`, `flutter test --reporter expanded` (727 passed), and `git diff --check` all passed.
