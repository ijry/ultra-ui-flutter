// UPNavbar ios-mode tests.
//
// The source's ios mode compresses a large title into the bar as the page
// scrolls, driven by three thresholds that are easy to get subtly wrong:
// progress is measured against the 52px large-title height, the frosted glass
// completes over the first half, and the centred title only appears in the
// final quarter.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

Widget _host(Widget child) => MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(body: child),
    );

void main() {
  group('default mode is unaffected', () {
    test('progress and opacities are inert', () {
      const navbar = UPNavbar(title: 'T');
      expect(navbar.isIosMode, isFalse);
      expect(navbar.navbarProgress, 1);
      expect(navbar.navbarGlassOpacity, 0);
      // The centre title is always fully visible outside ios mode.
      expect(navbar.navbarCenterOpacity, 1);
    });
  });

  group('ios mode progress', () {
    test('is measured against the 52px large-title height', () {
      expect(UPNavbar.kLargeTitleHeight, 52);
      for (final probe in <List<num>>[
        <num>[0, 0],
        <num>[13, 0.25],
        <num>[26, 0.5],
        <num>[52, 1],
        <num>[999, 1], // clamps
        <num>[-10, 0], // clamps
      ]) {
        final navbar = UPNavbar(mode: 'ios', title: 'T', scrollTop: probe[0]);
        expect(navbar.navbarProgress, closeTo(probe[1], 1e-9),
            reason: 'scrollTop=${probe[0]}');
      }
    });

    test('an empty title collapses the large-title row and pins progress', () {
      const navbar = UPNavbar(mode: 'ios', title: '', scrollTop: 10);
      expect(navbar.largeTitleHeight, 0);
      // With no large title there is nothing to compress, so progress is done.
      expect(navbar.navbarProgress, 1);
    });
  });

  group('ios mode opacity thresholds', () {
    test('the glass completes over the first half of the scroll', () {
      double glass(num top) =>
          UPNavbar(mode: 'ios', title: 'T', scrollTop: top).navbarGlassOpacity;
      expect(glass(0), 0);
      expect(glass(13), closeTo(0.5, 1e-9)); // progress 0.25 -> 0.5
      expect(glass(26), 1); // progress 0.5 -> fully opaque
      expect(glass(52), 1); // stays opaque
    });

    test('the centre title only appears in the final quarter', () {
      double centre(num top) =>
          UPNavbar(mode: 'ios', title: 'T', scrollTop: top).navbarCenterOpacity;
      expect(centre(0), 0);
      expect(centre(26), 0); // progress 0.5, still hidden
      expect(centre(39), 0); // progress 0.75, just about to start
      expect(centre(45.5), closeTo(0.5, 1e-9)); // progress 0.875
      expect(centre(52), 1);
    });

    test('the glass is fully opaque before the centre title starts', () {
      // This ordering is the point of the two thresholds: the centred title
      // must never bleed through onto the large title behind it.
      final navbar = UPNavbar(mode: 'ios', title: 'T', scrollTop: 39);
      expect(navbar.navbarGlassOpacity, 1);
      expect(navbar.navbarCenterOpacity, 0);
    });
  });

  group('ios mode centre-title rise', () {
    test('the rise finishes exactly as the fade completes', () {
      expect(UPNavbar.kCenterTitleRise, 12);
      double rise(num top) => UPNavbar(mode: 'ios', title: 'T', scrollTop: top)
          .navbarCenterTranslateY;
      // Hidden: offset is the full rise distance.
      expect(rise(0), 12);
      expect(rise(39), 12); // progress 0.75, fade about to start
      expect(rise(45.5), closeTo(6, 1e-9)); // half faded, half risen
      expect(rise(52), 0); // fully opaque and in place
    });

    test('default mode never offsets the title', () {
      expect(const UPNavbar(title: 'T').navbarCenterTranslateY, 0);
      expect(const UPNavbar(title: 'T').navbarCenterStyle, isEmpty);
    });

    test('navbarCenterStyle reports the source shape', () {
      final style =
          UPNavbar(mode: 'ios', title: 'T', scrollTop: 45.5).navbarCenterStyle;
      expect(style['opacity'], closeTo(0.5, 1e-9));
      expect(style['transform'], 'translateY(6.0px)');
    });
  });

  group('ios mode rendering', () {
    testWidgets('renders the large title and keeps the fixed layer clear',
        (tester) async {
      await tester.pumpWidget(_host(
        const UPNavbar(mode: 'ios', title: '设置', scrollTop: 0),
      ));
      await tester.pumpAndSettle();

      // Both the large title and the (transparent) centre title are present.
      expect(find.text('设置'), findsNWidgets(2));
      const navbar = UPNavbar(mode: 'ios', title: '设置');
      expect(navbar.navbarInnerStyle['background'], 'transparent',
          reason: 'the fixed layer must be transparent so the glass layer '
              'supplies the background');
    });

    testWidgets('default mode keeps its own background', (tester) async {
      await tester.pumpWidget(_host(const UPNavbar(title: '设置')));
      await tester.pumpAndSettle();
      expect(find.text('设置'), findsOneWidget);
      const navbar = UPNavbar(title: '设置');
      expect(navbar.navbarInnerStyle['background'], isNot('transparent'));
    });

    testWidgets('an explicit bgColor overrides the glass default',
        (tester) async {
      const navbar = UPNavbar(mode: 'ios', title: 'T', bgColor: '#ff0000');
      await tester.pumpWidget(_host(navbar));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(UPNavbar));
      expect(navbar.navbarGlassBgColor(context), const Color(0xFFFF0000));
    });

    testWidgets('the glass default carries the source readability alpha',
        (tester) async {
      const navbar = UPNavbar(mode: 'ios', title: 'T');
      await tester.pumpWidget(_host(navbar));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(UPNavbar));
      // rgba(255, 255, 255, 0.82) -> alpha byte 209.
      expect(navbar.navbarGlassBgColor(context), const Color(0xD1FFFFFF));
    });
  });
}
