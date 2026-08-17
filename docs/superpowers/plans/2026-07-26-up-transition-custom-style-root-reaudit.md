# UPTransition Custom Style Root Re-Audit Plan

**Goal:** Reconfirm that Flutter renders `UPTransition.customStyle` on the source-equivalent transition root in animated and non-animated modes.

**Architecture:** `u-transition.vue` applies computed `mergeStyle` to its only rendered root. `mergeStyle` starts with caller `addStyle(customStyle)` then layers internal animation `viewStyle` over it, keeping caller decoration bound to the transition node rather than to slot content. Flutter similarly wraps the source child in a `DecoratedBox` before the mode-specific animated wrappers or the `none` branch.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source root template, merge order, animation style ownership, and Flutter wrapper ordering.
- [x] Confirm caller `customStyle` belongs to the transition root rather than its child slot.
- [x] Upgrade the active-style regression to use a distinctive gradient and border.
- [x] Exercise an invisible `fade-up` branch and visible `none` branch while validating decoration containment and animation wrappers.
- [x] Run focused transition regressions and component analysis without a production code change.
- [x] Record the confirmed source transition-root scope in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- `flutter test test/widgets_test.dart --name "UPTransition (shows child|animates customStyle with its source root|BatchD open/close/clickHandler|BatchI classNames/enter leave)" --reporter expanded`
- `flutter analyze lib/src/widgets/up_transition.dart`
- `flutter test --reporter expanded`
- `git diff --check`

Results:
- Focused UPTransition regressions: 4 passed.
- `flutter analyze lib/src/widgets/up_transition.dart`: no issues.
- Full Flutter suite: 739 passed at the time of this re-audit; the later popup re-audit suite completed with 741 passed.
- `git diff --check`: clean at the time of this re-audit.
