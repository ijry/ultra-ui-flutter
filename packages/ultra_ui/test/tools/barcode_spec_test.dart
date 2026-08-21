// Verifies UPBarcode's encoders against independently-derived values rather
// than a re-reading of the same code.
//
// The `barcode` package cannot serve as an oracle here: it pins `qr ^3` while
// this package depends on `qr ^4`. So these assertions come from the published
// symbologies — documented width patterns, checksum algorithms, and module
// counts that any conforming encoder must reproduce.
//
// UPBarcode emits a 10-module quiet zone on each side (per the standards'
// minimum), which every expectation below accounts for.
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

/// Quiet-zone width UPBarcode adds to each side.
const int kQuiet = 10;

/// Expands a CODE128-style width string ("212222") into modules, bars first.
List<int> _expand(String widths) {
  final out = <int>[];
  var bar = true;
  for (final ch in widths.split('')) {
    out.addAll(List<int>.filled(int.parse(ch), bar ? 1 : 0));
    bar = !bar;
  }
  return out;
}

/// CODE128 weighted checksum straight from the spec: start value plus each
/// later symbol times its 1-based position, modulo 103.
int _code128Checksum(List<int> values) {
  var sum = values.first;
  for (var i = 1; i < values.length; i++) {
    sum += values[i] * i;
  }
  return sum % 103;
}

/// EAN-13 check digit: weights 1 and 3 alternating over the first 12 digits,
/// then the difference up to the next multiple of ten.
int _ean13CheckDigit(String twelve) {
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    final n = int.parse(twelve[i]);
    sum += i.isEven ? n : n * 3;
  }
  return (10 - (sum % 10)) % 10;
}

void main() {
  const barcode = UPBarcode(value: '');

  group('CODE128', () {
    test('module count matches the standard symbol structure', () {
      // start(11) + 11 per data char + checksum(11) + stop(13), plus quiet
      // zones. The stop pattern is 13 modules, not 11.
      for (final text in <String>['A', 'AB', 'HELLO', 'Code128']) {
        final modules = barcode.encodeCode128(text);
        final expected = kQuiet + 11 + text.length * 11 + 11 + 13 + kQuiet;
        expect(modules.length, expected, reason: 'CODE128("$text")');
      }
    });

    test('output is binary and carries the standard start and stop patterns',
        () {
      final modules = barcode.encodeCode128('HELLO');
      expect(modules.every((m) => m == 0 || m == 1), isTrue);
      // Start Code B is table entry 104, widths 211214.
      expect(modules.sublist(kQuiet, kQuiet + 11), _expand('211214'));
      // Stop is entry 106, widths 2331112 (13 modules).
      expect(
        modules.sublist(modules.length - kQuiet - 13, modules.length - kQuiet),
        _expand('2331112'),
      );
      // Quiet zones are blank.
      expect(modules.take(kQuiet).every((m) => m == 0), isTrue);
      expect(
          modules.skip(modules.length - kQuiet).every((m) => m == 0), isTrue);
    });

    test('the checksum symbol matches the specification', () {
      // 'AB' in Code Set B: start B (104), 'A' (33), 'B' (34).
      // 104 + 33*1 + 34*2 = 205; 205 % 103 = 102.
      const values = <int>[104, 33, 34];
      expect(_code128Checksum(values), 102);

      // Entry 102 is widths 411131; it must sit just before the stop pattern.
      final modules = barcode.encodeCode128('AB');
      final checksumEnd = modules.length - kQuiet - 13;
      expect(modules.sublist(checksumEnd - 11, checksumEnd), _expand('411131'));
    });
  });

  group('EAN-13', () {
    test('module count matches the standard 95-module symbol', () {
      final modules = barcode.encodeEAN13('590123412345');
      expect(modules.length, kQuiet + 95 + kQuiet,
          reason: 'EAN-13 is 95 modules: 3 guard + 42 left + 5 centre '
              '+ 42 right + 3 guard');
    });

    test('guard patterns sit at their standard offsets', () {
      final modules = barcode.encodeEAN13('590123412345');
      final body = modules.sublist(kQuiet, modules.length - kQuiet);
      expect(body.take(3).toList(), <int>[1, 0, 1]); // start guard
      expect(body.sublist(45, 50), <int>[0, 1, 0, 1, 0]); // centre guard
      expect(body.sublist(92), <int>[1, 0, 1]); // end guard
    });

    test('a supplied check digit yields the same symbol as an omitted one', () {
      // 5901234123457 is a documented valid EAN-13 (check digit 7).
      expect(_ean13CheckDigit('590123412345'), 7);
      expect(
        barcode.encodeEAN13('5901234123457'),
        barcode.encodeEAN13('590123412345'),
        reason: 'a 12-digit body must not be left-padded to 13, which would '
            'shift every digit and drop the last one',
      );
    });

    test('an incorrect supplied check digit is corrected', () {
      // ...9 is wrong; the encoder must recompute it as 7.
      expect(
        barcode.encodeEAN13('5901234123459'),
        barcode.encodeEAN13('5901234123457'),
      );
    });
  });

  group('EAN-8 and UPC-A', () {
    test('EAN-8 is a 67-module symbol and respects its body length', () {
      // 3 guard + 28 left + 5 centre + 28 right + 3 guard = 67.
      final modules = barcode.encodeEAN8('9638507');
      expect(modules.length, kQuiet + 67 + kQuiet);
      // 96385074 is a documented valid EAN-8 (check digit 4).
      expect(barcode.encodeEAN8('96385074'), modules,
          reason: 'a 7-digit body must not be left-padded to 8');
    });

    test('UPC-A matches the equivalent EAN-13 with a leading zero', () {
      // 036000291452 is a documented valid UPC-A (check digit 2).
      expect(
        barcode.encodeUPCA('03600029145'),
        barcode.encodeUPCA('036000291452'),
        reason: 'an 11-digit body must not be left-padded to 12',
      );
      expect(
        barcode.encodeUPCA('036000291452'),
        barcode.encodeEAN13('0036000291452'),
        reason: 'UPC-A is EAN-13 with a leading zero',
      );
    });
  });

  group('CODE39', () {
    test('data is bracketed by the standard start/stop character', () {
      final modules = barcode.encodeCode39('ABC');
      expect(modules.every((m) => m == 0 || m == 1), isTrue);
      // '*' is the CODE39 delimiter, widths 121121211 in this table's encoding.
      final body = modules.sublist(kQuiet, modules.length - kQuiet);
      final delimiter = _expand('121121211');
      expect(body.take(delimiter.length).toList(), delimiter,
          reason: 'CODE39 must open with the * delimiter');
      expect(body.sublist(body.length - delimiter.length), delimiter,
          reason: 'CODE39 must close with the * delimiter');
    });
  });
}
