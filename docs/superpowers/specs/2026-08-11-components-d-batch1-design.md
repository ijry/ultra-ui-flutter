# Components D Batch 1 Design

**Date:** 2026-08-11

**Goal:** Add the first five source-order Components D example pages to the
Flutter gallery: Qrcode, Copy, NavbarMini, Box, and FloatButton.

## Scope

The batch contains exactly these source routes, in this order:

1. `pages/componentsD/qrcode/qrcode`
2. `pages/componentsD/copy/copy`
3. `pages/componentsD/navbarMini/navbarMini`
4. `pages/componentsD/box/box`
5. `pages/componentsD/floatButton/floatButton`

The implementation adds five real page builders, enables the five existing
preview records, and raises the completed route count from `83` to `88`.
Components D then contains five completed routes. Existing `README.md`,
generated files, helper scripts, and unrelated historical untracked files are
outside the change.

## Approach

Each route gets one focused `StatefulWidget` or `StatelessWidget` page under
`example/lib/pages/components_d/`. Pages reuse `ExamplePageScaffold`,
`ExampleDemoBlock`, and the existing public `UP*` constructors. No generic
Components D abstraction is introduced.

The package is treated as the source of component behavior. A package change
is allowed only when a focused page test reproduces a concrete public API or
rendering gap, and the change must include a minimal package regression test.
No package change is expected for the initial implementation.

The source Qrcode page's remote logo is replaced by the already bundled local
`assets/uview/common/logo.png`. The logo is layered over a real `UPQrcode`
using Flutter layout, so the example remains offline while `UPQrcode` keeps
its existing `icon` string API unchanged.

## Page Designs

### Qrcode

`QrcodePage` renders three source blocks:

- `不带logo`: a 150px black QR code for the fixed source URL.
- `带logo`: the same QR code with the local uView logo centered over it.
- `二维码颜色`: a 150px QR code with red background and blue foreground.

Each block uses a real `UPQrcode`. The logo variant uses a `Stack` with a
small local asset overlay and does not access the source remote URL. The page
has root key `example-page-componentsD/qrcode/qrcode` and QR keys
`qrcode-page-basic`, `qrcode-page-logo`, and `qrcode-page-colors`.

### Copy

`CopyPage` renders `点击文字复制` and `点击按钮复制`. Both examples use
`UPCopy(content: 'uview-plus is great !')`. The page tracks successful copy
callbacks and renders a stable `复制次数：N` label. The text and button
triggers have keys `copy-page-text` and `copy-page-button`; the page root is
`example-page-componentsD/copy/copy`.

Clipboard failure is handled by the existing `UPCopy` feedback path. The page
does not introduce a platform clipboard plugin or network dependency.

### NavbarMini

`NavbarMiniPage` renders:

- `基础功能`: a fixed, safe-area-aware `UPNavbarMini` with a left-click
  callback and a visible click counter.
- `自定义插槽`: a non-fixed, non-safe-area `UPNavbarMini` with a custom left
  slot.

The page provides the callback explicitly so widget tests do not depend on
whether a test route can pop. Keys are `navbar-mini-page-basic`,
`navbar-mini-page-left`, and `navbar-mini-page-custom`; the root key is
`example-page-componentsD/navbarMini/navbarMini`.

### Box

`BoxPage` renders:

- `基础功能`: a 160px `UPBox` with default text slots and a 12px gap.
- `自定义插槽`: a 180px `UPBox` whose three slots contain `UPIcon` instances.

The page uses keys `box-page-basic` and `box-page-custom` and root key
`example-page-componentsD/box/box`. It demonstrates source layout, colors,
height, gap, and slot rendering without adding tap behavior that the source
page does not use.

### FloatButton

`FloatButtonPage` renders:

- `基础功能`: a non-menu `UPFloatButton`.
- `带子菜单模式`: a menu button with two fixed list entries, `plus` and
  `order`, and an item-click counter.
- `自定义插槽`: a menu button with two custom circular list widgets.

The menu examples are placed inside a bounded `Stack` so `Positioned` output
has stable geometry in both the gallery and widget tests. Keys are
`float-button-page-basic`, `float-button-page-menu`,
`float-button-page-custom`, and `float-button-page-menu-trigger`; the root key
is `example-page-componentsD/floatButton/floatButton`.

## Route and Catalog Changes

`example/lib/routes/example_catalog.dart` imports the five page classes,
registers their builders after `componentsC/subsection/subsection`, and keeps
the exact source order. `example/lib/routes/example_preview_catalog.dart`
changes only the five matching Components D records from `available: false` to
`available: true`. Preview groups are not reordered and no duplicate records
are added.

`example/test/route_catalog_test.dart` asserts:

- completed routes have length `88`;
- Components C still has its existing 28-route order;
- Components D has the five-route order listed above;
- all five source paths are in the completed set;
- all five preview records are available;
- route IDs resolve to real builders.

## Testing

`example/test/components_d_pages_test.dart` is added with focused tests:

- Qrcode renders three `UPQrcode` instances and the logo variant contains the
  local asset.
- Copy taps the text and button triggers and increments the success count.
- NavbarMini taps the explicit left callback and verifies the counter.
- Box renders both layouts and all three custom icon slots.
- FloatButton opens the menu, renders both list items, and reports item click.

Each page test also checks its root key and source block titles. The existing
route smoke test is extended to pump all five new route IDs and verify the
source title in the page app bar.

Validation after implementation:

- `dart format` on changed Dart files;
- focused Components D tests;
- route catalog tests;
- `flutter test example`;
- `flutter analyze example`;
- `flutter test packages/ultra_ui`;
- package analyzer with zero new errors;
- `git diff --check`;
- Android debug APK build.

## Non-Goals

- No Components D routes after `floatButton` are implemented in this batch.
- No new dependency, network request, host clipboard plugin, or persistence
  layer is added.
- No redesign of the existing page shell or preview catalog.
- No broad package refactor or API rename is included.

## Acceptance Criteria

The five routes open from the gallery, render source-visible content with
real `UP*` widgets, preserve deterministic offline behavior, and pass focused,
route, package, analyzer, and Android build validation. Existing completed
routes and unrelated worktree contents remain unchanged.
