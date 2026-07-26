import 'package:flutter/material.dart';

import '../pages/home/ad_page.dart';
import '../pages/home/components_home_page.dart';
import '../pages/home/mine_page.dart';
import '../pages/home/templates_home_page.dart';
import '../pages/components_a/cell_page.dart';
import '../pages/components_a/checkbox_page.dart';
import '../pages/components_a/divider_page.dart';
import '../pages/components_a/empty_page.dart';
import '../pages/components_a/gap_page.dart';
import '../pages/components_a/grid_page.dart';
import '../pages/components_a/icon_page.dart';
import '../pages/components_a/image_page.dart';
import '../pages/components_a/line_page.dart';
import '../pages/components_a/link_page.dart';
import '../pages/components_a/loading_icon_page.dart';
import '../pages/components_a/loading_page_page.dart';
import '../pages/components_a/overlay_page.dart';
import '../pages/components_a/popup_page.dart';
import '../pages/components_a/radio_page.dart';
import '../pages/components_a/rate_page.dart';
import '../pages/components_a/button_page.dart';
import '../pages/components_a/transition_page.dart';
import 'example_route.dart';

final List<ExampleRoute> exampleRoutes = <ExampleRoute>[
  const ExampleRoute(
    id: 'example/components',
    sourcePath: 'pages/example/components',
    title: 'uview-plus',
    group: ExampleRouteGroup.main,
    builder: _buildComponentsHome,
  ),
  const ExampleRoute(
    id: 'example/template',
    sourcePath: 'pages/example/template',
    title: '模板',
    group: ExampleRouteGroup.main,
    builder: _buildTemplatesHome,
  ),
  const ExampleRoute(
    id: 'example/mine',
    sourcePath: 'pages/example/mine',
    title: '我的',
    group: ExampleRouteGroup.main,
    builder: _buildMine,
  ),
  const ExampleRoute(
    id: 'example/ad',
    sourcePath: 'pages/example/ad',
    title: '广告',
    group: ExampleRouteGroup.main,
    builder: _buildAd,
  ),
  const ExampleRoute(
    id: 'componentsA/icon/icon',
    sourcePath: 'pages/componentsA/icon/icon',
    title: '图标',
    group: ExampleRouteGroup.componentsA,
    builder: _buildIcon,
  ),
  const ExampleRoute(
    id: 'componentsA/cell/cell',
    sourcePath: 'pages/componentsA/cell/cell',
    title: '单元格',
    group: ExampleRouteGroup.componentsA,
    builder: _buildCell,
  ),
  const ExampleRoute(
    id: 'componentsA/line/line',
    sourcePath: 'pages/componentsA/line/line',
    title: '线条',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLine,
  ),
  const ExampleRoute(
    id: 'componentsA/image/image',
    sourcePath: 'pages/componentsA/image/image',
    title: '图片',
    group: ExampleRouteGroup.componentsA,
    builder: _buildImage,
  ),
  const ExampleRoute(
    id: 'componentsA/button/button',
    sourcePath: 'pages/componentsA/button/button',
    title: '按钮',
    group: ExampleRouteGroup.componentsA,
    builder: _buildButton,
  ),
  const ExampleRoute(
    id: 'componentsA/link/link',
    sourcePath: 'pages/componentsA/link/link',
    title: '超链接',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLink,
  ),
  const ExampleRoute(
    id: 'componentsA/loading-icon/loading-icon',
    sourcePath: 'pages/componentsA/loading-icon/loading-icon',
    title: '加载中图标',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLoadingIcon,
  ),
  const ExampleRoute(
    id: 'componentsA/divider/divider',
    sourcePath: 'pages/componentsA/divider/divider',
    title: '分割线',
    group: ExampleRouteGroup.componentsA,
    builder: _buildDivider,
  ),
  const ExampleRoute(
    id: 'componentsA/empty/empty',
    sourcePath: 'pages/componentsA/empty/empty',
    title: '内容为空',
    group: ExampleRouteGroup.componentsA,
    builder: _buildEmpty,
  ),
  const ExampleRoute(
    id: 'componentsA/gap/gap',
    sourcePath: 'pages/componentsA/gap/gap',
    title: '间隔槽',
    group: ExampleRouteGroup.componentsA,
    builder: _buildGap,
  ),
  const ExampleRoute(
    id: 'componentsA/grid/grid',
    sourcePath: 'pages/componentsA/grid/grid',
    title: '宫格',
    group: ExampleRouteGroup.componentsA,
    builder: _buildGrid,
  ),
  const ExampleRoute(
    id: 'componentsA/radio/radio',
    sourcePath: 'pages/componentsA/radio/radio',
    title: '单选框',
    group: ExampleRouteGroup.componentsA,
    builder: _buildRadio,
  ),
  const ExampleRoute(
    id: 'componentsA/checkbox/checkbox',
    sourcePath: 'pages/componentsA/checkbox/checkbox',
    title: '复选框',
    group: ExampleRouteGroup.componentsA,
    builder: _buildCheckbox,
  ),
  const ExampleRoute(
    id: 'componentsA/rate/rate',
    sourcePath: 'pages/componentsA/rate/rate',
    title: '评分',
    group: ExampleRouteGroup.componentsA,
    builder: _buildRate,
  ),
  const ExampleRoute(
    id: 'componentsA/transition/transition',
    sourcePath: 'pages/componentsA/transition/transition',
    title: '动画',
    group: ExampleRouteGroup.componentsA,
    builder: _buildTransition,
  ),
  const ExampleRoute(
    id: 'componentsA/overlay/overlay',
    sourcePath: 'pages/componentsA/overlay/overlay',
    title: '遮罩层',
    group: ExampleRouteGroup.componentsA,
    builder: _buildOverlay,
  ),
  const ExampleRoute(
    id: 'componentsA/loading-page/loading-page',
    sourcePath: 'pages/componentsA/loading-page/loading-page',
    title: '加载页',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLoadingPage,
  ),
  const ExampleRoute(
    id: 'componentsA/popup/popup',
    sourcePath: 'pages/componentsA/popup/popup',
    title: '弹窗',
    group: ExampleRouteGroup.componentsA,
    builder: _buildPopup,
  ),
];

Widget _buildComponentsHome(BuildContext context) => const ComponentsHomePage();
Widget _buildTemplatesHome(BuildContext context) => const TemplatesHomePage();
Widget _buildMine(BuildContext context) => const MinePage();
Widget _buildAd(BuildContext context) => const AdPage();
Widget _buildIcon(BuildContext context) => const IconPage();
Widget _buildCell(BuildContext context) => const CellPage();
Widget _buildLine(BuildContext context) => const LinePage();
Widget _buildImage(BuildContext context) => const ImagePage();
Widget _buildButton(BuildContext context) => const ButtonPage();
Widget _buildLink(BuildContext context) => const LinkPage();
Widget _buildLoadingIcon(BuildContext context) => const LoadingIconPage();
Widget _buildDivider(BuildContext context) => const DividerPage();
Widget _buildEmpty(BuildContext context) => const EmptyPage();
Widget _buildGap(BuildContext context) => const GapPage();
Widget _buildGrid(BuildContext context) => const GridPage();
Widget _buildRadio(BuildContext context) => const RadioPage();
Widget _buildCheckbox(BuildContext context) => const CheckboxPage();
Widget _buildRate(BuildContext context) => const RatePage();
Widget _buildTransition(BuildContext context) => const TransitionPage();
Widget _buildOverlay(BuildContext context) => const OverlayPage();
Widget _buildLoadingPage(BuildContext context) => const LoadingPagePage();
Widget _buildPopup(BuildContext context) => const PopupPage();

ExampleRoute findExampleRoute(String id) {
  return exampleRoutes.firstWhere(
    (route) => route.id == id,
    orElse: () =>
        throw StateError('No completed example route registered for $id'),
  );
}

Future<void> pushExampleRoute(BuildContext context, ExampleRoute route) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: route.sourcePath),
      builder: route.builder,
    ),
  );
}
