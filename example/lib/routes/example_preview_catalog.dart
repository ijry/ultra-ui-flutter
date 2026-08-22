import 'example_route.dart';

class ExamplePreviewGroup {
  const ExamplePreviewGroup({required this.title, required this.routes});

  final String title;
  final List<ExamplePreviewRoute> routes;
}

const List<ExamplePreviewRoute> componentPreviewRoutes = <ExamplePreviewRoute>[
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/color/color',
      icon: 'color',
      title: 'Color 色彩',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/icon/icon',
      icon: 'icon',
      title: 'Icon 图标',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/image/image',
      icon: 'image',
      title: 'Image 图片',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/button/button',
      icon: 'button',
      title: 'Button 按钮',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/text/text',
      icon: 'text',
      title: 'Text 文本',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/layout/layout',
      icon: 'layout',
      title: 'Layout 布局',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/cell/cell',
      icon: 'cell',
      title: 'Cell 单元格',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/badge/badge',
      icon: 'badge',
      title: 'Badge 徽标数',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/tag/tag',
      icon: 'tag',
      title: 'Tag 标签',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/loading-icon/loading-icon',
      icon: 'loading',
      title: 'Loading 加载动画',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/loading-page/loading-page',
      icon: 'loading-page',
      title: 'Loading page 加载页',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/form/form',
      icon: 'form',
      title: 'Form 表单',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/calendar/calendar',
      icon: 'calendar',
      title: 'Calendar 日历',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/keyboard/keyboard',
      icon: 'keyboard',
      title: 'Keyboard 键盘',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/picker/picker',
      icon: 'picker',
      title: 'Picker 选择器',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/select/select',
      icon: 'picker',
      title: 'Select 经典下拉框',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cascader/cascader',
      icon: 'cascader',
      title: 'Cascader 级联选择器',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/choose/choose',
      icon: 'choose',
      title: 'Choose 选项选择器',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/datetimePicker/datetimePicker',
      icon: 'datetimePicker',
      title: 'DatetimePicker 时间选择器',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/rate/rate',
      icon: 'rate',
      title: 'Rate 评分',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/search/search',
      icon: 'search',
      title: 'Search 搜索',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/numberBox/numberBox',
      icon: 'numberBox',
      title: 'NumberBox 步进器',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/upload/upload',
      icon: 'upload',
      title: 'Upload 上传',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/code/code',
      icon: 'code',
      title: 'Code 验证码倒计时',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/input/input',
      icon: 'field',
      title: 'Input 输入框',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/textarea/textarea',
      icon: 'textarea',
      title: 'Textarea 文本域',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/checkbox/checkbox',
      icon: 'checkbox',
      title: 'Checkbox 复选框',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/radio/radio',
      icon: 'radio',
      title: 'Radio 单选框',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/switch/switch',
      icon: 'switch',
      title: 'Switch 开关选择器',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/slider/slider',
      icon: 'slider',
      title: 'Slider 滑动选择器',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/album/album',
      icon: 'album',
      title: 'Album 相册',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/list/list',
      icon: 'list',
      title: 'List 列表',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/virtualList/virtualList',
      icon: 'virtualList',
      title: 'VirtualList 虚拟列表',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/progress/progress',
      icon: 'progress',
      title: 'Progress 进度条',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/table/table',
      icon: 'table',
      title: 'Table 表格',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/table2/table2',
      icon: 'table',
      title: 'Table2 表格2',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/countDown/countDown',
      icon: 'countDown',
      title: 'CountDown 倒计时',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/countTo/countTo',
      icon: 'countTo',
      title: 'CountTo 数字滚动',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/tooltip/tooltip',
      icon: 'tooltip',
      title: 'Tooltip 长按提示',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/guide/guide',
      icon: 'tooltip',
      title: 'Guide 首屏引导',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/popover/popover',
      icon: 'popover',
      title: 'Popover 弹窗提示',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/actionSheet/actionSheet',
      icon: 'actionSheet',
      title: 'ActionSheet 上拉菜单',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/alert/alert',
      icon: 'alert',
      title: 'Alert 警告提示',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/toast/toast',
      icon: 'toast',
      title: 'Toast 消息提示',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/noticeBar/noticeBar',
      icon: 'noticeBar',
      title: 'NoticeBar 滚动通知',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/notify/notify',
      icon: 'notify',
      title: 'Notify 消息提示',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/swipeAction/swipeAction',
      icon: 'swipeAction',
      title: 'SwipeAction 滑动单元格',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/collapse/collapse',
      icon: 'collapse',
      title: 'Collapse 折叠面板',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/popup/popup',
      icon: 'popup',
      title: 'Popup 弹出层',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/modal/modal',
      icon: 'modal',
      title: 'Modal 模态框',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/copy/copy',
      icon: 'copy',
      title: 'Copy 复制',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/floatButton/floatButton',
      icon: 'copy',
      title: 'FloatButton 悬浮按钮',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/pullRefresh/pullRefresh',
      icon: 'pullRefresh',
      title: 'PullRefresh 下拉刷新',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/signature/signature',
      icon: 'signature',
      title: 'Signature 签名签字',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/agreement/agreement',
      icon: 'agreement',
      title: 'agreement 弹窗协议',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/scrollList/scrollList',
      icon: 'scrollList',
      title: 'ScrollList 横向滚动列表',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/line/line',
      icon: 'line',
      title: 'Line 线条',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/card/card',
      icon: 'empty',
      title: 'Card 卡片',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/overlay/overlay',
      icon: 'mask',
      title: 'Overlay 遮罩层',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/noNetwork/noNetwork',
      icon: 'noNetwork',
      title: 'NoNetwork 无网络提示',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/grid/grid',
      icon: 'grid',
      title: 'Grid 宫格布局',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/swiper/swiper',
      icon: 'swiper',
      title: 'Swiper 轮播图',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/skeleton/skeleton',
      icon: 'skeleton',
      title: 'Skeleton 骨架屏',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/sticky/sticky',
      icon: 'sticky',
      title: 'Sticky 吸顶',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/waterfall/waterfall',
      icon: 'waterfall',
      title: 'Waterfall 瀑布流',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/divider/divider',
      icon: 'divider',
      title: 'Divider 分割线',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/box/box',
      icon: 'box',
      title: 'Box 盒子',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cateTab/cateTab',
      icon: 'box',
      title: 'CateTab 垂直TAB',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/title/title',
      icon: 'title',
      title: 'Title 标题',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/shortVideo/shortVideo',
      icon: 'shortVideo',
      title: 'ShortVideo 短视频切换',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/dropdown/dropdown',
      icon: 'dropdown',
      title: 'Dropdown 下拉菜单',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/tabbar/tabbar',
      icon: 'tabbar',
      title: 'Tabbar 底部导航栏',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/backtop/backtop',
      icon: 'backTop',
      title: 'BackTop 返回顶部',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/navbar/navbar',
      icon: 'navbar',
      title: 'Navbar 导航栏',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/navbarMini/navbarMini',
      icon: 'navbar',
      title: 'NavbarMini 迷你导航栏',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/tabs/tabs',
      icon: 'tabs',
      title: 'Tabs 标签',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/subsection/subsection',
      icon: 'subsection',
      title: 'Subsection 分段器',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/indexList/indexList',
      icon: 'indexList',
      title: 'IndexList 索引列表',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/steps/steps',
      icon: 'steps',
      title: 'Steps 步骤条',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/empty/empty',
      icon: 'empty',
      title: 'Empty 内容为空',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/pagination/pagination',
      icon: 'pagination',
      title: 'Pagination 分页器',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/tree/tree',
      icon: 'tree',
      title: 'Tree 树形',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/parse/parse',
      icon: 'parse',
      title: 'Parse 富文本解析器',
      group: ExampleRouteGroup.componentsB,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/markdown/markdown',
      icon: 'markdown',
      title: 'Markdown 解析器',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/codeInput/codeInput',
      icon: 'messageInput',
      title: 'CodeInput 验证码输入',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/dragsort/dragsort',
      icon: 'dragsort',
      title: 'Dragsort 拖动排序',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cropper/cropper',
      icon: 'cropper',
      title: 'cropper 图片裁剪',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/loadmore/loadmore',
      icon: 'loadmore',
      title: 'Loadmore 加载更多',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/readMore/readMore',
      icon: 'readMore',
      title: 'ReadMore 展开阅读更多',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/lazyLoad/lazyLoad',
      icon: 'lazyLoad',
      title: 'LazyLoad 懒加载',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/gap/gap',
      icon: 'gap',
      title: 'Gap 间隔槽',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/avatar/avatar',
      icon: 'avatar',
      title: 'Avatar 头像',
      group: ExampleRouteGroup.componentsC,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/link/link',
      icon: 'link',
      title: 'Link 超链接',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/transition/transition',
      icon: 'transition',
      title: 'transition 动画',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/qrcode/qrcode',
      icon: 'qrcode',
      title: 'Qrcode 二维码',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/coupon/coupon',
      icon: 'coupon',
      title: 'Coupon 优惠券',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/barcode/barcode',
      icon: 'barcode',
      title: 'Barcode 条码',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/tabsPro/tabsPro',
      icon: 'tabs',
      title: 'TabsPro 增强标签',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/rootToastHost/rootToastHost',
      icon: 'toast',
      title: 'RootToastHost 全局提示宿主',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/novelReader/novelReader',
      icon: 'pdfReader',
      title: 'NovelReader 小说阅读器',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/colorPicker/colorPicker',
      icon: 'colorPicker',
      title: 'ColorPicker 颜色选择器',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/poster/poster',
      icon: 'poster',
      title: 'Poster 海报生成',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/goodsSku/goodsSku',
      icon: 'goodsSku',
      title: 'GoodsSku 商品SKU',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cityLocate/cityLocate',
      icon: 'cityLocate',
      title: 'CityLocate 城市定位',
      group: ExampleRouteGroup.componentsD,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/pdfReader/pdfReader',
      icon: 'pdfReader',
      title: 'PdfReader PDF阅读器',
      group: ExampleRouteGroup.componentsD,
      available: true),
];

const List<int> componentGroupLengths = <int>[11, 20, 7, 17, 15, 12, 23];

const List<String> componentPreviewGroupTitles = <String>[
  '基础组件',
  '表单组件',
  '数据组件',
  '反馈组件',
  '布局组件',
  '导航组件',
  '其他组件',
];

final List<ExamplePreviewGroup> componentPreviewGroups =
    _buildComponentPreviewGroups();

List<ExamplePreviewGroup> _buildComponentPreviewGroups() {
  var start = 0;
  return List<ExamplePreviewGroup>.generate(componentGroupLengths.length,
      (index) {
    final length = componentGroupLengths[index];
    final routes = componentPreviewRoutes.sublist(start, start + length);
    start += length;
    return ExamplePreviewGroup(
      title: componentPreviewGroupTitles[index],
      routes: routes,
    );
  });
}

const List<ExamplePreviewRoute> templatePreviewRoutes = <ExamplePreviewRoute>[
  ExamplePreviewRoute(
      sourcePath: 'pages/template/coupon/index',
      icon: 'coupon',
      title: 'Coupon 优惠券',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/wxCenter/index',
      icon: 'wxCenter',
      title: 'WxCenter 仿微信个人中心',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/keyboardPay/index',
      icon: 'keyboardPay',
      title: 'KeyboardPay 自定义键盘支付模板',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/mallMenu/index1',
      icon: 'mall_menu_1',
      title: 'MallMenu 垂直分类(左右独立)',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/mallMenu/index2',
      icon: 'mall_menu_2',
      title: 'MallMenu 垂直分类(左右联动)',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/submitBar/index',
      icon: 'submitBar',
      title: 'SubmitBar 提交订单栏',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/comment/index',
      icon: 'comment',
      title: 'Comment 评论列表',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/order/index',
      icon: 'order',
      title: 'Order 订单列表',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/login/index',
      icon: 'login',
      title: 'Login 登录界面',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/address/index',
      icon: 'address',
      title: 'Address 收货地址',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/citySelect/index',
      icon: 'citySelect',
      title: 'CitySelect 城市选择',
      group: ExampleRouteGroup.template,
      available: false),
];
