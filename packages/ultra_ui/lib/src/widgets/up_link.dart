import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_toast.dart';

/// Host-injectable open-url hook. Keep package Flutter-only.
typedef UPOpenLinkHandler = Future<void> Function(String href);

final Expando<Object> _upLinkLastToast = Expando<Object>('upLinkLastToast');

/// 1:1 port of u-link.
class UPLink extends StatelessWidget {
  const UPLink({
    super.key,
    this.color,
    this.fontSize = 15,
    this.underLine = false,
    this.href = '',
    this.mpTips = '链接已复制，请在浏览器打开',
    this.lineColor = '',
    this.text = '',
    this.customStyle,
    this.onClick,
  });

  /// Optional host handler for opening URLs (app / web).
  static UPOpenLinkHandler? openLinkHandler;

  final dynamic color;
  final dynamic fontSize;
  final bool underLine;
  final String href;
  final String mpTips;
  final dynamic lineColor;
  final String text;
  final TextStyle? customStyle;
  final VoidCallback? onClick;

  Future<void> _openLink(BuildContext context) async {
    if (href.isNotEmpty) {
      final handler = openLinkHandler;
      if (handler != null) {
        await handler(href);
      } else {
        // Fallback similar to mini-program: copy + toast.
        await Clipboard.setData(ClipboardData(text: href));
        if (!context.mounted) return;
        UPToast.show(context, message: mpTips);
      }
    }
    onClick?.call();
  }

  /// Source `openLink` public method.
  Future<void> openLink([BuildContext? context]) async {
    if (context != null) {
      await _openLink(context);
      return;
    }
    if (href.isNotEmpty) {
      final handler = openLinkHandler;
      if (handler != null) {
        await handler(href);
      } else {
        await Clipboard.setData(ClipboardData(text: href));
      }
    }
    onClick?.call();
  }

  /// Source `clickHandler` alias.
  Future<void> clickHandler([BuildContext? context]) => openLink(context);

  /// Source toast helper (Batch J).
  dynamic get lastToast => _upLinkLastToast[this];
  void toast([dynamic message]) {
    _upLinkLastToast[this] = message;
  }

  /// Source computed: linkStyle.
  dynamic get linkStyle {
    final fs = UPUtils.getPx(fontSize);
    return <String, dynamic>{
      'color': color ?? '#3c9cff',
      'fontSize': UPUtils.addUnit(fontSize),
      'lineHeight': UPUtils.addUnit(fs + 2),
      'textDecoration': underLine ? 'underline' : 'none',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final c =
        UPUtils.parseColor(color, fallback: tokens.primary) ?? tokens.primary;
    final fs = UPUtils.getPx(fontSize);

    final style = TextStyle(
      color: c,
      fontSize: fs,
      height: (fs + 2) / fs,
      decoration: underLine ? TextDecoration.underline : TextDecoration.none,
      decorationColor: c,
    ).merge(customStyle);

    return GestureDetector(
      onTap: () => _openLink(context),
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
