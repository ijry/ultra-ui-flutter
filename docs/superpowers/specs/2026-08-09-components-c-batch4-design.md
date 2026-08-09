# Components C Batch 4 Design

## Scope

Implement the next five source-order Components C example pages:

1. `componentsC/tooltip/tooltip`
2. `componentsC/guide/guide`
3. `componentsC/popover/popover`
4. `componentsC/tabs/tabs`
5. `componentsC/list/list`

The work continues the existing Flutter port in
`D:\Repos\xyito\open\ultra-ui-flutter`. The behavior contract comes from the
corresponding pages under
`D:\Repos\xyito\open\uview-plus\src\pages\componentsC`.

## Goals

- Add five usable Flutter example pages that follow the existing Components C
  page and route patterns.
- Preserve the source page titles, section labels, representative defaults,
  and principal interactions with the existing `UP*` widgets.
- Keep the pages and tests deterministic without network access or random
  data.
- Register the five routes in source order and enable exactly their preview
  rows.
- Keep state local to each page so interactions remain isolated and readable.

## Non-goals

- Do not add a generic demo-page framework.
- Do not redesign or rename existing public `ultra_ui` constructors.
- Do not add a network, persistence, or image-loading dependency.
- Do not migrate later Components C routes such as `modal`, `picker`, or
  `calendar` in this batch.
- Do not clean, revert, or stage the existing modified `README.md`, generated
  files, helper scripts, or other historical untracked workspace files.

## Page Design

### Tooltip

Create `TooltipPage` using `UPTooltip` and `ExampleDemoBlock`. Keep the source
sections for basic use, bottom direction, extension buttons, automatic
positioning, highlighted background, singleton opening, custom trigger/content,
and left direction with forced position.

The basic text and directional examples retain long-press triggers. Button and
custom-trigger examples use click triggers where the source does. The page
records the last extension-button index and a small callback count so widget
tests can observe `onClick` without inspecting package internals. Singleton
examples use the package singleton behavior; the page does not duplicate that
coordination.

### Guide

Create `GuidePage` with a `GlobalKey<UPGuideState>` and `UPGuide`. The guide is
shown automatically on first entry with `show: true`, `once: true`, and a
page-specific storage key. Its three page records use the existing local
`assets/uview/common/logo.png` so the page remains usable offline. The page
exposes source-style buttons to reopen the guide and reset its first-entry
mark, plus observable change/skip/finish counters.

Tests clear the page-specific key through `UPGuide.clearRemembered` before
pumping and use a fresh key per test. Reset is awaited before reopening when
the callback is asynchronous. No host persistence hooks are installed by the
example.

### Popover

Create `PopoverPage` with two `UPPopover` demonstrations matching the source:
right-side custom content and left-side custom content with forced positioning.
Each uses a real `UPButton` trigger and a content slot. The page shows open and
close callback counts as local status text, allowing tests to verify the
trigger-to-popover state transition.

### Tabs

Create `TabsPage` with fixed tab maps and `UPTabs`. Demonstrations cover the
source basic current index, sticky tabs, badges, non-scrollable tabs, disabled
items, custom active/inactive styles, a right-side action slot, and the
`capsule`, `card`, `pill-arrow`, and `tag` shape modes. The page keeps a
controlled current index for the interactive basic example and provides a
button that selects the next enabled tab. A small status text exposes the
selected index and callback count.

The source's bitmap line background and swiper-only composition are not
required for the component contract; the custom line-color and shape examples
remain visible using the existing `UPTabs` API.

### List

Create `ListPage` with a fixed-height `UPList` so it owns one bounded scroll
surface inside the page. Each row uses `UPListItem`, `UPCell`, and a local
asset-backed `UPAvatar` or `UPImage`, with the source-style `列表长度-N` title.
The initial fixture contains ten rows. `onScrolltolower` appends ten more
deterministic rows until the page reaches the configured demonstration limit,
then reports the current row count. The page uses `ExamplePageScaffold` with a
non-scrollable body to avoid nested scroll competition.

## State and Data Flow

- `TooltipPage` owns only status text and callback counters; popup visibility
  remains in each `UPTooltipState`.
- `GuidePage` owns its guide key, visible action status, and callback counters;
  `UPGuideState` owns the current page and once memory.
- `PopoverPage` owns callback counters; `UPPopoverState` owns visibility.
- `TabsPage` owns the controlled current index and next-tab action; `UPTabs`
  emits selection callbacks.
- `ListPage` owns the deterministic row list and append count; `UPListState`
  owns scroll position and emits the lower-edge callback.

All image sources are local. If an asset-backed widget reports a load failure,
its existing package fallback is acceptable; image-success timing is not a
test condition.

## File Boundaries

Create:

- `example/lib/pages/components_c/tooltip_page.dart`
- `example/lib/pages/components_c/guide_page.dart`
- `example/lib/pages/components_c/popover_page.dart`
- `example/lib/pages/components_c/tabs_page.dart`
- `example/lib/pages/components_c/list_page.dart`

Modify:

- `example/lib/routes/example_catalog.dart`
- `example/lib/routes/example_preview_catalog.dart`
- `example/test/components_c_pages_test.dart`
- `example/test/route_catalog_test.dart`

Do not modify package files unless a focused page test proves a package gap.
Any such fix must change only the affected widget and add a corresponding
focused package regression test.

## Testing and Acceptance

Add one behavior test per route:

- Tooltip opens a click-triggered example, invokes an extension action, and
  verifies the visible callback status.
- Guide starts open, advances through its pages, finishes, resets its mark,
  and can open again.
- Popover opens through the right-side trigger and exposes its custom content,
  then closes through the widget state.
- Tabs changes the controlled selection, rejects the disabled item, and
  renders the source shape/badge sections.
- List renders the initial deterministic rows and appends the next batch after
  reaching the lower edge.

Update route catalog tests to assert the five source paths are consecutive,
unique, backed by real builders, and marked available in the preview catalog.

Run the focused page tests first, then:

```text
dart format lib/pages/components_c/tooltip_page.dart lib/pages/components_c/guide_page.dart lib/pages/components_c/popover_page.dart lib/pages/components_c/tabs_page.dart lib/pages/components_c/list_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
flutter test
flutter analyze
```

Run package tests and package analysis only if package files are changed. Run
the Android debug APK build from `example` as the final platform check.

## Platform Notes

The example targets Android and iOS. Browser-only behavior is not introduced.
Tooltip and popover interactions remain in-app; guide memory is in-memory for
the example process; list data is local and deterministic.
