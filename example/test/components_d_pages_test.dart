import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/components_d/qrcode_page.dart';
import 'example_test_helpers.dart';

void main() {
  testWidgets('qrcode page renders source variants offline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const QrcodePage(),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('example-page-componentsD/qrcode/qrcode')),
      findsOneWidget,
    );
    expect(find.text('不带logo'), findsOneWidget);
    expect(find.text('带logo'), findsOneWidget);
    expect(find.text('二维码颜色'), findsOneWidget);
    expect(find.byType(UPQrcode), findsNWidgets(3));
    expect(find.byKey(const ValueKey('qrcode-page-logo')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
