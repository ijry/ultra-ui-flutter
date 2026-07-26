import 'package:flutter/material.dart';

import '../pages/home/ad_page.dart';
import '../pages/home/components_home_page.dart';
import '../pages/home/mine_page.dart';
import '../pages/home/templates_home_page.dart';
import '../pages/components_a/cell_page.dart';
import '../pages/components_a/divider_page.dart';
import '../pages/components_a/gap_page.dart';
import '../pages/components_a/grid_page.dart';
import '../pages/components_a/icon_page.dart';
import '../pages/components_a/image_page.dart';
import '../pages/components_a/line_page.dart';
import '../pages/components_a/link_page.dart';
import '../pages/components_a/loading_icon_page.dart';
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
];

Widget _buildComponentsHome(BuildContext context) => const ComponentsHomePage();
Widget _buildTemplatesHome(BuildContext context) => const TemplatesHomePage();
Widget _buildMine(BuildContext context) => const MinePage();
Widget _buildAd(BuildContext context) => const AdPage();
Widget _buildIcon(BuildContext context) => const IconPage();
Widget _buildCell(BuildContext context) => const CellPage();
Widget _buildLine(BuildContext context) => const LinePage();
Widget _buildImage(BuildContext context) => const ImagePage();
Widget _buildLink(BuildContext context) => const LinkPage();
Widget _buildLoadingIcon(BuildContext context) => const LoadingIconPage();
Widget _buildDivider(BuildContext context) => const DividerPage();
Widget _buildGap(BuildContext context) => const GapPage();
Widget _buildGrid(BuildContext context) => const GridPage();

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
