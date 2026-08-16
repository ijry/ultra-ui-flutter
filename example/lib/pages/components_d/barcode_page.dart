import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key});

  Widget _centered(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '条码',
      child: Container(
        key: const ValueKey('example-page-componentsD/barcode/barcode'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: 'CODE128 条形码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-code128'),
                  value: '1234567890',
                  format: 'CODE128',
                  height: 70,
                  fontSize: 16,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'EAN-13 条形码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-ean13'),
                  value: '5901234123457',
                  format: 'EAN13',
                  height: 70,
                  fontSize: 16,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'EAN-8 条形码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-ean8'),
                  value: '96385074',
                  format: 'EAN8',
                  height: 70,
                  fontSize: 11,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'UPC-A 条形码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-upca'),
                  value: '123456789012',
                  format: 'UPCA',
                  height: 70,
                  fontSize: 16,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'CODE39 条形码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-code39'),
                  value: 'CODE39',
                  format: 'CODE39',
                  height: 70,
                  fontSize: 16,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'EAN-5 补充码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-ean5'),
                  value: '12345',
                  format: 'EAN5',
                  width: 100,
                  height: 60,
                  fontSize: 14,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'EAN-2 补充码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-ean2'),
                  value: '12',
                  format: 'EAN2',
                  width: 100,
                  height: 60,
                  fontSize: 14,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义样式条形码',
              child: _centered(
                const UPBarcode(
                  key: ValueKey('barcode-page-custom'),
                  value: 'CUSTOM123',
                  format: 'CODE128',
                  width: 200,
                  height: 70,
                  fontSize: 14,
                  lineColor: '#FF0000',
                  background: '#F0F0F0',
                  textPosition: 'top',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
