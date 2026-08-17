# UPTabs Custom Style Inactive Re-Audit Plan

**Goal:** Reconfirm that Flutter retains `UPTabs.customStyle` and `UPTabsItem.customStyle` for API compatibility without rendering them, matching their uView templates.

**Architecture:** `u-tabs.vue` renders a root, navigation wrapper, scroll container, tab items, optional line, and slots with no shared-style binding. `u-tabs-item.vue` renders only its content slot. Flutter retains both constructor fields while keeping caller decoration off the tabs root, shape-mode container, tab navigation, and content pane.

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`
- Modify: `docs/gap-matrix.md`

## Tasks

- [x] Compare both Vue templates and their source root/style bindings with Flutter widget trees.
- [x] Strengthen regressions using caller gradients, including a UPTabs capsule shape-mode root and a populated UPTabsItem pane.
- [x] Run focused tests and analysis without a production code change.
- [x] Record the no-production-change compatibility conclusion in `docs/gap-matrix.md`.
- [x] Run the full suite and `git diff --check`.

Verification: `dart format test/widgets_test.dart`, focused tabs/tabs-item inactive-style and selection regressions, `flutter analyze lib/src/widgets/up_tabs.dart`, `flutter test --reporter expanded` (738 passed), and `git diff --check` all passed.
