import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

class ExampleDemoBlock extends StatelessWidget {
  const ExampleDemoBlock({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: TextStyle(color: tokens.contentColor)),
          ),
          // SizedBox.expand-width: without this the card shrink-wraps its
          // child, so a demo holding narrow content (an icon, a switch, a short
          // link) rendered a card only as wide as that content instead of a
          // full-width panel.
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(color: tokens.cardBgColor),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
