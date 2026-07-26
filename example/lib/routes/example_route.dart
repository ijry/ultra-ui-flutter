import 'package:flutter/widgets.dart';

enum ExampleRouteGroup {
  main,
  componentsA,
  componentsB,
  componentsC,
  componentsD,
  template,
}

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

  bool get available => true;
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

  String get id => sourcePath.replaceFirst(RegExp(r'^/?pages/'), '');
}
