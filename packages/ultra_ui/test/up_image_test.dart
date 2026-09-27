// UPImage contract test.
//
// Same treatment as up_flex_test.dart: assert the widget's constructor defaults
// equal the shared cross-platform contract's canonical default values, plus a
// basic pump/render.
//
// The single source of truth for these values is
// contracts/up-image.contract.json at the ultra-ui repo root (the sibling of
// ultra-ui-flutter). Flutter has NO per-platform default override, so it uses
// the canonical defaults verbatim. The `contract` map below is transcribed from
// that file's props[*].default; keep it in sync if the contract changes.
//
// The Flutter-only extras (loadingWidget / errorWidget / backgroundStyle) are
// not part of the shared contract and are intentionally not asserted here.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  // Canonical defaults from contracts/up-image.contract.json (props[*].default).
  const contract = <String, Object?>{
    'src': '',
    'mode': 'aspectFill',
    'width': '300',
    'height': '225',
    'shape': 'square',
    'radius': 0,
    'lazyLoad': true,
    'showMenuByLongpress': true,
    'loadingIcon': 'photo',
    'errorIcon': 'error-circle',
    'showLoading': true,
    'showError': true,
    'fade': true,
    'webp': false,
    'duration': 500,
    'bgColor': '#f3f4f6',
  };

  test('constructor defaults equal the shared up-image contract', () {
    const img = UPImage();
    expect(img.src, contract['src'], reason: 'src default');
    expect(img.mode, contract['mode'], reason: 'mode default');
    expect(img.width, contract['width'], reason: 'width default');
    expect(img.height, contract['height'], reason: 'height default');
    expect(img.shape, contract['shape'], reason: 'shape default');
    expect(img.radius, contract['radius'], reason: 'radius default');
    expect(img.lazyLoad, contract['lazyLoad'], reason: 'lazyLoad default');
    expect(img.showMenuByLongpress, contract['showMenuByLongpress'],
        reason: 'showMenuByLongpress default');
    expect(img.loadingIcon, contract['loadingIcon'],
        reason: 'loadingIcon default');
    expect(img.errorIcon, contract['errorIcon'], reason: 'errorIcon default');
    expect(img.showLoading, contract['showLoading'],
        reason: 'showLoading default');
    expect(img.showError, contract['showError'], reason: 'showError default');
    expect(img.fade, contract['fade'], reason: 'fade default');
    expect(img.webp, contract['webp'], reason: 'webp default');
    expect(img.duration, contract['duration'], reason: 'duration default');
    expect(img.bgColor, contract['bgColor'], reason: 'bgColor default');
  });

  testWidgets('defaults: empty src renders a placeholder, not an Image',
      (tester) async {
    await pump(tester, const UPImage());
    expect(find.byType(UPImage), findsOneWidget);
    // With the default empty src the widget paints its bgColor placeholder
    // rather than loading a network/asset Image.
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a provided src builds an Image', (tester) async {
    await pump(tester, const UPImage(src: 'assets/logo.png'));
    expect(find.byType(UPImage), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
