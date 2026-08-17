import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';

/// 1:1 port of u-title.
class UPTitle extends StatelessWidget {
  const UPTitle({
    super.key,
    this.prefix,
    this.child,
    this.text = '',
    this.customStyle,
  });

  final Widget? prefix;
  final Widget? child;
  final String text;
  final BoxDecoration? customStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    Widget body = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.mainColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          prefix ??
              Container(
                width: 4,
                height: 18,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: tokens.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          child ??
              Text(
                text,
                style: TextStyle(
                  color: tokens.mainColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ],
      ),
    );
    return body;
  }
}
