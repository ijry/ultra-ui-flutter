import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class QrcodePage extends StatelessWidget {
  const QrcodePage({super.key});

  static const String _sourceValue =
      'https://click.meituan.com/t?t=1&c=2&p=WhaD2b5zGU-h';

  Widget _centered(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '二维码',
      child: Container(
        key: const ValueKey('example-page-componentsD/qrcode/qrcode'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '不带logo',
              child: _centered(
                const UPQrcode(
                  key: ValueKey('qrcode-page-basic'),
                  cid: 'up1',
                  size: 150,
                  val: _sourceValue,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '带logo',
              child: _centered(
                Stack(
                  key: const ValueKey('qrcode-page-logo'),
                  alignment: Alignment.center,
                  children: const [
                    UPQrcode(cid: 'up2', size: 150, val: _sourceValue),
                    DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Image(
                          image: AssetImage('assets/uview/common/logo.png'),
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '二维码颜色',
              child: _centered(
                const UPQrcode(
                  key: ValueKey('qrcode-page-colors'),
                  cid: 'up3',
                  size: 150,
                  val: _sourceValue,
                  background: 'red',
                  foreground: 'blue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
