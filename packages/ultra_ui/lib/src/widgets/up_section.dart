import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

class UPSection extends StatelessWidget {
  const UPSection({
    super.key,
    this.title = '',
    this.subTitle = '更多',
    this.right = true,
    this.fontSize = 15,
    this.bold = true,
    this.color = '#303133',
    this.subColor = '#909399',
    this.showLine = true,
    this.lineColor = '',
    this.arrow = true,
    this.customStyle,
    this.onClick,
  });

  final String title;
  final String subTitle;
  final bool right;
  final dynamic fontSize;
  final bool bold;
  final dynamic color;
  final dynamic subColor;
  final bool showLine;
  final dynamic lineColor;
  final bool arrow;
  final BoxDecoration? customStyle;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final fs = UPUtils.getPx(fontSize);
    final titleColor = UPUtils.parseColor(color, fallback: tokens.mainColor) ??
        tokens.mainColor;
    final sub = UPUtils.parseColor(subColor, fallback: tokens.tipsColor) ??
        tokens.tipsColor;
    final line = UPUtils.parseColor(lineColor, fallback: tokens.primary) ??
        tokens.primary;

    Widget body = GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (showLine)
              Container(
                width: 3,
                height: fs + 4,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: fs,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (right) ...[
              Text(subTitle, style: TextStyle(color: sub, fontSize: 13)),
              if (arrow) ...[
                const SizedBox(width: 2),
                UPIcon(name: 'arrow-right', size: 13, color: sub),
              ],
            ],
          ],
        ),
      ),
    );

    return body;
  }
}
