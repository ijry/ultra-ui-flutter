# UPAvatarGroup Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter accepts `UPAvatarGroup.customStyle` for API compatibility without rendering it, matching the uView avatar-group template.

**Architecture:** `u-avatar-group.vue` inherits the shared mixin but binds only the per-item overlap margin. Avatar display and the more overlay have source-owned paths; the latter includes its own fixed translucent background. Flutter keeps the shared field inert so caller decoration cannot leak onto group layout, avatars, or either shape of more badge.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare the source group root, overlap item style, avatar resolution, more overlay, and Flutter widget tree.
- [x] Strengthen the regression with a caller gradient across object URL resolution, circle/square avatars, and extra-value more badges.
- [x] Run focused tests and component analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification:
- `dart format test/widgets_test.dart`
- Focused inactive-style and more-badge regressions
- `flutter analyze lib/src/widgets/up_avatar_group.dart`
- `flutter test --reporter expanded` (738 passed)
- `git diff --check` (clean)
