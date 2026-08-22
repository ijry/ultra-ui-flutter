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
        final iconAsset = preview.iconAsset;
        return UPCell(
          title: preview.title,
          value: isAvailable ? '' : '后续迁移',
          disabled: !isAvailable,
          isLink: isAvailable,
          clickable: isAvailable,
          // Source renders the icon through the cell's icon slot at
          // 36rpx (18px) with an 8rpx (4px) trailing gap.
          iconSlot: iconAsset == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Image.asset(
                    iconAsset,
                    width: 18,
                    height: 18,
                    // A missing or unreadable asset should not blank the row.
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 18, height: 18),
                  ),
                ),
          onClick: isAvailable
              ? () => pushExampleRoute(context, findExampleRoute(preview.id))
              : null,
        );
      }).toList(),
    );
  }
}
