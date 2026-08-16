# Components D Batch 3 Design

**Date:** 2026-08-16

## Goal

Add the next five source-order Components D example pages to the Flutter
gallery:

1. `componentsD/cityLocate/cityLocate`
2. `componentsD/title/title`
3. `componentsD/pullRefresh/pullRefresh`
4. `componentsD/virtualList/virtualList`
5. `componentsD/barcode/barcode`

The pages preserve the source titles, source route order, representative
defaults, and principal interactions while reusing existing public
`ultra_ui` widgets. The completed route count increases from `93` to `98`.

## Scope and Constraints

- Keep the batch to exactly the five routes above, in the listed order.
- Add one focused page per route under `example/lib/pages/components_d/`.
- Reuse `ExamplePageScaffold`, `ExampleDemoBlock`, and public `UP*` widgets.
- Keep all examples deterministic and offline. Do not add dependencies,
  network requests, platform permission requests, or persistent state.
- Do not create a generic Components D page abstraction.
- Do not modify package source by default. A package change is allowed only
  after a focused example test reproduces a concrete public behavior gap; it
  must then include a package regression test and separate commit.
- Preserve the user-modified `README.md`, historical untracked scripts,
  generated files, source manifest, and unrelated package files.

## Architecture

Create the following page classes:

- `CityLocatePage`
- `TitlePage`
- `PullRefreshPage`
- `VirtualListPage`
- `BarcodePage`

Each page owns only its local controlled state and exposes a root key matching
the source route: `example-page-<route-id>`. Page-specific behavior remains
inside that page instead of adding cross-page helper abstractions.

Route registration adds five builders immediately after
`componentsD/dragsort/dragsort` in `example/lib/routes/example_catalog.dart`.
The existing five preview records are changed from `available: false` to
`available: true` without reordering the preview catalog. The source manifest
already has the required records and must not change.

## Page Designs

### CityLocate

`CityLocatePage` reproduces the source `基础用法` demo using a real
`UPCityLocate`.

- Use local city data for the hot-city group (`北京`, `上海`, `广州`) and the
  all-city group (`北京`, `上海`, `广州`, `深圳`, `杭州`). The existing Flutter
  widget renders its first city-list group as hot chips, matching this source
  arrangement.
- Inject `locationHandler` that asynchronously resolves to `南京`. The page
  updates its controlled current-city state from `onLocationSuccess`.
- Record `onSelectCity` in a visible result label, so selecting a city is
  testable without inspecting widget internals.
- Keep the component's location-failure behavior available if the injected
  handler returns `null` or throws; the page's deterministic handler succeeds
  and never requests device GPS.

Required keys:

- `example-page-componentsD/cityLocate/cityLocate`
- `city-locate-page-basic`
- `city-locate-page-selection`

### Title

`TitlePage` reproduces both source display variants using real `UPTitle`
widgets:

- `默认` shows `默认标题` with the default vertical prefix.
- `自定义前缀` supplies a red `UPIcon(name: 'level')` and displays `等级3`.

The page is stateless apart from normal widget rendering.

Required keys:

- `example-page-componentsD/title/title`
- `title-page-default`
- `title-page-prefix`

### PullRefresh

`PullRefreshPage` reproduces the source's four bounded demonstrations using
real `UPPullRefresh` widgets and local lists of named items:

1. `基本使用` uses a threshold of `50` and shows a refresh count.
2. `自定义下拉动画` supplies local pull, release, and refreshing slot widgets;
   local icons and text replace the source's remote GIF.
3. `结合虚拟列表` places a fixed-height `UPVirtualList` inside a bounded
   `UPPullRefresh` with `useScrollView: false` so nested scrolling has a
   stable Flutter layout.
4. `上拉加载` enables `showLoadmore`, updates local load-more status, and
   appends one deterministic item per load-more callback.

Refresh and load-more callbacks use a short local delay before restoring their
controlled state; no simulated network service is introduced. Every bounded
refresh viewport has an explicit height so gestures, loading indicators, and
nested scrollables are stable in the gallery and widget tests.

Required keys:

- `example-page-componentsD/pullRefresh/pullRefresh`
- `pull-refresh-page-basic`
- `pull-refresh-page-custom`
- `pull-refresh-page-virtual`
- `pull-refresh-page-loadmore`

### VirtualList

`VirtualListPage` mirrors the source `基本使用` demo with a real
`UPVirtualList`:

- Generate deterministic local records `Item 0` through `Item 9999`.
- Use `itemHeight: 49`, `keyField: 'id'`, the source `height: '800px'`
  viewport, and controlled `scrollTop` via `onUpdateScrollTop`.
- Render each visible row through `UPCell` with its source-style item title.
- Display the latest scroll position or visible range as a stable result line
  for interaction testing.

Required keys:

- `example-page-componentsD/virtualList/virtualList`
- `virtual-list-page-basic`
- `virtual-list-page-result`

### Barcode

`BarcodePage` renders all eight source variants with real `UPBarcode`
widgets:

- `CODE128`: `1234567890`
- `EAN-13`: `5901234123457`
- `EAN-8`: `96385074`
- `UPC-A`: `123456789012`
- `CODE39`: `CODE39`
- `EAN-5 补充码`: `12345`
- `EAN-2 补充码`: `12`
- `自定义样式条形码`: `CUSTOM123`, red bars, gray background, top text

The page preserves the source heights, relevant widths, font sizes, and
custom colors. `UPBarcode` already provides standard encoders for CODE128,
EAN13, EAN8, UPCA, and CODE39. The selected page-first scope deliberately
retains its deterministic visual fallback for EAN5 and EAN2 instead of
expanding package encoders in this batch.

Required keys:

- `example-page-componentsD/barcode/barcode`
- `barcode-page-code128`
- `barcode-page-ean13`
- `barcode-page-ean8`
- `barcode-page-upca`
- `barcode-page-code39`
- `barcode-page-ean5`
- `barcode-page-ean2`
- `barcode-page-custom`

## Route Registration

Add these route records after `componentsD/dragsort/dragsort`:

```dart
const ExampleRoute(
  id: 'componentsD/cityLocate/cityLocate',
  sourcePath: 'pages/componentsD/cityLocate/cityLocate',
  title: '城市定位',
  group: ExampleRouteGroup.componentsD,
  builder: _buildCityLocate,
),
const ExampleRoute(
  id: 'componentsD/title/title',
  sourcePath: 'pages/componentsD/title/title',
  title: '标题',
  group: ExampleRouteGroup.componentsD,
  builder: _buildTitle,
),
const ExampleRoute(
  id: 'componentsD/pullRefresh/pullRefresh',
  sourcePath: 'pages/componentsD/pullRefresh/pullRefresh',
  title: '下拉刷新',
  group: ExampleRouteGroup.componentsD,
  builder: _buildPullRefresh,
),
const ExampleRoute(
  id: 'componentsD/virtualList/virtualList',
  sourcePath: 'pages/componentsD/virtualList/virtualList',
  title: '虚拟列表',
  group: ExampleRouteGroup.componentsD,
  builder: _buildVirtualList,
),
const ExampleRoute(
  id: 'componentsD/barcode/barcode',
  sourcePath: 'pages/componentsD/barcode/barcode',
  title: '条码',
  group: ExampleRouteGroup.componentsD,
  builder: _buildBarcode,
),
```

Only the matching existing records in `example_preview_catalog.dart` become
available. The preview order and semantic groups remain unchanged.

## Testing

Extend `example/test/components_d_pages_test.dart` with five focused tests:

1. CityLocate settles the injected `南京` result, renders local city data,
   and reports a tapped city selection.
2. Title renders both source variants with two `UPTitle` instances and its
   custom prefix icon.
3. PullRefresh performs a real downward drag in the basic viewport and
   verifies the refresh callback/result; it also verifies all four demo keys.
4. VirtualList renders the first item, performs a real list drag, and checks
   that the visible content/result changes without building all 10,000 rows.
5. Barcode renders all eight `UPBarcode` variants and verifies the custom
   variant's source-visible label/value.

Extend `example/test/route_catalog_test.dart`:

- Update the route count from `93` to `98`.
- Extend the literal Components D route ID list from ten to fifteen IDs in
  source order.
- Add the five source paths to the completed-path assertion.
- Assert the five matching preview records are available.
- Include all five pages in the Components D route smoke test, allowing a
  short pump for CityLocate's post-frame injected location callback.

Do not add package tests unless a focused page test reveals a concrete package
defect.

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

The existing `README.md`, historical untracked files, package source, and
build output remain outside the staged set. Any existing package analyzer
warnings are reported separately; this batch must introduce no new warnings
or errors.

## Non-Goals

- No new package dependency or host integration.
- No real GPS lookup, remote refresh request, or remote animation asset.
- No EAN5/EAN2 barcode encoder expansion.
- No source-manifest edit, catalog redesign, generic page framework, or
  unrelated cleanup.
