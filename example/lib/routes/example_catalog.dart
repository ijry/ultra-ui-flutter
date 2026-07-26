import 'package:flutter/material.dart';

import '../pages/home/ad_page.dart';
import '../pages/home/components_home_page.dart';
import '../pages/home/mine_page.dart';
import '../pages/home/templates_home_page.dart';
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
];

Widget _buildComponentsHome(BuildContext context) => const ComponentsHomePage();
Widget _buildTemplatesHome(BuildContext context) => const TemplatesHomePage();
Widget _buildMine(BuildContext context) => const MinePage();
Widget _buildAd(BuildContext context) => const AdPage();

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
