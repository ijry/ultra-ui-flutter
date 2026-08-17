import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 port of u-box.
class UPBox extends StatelessWidget {
  const UPBox({
    super.key,
    this.bgColors = const ['#EEFCFF', '#FCF8FF', '#FDF8F2'],
    this.height = '160px',
    this.borderRadius = '6px',
    this.gap = '15px',
    this.leftIcon = '',
    this.leftTitle = '左',
    this.rightTopIcon = '',
    this.rightTopTitle = '右上',
    this.rightBottomIcon = '',
    this.rightBottomTitle = '右下',
    this.left,
    this.rightTop,
    this.rightBottom,
    this.onLeftClick,
    this.onRightTopClick,
    this.onRightBottomClick,
    this.customStyle,
  });

  final List bgColors;
  final dynamic height;
  final dynamic borderRadius;
  final dynamic gap;
  final String leftIcon;
  final String leftTitle;
  final String rightTopIcon;
  final String rightTopTitle;
  final String rightBottomIcon;
  final String rightBottomTitle;
  final Widget? left;
  final Widget? rightTop;
  final Widget? rightBottom;
  final VoidCallback? onLeftClick;
  final VoidCallback? onRightTopClick;
  final VoidCallback? onRightBottomClick;

  final BoxDecoration? customStyle;
  Color? _bg(int i) {
    if (i >= bgColors.length) return null;
    return UPUtils.parseColor(bgColors[i]);
  }

  Widget _cell({
    required Color? bg,
    required double radius,
    required Widget child,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }

  Widget _defaultContent(String icon, String title, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon.isNotEmpty) ...[
          UPIcon(name: icon, size: 36),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style:
                TextStyle(fontSize: fontSize, color: const Color(0xFF303133)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = UPUtils.getPx(height);
    final r = UPUtils.getPx(borderRadius);
    final g = UPUtils.getPx(gap);

    return Container(
      height: h,
      decoration: customStyle,
      child: Row(
        children: [
          Expanded(
            child: _cell(
              bg: _bg(0),
              radius: r,
              child: left ?? _defaultContent(leftIcon, leftTitle, 16),
            ),
          ),
          SizedBox(width: g),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _cell(
                    bg: _bg(1),
                    radius: r,
                    child: rightTop ??
                        _defaultContent(rightTopIcon, rightTopTitle, 15),
                  ),
                ),
                SizedBox(height: g),
                Expanded(
                  child: _cell(
                    bg: _bg(2),
                    radius: r,
                    child: rightBottom ??
                        _defaultContent(rightBottomIcon, rightBottomTitle, 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
