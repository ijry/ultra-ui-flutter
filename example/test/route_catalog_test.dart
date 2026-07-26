import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';
import 'package:ultra_ui_example/routes/example_preview_catalog.dart';
import 'package:ultra_ui_example/routes/example_route.dart';

void main() {
  test('source main catalog contains exactly four available routes', () {
    expect(exampleRoutes, hasLength(4));
    expect(exampleRoutes.every((route) => route.available), isTrue);
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
    expect(componentPreviewRoutes.every((route) => route.available), isFalse);
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
