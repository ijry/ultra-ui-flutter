import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

import 'example_test_helpers.dart';

const List<String> _emptyModes = <String>[
  'car',
  'data',
  'comment',
  'coupon',
  'history',
  'list',
  'message',
  'news',
  'order',
  'page',
  'permission',
  'search',
  'wifi',
];

Future<void> _pushRouteUnderTest(WidgetTester tester, String id) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => pushExampleRoute(context, findExampleRoute(id)),
          child: const Text('打开组件页面'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开组件页面'));
  await tester.pumpAndSettle();
}

Set<String> _assetImagePaths(WidgetTester tester) {
  return tester
      .widgetList<Image>(find.byType(Image))
      .map((image) => image.image)
      .whereType<AssetImage>()
      .map((image) => image.assetName)
      .toSet();
}

bool _isPng(File file) {
  final bytes = file.readAsBytesSync();
  const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  return bytes.length >= signature.length &&
      signature
          .asMap()
          .entries
          .every((entry) => bytes[entry.key] == entry.value);
}

void main() {
  test('Empty source asset fixtures are available locally', () {
    for (final mode in _emptyModes) {
      final emptyAsset = File('assets/uview/empty/$mode.png');
      final previewAsset = File('assets/uview/demo/empty/$mode.png');

      expect(emptyAsset.existsSync(), isTrue);
      expect(previewAsset.existsSync(), isTrue);
      expect(_isPng(emptyAsset), isTrue,
          reason: '$mode Empty asset must not be a remote response payload');
      expect(_isPng(previewAsset), isTrue,
          reason: '$mode preview asset must be a local PNG');
    }
  });

  testWidgets('Component A scroll routes render their source titles',
      (tester) async {
    for (final id in <String>[
      'componentsA/swipeAction/swipeAction',
      'componentsA/sticky/sticky',
      'componentsA/backtop/backtop',
      'componentsA/lazyLoad/lazyLoad',
      'componentsA/test/test',
    ]) {
      await tester.pumpWidget(buildRouteUnderTest(id));

      expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
      expect(find.text(findExampleRoute(id).title).first, findsOneWidget);
    }
  });

  testWidgets('swipe action delete confirmation removes the base row',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsA/swipeAction/swipeAction'));
    await tester.drag(find.text('基础使用'), const Offset(-320, 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(UPSwipeActionItem).first,
        matching: find.text('删除'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('基础使用'), findsNothing);
  });

  testWidgets('back top page returns its controller to scroll origin',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/backtop/backtop'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(UPBackTop));
    await tester.pumpAndSettle();
    expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        0);
  });

  testWidgets('lazy load page appends a source image batch', (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsA/lazyLoad/lazyLoad'));
    final before = find.byType(UPLazyLoad).evaluate().length;
    await tester.tap(find.text('加载更多'));
    await tester.pumpAndSettle();
    expect(find.byType(UPLazyLoad).evaluate().length, greaterThan(before));
  });

  testWidgets('Component A display routes render their source titles',
      (tester) async {
    for (final id in <String>[
      'componentsA/icon/icon',
      'componentsA/cell/cell',
      'componentsA/line/line',
      'componentsA/image/image',
      'componentsA/link/link',
      'componentsA/loading-icon/loading-icon',
      'componentsA/divider/divider',
      'componentsA/gap/gap',
      'componentsA/grid/grid',
    ]) {
      await tester.pumpWidget(buildRouteUnderTest(id));

      expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
      expect(find.text(findExampleRoute(id).title).first, findsOneWidget);
    }
  });

  testWidgets('grid item tap reports source-style feedback', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/grid/grid'));

    expect(find.byType(UPGrid), findsWidgets);
    expect(find.byType(UPGridItem), findsWidgets);
    await tester.tap(find.text('宫格1').first);
    await tester.pump();

    expect(find.text('点击了宫格1'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('radio page changes the source group value', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/radio/radio'));
    await tester.tap(find.text('苹果').first);
    await tester.pump();
    expect(find.text('当前选择：apple'), findsOneWidget);
  });

  testWidgets('checkbox page programmatic toggle changes standalone state',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsA/checkbox/checkbox'));
    await tester.tap(find.text('切换').first);
    await tester.pump();
    expect(find.text('true'), findsWidgets);
  });

  testWidgets('rate page emits an editable half rating', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/rate/rate'));

    final halfRate = find.byKey(const ValueKey('rate-half-mode'));
    await tester.ensureVisible(halfRate);
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getTopLeft(halfRate) + const Offset(5, 10));
    await tester.pump();

    expect(tester.state<UPRateState>(halfRate).value, 0.5);
    expect(find.text('当前评分：0.5'), findsOneWidget);
  });

  testWidgets('button page opens its source action sheet', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/button/button'));
    final actionSheet = find.byType(UPActionSheet);

    expect(tester.state<UPActionSheetState>(actionSheet).isShown, isFalse);
    await tester.tap(find.text('打开上拉菜单'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.state<UPActionSheetState>(actionSheet).isShown, isTrue);
    expect(find.text('拍照'), findsOneWidget);
    expect(
      TickerMode.valuesOf(tester.element(find.byType(UPLoadingIcon).first))
          .enabled,
      isTrue,
    );
  });

  testWidgets('transition page shows the selected transition block',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsA/transition/transition'));
    final transition = find.byType(UPTransition);

    expect(tester.state<UPTransitionState>(transition).isShown, isFalse);
    await tester.tap(find.text('淡入'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.state<UPTransitionState>(transition).isShown, isTrue);
    expect(
      find.byKey(const ValueKey('transition-preview')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('empty page uses local source assets for its default and switch',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/empty/empty'));

    var empty = tester.widget<UPEmpty>(find.byType(UPEmpty));
    expect(empty.mode, 'car');
    expect(empty.icon, 'assets/uview/empty/car.png');
    expect(
      _assetImagePaths(tester),
      containsAll(<String>{
        'assets/uview/empty/car.png',
        ..._emptyModes.map((mode) => 'assets/uview/demo/empty/$mode.png'),
      }),
    );

    await tester.tap(find.text('数据为空'));
    await tester.pump();

    empty = tester.widget<UPEmpty>(find.byType(UPEmpty));
    expect(empty.mode, 'data');
    expect(empty.icon, 'assets/uview/empty/data.png');
    expect(_assetImagePaths(tester), contains('assets/uview/empty/data.png'));
  });

  testWidgets('icon tap emits source feedback', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/icon/icon'));
    await tester.tap(find.text('level'));
    await tester.pump();

    expect(find.text('当前图标：level'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('image page uses local source assets and reports taps',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/image/image'));
    final images = tester.widgetList<UPImage>(find.byType(UPImage)).toList();

    expect(images.first.src, 'assets/uview/album/1.jpg');
    expect(images.last.src, isEmpty);
    expect(images.last.loadingWidget, isA<UPLoadingIcon>());

    await tester.tap(find.byType(UPImage).first);
    await tester.pump();
    expect(find.text('点击图片'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('link page reports in-app feedback instead of navigating',
      (tester) async {
    UPLink.openLinkHandler = (_) async {};
    addTearDown(() => UPLink.openLinkHandler = null);
    await tester.pumpWidget(buildRouteUnderTest('componentsA/link/link'));

    await tester.tap(find.text('打开uview-plus文档').first);
    await tester.pump();

    expect(find.text('https://uview-plus.jiangruyi.com/'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('test list changes its real scroll offset', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/test/test'));
    final list = find.byType(UPList);

    expect(tester.state<UPListState>(list).scrollOffset, 0);
    await tester.drag(list, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.state<UPListState>(list).scrollOffset, greaterThan(0));
  });

  testWidgets('sticky source button reports feedback after scrolling',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/sticky/sticky'));
    final scrollable = find.byType(Scrollable).first;

    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0));

    await tester.tap(find.text('吸顶按钮'));
    await tester.pump();
    expect(find.text('点击了吸顶按钮'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('overlay page opens and dismisses embedded content',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/overlay/overlay'));
    await tester.tap(find.text('嵌入内容'));
    await tester.pump();
    expect(find.byKey(const ValueKey('overlay-content-box')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('up-overlay-mask')));
    await tester.pump();
    expect(find.byKey(const ValueKey('overlay-content-box')), findsNothing);
  });

  testWidgets('overlay system back dismisses content before popping route',
      (tester) async {
    await _pushRouteUnderTest(tester, 'componentsA/overlay/overlay');
    await tester.tap(find.text('嵌入内容'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('overlay-content-box')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('example-page-componentsA/overlay/overlay')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('overlay-content-box')), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('打开组件页面'), findsOneWidget);
  });

  testWidgets('loading page uses the custom text preset', (tester) async {
    await tester.pumpWidget(
        buildRouteUnderTest('componentsA/loading-page/loading-page'));
    await tester.tap(find.text('自定义提示内容'));
    await tester.pump();
    expect(find.text('Hello uview-plus'), findsOneWidget);
  });

  testWidgets('popup page opens a top popup preset', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/popup/popup'));

    final popup = find.byType(UPPopup);
    expect(tester.state<UPPopupState>(popup).isShown, isFalse);

    await tester.tap(find.text('顶部弹出'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.state<UPPopupState>(popup).isShown, isTrue);
    await tester.tap(find.text('点我关闭'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.state<UPPopupState>(popup).isShown, isFalse);
  });

  testWidgets('popup system back dismisses non-dismissible overlay preset',
      (tester) async {
    await _pushRouteUnderTest(tester, 'componentsA/popup/popup');
    await tester.tap(find.text('禁止点击遮罩关闭'));
    await tester.pumpAndSettle();
    final popup = find.byType(UPPopup);
    expect(tester.state<UPPopupState>(popup).isShown, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('example-page-componentsA/popup/popup')),
        findsOneWidget);
    expect(tester.state<UPPopupState>(popup).isShown, isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('打开组件页面'), findsOneWidget);
  });
}
