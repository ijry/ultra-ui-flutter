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
    this.icon = '',
  });

  final String sourcePath;
  final String title;
  final ExampleRouteGroup group;
  final bool available;

  /// Demo-list icon name, as in the source's components.config.js. The source
  /// resolves it as `/static/uview/demo/<icon>.png`; the same PNGs are vendored
  /// under assets/uview/demo/icons/.
  final String icon;

  /// Asset path for [icon], or null when the entry has none.
  String? get iconAsset =>
      icon.isEmpty ? null : 'assets/uview/demo/icons/$icon.png';

  String get id => sourcePath.replaceFirst(RegExp(r'^/?pages/'), '');
}
