# UPSteps, UPSection, UPSwiperIndicator, and UPTabbar Custom Style Parity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove Flutter-only `customStyle` rendering where the uView source has no consumer and attach Tabbar styles to the source-equivalent visible content nodes.

**Architecture:** `u-steps.vue`, `u-swiper.vue`, and the independent `u-swiper-indicator.vue` do not bind `customStyle`; the u-section source contains only default props and no render component. Their Flutter constructors retain the compatibility field but must not render it. In contrast, `u-tabbar.vue` merges custom style into `.u-tabbar__content`, and `u-tabbar-item.vue` merges it into the item root, so Flutter must merge decoration on those exact visible nodes rather than an enclosing placeholder layout.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve existing public constructors and `customStyle` fields; add `UPTabbarItem.customStyle` because its Vue source declares and renders the prop.
- Match the source files under `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components`.
- Preserve steps layout, section content, swiper indicators, tabbar placeholder, safe-area, callbacks, and selection behavior.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Verify Source Style Consumption

**Files:**
- Inspect: `components\u-steps\u-steps.vue` and `props.js`
- Inspect: `components\u-section\section.js`
- Inspect: `components\u-swiper\u-swiper.vue` and `props.js`
- Inspect: `components\u-swiper-indicator\u-swiper-indicator.vue` and `props.js`
- Inspect: `components\u-tabbar\u-tabbar.vue`
- Inspect: `components\u-tabbar-item\u-tabbar-item.vue` and `props.js`

- [x] **Step 1: Identify inactive source fields**

`u-steps.vue` renders only direction classes and children; its local props do
not declare `customStyle`. `u-swiper.vue` and `u-swiper-indicator.vue` do not
bind or declare the prop. `u-section` provides only `section.js` defaults and
has no Vue render template; its defaults likewise omit the prop. Flutter-only
rendering for these fields is therefore not source-compatible.

- [x] **Step 2: Identify active Tabbar fields and target nodes**

`u-tabbar.vue` merges `customStyle` after the intrinsic `tabbarStyle` and
binds the result to `.u-tabbar__content`, not its outer placeholder wrapper.
`u-tabbar-item.vue:2-6` binds `[itemInlineStyle, addStyle(customStyle)]` to
the clickable item root; its local `props.js` does not redeclare the field
because the shared mixin supplies it.

### Task 2: Add Failing Render Regressions

**Files:**
- Modify: `packages/ultra_ui/test/widgets_test.dart`

- [x] **Step 1: Cover inactive components**

For `UPSteps`, `UPSection`, and `UPSwiperIndicator`, mount with a uniquely
colored `BoxDecoration` and assert no matching `DecoratedBox` appears.

Observed: all three regressions failed before implementation because each
Flutter widget still rendered its own root decoration.

- [x] **Step 2: Cover Tabbar content and item targets**

For `UPTabbar`, assert a custom color merges into the keyed visible content
container while its source default top border remains and the fixed placeholder
does not receive the raw decoration. For `UPTabbarItem`, compile and mount the
new `customStyle` parameter, then assert the item root combines caller border
with its source active-background color.

Observed: the item test initially failed to compile because Flutter lacked the
Vue-supported `UPTabbarItem.customStyle` constructor parameter. The Tabbar
test then verified that style applies to content rather than its placeholder.

### Task 3: Implement the Minimal Source-Compatible Changes

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_steps.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_section.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_swiper.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_tabbar.dart`

- [x] **Step 1: Remove inactive decoration wrappers**

Delete only the Flutter root wrappers from `UPSteps`, `UPSection`, and
`UPSwiperIndicator`; retain their constructor parameters and fields for API
compatibility.

Implemented: the three constructors retain their compatibility fields, but no
longer render Flutter-only root decorations.

- [x] **Step 2: Merge Tabbar decoration on source nodes**

Build the source default content and item decorations first, overlay non-null
caller `BoxDecoration` fields, place the result on the keyed Tabbar content
and item roots, and remove the old outer Tabbar wrapper.

Implemented: `UPTabbar` now keys and decorates only
`up-tabbar-content`; `UPTabbarItem` accepts `customStyle` and keys/decorates
its clickable `up-tabbar-item-<name>` root. Both retain source-derived
backgrounds or borders before caller fields override them.

### Task 4: Verify and Record Parity

**Files:**
- Modify: `docs/gap-matrix.md`

- [x] **Step 1: Run focused validation**

Run: `dart format lib/src/widgets/up_steps.dart lib/src/widgets/up_section.dart lib/src/widgets/up_swiper.dart lib/src/widgets/up_tabbar.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UP(Steps|Section|SwiperIndicator|Tabbar).*customStyle|UPTabbarItem exposes" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_steps.dart lib/src/widgets/up_section.dart lib/src/widgets/up_swiper.dart lib/src/widgets/up_tabbar.dart`

Observed: five focused custom-style regressions and eight broader interaction
regressions passed. Analysis reported no diagnostics for all four components.

- [x] **Step 2: Run suite and record outcome**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated compatibility matrix entry documenting inactive removals and the
Tabbar/TabbarItem style target parity.

Observed: the full suite passed all 695 tests before the final whitespace
check. The compatibility matrix records batch HU.
