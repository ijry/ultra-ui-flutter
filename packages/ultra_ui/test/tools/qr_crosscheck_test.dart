// Cross-checks UPQrcode's hand-rolled encoder against the `qr` package, a port
// of the reference kazuhikoarase implementation.
//
// up_qrcode.dart comments its capacity calculation as "Approximate", which
// raises the question of whether it can emit undecodable symbols. A QR code
// only scans if its module matrix is correct, so this compares matrices
// bit-for-bit: any size or module disagreement is a real, user-visible defect.
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart' as qr;
import 'package:ultra_ui/ultra_ui.dart';

/// Maps UPQrcode's `lv` (1..4) onto the `qr` package's level enum.
///
/// UPQrcode._ecLevel returns the QR standard's own indices (M=0, L=1, H=2,
/// Q=3), which is also how that enum is ordered.
qr.QrErrorCorrectLevel _levelFor(int lv) => switch (lv.clamp(1, 4)) {
      1 => qr.QrErrorCorrectLevel.low,
      2 => qr.QrErrorCorrectLevel.medium,
      4 => qr.QrErrorCorrectLevel.high,
      _ => qr.QrErrorCorrectLevel.quartile,
    };

void main() {
  // Byte-mode payloads of growing length, to walk up through QR versions.
  final samples = <String>[
    'a',
    'hello',
    'https://example.com',
    'https://example.com/some/longer/path?query=value&x=1',
    'A' * 40,
    'A' * 80,
    'A' * 120,
    'A' * 200,
    '1234567890' * 10,
    // Beyond version 10, where the previous hand-rolled encoder silently
    // clamped and produced an unscannable symbol.
    'A' * 400,
    'https://example.com/a?v=' + '9' * 600,
  ];

  test('UPQrcode matrices match the reference qr implementation', () {
    final failures = <String>[];
    var checked = 0;

    for (final lv in <int>[1, 2, 3, 4]) {
      for (final text in samples) {
        final label = 'lv=$lv len=${text.length}';
        final ours = UPQrcode.encodeMatrix(text, lv);
        final reference = qr.QrImage(
          qr.QrCode(
            payload: qr.QrPayload.fromString(text),
            errorCorrectLevel: _levelFor(lv),
          ),
        );
        checked++;

        if (ours.length != reference.moduleCount) {
          failures.add(
            '$label: size ${ours.length} vs reference ${reference.moduleCount}',
          );
          continue;
        }

        var differing = 0;
        for (var y = 0; y < ours.length; y++) {
          for (var x = 0; x < ours.length; x++) {
            if ((ours[y][x] == 1) != reference.isDark(y, x)) differing++;
          }
        }
        if (differing != 0) {
          failures.add(
            '$label: $differing/${ours.length * ours.length} modules differ',
          );
        }
      }
    }

    expect(checked, samples.length * 4);
    expect(
      failures,
      isEmpty,
      reason: 'A QR matrix must match the reference bit-for-bit or the code '
          'will not scan. Divergences:\n${failures.join('\n')}',
    );
  });
}
