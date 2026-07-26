import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class AdPage extends StatelessWidget {
  const AdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '广告',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 100, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            UPButton(
              text: '打开广告',
              type: 'primary',
              onClick: () => UP.toast(
                context,
                message: '激励广告仅适用于微信小程序，Flutter 示例不提供广告播放',
              ),
            ),
            const SizedBox(height: 20),
            const Text('激励广告仅适用于微信小程序，Flutter 示例不提供广告播放'),
          ],
        ),
      ),
    );
  }
}
