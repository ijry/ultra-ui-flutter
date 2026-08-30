import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  test('makeCode leaves source-empty sentinel values ungenerated', () {
    for (final value in <String>['', 'undefined', 'null', '{}', '[]']) {
      final qr = UPQrcode(val: value);

      expect(qr.makeCode(), isEmpty, reason: 'value: $value');
      expect(qr.resultData, isEmpty, reason: 'value: $value');
    }
  });

  testWidgets('content tap emits preview even when native preview is disabled',
      (tester) async {
    dynamic payload;
    final qr = UPQrcode(
      val: 'tap-content',
      onPreview: (value) => payload = value,
    );
    qr.makeCode();

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: qr))),
    );
    await tester.tap(find.byType(UPQrcode));

    expect(payload, <String, dynamic>{'url': 'tap-content'});
  });

  testWidgets('content long press emits only the exported path callback',
      (tester) async {
    dynamic previewPayload;
    dynamic longpressPayload;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: UPQrcode(
              val: 'long-content',
              onPreview: (value) => previewPayload = value,
              onLongpressCallback: (value) => longpressPayload = value,
            ),
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(UPQrcode));
    await tester.pump();

    expect(longpressPayload, '');
    expect(previewPayload, isNull);
  });

  testWidgets('source-inactive show prop does not hide the rendered code',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UPQrcode(val: 'still-visible', size: 80, show: false),
        ),
      ),
    );

    expect(tester.getSize(find.byType(UPQrcode)), const Size(80, 80));
  });
}
