# UPSafeBottom Custom Style Root Audit Plan

**Goal:** Preserve `UPSafeBottom.customStyle` on the same full-width root that receives the source safe-area height.

**Architecture:** `u-safe-bottom.vue` computes `style` by merging platform-specific height with `addStyle(customStyle)` and binds it to `.u-safe-bottom`. Flutter already decorates its MediaQuery bottom-inset container directly, so this batch adds a regression without changing production code.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the Vue computed style merge and rendered root with Flutter's safe-area container.
- [x] Confirm `bgColor` remains source-inactive while caller decoration shares the height-bearing root.
- [x] Add a regression proving caller decoration, safe-area height, and full-width layout share one root.
- [x] Run formatting, focused safe-bottom tests, analysis, the complete package suite, and `git diff --check`.
- [x] Record the confirmed source scope in `docs/gap-matrix.md`.

Verification: `dart format`, focused safe-bottom style tests, `flutter analyze lib/src/widgets/up_safe_bottom.dart`, `flutter test --reporter expanded` (732 passed), and `git diff --check` all passed.
