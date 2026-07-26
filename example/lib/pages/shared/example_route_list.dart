import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../../routes/example_route.dart';

class ExampleRouteList extends StatelessWidget {
  const ExampleRouteList({super.key, required this.routes});

  final List<ExamplePreviewRoute> routes;

  @override
  Widget build(BuildContext context) {
    return UPCellGroup(
      children: routes.map((preview) {
        final isAvailable = preview.available;
        return UPCell(
          title: preview.title,
          value: isAvailable ? '' : '后续迁移',
          disabled: !isAvailable,
          isLink: isAvailable,
          clickable: isAvailable,
          onClick: isAvailable
              ? () => pushExampleRoute(context, findExampleRoute(preview.id))
              : null,
        );
      }).toList(),
    );
  }
}
