# Components D Batch 2 Design

## Goal

Add the next five source-order Components D example pages to the Flutter
gallery:

1. `componentsD/cateTab/cateTab`
2. `componentsD/select/select`
3. `componentsD/pagination/pagination`
4. `componentsD/tree/tree`
5. `componentsD/dragsort/dragsort`

The pages must preserve the source titles, source route order, representative
defaults, and principal interactions while reusing the existing public
`ultra_ui` widgets.

## Context

Components D Batch 1 completed these routes:

- `componentsD/qrcode/qrcode`
- `componentsD/copy/copy`
- `componentsD/navbarMini/navbarMini`
- `componentsD/box/box`
- `componentsD/floatButton/floatButton`

The completed example route catalog currently contains `88` routes. This
batch will add exactly five routes, bringing the total to `93`.

The source manifest already contains all five target routes. The preview
catalog also contains all five records with `available: false`; only those
five flags should change.

## Architecture

Each component gets one focused page under
`example/lib/pages/components_d/`. Pages use the existing
`ExamplePageScaffold` and `ExampleDemoBlock` patterns and own only the state
needed to display callback results or controlled values.

The pages use these public package widgets directly:

- `UPCateTab`
- `UPSelect`
- `UPPagination`
- `UPTree`
- `UPDragSort`

No generic Components D page abstraction will be introduced. Route
registration, preview availability, and page smoke tests remain separate from
the component-specific interaction tests.

The package will be modified only if a focused page test reproduces a concrete
behavioral defect in one of the five public widgets. Any package change must
include a package-level regression test and a separate commit.

## Page Designs

### CateTab

Create `CateTabPage` with two source-style demonstrations:

- `follow` mode with multiple category sections and child items. Selecting a
  left category changes the active index and scrolls the right section into
  view.
- `tab` mode showing only the currently selected category's child items.

Use deterministic local data with category names and child names. The page
renders active-index text and callback count so tests can verify state without
depending on visual color details.

Required page keys:

- `example-page-componentsD/cateTab/cateTab`
- `cate-tab-page-follow`
- `cate-tab-page-tab`

The follow-mode test taps a keyed left menu item and verifies the active index
and change count. The test also verifies that the page renders section and
child labels from local data.

### Select

Create `SelectPage` with:

- a default bordered select trigger;
- a deterministic list of three options;
- controlled current value state;
- a result label showing the selected option.

The page must use `UPSelect`'s real overlay/options panel. It must not replace
the component with a Material `DropdownButton` or page-local fake menu.

Required page keys:

- `example-page-componentsD/select/select`
- `select-page-basic`
- `select-page-trigger`

The focused test taps the trigger, verifies
`up-select-options-panel`, taps a real option, and verifies the selected label
and selection callback result. A second assertion verifies that the panel
closes after selection.

### Pagination

Create `PaginationPage` with two demonstrations:

- standard `prev, pager, next` pagination over a fixed total;
- a `total, sizes, prev, pager, next` configuration using deterministic page
  sizes.

The page owns current page and page size state and forwards changes back into
the widget, matching the source's controlled prop/event model.

Required page keys:

- `example-page-componentsD/pagination/pagination`
- `pagination-page-basic`
- `pagination-page-sized`

The focused test taps a page number and verifies the current-page result, then
selects a page-size option in the sized example and verifies the page-size
result. It should use visible source labels or stable keys rather than
coordinate-only taps.

### Tree

Create `TreePage` with a small nested tree containing:

- one root with two children;
- one nested child under the first child;
- one disabled leaf;
- visible checkboxes;
- default expansion of the root.

Enable source-style node expansion and check-on-click behavior where useful,
while preserving explicit checkbox interaction for the cascade test.

Required page keys:

- `example-page-componentsD/tree/tree`
- `tree-page-basic`
- `tree-page-checkbox`
- `up-tree-checkbox-root`

The focused test verifies that a child node becomes visible after expansion,
checking a parent cascades to enabled descendants, and the displayed checked
keys/result text matches the callback state. Disabled nodes must remain
unselected.

### Dragsort

Create `DragsortPage` with:

- a vertical draggable list of deterministic labeled items;
- a visible ordered-result line;
- a non-draggable/static comparison block or handler-based variant only if it
  can be shown without obscuring the primary drag workflow.

Use `UPDragSort` with its public `itemBuilder` and `onDragEnd`. The primary test
must exercise a real drag gesture against the rendered reorderable list. The
page must not call `move()` directly as a substitute for the user interaction
under test.

Required page keys:

- `example-page-componentsD/dragsort/dragsort`
- `dragsort-page-basic`
- `dragsort-page-item-0`
- `dragsort-page-item-1`

The focused test drags the first visible item below the second item, waits for
the reorder settlement, and verifies the result order and callback count. If
the widget's default drag handle is not discoverable, the page may use a
public `handlerBuilder`, but the test must still perform the actual gesture.

## Route Registration

Modify `example/lib/routes/example_catalog.dart`:

- import the five page files;
- add route records immediately after
  `componentsD/floatButton/floatButton`;
- add one builder per page;
- preserve all existing route order and titles.

Use these route records:

```dart
const ExampleRoute(
  id: 'componentsD/cateTab/cateTab',
  sourcePath: 'pages/componentsD/cateTab/cateTab',
  title: '垂直TAB',
  group: ExampleRouteGroup.componentsD,
  builder: _buildCateTab,
),
const ExampleRoute(
  id: 'componentsD/select/select',
  sourcePath: 'pages/componentsD/select/select',
  title: '经典下拉框',
  group: ExampleRouteGroup.componentsD,
  builder: _buildSelect,
),
const ExampleRoute(
  id: 'componentsD/pagination/pagination',
  sourcePath: 'pages/componentsD/pagination/pagination',
  title: '分页器',
  group: ExampleRouteGroup.componentsD,
  builder: _buildPagination,
),
const ExampleRoute(
  id: 'componentsD/tree/tree',
  sourcePath: 'pages/componentsD/tree/tree',
  title: '树形',
  group: ExampleRouteGroup.componentsD,
  builder: _buildTree,
),
const ExampleRoute(
  id: 'componentsD/dragsort/dragsort',
  sourcePath: 'pages/componentsD/dragsort/dragsort',
  title: '拖动排序',
  group: ExampleRouteGroup.componentsD,
  builder: _buildDragsort,
),
```

Modify `example/lib/routes/example_preview_catalog.dart` only by changing
these five records from `available: false` to `available: true`. Do not
reorder preview records or change group lengths.

## Testing

Extend `example/test/components_d_pages_test.dart` with five focused tests:

1. CateTab renders local sections and changes active menu.
2. Select opens the real options overlay and reports a selected option.
3. Pagination changes page and page size through visible controls.
4. Tree expands and cascades checkbox selection.
5. Dragsort reorders items through a real drag gesture.

Extend `example/test/route_catalog_test.dart`:

- change the route count assertion from `88` to `93`;
- define the literal Components D route ID list of ten completed routes in
  source order;
- assert the Components D extraction equals that list;
- add the five source paths to the completed-path set;
- add the five source paths to the available-preview assertion;
- add a Components D route smoke test that renders each route and checks its
  root key and AppBar title.

All focused page tests should mount pages directly in a `MaterialApp`, as
established by Batch 1. Route registration is verified independently through
the route catalog tests.

Package tests should be added only after a page test demonstrates a package
defect. No package test is planned by default.

## Validation

Run in this order:

```text
dart format example/lib/pages/components_d example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_d_pages_test.dart example/test/route_catalog_test.dart
flutter test example/test/components_d_pages_test.dart --reporter expanded
flutter test example/test/route_catalog_test.dart --reporter expanded
flutter test example
flutter analyze example
flutter test packages/ultra_ui
flutter analyze packages/ultra_ui
git diff --check
flutter build apk --debug --target-platform android-arm64
```

The existing user-modified `README.md`, historical untracked scripts,
generated files, package sources, and documentation must remain untouched
unless directly required by this batch. Build output must not be staged.

## Non-Goals

- No new dependency.
- No network-backed demo data.
- No source manifest changes beyond the already existing entries.
- No generic D-component abstraction.
- No broad package refactor.
- No unrelated cleanup of the dirty worktree.
