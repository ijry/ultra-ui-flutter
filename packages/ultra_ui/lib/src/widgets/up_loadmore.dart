import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_layout.dart';
import 'up_loading_icon.dart';

/// 1:1 port of u-loadmore defaults.
class UPLoadmore extends StatelessWidget {
  const UPLoadmore({
    super.key,
    this.status = 'loadmore',
    this.bgColor = 'transparent',
    this.icon = true,
    this.fontSize = 14,
    this.iconSize = 17,
    this.color = '#606266',
    this.loadingIcon = 'spinner',
    this.loadmoreText = '加载更多',
    this.loadingText = '正在加载...',
    this.nomoreText = '没有更多了',
    this.isDot = false,
    this.iconColor = '#b7b7b7',
    this.marginTop = 10,
    this.marginBottom = 10,
    this.height = 'auto',
    this.line = false,
    this.lineColor = '#E6E8EB',
    this.dashed = false,
    this.customStyle,
    this.onLoadmore,
  });

  final String status;
  final dynamic bgColor;
  final bool icon;
  final dynamic fontSize;
  final dynamic iconSize;
  final dynamic color;
  final String loadingIcon;
  final String loadmoreText;
  final String loadingText;
  final String nomoreText;
  final bool isDot;
  final dynamic iconColor;
  final dynamic marginTop;
  final dynamic marginBottom;
  final dynamic height;
  final bool line;
  final dynamic lineColor;
  final bool dashed;
  final BoxDecoration? customStyle;

  /// Source data.
  String get dotText => '●';

  final VoidCallback? onLoadmore;

  /// Source `loadMore` / `loadmore` method.
  void loadMore([dynamic _]) {
    if (status == 'loadmore') onLoadmore?.call();
  }

  /// Source alias.
  void loadmore([dynamic _]) => loadMore(_);

  /// Source computed: loadTextStyle.
  dynamic get loadTextStyle => <String, dynamic>{
        'color': color,
        'fontSize': UPUtils.addUnit(fontSize),
        'lineHeight': UPUtils.addUnit(fontSize),
        'backgroundColor': bgColor,
      };

  /// Source computed: showText.
  String get showText {
    if (status == 'loadmore') return loadmoreText;
    if (status == 'loading') return loadingText;
    if (status == 'nomore' && isDot) return dotText;
    return nomoreText;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final c = UPUtils.parseColor(color) ?? tokens.contentColor;
    final text = showText;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon && status == 'loading') ...[
          UPLoadingIcon(
            mode: loadingIcon,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: status == 'loadmore' ? onLoadmore : null,
          child: Text(
            text,
            style: TextStyle(
              color: c,
              fontSize: UPUtils.getPx(fontSize),
              height: 1,
            ),
          ),
        ),
      ],
    );

    if (line) {
      Widget side() => UPLine(
            color: lineColor,
            dashed: dashed,
            hairline: false,
            length: '140rpx',
          );
      // The two 140rpx lines plus the label can exceed a narrow viewport. CSS
      // lets that overflow silently; Flutter throws, so the lines yield space
      // instead of forcing the row wider than its parent.
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: side()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: content,
          ),
          Flexible(child: side()),
        ],
      );
    }

    final bg = UPUtils.parseColor(bgColor) ?? const Color(0x00000000);
    final decoration = (customStyle ?? const BoxDecoration()).copyWith(
      color: bg,
    );

    return Container(
      width: double.infinity,
      height: '$height' == 'auto' ? null : UPUtils.getPx(height),
      margin: EdgeInsets.only(
        top: UPUtils.getPx(marginTop),
        bottom: UPUtils.getPx(marginBottom),
      ),
      decoration: decoration,
      alignment: Alignment.center,
      child: content,
    );
  }
}
