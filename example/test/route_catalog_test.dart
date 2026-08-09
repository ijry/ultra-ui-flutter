import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';
import 'package:ultra_ui_example/routes/example_preview_catalog.dart';
import 'package:ultra_ui_example/routes/example_route.dart';
import 'package:ultra_ui_example/routes/example_source_manifest.dart';

import 'example_test_helpers.dart';

void main() {
  test('source route manifest preserves all registered pages.json routes', () {
    expect(sourceExampleRoutes, hasLength(124));
    expect(
      sourceExampleRoutes.take(5).map((route) => route.id),
      <String>[
        'example/components',
        'example/template',
        'example/mine',
        'example/ad',
        'componentsA/transition/transition',
      ],
    );
    expect(
      sourceExampleRoutes.skip(27).take(4).map((route) => route.id),
      <String>[
        'componentsB/dropdown/dropdown',
        'componentsB/actionSheet/actionSheet',
        'componentsB/parse/parse',
        'componentsB/parse/jump',
      ],
    );
    expect(
      sourceExampleRoutes.skip(120).map((route) => route.id),
      <String>[
        'template/order/index',
        'template/login/code',
        'template/address/index',
        'template/address/addSite',
      ],
    );
    expect(
      sourceExampleRoutes.map((route) => route.sourcePath).toSet().length,
      sourceExampleRoutes.length,
    );
  });

  testWidgets('every completed Component A source route renders a real page',
      (tester) async {
    for (final id in componentARouteIds) {
      await tester.pumpWidget(buildRouteUnderTest(id));
      final route = findExampleRoute(id);
      expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(route.title),
        ),
        findsOneWidget,
      );
    }
  });

  test('component catalogs preserve literal source order and total', () {
    final componentARoutes = exampleRoutes
        .where((route) => route.group == ExampleRouteGroup.componentsA)
        .toList();

    expect(exampleRoutes, hasLength(75));
    expect(componentARoutes.map((route) => route.id), componentARouteIds);
    expect(
      componentARoutes.map((route) => route.sourcePath),
      componentARouteIds.map((id) => 'pages/$id'),
    );

    final componentBRoutes = exampleRoutes
        .where((route) => route.group == ExampleRouteGroup.componentsB)
        .map((route) => route.id)
        .toList();
    expect(
      componentBRoutes.take(28),
      <String>[
        'componentsB/dropdown/dropdown',
        'componentsB/actionSheet/actionSheet',
        'componentsB/parse/parse',
        'componentsB/parse/jump',
        'componentsB/toast/toast',
        'componentsB/keyboard/keyboard',
        'componentsB/slider/slider',
        'componentsB/upload/upload',
        'componentsB/notify/notify',
        'componentsB/countDown/countDown',
        'componentsB/color/color',
        'componentsB/numberBox/numberBox',
        'componentsB/countTo/countTo',
        'componentsB/search/search',
        'componentsB/badge/badge',
        'componentsB/tag/tag',
        'componentsB/alert/alert',
        'componentsB/switch/switch',
        'componentsB/collapse/collapse',
        'componentsB/code/code',
        'componentsB/noticeBar/noticeBar',
        'componentsB/progress/progress',
        'componentsB/tabbar/tabbar',
        'componentsB/tabbar/tabbar2',
        'componentsB/waterfall/waterfall',
        'componentsB/card/card',
        'componentsB/table/table',
        'componentsB/table2/table2',
      ],
    );

    final componentCRoutes = exampleRoutes
        .where((route) => route.group == ExampleRouteGroup.componentsC)
        .map((route) => route.id)
        .toList();
    expect(componentCRoutes, <String>[
      'componentsC/form/form',
      'componentsC/textarea/textarea',
      'componentsC/noNetwork/noNetwork',
      'componentsC/loadmore/loadmore',
      'componentsC/text/text',
      'componentsC/steps/steps',
      'componentsC/navbar/navbar',
      'componentsC/skeleton/skeleton',
      'componentsC/input/input',
      'componentsC/album/album',
      'componentsC/avatar/avatar',
      'componentsC/readMore/readMore',
      'componentsC/layout/layout',
      'componentsC/indexList/indexList',
      'componentsC/indexList/indexList2',
      'componentsC/tooltip/tooltip',
      'componentsC/guide/guide',
      'componentsC/popover/popover',
      'componentsC/tabs/tabs',
      'componentsC/list/list',
    ]);
  });

  test('source main catalog contains exactly four available routes', () {
    final mainRoutes = exampleRoutes
        .where((route) => route.group == ExampleRouteGroup.main)
        .toList();

    expect(mainRoutes, hasLength(4));
    expect(mainRoutes.every((route) => route.available), isTrue);
    expect(
      mainRoutes.map((route) => route.sourcePath),
      <String>[
        'pages/example/components',
        'pages/example/template',
        'pages/example/mine',
        'pages/example/ad',
      ],
    );

    final completedSourcePaths =
        exampleRoutes.map((route) => route.sourcePath).toSet();
    expect(
      completedSourcePaths,
      containsAll(<String>{
        'pages/example/components',
        'pages/example/template',
        'pages/example/mine',
        'pages/example/ad',
        'pages/componentsA/icon/icon',
        'pages/componentsA/cell/cell',
        'pages/componentsA/line/line',
        'pages/componentsA/image/image',
        'pages/componentsA/link/link',
        'pages/componentsA/loading-icon/loading-icon',
        'pages/componentsA/divider/divider',
        'pages/componentsA/gap/gap',
        'pages/componentsA/grid/grid',
        'pages/componentsC/avatar/avatar',
        'pages/componentsC/readMore/readMore',
        'pages/componentsC/layout/layout',
        'pages/componentsC/indexList/indexList',
        'pages/componentsC/indexList/indexList2',
        'pages/componentsC/tooltip/tooltip',
        'pages/componentsC/guide/guide',
        'pages/componentsC/popover/popover',
        'pages/componentsC/tabs/tabs',
        'pages/componentsC/list/list',
      }),
    );
  });

  test('route ids resolve to their registered catalog entries', () {
    for (final route in exampleRoutes) {
      expect(findExampleRoute(route.id), same(route));
      expect(route.builder, isA<WidgetBuilder>());
    }
  });

  test('component previews retain the seven source semantic groups and order',
      () {
    expect(
      componentPreviewGroups.map((group) => group.title),
      <String>[
        '基础组件',
        '表单组件',
        '数据组件',
        '反馈组件',
        '布局组件',
        '导航组件',
        '其他组件',
      ],
    );
    expect(
      componentPreviewGroups
          .map((group) => group.routes.map((route) => route.sourcePath))
          .toList(),
      <List<String>>[
        <String>[
          'pages/componentsB/color/color',
          'pages/componentsA/icon/icon',
          'pages/componentsA/image/image',
          'pages/componentsA/button/button',
          'pages/componentsC/text/text',
          'pages/componentsC/layout/layout',
          'pages/componentsA/cell/cell',
          'pages/componentsB/badge/badge',
          'pages/componentsB/tag/tag',
          'pages/componentsA/loading-icon/loading-icon',
          'pages/componentsA/loading-page/loading-page',
        ],
        <String>[
          'pages/componentsC/form/form',
          'pages/componentsC/calendar/calendar',
          'pages/componentsB/keyboard/keyboard',
          'pages/componentsC/picker/picker',
          'pages/componentsD/select/select',
          'pages/componentsD/cascader/cascader',
          'pages/componentsD/choose/choose',
          'pages/componentsC/datetimePicker/datetimePicker',
          'pages/componentsA/rate/rate',
          'pages/componentsB/search/search',
          'pages/componentsB/numberBox/numberBox',
          'pages/componentsB/upload/upload',
          'pages/componentsB/code/code',
          'pages/componentsC/input/input',
          'pages/componentsC/textarea/textarea',
          'pages/componentsA/checkbox/checkbox',
          'pages/componentsA/radio/radio',
          'pages/componentsB/switch/switch',
          'pages/componentsB/slider/slider',
          'pages/componentsC/album/album',
        ],
        <String>[
          'pages/componentsC/list/list',
          'pages/componentsD/virtualList/virtualList',
          'pages/componentsB/progress/progress',
          'pages/componentsB/table/table',
          'pages/componentsB/table2/table2',
          'pages/componentsB/countDown/countDown',
          'pages/componentsB/countTo/countTo',
        ],
        <String>[
          'pages/componentsC/tooltip/tooltip',
          'pages/componentsC/guide/guide',
          'pages/componentsC/popover/popover',
          'pages/componentsB/actionSheet/actionSheet',
          'pages/componentsB/alert/alert',
          'pages/componentsB/toast/toast',
          'pages/componentsB/noticeBar/noticeBar',
          'pages/componentsB/notify/notify',
          'pages/componentsA/swipeAction/swipeAction',
          'pages/componentsB/collapse/collapse',
          'pages/componentsA/popup/popup',
          'pages/componentsC/modal/modal',
          'pages/componentsD/copy/copy',
          'pages/componentsD/floatButton/floatButton',
          'pages/componentsD/pullRefresh/pullRefresh',
          'pages/componentsD/signature/signature',
          'pages/componentsD/agreement/agreement',
        ],
        <String>[
          'pages/componentsC/scrollList/scrollList',
          'pages/componentsA/line/line',
          'pages/componentsB/card/card',
          'pages/componentsA/overlay/overlay',
          'pages/componentsC/noNetwork/noNetwork',
          'pages/componentsA/grid/grid',
          'pages/componentsC/swiper/swiper',
          'pages/componentsC/skeleton/skeleton',
          'pages/componentsA/sticky/sticky',
          'pages/componentsB/waterfall/waterfall',
          'pages/componentsA/divider/divider',
          'pages/componentsD/box/box',
          'pages/componentsD/cateTab/cateTab',
          'pages/componentsD/title/title',
          'pages/componentsD/shortVideo/shortVideo',
        ],
        <String>[
          'pages/componentsB/dropdown/dropdown',
          'pages/componentsB/tabbar/tabbar',
          'pages/componentsA/backtop/backtop',
          'pages/componentsC/navbar/navbar',
          'pages/componentsD/navbarMini/navbarMini',
          'pages/componentsC/tabs/tabs',
          'pages/componentsC/subsection/subsection',
          'pages/componentsC/indexList/indexList',
          'pages/componentsC/steps/steps',
          'pages/componentsA/empty/empty',
          'pages/componentsD/pagination/pagination',
          'pages/componentsD/tree/tree',
        ],
        <String>[
          'pages/componentsB/parse/parse',
          'pages/componentsD/markdown/markdown',
          'pages/componentsC/codeInput/codeInput',
          'pages/componentsD/dragsort/dragsort',
          'pages/componentsD/cropper/cropper',
          'pages/componentsC/loadmore/loadmore',
          'pages/componentsC/readMore/readMore',
          'pages/componentsA/lazyLoad/lazyLoad',
          'pages/componentsA/gap/gap',
          'pages/componentsC/avatar/avatar',
          'pages/componentsA/link/link',
          'pages/componentsA/transition/transition',
          'pages/componentsD/qrcode/qrcode',
          'pages/componentsD/coupon/coupon',
          'pages/componentsD/barcode/barcode',
          'pages/componentsD/colorPicker/colorPicker',
          'pages/componentsD/poster/poster',
          'pages/componentsD/goodsSku/goodsSku',
          'pages/componentsD/cityLocate/cityLocate',
          'pages/componentsD/pdfReader/pdfReader',
        ],
      ],
    );
    final componentAPreviews = componentPreviewRoutes
        .where((route) => route.group == ExampleRouteGroup.componentsA);
    final completedPreviewPaths =
        exampleRoutes.map((route) => route.sourcePath).toSet();

    expect(componentAPreviews, isNotEmpty);
    expect(componentAPreviews.every((route) => route.available), isTrue);
    expect(
      componentPreviewRoutes
          .where(
            (route) => <String>{
              'pages/componentsC/tooltip/tooltip',
              'pages/componentsC/guide/guide',
              'pages/componentsC/popover/popover',
              'pages/componentsC/tabs/tabs',
              'pages/componentsC/list/list',
            }.contains(route.sourcePath),
          )
          .every((route) => route.available),
      isTrue,
    );
    expect(
      componentPreviewRoutes.every(
        (route) =>
            route.available == completedPreviewPaths.contains(route.sourcePath),
      ),
      isTrue,
    );
    expect(
      componentPreviewRoutes
          .map((route) => route.sourcePath)
          .contains('pages/componentsA/test/test'),
      isFalse,
    );
    expect(
      componentPreviewRoutes.every(
        (route) => route.group != ExampleRouteGroup.main,
      ),
      isTrue,
    );
    expect(templatePreviewRoutes.every((route) => route.available), isFalse);
    expect(
      templatePreviewRoutes.map((route) => route.sourcePath),
      <String>[
        'pages/template/coupon/index',
        'pages/template/wxCenter/index',
        'pages/template/keyboardPay/index',
        'pages/template/mallMenu/index1',
        'pages/template/mallMenu/index2',
        'pages/template/submitBar/index',
        'pages/template/comment/index',
        'pages/template/order/index',
        'pages/template/login/index',
        'pages/template/address/index',
        'pages/template/citySelect/index',
      ],
    );
    expect(
      componentPreviewRoutes.map((route) => route.sourcePath).toSet().length,
      componentPreviewRoutes.length,
    );
    expect(
      templatePreviewRoutes.map((route) => route.sourcePath).toSet().length,
      templatePreviewRoutes.length,
    );
    final allPreviewPaths = <String>[
      ...componentPreviewGroups.expand(
        (group) => group.routes.map((route) => route.sourcePath),
      ),
      ...templatePreviewRoutes.map((route) => route.sourcePath),
    ];
    expect(allPreviewPaths.toSet().length, allPreviewPaths.length);
  });
}
