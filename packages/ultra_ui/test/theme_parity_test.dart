// Theme parity tests.
//
// The source's real style contract is libs/css/theme-vars-core.scss, which
// declares every color as a CSS custom property for both the light and dark
// palettes. tool/theme_parity_scan.py diffs those against UPThemeTokens; these
// tests pin the component-scoped tokens that the scanner cannot check on its
// own, because a component could still read the wrong token.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: UP.themeData(brightness: brightness),
    home: Scaffold(body: child),
  );
}

/// Reads the resolved tokens from a mounted subtree.
UPThemeTokens _tokens(WidgetTester tester, Type of) =>
    UPThemeTokens.of(tester.element(find.byType(of)));

void main() {
  group('component-scoped tokens carry both palettes', () {
    test('light values match theme-vars-core.scss', () {
      final t = UPThemeTokens.light();
      expect(t.hoverBgColor, const Color(0xFFE7EBF0));
      expect(t.navbarBgColor, const Color(0xFFFFFFFF));
      expect(t.gapBgColor, const Color(0xFFF3F4F6));
      expect(t.skeletonBgColor, const Color(0xFFF1F2F4));
      expect(t.skeletonShimmerColor, const Color(0xFFE6E6E6));
      expect(t.swipeActionButtonBgColor, const Color(0xFFC7C6CD));
      expect(t.indexListIndicatorBgColor, const Color(0xFFC9C9C9));
      expect(t.table2HeaderBgColor, const Color(0xFFF5F7FA));
      expect(t.table2ZebraBgColor, const Color(0xFFFAFAFA));
      expect(t.table2HighlightBgColor, const Color(0xFFF5F7FA));
    });

    test('dark values match theme-vars-core.scss', () {
      final t = UPThemeTokens.dark();
      expect(t.hoverBgColor, const Color(0xFF343741));
      expect(t.navbarBgColor, const Color(0xFF1C1C1E));
      expect(t.gapBgColor, const Color(0xFF111111));
      expect(t.skeletonBgColor, const Color(0xFF2F3135));
      // rgba(255, 255, 255, 0.12) -> alpha byte 31.
      expect(t.skeletonShimmerColor, const Color(0x1FFFFFFF));
      expect(t.swipeActionButtonBgColor, const Color(0xFF4B5563));
      expect(t.indexListIndicatorBgColor, const Color(0xFF4B5563));
      expect(t.table2HeaderBgColor, const Color(0xFF2A2D33));
      expect(t.table2ZebraBgColor, const Color(0xFF23262B));
      expect(t.table2HighlightBgColor, const Color(0xFF2F3440));
    });

    test('the component tokens are distinct from the generic ones', () {
      // The point of these being separate variables upstream: substituting a
      // generic color would be visibly wrong.
      final light = UPThemeTokens.light();
      expect(light.skeletonBgColor, isNot(light.bgColor));
      expect(light.table2ZebraBgColor, isNot(light.cardBgColor));

      final dark = UPThemeTokens.dark();
      expect(dark.skeletonBgColor, isNot(dark.bgColor));
      expect(dark.gapBgColor, isNot(dark.pageBgColor));
    });
  });

  group('components read their own token', () {
    testWidgets('UPGap uses the gap background in both palettes',
        (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          _host(const UPGap(height: 20), brightness: brightness),
        );
        await tester.pumpAndSettle();

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(UPGap),
            matching: find.byType(Container),
          ),
        );
        final expected = brightness == Brightness.dark
            ? UPThemeTokens.dark().gapBgColor
            : UPThemeTokens.light().gapBgColor;
        expect(
            container.color ?? (container.decoration as BoxDecoration?)?.color,
            expected,
            reason: 'gap should follow --up-gap-bg-color in $brightness');
      }
    });

    testWidgets('UPSkeleton uses the skeleton token, not the generic fill',
        (tester) async {
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 300,
          height: 200,
          child: UPSkeleton(loading: true, rows: 2, animate: false),
        ),
      ));
      await tester.pumpAndSettle();

      final tokens = _tokens(tester, UPSkeleton);
      final bones = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(UPSkeleton),
            matching: find.byType(Container),
          ))
          .where((c) =>
              (c.decoration as BoxDecoration?)?.color == tokens.skeletonBgColor)
          .toList();
      expect(bones, isNotEmpty,
          reason: 'bones must paint --up-skeleton-bg-color (#f1f2f4), '
              'not the generic bg color (#f3f4f6)');
    });

    testWidgets('UPNavbar uses the navbar background token', (tester) async {
      await tester.pumpWidget(_host(const UPNavbar(title: 'T')));
      await tester.pumpAndSettle();

      final tokens = _tokens(tester, UPNavbar);
      expect(tokens.navbarBgColor, const Color(0xFFFFFFFF));
      // The bar paints that token when no explicit bgColor is given.
      final painted = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(UPNavbar),
            matching: find.byType(Container),
          ))
          .any((c) =>
              (c.decoration as BoxDecoration?)?.color == tokens.navbarBgColor);
      expect(painted, isTrue);
    });

    testWidgets('UPSwipeActionItem uses the swipe-action button token',
        (tester) async {
      final key = GlobalKey<UPSwipeActionItemState>();
      await tester.pumpWidget(_host(
        UPSwipeAction(
          children: <Widget>[
            UPSwipeActionItem(
              key: key,
              options: const <Map<String, dynamic>>[
                <String, dynamic>{'text': '删除'},
              ],
              child: const SizedBox(height: 60, child: Text('row')),
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UPSwipeActionItem));
      expect(
        key.currentState!.defaultButtonBgColor(context),
        UPThemeTokens.light().swipeActionButtonBgColor,
      );
    });
  });

  group('per-component tokens with distinct dark values', () {
    test('subsection, switch, tag and notice-bar match their theme-vars.scss',
        () {
      final light = UPThemeTokens.light();
      expect(light.subsectionBgColor, const Color(0xFFEEEEEF));
      expect(light.subsectionBarColor, const Color(0xFFFFFFFF));
      expect(light.subsectionInactiveColor, const Color(0xFF303133));
      expect(light.subsectionDisabledTextColor, const Color(0xFFC8C9CC));
      expect(light.subsectionDisabledBorderColor, const Color(0xFFD4D4D4));
      expect(light.subsectionDisabledBarColor, const Color(0xFFF5F5F5));
      expect(light.switchInactiveColor, const Color(0xFFFFFFFF));
      expect(light.switchDotInactiveColor, const Color(0xFFFFFFFF));
      expect(light.switchLoadingInactiveColor, const Color(0xFFAAABAD));
      expect(light.tagCloseBgColor, const Color(0xFFC8C9CC));
      expect(light.noticeBarBgColor, const Color(0xFFFDF6EC));

      final dark = UPThemeTokens.dark();
      expect(dark.subsectionBgColor, const Color(0xFF2B2C30));
      expect(dark.subsectionBarColor, const Color(0xFF3A3B40));
      expect(dark.subsectionInactiveColor, const Color(0xFFD1D5DB));
      expect(dark.subsectionDisabledTextColor, const Color(0xFF6B7280));
      expect(dark.subsectionDisabledBorderColor, const Color(0xFF3A3A3C));
      expect(dark.subsectionDisabledBarColor, const Color(0xFF3A3A3C));
      expect(dark.switchInactiveColor, const Color(0xFF3A3A3C));
      expect(dark.switchDotInactiveColor, const Color(0xFFD1D5DB));
      expect(dark.switchLoadingInactiveColor, const Color(0xFF9CA3AF));
      expect(dark.tagCloseBgColor, const Color(0xFF4B5563));
      expect(dark.noticeBarBgColor, const Color(0xFF3D2F1B));
    });

    testWidgets('UPSwitch takes the token when inactiveColor is left default',
        (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          _host(const UPSwitch(value: false), brightness: brightness),
        );
        await tester.pumpAndSettle();

        final expected = brightness == Brightness.dark
            ? UPThemeTokens.dark().switchInactiveColor
            : UPThemeTokens.light().switchInactiveColor;
        final painted = tester
            .widgetList<Container>(find.descendant(
              of: find.byType(UPSwitch),
              matching: find.byType(Container),
            ))
            .any((c) => (c.decoration as BoxDecoration?)?.color == expected);
        expect(painted, isTrue,
            reason: 'an untouched inactiveColor must follow the theme in '
                '$brightness, not stay #ffffff');
      }
    });

    testWidgets('UPSwitch still honors an explicit inactiveColor',
        (tester) async {
      await tester.pumpWidget(
        _host(const UPSwitch(value: false, inactiveColor: '#ff0000')),
      );
      await tester.pumpAndSettle();

      final painted = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(UPSwitch),
            matching: find.byType(Container),
          ))
          .any((c) =>
              (c.decoration as BoxDecoration?)?.color ==
              const Color(0xFFFF0000));
      expect(painted, isTrue);
    });

    testWidgets('UPNoticeBar takes the token when bgColor is left default',
        (tester) async {
      await tester.pumpWidget(_host(
        const UPNoticeBar(text: 'hi'),
        brightness: Brightness.dark,
      ));
      // A single pump: the notice bar scrolls continuously, so it never
      // settles.
      await tester.pump();

      final expected = UPThemeTokens.dark().noticeBarBgColor;
      final painted = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(UPNoticeBar),
            matching: find.byType(Container),
          ))
          .any((c) => (c.decoration as BoxDecoration?)?.color == expected);
      expect(painted, isTrue,
          reason: 'dark mode must use #3d2f1b, not the light #fdf6ec');
    });
  });
}
