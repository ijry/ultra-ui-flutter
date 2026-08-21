// UPTabbarItem mid-button tests.
//
// The source's `midButton` mode renders a raised circle straddling the bar's
// top edge. Its geometry comes from a small set of computed values whose numbers
// are easy to get wrong, so each is pinned here — including the border clip,
// whose base differs depending on whether the button carries a label.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

Widget _host(List<Widget> items, {String borderColor = ''}) => MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: UPTabbar(
          value: 'home',
          borderColor: borderColor,
          children: items,
        ),
      ),
    );

void main() {
  group('mid-button geometry', () {
    test('offsetY falls back to the source default of -10', () {
      expect(
          const UPTabbarItem(mode: 'midButton').resolvedMidButtonOffsetY, -10);
      // Unparseable values also take the default rather than becoming 0.
      expect(
        const UPTabbarItem(mode: 'midButton', midButtonOffsetY: 'nope')
            .resolvedMidButtonOffsetY,
        -10,
      );
      expect(
        const UPTabbarItem(mode: 'midButton', midButtonOffsetY: -20)
            .resolvedMidButtonOffsetY,
        -20,
      );
    });

    test('translateY reports the offset in px', () {
      expect(
        const UPTabbarItem(mode: 'midButton', midButtonOffsetY: -14)
            .midButtonTranslateY,
        '-14.0px',
      );
    });

    test('the border clip base differs with and without a label', () {
      // Labelled: base 15.5; unlabelled: base 7. Both minus the offset.
      const labelled = UPTabbarItem(mode: 'midButton', text: '发布');
      const bare = UPTabbarItem(mode: 'midButton');
      expect(labelled.hasMidButtonText, isTrue);
      expect(bare.hasMidButtonText, isFalse);
      expect(labelled.midButtonBorderClipHeight, '25.5px'); // 15.5 - (-10)
      expect(bare.midButtonBorderClipHeight, '17.0px'); // 7 - (-10)
    });

    test('raising the button exposes more of the ring', () {
      const higher =
          UPTabbarItem(mode: 'midButton', text: 'x', midButtonOffsetY: -30);
      expect(higher.midButtonBorderClipHeight, '45.5px'); // 15.5 - (-30)
    });

    test('the clip height is clamped to 0..64', () {
      // A large positive offset would otherwise go negative.
      expect(
        const UPTabbarItem(mode: 'midButton', midButtonOffsetY: 100)
            .midButtonBorderClipHeight,
        '0.0px',
      );
      // A very negative offset would otherwise exceed the ceiling.
      expect(
        const UPTabbarItem(mode: 'midButton', midButtonOffsetY: -200)
            .midButtonBorderClipHeight,
        '64.0px',
      );
    });

    test('the icon is lifted above the notch only in mid-button mode', () {
      expect(const UPTabbarItem(mode: 'midButton').midButtonIconStyle,
          <String, dynamic>{'position': 'relative', 'zIndex': 2});
      expect(const UPTabbarItem().midButtonIconStyle, isEmpty);
    });

    test('the default mid-button icon color is the source blue', () {
      expect(const UPTabbarItem(mode: 'midButton').resolvedMidButtonIconColor,
          '#3c9cff');
      // An explicit color wins.
      expect(
        const UPTabbarItem(mode: 'midButton', midButtonIconColor: '#ff0000')
            .resolvedMidButtonIconColor,
        '#ff0000',
      );
    });
  });

  group('mid-button rendering', () {
    testWidgets('the raised circle is drawn and offset upward', (tester) async {
      await tester.pumpWidget(_host(const <Widget>[
        UPTabbarItem(name: 'home', text: '首页', icon: 'home'),
        UPTabbarItem(
          name: 'post',
          mode: 'midButton',
          icon: 'plus',
          midButtonBgColor: '#2979ff',
        ),
      ]));
      await tester.pumpAndSettle();

      // UPIcon adds its own Transform, so find the one that actually raises the
      // button rather than assuming a position in the tree.
      final raised = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byKey(const ValueKey('up-tabbar-item-post')),
              matching: find.byType(Transform),
            ),
          )
          .where((t) => t.transform.getTranslation().y != 0)
          .toList();
      expect(raised, hasLength(1));
      // A negative dy means the button sits above the bar.
      expect(raised.single.transform.getTranslation().y, -10);

      // The circle uses the supplied background.
      final circle = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('up-tabbar-item-post')),
              matching: find.byType(Container),
            )
            .last,
      );
      final decoration = circle.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, const Color(0xFF2979FF));
    });

    testWidgets('the ring takes the bar border color', (tester) async {
      await tester.pumpWidget(_host(
        const <Widget>[
          UPTabbarItem(name: 'home', text: '首页', icon: 'home'),
          UPTabbarItem(name: 'post', mode: 'midButton', icon: 'plus'),
        ],
        borderColor: '#ff0000',
      ));
      await tester.pumpAndSettle();

      final circle = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('up-tabbar-item-post')),
              matching: find.byType(Container),
            )
            .last,
      );
      final decoration = circle.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border as Border).top.color,
        const Color(0xFFFF0000),
      );
    });

    testWidgets('a normal item is not raised', (tester) async {
      await tester.pumpWidget(_host(const <Widget>[
        UPTabbarItem(name: 'home', text: '首页', icon: 'home'),
      ]));
      await tester.pumpAndSettle();

      // UPIcon contributes its own Transform, so assert on the offset rather
      // than the widget's presence: nothing may shift the item vertically.
      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byKey(const ValueKey('up-tabbar-item-home')),
          matching: find.byType(Transform),
        ),
      );
      for (final t in transforms) {
        expect(t.transform.getTranslation().y, 0);
      }
    });
  });
}
