import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_image.dart';

class UPAvatarGroup extends StatelessWidget {
  const UPAvatarGroup({
    super.key,
    this.urls = const [],
    this.maxCount = 5,
    this.shape = 'circle',
    this.mode = 'scaleToFill',
    this.showMore = true,
    this.size = 40,
    this.keyName = '',
    this.gap = 0.5,
    this.extraValue = 0,
    this.onShowMore,
    this.customStyle,
  });

  final List urls;
  final dynamic maxCount;
  final String shape;
  final String mode;
  final bool showMore;
  final dynamic size;
  final String keyName;
  final dynamic gap;
  final dynamic extraValue;
  final VoidCallback? onShowMore;
  final BoxDecoration? customStyle;

  String _srcOf(dynamic item) {
    if (item is Map) {
      if (keyName.isNotEmpty && item[keyName] != null)
        return '${item[keyName]}';
      return '${item['url'] ?? ''}';
    }
    return '$item';
  }

  /// Source `clickHandler` — more badge / overflow click.
  void clickHandler([dynamic _]) => onShowMore?.call();

  /// Source computed: showUrl.
  dynamic get showUrl {
    final max = (num.tryParse('$maxCount') ?? 5).toInt();
    return urls.take(max < 0 ? 0 : max).toList();
  }

  /// Source host helper: testObject.
  dynamic testObject([dynamic v]) => null;

  @override
  Widget build(BuildContext context) {
    final s = UPUtils.getPx(size);
    final max = (num.tryParse('$maxCount') ?? 5).toInt();
    final g = (num.tryParse('$gap') ?? 0.5).toDouble().clamp(0.0, 1.0);
    final show = urls.take(max).toList();
    final extra = num.tryParse('$extraValue') ?? 0;
    final moreCount = extra > 0 ? extra : (urls.length - show.length);

    Widget root = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < show.length; i++)
          Transform.translate(
            offset: Offset(i == 0 ? 0 : -s * g, 0),
            child: Stack(
              children: [
                UPImage(
                  src: _srcOf(show[i]),
                  width: s,
                  height: s,
                  shape: shape == 'circle' ? 'circle' : 'square',
                  radius: shape == 'square' ? 4 : 0,
                  mode: mode == 'scaleToFill' ? 'scaleToFill' : 'aspectFill',
                  showLoading: false,
                ),
                if (showMore &&
                    i == show.length - 1 &&
                    (urls.length > max || extra > 0))
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: onShowMore,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x4D000000),
                          borderRadius: BorderRadius.circular(
                            shape == 'square' ? 4 : 1000,
                          ),
                        ),
                        child: Text(
                          '+$moreCount',
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: s * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
    return root;
  }
}
