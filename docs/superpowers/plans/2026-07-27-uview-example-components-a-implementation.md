# uView Plus Flutter Example Components A Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single long-form Flutter showcase with the first installable Android/iOS uView Plus example milestone: a three-destination mobile shell and all 23 registered `pages/componentsA` pages.

**Architecture:** Keep `example/lib/main.dart` as a bootstrap only. Put mobile shell/navigation, source-route metadata, shared source-style page chrome, home destinations, and every Component A page in focused files. The route catalog contains the four source main routes plus the 23 completed Component A routes; the component index uses the seven source semantic groups from `components.config.js`, while implementation batches A-D only control which rows are enabled. The template index shows later source routes as disabled catalog previews until their corresponding migration batch registers a real builder.

**Tech Stack:** Flutter SDK `>=3.19.0`, Dart `>=3.3.0`, Material 3 shell primitives, `flutter_test`, and local package dependency `ultra_ui` using only `UP*` widgets for component demonstrations.

## Global Constraints

- Target Android and iOS only. Do not add Flutter Web-only behavior or browser dependencies.
- Source of truth: `D:\Repos\xyito\open\uview-plus\src\pages.json` plus the corresponding files beneath `D:\Repos\xyito\open\uview-plus\src\pages`.
- Preserve source Chinese titles, source route order, representative default states, and interactive behavior with real `UP*` widgets.
- Component A scope is exactly these 23 registered routes: `transition`, `test`, `icon`, `cell`, `line`, `image`, `link`, `button`, `loading-icon`, `overlay`, `loading-page`, `popup`, `swipeAction`, `sticky`, `radio`, `checkbox`, `empty`, `backtop`, `divider`, `rate`, `gap`, `grid`, and `lazyLoad`.
- Every Component A route has one dedicated non-placeholder page class and one catalog entry. A disabled preview row is allowed only for a later-batch route that has no builder yet.
- All page interactions must use `UP*` components; do not recreate their UI with substitute Material controls.
- Asset-dependent Component A pages must work without network access. Package the source assets actually used by the completed pages under `example/assets/uview/` and list them in `example/pubspec.yaml`.
- Use `dart format`, `flutter analyze`, and widget tests after every task. Do not edit or clean unrelated existing workspace changes.

---

## File Structure

```text
example/
  pubspec.yaml
  lib/
    main.dart
    app/example_app.dart
    app/example_shell.dart
    routes/example_route.dart
    routes/example_catalog.dart
    routes/example_preview_catalog.dart
    pages/home/components_home_page.dart
    pages/home/templates_home_page.dart
    pages/home/mine_page.dart
    pages/home/ad_page.dart
    pages/shared/example_page_scaffold.dart
    pages/shared/example_demo_block.dart
    pages/shared/example_route_list.dart
    pages/shared/example_unavailable_page.dart
    pages/components_a/transition_page.dart
    pages/components_a/test_list_page.dart
    pages/components_a/icon_page.dart
    pages/components_a/cell_page.dart
    pages/components_a/line_page.dart
    pages/components_a/image_page.dart
    pages/components_a/link_page.dart
    pages/components_a/button_page.dart
    pages/components_a/loading_icon_page.dart
    pages/components_a/overlay_page.dart
    pages/components_a/loading_page_page.dart
    pages/components_a/popup_page.dart
    pages/components_a/swipe_action_page.dart
    pages/components_a/sticky_page.dart
    pages/components_a/radio_page.dart
    pages/components_a/checkbox_page.dart
    pages/components_a/empty_page.dart
    pages/components_a/back_top_page.dart
    pages/components_a/divider_page.dart
    pages/components_a/rate_page.dart
    pages/components_a/gap_page.dart
    pages/components_a/grid_page.dart
    pages/components_a/lazy_load_page.dart
  test/
    example_app_test.dart
    example_test_helpers.dart
    route_catalog_test.dart
    components_a_pages_test.dart
  tool/download_component_a_assets.ps1
  assets/uview/common/logo.png
  assets/uview/album/1.jpg
  assets/uview/empty/{address,car,comment,coupon,data,history,list,message,news,order,page,permission,search,wifi}.png
  assets/uview/demo/cell/tag.png
  assets/uview/demo/empty/{car,data,comment,coupon,history,list,message,news,order,page,permission,search,wifi}.png
  assets/uview/demo/transition/{fade,fadeUp,zoom,fadeZoom,fadeDown,fadeLeft,fadeRight,slideUp,slideDown,slideLeft,slideRight}.png
  assets/uview/demo/overlay/{baseCases,embeddedContent,setTransparency}.png
  assets/uview/demo/loading-page/{promptContent,customPicture,customMode,customBgColor}.png
  assets/uview/demo/popup/{modeTop,modeRight,modeBottom,modeLeft,modeCenter,showRadis,noClose,showCloseBtn}.png
  assets/uview/swiper/{swiper1,swiper2,swiper3}.png
  assets/uview/test/list-item.jpg
```

`ExampleRoute` is the app's completed-route contract. `ExamplePreviewRoute` is index-only metadata for source routes that are visible in the source list but not yet registered because their migration batch is incomplete.

```dart
enum ExampleRouteGroup { main, componentsA, componentsB, componentsC, componentsD, template }

class ExampleRoute {
  const ExampleRoute({
    required this.id,
    required this.sourcePath,
    required this.title,
    required this.group,
    required this.builder,
  });

  final String id;
  final String sourcePath;
  final String title;
  final ExampleRouteGroup group;
  final WidgetBuilder builder;
}

class ExamplePreviewRoute {
  const ExamplePreviewRoute({
    required this.sourcePath,
    required this.title,
    required this.group,
    required this.available,
  });

  final String sourcePath;
  final String title;
  final ExampleRouteGroup group;
  final bool available;
}
```

## Source Route Matrix

| Source path | Title | Flutter page | Required observable behavior |
| --- | --- | --- | --- |
| `pages/componentsA/transition/transition` | `过渡动画` | `TransitionPage` | Tap each mode row; a 120px primary block enters with that `UPTransition` mode and leaves after 1.5 seconds. |
| `pages/componentsA/test/test` | `测试` | `TestListPage` | Scroll a fixed-height `UPList` with repeated image list items. |
| `pages/componentsA/icon/icon` | `图标` | `IconPage` | Render source icon-name grid and invoke a source-style feedback message on icon tap. |
| `pages/componentsA/cell/cell` | `单元格` | `CellPage` | Render cell groups covering titles, labels, icons, values, links, borders, and slot-like tag content. |
| `pages/componentsA/line/line` | `线条` | `LinePage` | Render default, colored, fixed-length, dashed, non-hairline, margin, and vertical `UPLine` examples. |
| `pages/componentsA/image/image` | `图片` | `ImagePage` | Render source image fit/radius/shape examples plus a loading-slot `UPLoadingIcon`; tap reports a message. |
| `pages/componentsA/link/link` | `超链接` | `LinkPage` | Render default, color, disabled, and underline `UPLink` variants; interaction gives in-app feedback without relying on a browser. |
| `pages/componentsA/button/button` | `按钮` | `ButtonPage` | Render source type/plain/hairline/shape/size/loading/disabled/icon variants; action-sheet trigger opens `UPActionSheet`. |
| `pages/componentsA/loading-icon/loading-icon` | `加载中图标` | `LoadingIconPage` | Render source spinner, semicircle, circle, linear, custom color, size, and text examples. |
| `pages/componentsA/overlay/overlay` | `遮罩层` | `OverlayPage` | Open basic, embedded-content, and opacity overlays; tapping each overlay closes it. |
| `pages/componentsA/loading-page/loading-page` | `加载页` | `LoadingPagePage` | Select each source preset; show `UPLoadingPage` for two seconds with matching text/image/mode/background. |
| `pages/componentsA/popup/popup` | `弹窗` | `PopupPage` | Open source top/right/bottom/left/center/round/non-dismissible/closeable/touchable presets with close behavior preserved. |
| `pages/componentsA/swipeAction/swipeAction` | `滑动单元格` | `SwipeActionPage` | Show default, multi-action, icon, disabled, auto-close, and round-action rows; confirming delete removes the first row. |
| `pages/componentsA/sticky/sticky` | `吸顶` | `StickyPage` | Scroll long content; `UPSticky` button remains at top and reports tap feedback. |
| `pages/componentsA/radio/radio` | `单选框` | `RadioPage` | Render source group direction, disabled, icon/color/shape/size/label variants and retain selected names. |
| `pages/componentsA/checkbox/checkbox` | `复选框` | `CheckboxPage` | Render source group direction, disabled, icon/color/shape/size/label variants plus programmatic standalone toggle. |
| `pages/componentsA/empty/empty` | `内容为空` | `EmptyPage` | Render default empty state and a selectable source mode list that updates its icon/text. |
| `pages/componentsA/backtop/backtop` | `返回顶部` | `BackTopPage` | Long scroll content and source checkbox controls for `UPBackTop`; tapping it scrolls to top. |
| `pages/componentsA/divider/divider` | `分割线` | `DividerPage` | Render source text/line-color/text-position/text-color/dashed/hairline variants. |
| `pages/componentsA/rate/rate` | `评分` | `RatePage` | Render source size/count/disabled/readonly/color/void-icon/touch/half/icon variants; editable ratings update state. |
| `pages/componentsA/gap/gap` | `间隔槽` | `GapPage` | Render source default, custom-color, custom-height, and custom-margin `UPGap` variants. |
| `pages/componentsA/grid/grid` | `宫格` | `GridPage` | Render source no-border, border, custom-column, icon-size, and square grids; tap gives feedback. |
| `pages/componentsA/lazyLoad/lazyLoad` | `图片懒加载` | `LazyLoadPage` | Render source lazy image list and `UPLoadmore`; tapping load-more appends the next fixed local-image batch. |

---

### Task 1: Establish Example App Foundation, Shell, and Route Contracts

**Files:**
- Modify: `example/pubspec.yaml`
- Modify: `example/lib/main.dart`
- Create: `example/lib/app/example_app.dart`
- Create: `example/lib/app/example_shell.dart`
- Create: `example/lib/routes/example_route.dart`
- Create: `example/lib/routes/example_catalog.dart`
- Create: `example/lib/routes/example_preview_catalog.dart`
- Create: `example/lib/pages/shared/example_page_scaffold.dart`
- Create: `example/lib/pages/shared/example_demo_block.dart`
- Create: `example/lib/pages/shared/example_route_list.dart`
- Create: `example/lib/pages/shared/example_unavailable_page.dart`
- Create: `example/lib/pages/home/components_home_page.dart`
- Create: `example/lib/pages/home/templates_home_page.dart`
- Create: `example/lib/pages/home/mine_page.dart`
- Create: `example/lib/pages/home/ad_page.dart`
- Create: `example/test/example_app_test.dart`
- Create: `example/test/example_test_helpers.dart`
- Create: `example/test/route_catalog_test.dart`

**Interfaces:**
- Produces `UltraUiExampleApp`, a `MaterialApp` using `UP.themeData()` and `ExampleShell` as `home`.
- Produces `ExampleRoute`, `ExamplePreviewRoute`, `exampleRoutes`, `findExampleRoute(String id)`, `ExampleShell`, `ExamplePageScaffold`, and `pushExampleRoute(BuildContext context, ExampleRoute route)`.
- Produces `pumpExampleApp(WidgetTester tester)` and `buildRouteUnderTest(String id)` for later example tests.
- `exampleRoutes` contains exactly four source-main entries. Component A entries are registered by Tasks 3-7 and all later-batch rows remain `ExamplePreviewRoute(available: false)` until their batch is complete.

- [ ] **Step 1: Write the failing app boot test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/app/example_app.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

Future<void> pumpExampleApp(WidgetTester tester) {
  return tester.pumpWidget(const UltraUiExampleApp());
}

void main() {
  testWidgets('example app opens the source component destination',
      (tester) async {
    await pumpExampleApp(tester);

    expect(find.text('组件'), findsWidgets);
    expect(find.text('模板'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('uview-plus'), findsOneWidget);
  });

  testWidgets('bottom navigation preserves all three source destinations',
      (tester) async {
    await pumpExampleApp(tester);

    await tester.tap(find.text('模板'));
    await tester.pumpAndSettle();
    expect(find.text('模板'), findsWidgets);
    expect(find.text('部件'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('演示用户'), findsOneWidget);
  });

  test('completed catalog ids and source paths are unique', () {
    expect(exampleRoutes.map((route) => route.id).toSet().length,
        exampleRoutes.length);
    expect(exampleRoutes.map((route) => route.sourcePath).toSet().length,
        exampleRoutes.length);
  });
}
```

- [ ] **Step 2: Run the app boot test to verify it fails**

Run: `flutter test test/example_app_test.dart --plain-name "example app opens the source component destination" --reporter expanded`

Expected: FAIL because the app root, source shell, and route catalog are absent.

- [ ] **Step 3: Implement the bootstrap, source shell, routes, and shared page primitives**

```dart
// example/lib/main.dart
import 'package:flutter/widgets.dart';
import 'app/example_app.dart';

void main() => runApp(const UltraUiExampleApp());
```

```dart
// example/lib/app/example_app.dart
class UltraUiExampleApp extends StatelessWidget {
  const UltraUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uview-plus',
      debugShowCheckedModeBanner: false,
      theme: UP.themeData(),
      home: const ExampleShell(),
    );
  }
}
```

Add `assets/uview/` to `example/pubspec.yaml` now. Keep `ultra_ui` as a local path dependency and do not add an HTTP/image package for Component A.

Implement `ExampleShell` as a stateful `Scaffold` with `NavigationBar` destinations named exactly `组件`, `模板`, and `我的`. Keep each root destination alive with an `IndexedStack` so navigation tab changes preserve source-style local state.

Implement `ExamplePageScaffold` with a `SafeArea`, a Material app bar containing the source title, normal `Navigator.maybePop` back behavior, source page background from `UPThemeTokens.of(context).pageBgColor`, and a `ListView` body when `scrollable` is true.

```dart
class ExamplePageScaffold extends StatelessWidget {
  const ExamplePageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.scrollable = true,
  });

  final String title;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? ListView(padding: const EdgeInsets.only(bottom: 24), children: [child])
        : child;
    return Scaffold(appBar: AppBar(title: Text(title)), body: SafeArea(child: body));
  }
}
```

Implement root pages with source-visible content:

- `ComponentsHomePage`: source description and the seven source semantic groups from `pages/example/components.config.js`. Component A entries stay unavailable until their corresponding Task 3-7 registration. Components B-D entries are disabled and labelled `后续迁移`.
- `TemplatesHomePage`: source `部件` and `页面` groups from `template.config.js`, all entries disabled and labelled `后续迁移` during this batch.
- `MinePage`: source avatar/name/ID, theme-preference cells, readable current theme state, and a local `UPToast` bridge demonstration.
- `AdPage`: source title/body/button with Android/iOS message `激励广告仅适用于微信小程序，Flutter 示例不提供广告播放` instead of a fake video ad.

`ExampleRouteList` must open available entries using the actual catalog builder and show a disabled trailing `后续迁移` value for previews with `available: false`.

Define the shared widget-test helper with the same theme and builder contract used at runtime:

```dart
// example/test/example_test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';
import 'package:ultra_ui_example/app/example_app.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

Future<void> pumpExampleApp(WidgetTester tester) {
  return tester.pumpWidget(const UltraUiExampleApp());
}

Widget buildRouteUnderTest(String id) {
  final route = findExampleRoute(id);
  return MaterialApp(
    theme: UP.themeData(),
    home: Builder(builder: route.builder),
  );
}
```

- [ ] **Step 4: Run foundation tests and analyzer**

Run: `flutter test test/example_app_test.dart test/route_catalog_test.dart --reporter expanded`

Expected: PASS.

Run: `flutter analyze`

Expected: no issues.

- [ ] **Step 5: Commit the app foundation**

```bash
git add example/pubspec.yaml example/lib/main.dart example/lib/app example/lib/routes example/lib/pages/shared example/lib/pages/home example/test/example_app_test.dart example/test/example_test_helpers.dart example/test/route_catalog_test.dart
git commit -m "feat(example): add source-shaped mobile shell"
```

### Task 2: Add Offline Asset and Loading-Slot Support to Core Image Components

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_image.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_empty.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- Consumes the existing `UPImage` and `UPEmpty` constructors.
- Extends `UPImage` with optional `Widget? loadingWidget` and `Widget? errorWidget` slots without changing existing defaults.
- Makes `UPEmpty(icon: 'assets/...')` render its provided icon through an asset image and keeps `http://` / `https://` icons on the existing network path.
- Produces offline-safe component behavior used by Component A pages in Tasks 3-7.

- [ ] **Step 1: Write failing package widget tests for local assets and the loading slot**

```dart
testWidgets('UPImage renders a supplied loading slot while its source is empty',
    (tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: Scaffold(
      body: UPImage(
        src: '',
        width: 80,
        height: 80,
        loadingWidget: Text('图片加载中'),
      ),
    ),
  ));

  expect(find.text('图片加载中'), findsOneWidget);
});

testWidgets('UPEmpty uses an asset image when its icon is a local asset path',
    (tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: Scaffold(
      body: UPEmpty(
        mode: 'car',
        icon: 'assets/uview/empty/car.png',
      ),
    ),
  ));

  expect(find.byType(Image), findsOneWidget);
  expect(
    tester.widget<Image>(find.byType(Image)).image,
    isA<AssetImage>(),
  );
});
```

- [ ] **Step 2: Run package tests to verify they fail**

Run: `flutter test test/widgets_test.dart --name "UPImage renders a supplied loading slot|UPEmpty uses an asset image" --reporter expanded`

Expected: FAIL because `UPImage.loadingWidget` is absent and `UPEmpty` always uses `Image.network` for icon paths.

- [ ] **Step 3: Implement backward-compatible offline asset and slot behavior**

Add these optional fields to `UPImage`, preserving the existing constructor defaults and existing loading/error behavior when neither field is supplied:

```dart
final Widget? loadingWidget;
final Widget? errorWidget;
```

Use `loadingWidget` in the empty-source and network frame-loading branches, and `errorWidget` in both image error branches. Retain the existing `UPIcon` fallback when the corresponding widget is null.

In `UPEmpty`, split the current `_isSrc` image branch by URL scheme:

```dart
final isNetworkIcon = icon.startsWith('http://') || icon.startsWith('https://');
final image = isNetworkIcon
    ? Image.network(icon, fit: BoxFit.contain, errorBuilder: fallback)
    : Image.asset(icon, fit: BoxFit.contain, errorBuilder: fallback);
```

`fallback` must remain the existing `UPIcon(name: 'photo', ...)` behavior.

- [ ] **Step 4: Run focused and full package verification**

Run: `dart format lib/src/widgets/up_image.dart lib/src/widgets/up_empty.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPImage renders a supplied loading slot|UPEmpty uses an asset image" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_image.dart lib/src/widgets/up_empty.dart`

Expected: all commands PASS with no analyzer issues.

- [ ] **Step 5: Commit core offline image support**

```bash
git add packages/ultra_ui/lib/src/widgets/up_image.dart packages/ultra_ui/lib/src/widgets/up_empty.dart packages/ultra_ui/test/widgets_test.dart
git commit -m "feat: support local example image assets"
```

### Task 3: Migrate Component A Display and Layout Pages

**Files:**
- Create: `example/lib/pages/components_a/icon_page.dart`
- Create: `example/lib/pages/components_a/cell_page.dart`
- Create: `example/lib/pages/components_a/line_page.dart`
- Create: `example/lib/pages/components_a/image_page.dart`
- Create: `example/lib/pages/components_a/link_page.dart`
- Create: `example/lib/pages/components_a/loading_icon_page.dart`
- Create: `example/lib/pages/components_a/divider_page.dart`
- Create: `example/lib/pages/components_a/gap_page.dart`
- Create: `example/lib/pages/components_a/grid_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/pubspec.yaml`
- Create: `example/tool/download_component_a_assets.ps1`
- Create: `example/test/components_a_pages_test.dart`
- Create: `example/assets/uview/album/1.jpg`
- Create: `example/assets/uview/demo/cell/tag.png`
- Create: `example/assets/uview/demo/transition/{fade,fadeUp,zoom,fadeZoom,fadeDown,fadeLeft,fadeRight,slideUp,slideDown,slideLeft,slideRight}.png`

**Interfaces:**
- Consumes `ExamplePageScaffold`, `ExampleDemoBlock`, `ExampleRoute`, and `UP*` components from Task 1.
- Produces nine dedicated page builders registered under the exact source paths in the route matrix.
- Adds nine `ExamplePreviewRoute(available: true)` entries for the component index.

- [ ] **Step 1: Write failing route and interaction tests for display/layout pages**

```dart
testWidgets('Component A display routes render their source titles',
    (tester) async {
  for (final id in [
    'componentsA/icon/icon',
    'componentsA/cell/cell',
    'componentsA/line/line',
    'componentsA/image/image',
    'componentsA/link/link',
    'componentsA/loading-icon/loading-icon',
    'componentsA/divider/divider',
    'componentsA/gap/gap',
    'componentsA/grid/grid',
  ]) {
    await tester.pumpWidget(buildRouteUnderTest(id));
    expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
    expect(find.text(findExampleRoute(id).title), findsOneWidget);
  }
});

testWidgets('grid item tap reports source-style feedback', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/grid/grid'));
  await tester.tap(find.text('宫格1').first);
  await tester.pump();
  expect(find.text('点击了宫格1'), findsOneWidget);
});
```

- [ ] **Step 2: Run display/layout tests to verify they fail**

Run: `flutter test test/components_a_pages_test.dart --name "Component A display|grid item" --reporter expanded`

Expected: FAIL because the route builders and pages are absent.

- [ ] **Step 3: Implement the nine dedicated source-shaped pages**

Every page uses its literal source title in `ExamplePageScaffold` and a route marker whose key is the literal form `ValueKey('example-page-componentsA/<component>/<component>')`.

- `IconPage`: icon groups from `icon.nvue`; tap an icon and show `UPToast` text `当前图标：<name>`.
- `CellPage`: preserve the six `UPCellGroup` sections from `cell.nvue`, including title/label/value/link/icon and the `UPTag` content row.
- `LinePage`: preserve the seven examples from `line.nvue` with source colors, lengths, direction, margins, and hairline settings.
- `ImagePage`: preserve source width/height/radius/shape/mode/loading cases using `assets/uview/album/1.jpg` and `UPImage(loadingWidget: const UPLoadingIcon(color: 'red'))` for the source loading-slot case.
- `LinkPage`: preserve default/color/disabled/underlined source variants. Link taps show `UPToast` with the requested source URL rather than launching an external browser.
- `LoadingIconPage`: preserve all source `UPLoadingIcon` mode, timing, color, size, and text variants.
- `DividerPage`: preserve default text, text position, line/text colors, dashed line, and hairline variants.
- `GapPage`: preserve default theme-background, `#2979ff`, 40px height, and custom margin examples.
- `GridPage`: preserve no-border, border, custom column count, custom icon-size, and square modes; cell labels are `宫格1` through `宫格8` and tapping reports `点击了宫格N`.

Create `example/tool/download_component_a_assets.ps1`. It is a build-time fixture acquisition script only; the application reads the copied files from its Flutter asset bundle and never requests a remote image at runtime. The script must copy the source logo and download every listed Component A source image using this literal manifest:

```powershell
$ErrorActionPreference = 'Stop'
$exampleRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = 'D:\Repos\xyito\open\uview-plus\src'
$assetsRoot = Join-Path $exampleRoot 'assets\uview'

New-Item -ItemType Directory -Force -Path (Join-Path $assetsRoot 'common') | Out-Null
Copy-Item -LiteralPath (Join-Path $sourceRoot 'static\uview\common\logo.png') `
  -Destination (Join-Path $assetsRoot 'common\logo.png') -Force

$assets = [ordered]@{
  'album\1.jpg' = 'https://uview-plus.jiangruyi.com/uview/album/1.jpg'
  'demo\cell\tag.png' = 'https://uview-plus.jiangruyi.com/uview/example/tag.png'
  'demo\transition\fade.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fade.png'
  'demo\transition\fadeUp.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeUp.png'
  'demo\transition\zoom.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/zoom.png'
  'demo\transition\fadeZoom.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeZoom.png'
  'demo\transition\fadeDown.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeDown.png'
  'demo\transition\fadeLeft.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeLeft.png'
  'demo\transition\fadeRight.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeRight.png'
  'demo\transition\slideUp.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideUp.png'
  'demo\transition\slideDown.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideDown.png'
  'demo\transition\slideLeft.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideLeft.png'
  'demo\transition\slideRight.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideRight.png'
  'demo\overlay\baseCases.png' = 'https://uview-plus.jiangruyi.com/uview/demo/overlay/baseCases.png'
  'demo\overlay\embeddedContent.png' = 'https://uview-plus.jiangruyi.com/uview/demo/overlay/embeddedContent.png'
  'demo\overlay\setTransparency.png' = 'https://uview-plus.jiangruyi.com/uview/demo/overlay/setTransparency.png'
  'demo\loading-page\promptContent.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/promptContent.png'
  'demo\loading-page\customPicture.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/customPicture.png'
  'demo\loading-page\customMode.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/customMode.png'
  'demo\loading-page\customBgColor.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/customBgColor.png'
  'demo\popup\modeTop.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeTop.png'
  'demo\popup\modeRight.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeRight.png'
  'demo\popup\modeBottom.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeBottom.png'
  'demo\popup\modeLeft.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeLeft.png'
  'demo\popup\modeCenter.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeCenter.png'
  'demo\popup\showRadis.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/showRadis.png'
  'demo\popup\noClose.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/noClose.png'
  'demo\popup\showCloseBtn.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/showCloseBtn.png'
  'swiper\swiper1.png' = 'https://uview-plus.jiangruyi.com/uview/swiper/swiper1.png'
  'swiper\swiper2.png' = 'https://uview-plus.jiangruyi.com/uview/swiper/swiper2.png'
  'swiper\swiper3.png' = 'https://uview-plus.jiangruyi.com/uview/swiper/swiper3.png'
  'test\list-item.jpg' = 'https://img2020.cnblogs.com/blog/35695/202112/35695-20211222112522991-1769312387.jpg'
}

foreach ($entry in $assets.GetEnumerator()) {
  $destination = Join-Path $assetsRoot $entry.Key
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Invoke-WebRequest -Uri $entry.Value -OutFile $destination
}

$emptyModes = 'address', 'car', 'comment', 'coupon', 'data', 'history', 'list', 'message', 'news', 'order', 'page', 'permission', 'search', 'wifi'
foreach ($mode in $emptyModes) {
  $destination = Join-Path $assetsRoot "empty\$mode.png"
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Invoke-WebRequest -Uri "https://uview-plus.jiangruyi.com/uview/empty/$mode.png" -OutFile $destination
}

$emptyDemoModes = 'car', 'data', 'comment', 'coupon', 'history', 'list', 'message', 'news', 'order', 'page', 'permission', 'search', 'wifi'
foreach ($mode in $emptyDemoModes) {
  $destination = Join-Path $assetsRoot "demo\empty\$mode.png"
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Invoke-WebRequest -Uri "https://uview-plus.jiangruyi.com/uview/demo/empty/$mode.png" -OutFile $destination
}
```

Run `powershell -ExecutionPolicy Bypass -File tool/download_component_a_assets.ps1` from `example/`, then declare each directory in `pubspec.yaml` under `flutter.assets`: `assets/uview/common/`, `assets/uview/album/`, `assets/uview/empty/`, `assets/uview/demo/cell/`, `assets/uview/demo/empty/`, `assets/uview/demo/transition/`, `assets/uview/demo/overlay/`, `assets/uview/demo/loading-page/`, `assets/uview/demo/popup/`, `assets/uview/swiper/`, and `assets/uview/test/`.

- [ ] **Step 4: Run display/layout tests and formatter**

Run: `dart format lib test`

Run: `flutter test test/components_a_pages_test.dart --name "Component A display|grid item" --reporter expanded`

Expected: PASS.

- [ ] **Step 5: Commit display/layout Component A pages**

```bash
git add example/lib/pages/components_a/icon_page.dart example/lib/pages/components_a/cell_page.dart example/lib/pages/components_a/line_page.dart example/lib/pages/components_a/image_page.dart example/lib/pages/components_a/link_page.dart example/lib/pages/components_a/loading_icon_page.dart example/lib/pages/components_a/divider_page.dart example/lib/pages/components_a/gap_page.dart example/lib/pages/components_a/grid_page.dart example/lib/routes example/tool/download_component_a_assets.ps1 example/assets/uview example/pubspec.yaml example/test/components_a_pages_test.dart
git commit -m "feat(example): add component A display pages"
```

### Task 4: Migrate Component A Selection and Rating Pages

**Files:**
- Create: `example/lib/pages/components_a/radio_page.dart`
- Create: `example/lib/pages/components_a/checkbox_page.dart`
- Create: `example/lib/pages/components_a/rate_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_a_pages_test.dart`

**Interfaces:**
- Consumes the page scaffold, catalog contracts, `UPRadioGroup`, `UPRadio`, `UPCheckboxGroup`, `UPCheckbox`, `UPRate`, and `UPButton`.
- Produces three stateful pages registered at the exact source paths, whose selected values survive ordinary rebuilds within their page.

- [ ] **Step 1: Write failing selection-state tests**

```dart
testWidgets('radio page changes the source group value', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/radio/radio'));
  await tester.tap(find.text('苹果').first);
  await tester.pump();
  expect(find.text('当前选择：apple'), findsOneWidget);
});

testWidgets('checkbox page programmatic toggle changes standalone state',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/checkbox/checkbox'));
  await tester.tap(find.text('切换').first);
  await tester.pump();
  expect(find.text('true'), findsWidgets);
});

testWidgets('rate page emits an editable half rating', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/rate/rate'));
  await tester.tap(find.byType(UPRate).last);
  await tester.pump();
  expect(find.textContaining('当前评分：'), findsOneWidget);
});
```

- [ ] **Step 2: Run selection-state tests to verify they fail**

Run: `flutter test test/components_a_pages_test.dart --name "radio page|checkbox page|rate page" --reporter expanded`

Expected: FAIL because the pages are absent.

- [ ] **Step 3: Implement radio, checkbox, and rate pages from their source matrices**

- `RadioPage`: create seven source sections with group values `radiovalue1` through `radiovalue7`; demonstrate horizontal/vertical direction, disabled state, icon/color/shape/size/label styling and group change display. Use source names `苹果`, `香蕉`, `橙子` where the source uses fruit options.
- `CheckboxPage`: create seven source group sections with values `checkboxValue1` through `checkboxValue7`; preserve source group direction, disabled state, icon/color/shape/size/label styling. Include `aloneChecked` and a primary source `切换` button that toggles it.
- `RatePage`: create source sections for 20px default, controlled value, count 4, disabled, readonly, custom active color, void icon, non-touchable/touchable, half mode, and active icon. Each editable source section updates a visible `当前评分：<value>` result.

Each page must use local `StatefulWidget` state, invoke `UP*` callbacks to update that state, and keep disabled/readonly variants non-interactive.

- [ ] **Step 4: Run selection-state tests and full example test suite**

Run: `flutter test test/components_a_pages_test.dart --name "radio page|checkbox page|rate page" --reporter expanded`

Run: `flutter test --reporter expanded`

Expected: PASS.

- [ ] **Step 5: Commit selection Component A pages**

```bash
git add example/lib/pages/components_a/radio_page.dart example/lib/pages/components_a/checkbox_page.dart example/lib/pages/components_a/rate_page.dart example/lib/routes example/test/components_a_pages_test.dart
git commit -m "feat(example): add component A selection pages"
```

### Task 5: Migrate Component A Buttons, Transitions, and Empty States

**Files:**
- Create: `example/lib/pages/components_a/button_page.dart`
- Create: `example/lib/pages/components_a/transition_page.dart`
- Create: `example/lib/pages/components_a/empty_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_a_pages_test.dart`

**Interfaces:**
- Consumes `UPButton`, `UPActionSheet`, `UPTransition`, `UPEmpty`, `UPCell`, and shared source page scaffold.
- Produces three page builders for `button/button`, `transition/transition`, and `empty/empty`.

- [ ] **Step 1: Write failing transient-state tests**

```dart
testWidgets('button page opens its source action sheet', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/button/button'));
  await tester.tap(find.text('打开上拉菜单'));
  await tester.pumpAndSettle();
  expect(find.text('拍照'), findsOneWidget);
});

testWidgets('transition page shows the selected transition block',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/transition/transition'));
  await tester.tap(find.text('淡入'));
  await tester.pump();
  expect(find.byKey(const ValueKey('transition-preview')), findsOneWidget);
});

testWidgets('empty page changes its selected source mode', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/empty/empty'));
  await tester.tap(find.text('购物车为空'));
  await tester.pump();
  expect(find.text('购物车为空'), findsWidgets);
});
```

- [ ] **Step 2: Run transient-state tests to verify they fail**

Run: `flutter test test/components_a_pages_test.dart --name "button page|transition page|empty page" --reporter expanded`

Expected: FAIL because the pages are absent.

- [ ] **Step 3: Implement the three stateful source pages**

- `ButtonPage`: implement all source groups: component type, plain, hairline border, size, shape, disabled, loading, icon, color, and custom style. Preserve source labels. The source ActionSheet trigger must be labeled `打开上拉菜单`, use `UPActionSheet`, and expose `拍照`, `从相册选择`, and `删除` actions.
- `TransitionPage`: render all eleven source rows in source order. Tapping a row sets its exact mode, shows a 120px primary preview keyed `transition-preview`, and schedules one 1500ms hide with a cancel-safe `Timer` disposed by the page.
- `EmptyPage`: render the default source `UPEmpty` plus source mode rows `购物车为空`, `数据为空`, `评论为空`, `优惠券为空`, `历史记录为空`, `列表为空`, `消息为空`, `新闻为空`, `订单为空`, `页面不存在`, `权限不足`, `搜索结果为空`, and `网络不给力`; tapping a row changes the displayed `UPEmpty` mode.

- [ ] **Step 4: Run transient-state tests**

Run: `flutter test test/components_a_pages_test.dart --name "button page|transition page|empty page" --reporter expanded`

Expected: PASS.

- [ ] **Step 5: Commit button, transition, and empty pages**

```bash
git add example/lib/pages/components_a/button_page.dart example/lib/pages/components_a/transition_page.dart example/lib/pages/components_a/empty_page.dart example/lib/routes example/test/components_a_pages_test.dart
git commit -m "feat(example): add component A feedback pages"
```

### Task 6: Migrate Component A Overlay, Loading Page, and Popup Pages

**Files:**
- Create: `example/lib/pages/components_a/overlay_page.dart`
- Create: `example/lib/pages/components_a/loading_page_page.dart`
- Create: `example/lib/pages/components_a/popup_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/pubspec.yaml`
- Modify: `example/test/components_a_pages_test.dart`

**Interfaces:**
- Consumes `UPOverlay`, `UPLoadingPage`, `UPPopup`, `UPCell`, `UPButton`, and the shared page scaffold.
- Produces three dedicated stateful pages using the already bundled offline assets from Task 3.

- [ ] **Step 1: Write failing overlay, loading, and popup tests**

```dart
testWidgets('overlay page opens and dismisses embedded content', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/overlay/overlay'));
  await tester.tap(find.text('嵌入内容'));
  await tester.pump();
  expect(find.byKey(const ValueKey('overlay-content-box')), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('up-overlay-mask')));
  await tester.pump();
  expect(find.byKey(const ValueKey('overlay-content-box')), findsNothing);
});

testWidgets('loading page uses the custom text preset', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/loading-page/loading-page'));
  await tester.tap(find.text('自定义提示内容'));
  await tester.pump();
  expect(find.text('Hello uview-plus'), findsOneWidget);
});

testWidgets('popup page opens a top popup preset', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/popup/popup'));
  await tester.tap(find.text('顶部弹出'));
  await tester.pumpAndSettle();
  expect(find.text('点我关闭'), findsOneWidget);
});
```

- [ ] **Step 2: Run overlay/loading/popup tests to verify they fail**

Run: `flutter test test/components_a_pages_test.dart --name "overlay page|loading page|popup page" --reporter expanded`

Expected: FAIL because the pages are absent.

- [ ] **Step 3: Implement source presets and offline assets**

- `OverlayPage`: present `基本案列`, `嵌入内容`, and `设置透明度` cells. Use three independent boolean states. The embedded variant displays `overlay-content-box`; every visible overlay closes on tap.
- `LoadingPagePage`: present all four source preset cells. Reset all values before applying each preset, show `UPLoadingPage` for 2 seconds, and retain source values: `Hello uview-plus` semicircle, local `logo.png` with `uview-plus`, circle, and a translucent dark spinner variant.
- `PopupPage`: present nine source cells: top/right/bottom/left/center, round, non-dismissible overlay, closeable, and touchable bottom. Each tap overwrites a `PopupPreset` value object before setting `show = true`. The slot includes a small scrollable `列表滚动1` through `列表滚动30` list and a `点我关闭` `UPButton`.

Use the exact source-derived asset paths acquired in Task 3: `assets/uview/demo/overlay/baseCases.png`, `embeddedContent.png`, `setTransparency.png`; `assets/uview/demo/loading-page/promptContent.png`, `customPicture.png`, `customMode.png`, `customBgColor.png`; `assets/uview/demo/popup/modeTop.png`, `modeRight.png`, `modeBottom.png`, `modeLeft.png`, `modeCenter.png`, `showRadis.png`, `noClose.png`, `showCloseBtn.png`; and `assets/uview/common/logo.png`. Do not use remote URLs at runtime.

- [ ] **Step 4: Run overlay/loading/popup tests and asset-aware build validation**

Run: `flutter test test/components_a_pages_test.dart --name "overlay page|loading page|popup page" --reporter expanded`

Run: `flutter build apk --debug`

Expected: tests PASS and debug APK builds with all declared assets resolved.

- [ ] **Step 5: Commit Component A layer pages and assets**

```bash
git add example/lib/pages/components_a/overlay_page.dart example/lib/pages/components_a/loading_page_page.dart example/lib/pages/components_a/popup_page.dart example/lib/routes example/assets/uview example/pubspec.yaml example/test/components_a_pages_test.dart
git commit -m "feat(example): add component A layer pages"
```

### Task 7: Migrate Component A Swipe, Sticky, BackTop, and Lazy List Pages

**Files:**
- Create: `example/lib/pages/components_a/swipe_action_page.dart`
- Create: `example/lib/pages/components_a/sticky_page.dart`
- Create: `example/lib/pages/components_a/back_top_page.dart`
- Create: `example/lib/pages/components_a/lazy_load_page.dart`
- Create: `example/lib/pages/components_a/test_list_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/pubspec.yaml`
- Modify: `example/test/components_a_pages_test.dart`

**Interfaces:**
- Consumes `UPSwipeAction`, `UPSwipeActionItem`, `UPSticky`, `UPBackTop`, `UPLazyLoad`, `UPLoadmore`, `UPList`, `UPListItem`, `UPImage`, and shared page chrome.
- Produces five dedicated scroll/gesture page builders using the already bundled offline image fixtures from Task 3.

- [ ] **Step 1: Write failing scroll and gesture tests**

```dart
testWidgets('swipe action delete confirmation removes the base row',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/swipeAction/swipeAction'));
  await tester.drag(find.text('基础使用'), const Offset(-320, 0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('删除'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('确定'));
  await tester.pumpAndSettle();
  expect(find.text('基础使用'), findsNothing);
});

testWidgets('back top page returns its controller to scroll origin',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/backtop/backtop'));
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(UPBackTop));
  await tester.pumpAndSettle();
  expect(tester.state<ScrollableState>(find.byType(Scrollable).first)
      .position.pixels, 0);
});

testWidgets('lazy load page appends a source image batch', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsA/lazyLoad/lazyLoad'));
  final before = find.byType(UPLazyLoad).evaluate().length;
  await tester.tap(find.text('加载更多'));
  await tester.pumpAndSettle();
  expect(find.byType(UPLazyLoad).evaluate().length, greaterThan(before));
});
```

- [ ] **Step 2: Run scroll and gesture tests to verify they fail**

Run: `flutter test test/components_a_pages_test.dart --name "swipe action|back top|lazy load" --reporter expanded`

Expected: FAIL because the page builders are absent.

- [ ] **Step 3: Implement the five scroll/gesture pages**

- `SwipeActionPage`: preserve all five source blocks. The base row opens delete, gives a source text confirmation dialog `温馨提示` / `确定要删除吗？`, and removes itself only after confirmation. Preserve multi-action, icon action, disabled/normal/auto-close rows, and round action styles.
- `StickyPage`: use a controller-owned scrollable page with preceding source labels, a `UPSticky` primary button, long filler content, and a bottom `已到底部` divider. The sticky button shows source-style feedback on tap.
- `BackTopPage`: render long content with the source checkbox group for behavior controls, bind a `ScrollController`, and use `UPBackTop` to animate to offset zero. Dispose the controller.
- `LazyLoadPage`: use `assets/uview/swiper/swiper1.png`, `swiper2.png`, and `swiper3.png` in the source order. Initial data has three images; `UPLoadmore` appends the next three local entries until the fixed list is exhausted, then changes to the source no-more state.
- `TestListPage`: use `assets/uview/test/list-item.jpg` in a fixed 500px red `UPList` containing seven repeated `UPListItem`/`UPImage` entries to reproduce `test.vue`.

- [ ] **Step 4: Run scroll/gesture tests, page-title smoke tests, and analyzer**

Run: `flutter test test/components_a_pages_test.dart --name "swipe action|back top|lazy load" --reporter expanded`

Run: `flutter analyze`

Expected: PASS with no analyzer issues.

- [ ] **Step 5: Commit scroll and gesture pages**

```bash
git add example/lib/pages/components_a/swipe_action_page.dart example/lib/pages/components_a/sticky_page.dart example/lib/pages/components_a/back_top_page.dart example/lib/pages/components_a/lazy_load_page.dart example/lib/pages/components_a/test_list_page.dart example/lib/routes example/assets/uview example/pubspec.yaml example/test/components_a_pages_test.dart
git commit -m "feat(example): add component A scroll pages"
```

### Task 8: Complete Component A Catalog, Route Smoke Coverage, and Mobile Validation

**Files:**
- Create: `example/android/`
- Create: `example/ios/`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`
- Modify: `example/test/components_a_pages_test.dart`
- Modify: `example/README.md`
- Create: `docs/superpowers/plans/2026-07-27-uview-example-components-a-route-audit.md`

**Interfaces:**
- Consumes all Task 1-7 page builders.
- Produces a catalog with exactly 27 completed entries: 4 main-source routes and all 23 Component A routes.
- Produces `componentARouteIds`, a literal ordered list used by smoke tests and route audit.

- [ ] **Step 1: Write failing full Component A route smoke test**

```dart
const componentARouteIds = <String>[
  'componentsA/transition/transition',
  'componentsA/test/test',
  'componentsA/icon/icon',
  'componentsA/cell/cell',
  'componentsA/line/line',
  'componentsA/image/image',
  'componentsA/link/link',
  'componentsA/button/button',
  'componentsA/loading-icon/loading-icon',
  'componentsA/overlay/overlay',
  'componentsA/loading-page/loading-page',
  'componentsA/popup/popup',
  'componentsA/swipeAction/swipeAction',
  'componentsA/sticky/sticky',
  'componentsA/radio/radio',
  'componentsA/checkbox/checkbox',
  'componentsA/empty/empty',
  'componentsA/backtop/backtop',
  'componentsA/divider/divider',
  'componentsA/rate/rate',
  'componentsA/gap/gap',
  'componentsA/grid/grid',
  'componentsA/lazyLoad/lazyLoad',
];

testWidgets('every completed Component A source route renders a real page',
    (tester) async {
  for (final id in componentARouteIds) {
    await tester.pumpWidget(buildRouteUnderTest(id));
    final route = findExampleRoute(id);
    expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
    expect(find.text(route.title), findsOneWidget);
  }
});
```

- [ ] **Step 2: Run full Component A route smoke test to verify it fails for any missing catalog entry**

Run: `flutter test test/route_catalog_test.dart --plain-name "every completed Component A source route renders a real page" --reporter expanded`

Expected: FAIL until all 23 entries and marker keys are present.

- [ ] **Step 3: Make catalog order and preview state match the source**

Add the remaining Component A pages to `exampleRoutes` in the exact `pages.json` order. Set all 23 Component A preview records to `available: true`; preserve Components B-D and templates in source order with `available: false` previews. Ensure all four main source routes resolve with real page builders: component home, template home, mine, and platform-substitute ad page.

Write the route audit using a table with the 23 source paths, Flutter class names, local assets used, a representative interaction test name, and any Android/iOS source substitution. Record only actual substitutions: remote source illustration replaced by local bundled source asset, link opening replaced by in-app feedback, and WeChat rewarded ad replaced by an explanatory mobile page.

Update `example/README.md` with:

```markdown
flutter pub get
flutter run -d <android-or-ios-device>
flutter test
```

State that the current milestone covers source main routes and `componentsA`, while later source groups appear disabled in the index until migrated.

- [ ] **Step 4: Run full automated validation**

Run: `dart format lib test`

Run: `flutter analyze`

Run: `flutter test --reporter expanded`

The example currently contains Dart sources and package configuration only. Generate the Android/iOS Flutter host projects before the build commands, preserving the existing `lib/`, `assets/`, `test/`, `pubspec.yaml`, and `analysis_options.yaml` files:

```powershell
flutter create --platforms=android,ios .
```

After generation, re-check that the local `ultra_ui` path dependency and every `assets/uview/` declaration remain in `pubspec.yaml`. Do not create Web, Windows, macOS, or Linux platform directories.

Run: `flutter build apk --debug`

Run: `flutter build ios --simulator --no-codesign` on macOS only

Expected: all applicable commands pass. The iOS command is skipped and explicitly reported when the execution host is not macOS.

- [ ] **Step 5: Run Android/iOS manual acceptance and record results**

On Android and iOS, verify launch, safe areas, three bottom tabs, system back, every enabled Component A route, long-list scrolling, popup/overlay dismissal, keyboard-free interaction, and the matrix interactions from Tasks 3-7. Record device/OS, pass/fail, and platform substitutions in the route audit document.

- [ ] **Step 6: Commit the first installable milestone**

```bash
git add example/lib example/test example/assets example/pubspec.yaml example/README.md docs/superpowers/plans/2026-07-27-uview-example-components-a-route-audit.md
git commit -m "feat(example): migrate uview component pages A"
```

## Plan Self-Review

- Spec coverage: Task 1 implements the Android/iOS shell, main source routes, safe page chrome, source grouping, and disabled future previews. Task 2 enables asset-backed source parity in shared `UP*` components. Tasks 3-7 implement every registered Component A route. Task 8 verifies catalog completeness, local assets, automated smoke coverage, and Android/iOS acceptance.
- Route coverage: the source route matrix lists all 23 `pages/componentsA` registrations from `pages.json` in order; Task 8 uses the same literal list for runtime smoke coverage.
- No-placeholder review: Component A pages have dedicated class/file names and a concrete user-observable behavior. Only later batches appear disabled in indexes, as specified by the approved design.
- Type consistency: `ExampleRoute`, `ExamplePreviewRoute`, `ExamplePageScaffold`, `exampleRoutes`, `findExampleRoute`, and `componentARouteIds` are defined once and reused with identical names throughout the plan.
- Asset scope: only Component A source-visible assets are bundled; no runtime remote-image requirement or network plugin is introduced.
