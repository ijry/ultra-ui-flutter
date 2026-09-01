import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_media/ultra_ui_media.dart';

void main() {
  group('resolvePdfTarget', () {
    test('unwraps the file parameter from a pdf.js viewer URL', () {
      // This is exactly what UPPdfReader hands to viewerBuilder.
      expect(
        resolvePdfTarget(
          'https://mozilla.github.io/pdf.js/web/viewer.html'
          '?file=https%3A%2F%2Fexample.com%2Fdoc.pdf',
        ),
        'https://example.com/doc.pdf',
      );
    });

    test('keeps a bare document URL unchanged', () {
      expect(
        resolvePdfTarget('https://example.com/doc.pdf'),
        'https://example.com/doc.pdf',
      );
    });

    test('keeps an asset path unchanged', () {
      expect(resolvePdfTarget('assets/docs/manual.pdf'),
          'assets/docs/manual.pdf');
    });

    test('preserves an encoded local file URI', () {
      expect(
        resolvePdfTarget(
          'https://host/viewer.html?file=file%3A%2F%2F%2Ftmp%2Fa%20b.pdf',
        ),
        'file:///tmp/a b.pdf',
      );
    });

    test('empty input stays empty', () {
      expect(resolvePdfTarget(''), '');
    });

    test('a viewer URL without a file parameter falls back to itself', () {
      expect(
        resolvePdfTarget('https://host/viewer.html'),
        'https://host/viewer.html',
      );
    });
  });
}
