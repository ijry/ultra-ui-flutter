import 'example_route.dart';

class ExamplePreviewGroup {
  const ExamplePreviewGroup({required this.title, required this.routes});

  final String title;
  final List<ExamplePreviewRoute> routes;
}

const List<ExamplePreviewRoute> componentPreviewRoutes = <ExamplePreviewRoute>[
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/color/color',
      title: 'Color 色彩',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/icon/icon',
      title: 'Icon 图标',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/image/image',
      title: 'Image 图片',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/button/button',
      title: 'Button 按钮',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/text/text',
      title: 'Text 文本',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/layout/layout',
      title: 'Layout 布局',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/cell/cell',
      title: 'Cell 单元格',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/badge/badge',
      title: 'Badge 徽标数',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/tag/tag',
      title: 'Tag 标签',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/loading-icon/loading-icon',
      title: 'Loading 加载动画',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/loading-page/loading-page',
      title: 'Loading page 加载页',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/form/form',
      title: 'Form 表单',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/calendar/calendar',
      title: 'Calendar 日历',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/keyboard/keyboard',
      title: 'Keyboard 键盘',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/picker/picker',
      title: 'Picker 选择器',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/select/select',
      title: 'Select 经典下拉框',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cascader/cascader',
      title: 'Cascader 级联选择器',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/choose/choose',
      title: 'Choose 选项选择器',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/datetimePicker/datetimePicker',
      title: 'DatetimePicker 时间选择器',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/rate/rate',
      title: 'Rate 评分',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/search/search',
      title: 'Search 搜索',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/numberBox/numberBox',
      title: 'NumberBox 步进器',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/upload/upload',
      title: 'Upload 上传',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/code/code',
      title: 'Code 验证码倒计时',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/input/input',
      title: 'Input 输入框',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/textarea/textarea',
      title: 'Textarea 文本域',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/checkbox/checkbox',
      title: 'Checkbox 复选框',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/radio/radio',
      title: 'Radio 单选框',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/switch/switch',
      title: 'Switch 开关选择器',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/slider/slider',
      title: 'Slider 滑动选择器',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/album/album',
      title: 'Album 相册',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/list/list',
      title: 'List 列表',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/virtualList/virtualList',
      title: 'VirtualList 虚拟列表',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/progress/progress',
      title: 'Progress 进度条',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/table/table',
      title: 'Table 表格',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/table2/table2',
      title: 'Table2 表格2',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/countDown/countDown',
      title: 'CountDown 倒计时',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/countTo/countTo',
      title: 'CountTo 数字滚动',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/tooltip/tooltip',
      title: 'Tooltip 长按提示',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/guide/guide',
      title: 'Guide 首屏引导',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/popover/popover',
      title: 'Popover 弹窗提示',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/actionSheet/actionSheet',
      title: 'ActionSheet 上拉菜单',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/alert/alert',
      title: 'Alert 警告提示',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/toast/toast',
      title: 'Toast 消息提示',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/noticeBar/noticeBar',
      title: 'NoticeBar 滚动通知',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/notify/notify',
      title: 'Notify 消息提示',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/swipeAction/swipeAction',
      title: 'SwipeAction 滑动单元格',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/collapse/collapse',
      title: 'Collapse 折叠面板',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/popup/popup',
      title: 'Popup 弹出层',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/modal/modal',
      title: 'Modal 模态框',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/copy/copy',
      title: 'Copy 复制',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/floatButton/floatButton',
      title: 'FloatButton 悬浮按钮',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/pullRefresh/pullRefresh',
      title: 'PullRefresh 下拉刷新',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/signature/signature',
      title: 'Signature 签名签字',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/agreement/agreement',
      title: 'agreement 弹窗协议',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/scrollList/scrollList',
      title: 'ScrollList 横向滚动列表',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/line/line',
      title: 'Line 线条',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/card/card',
      title: 'Card 卡片',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/overlay/overlay',
      title: 'Overlay 遮罩层',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/noNetwork/noNetwork',
      title: 'NoNetwork 无网络提示',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/grid/grid',
      title: 'Grid 宫格布局',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/swiper/swiper',
      title: 'Swiper 轮播图',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/skeleton/skeleton',
      title: 'Skeleton 骨架屏',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/sticky/sticky',
      title: 'Sticky 吸顶',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/waterfall/waterfall',
      title: 'Waterfall 瀑布流',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/divider/divider',
      title: 'Divider 分割线',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/box/box',
      title: 'Box 盒子',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cateTab/cateTab',
      title: 'CateTab 垂直TAB',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/title/title',
      title: 'Title 标题',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/shortVideo/shortVideo',
      title: 'ShortVideo 短视频切换',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/dropdown/dropdown',
      title: 'Dropdown 下拉菜单',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/tabbar/tabbar',
      title: 'Tabbar 底部导航栏',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/backtop/backtop',
      title: 'BackTop 返回顶部',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/navbar/navbar',
      title: 'Navbar 导航栏',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/navbarMini/navbarMini',
      title: 'NavbarMini 迷你导航栏',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/tabs/tabs',
      title: 'Tabs 标签',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/subsection/subsection',
      title: 'Subsection 分段器',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/indexList/indexList',
      title: 'IndexList 索引列表',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/steps/steps',
      title: 'Steps 步骤条',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/empty/empty',
      title: 'Empty 内容为空',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/pagination/pagination',
      title: 'Pagination 分页器',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/tree/tree',
      title: 'Tree 树形',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsB/parse/parse',
      title: 'Parse 富文本解析器',
      group: ExampleRouteGroup.componentsB,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/markdown/markdown',
      title: 'Markdown 解析器',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/codeInput/codeInput',
      title: 'CodeInput 验证码输入',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/dragsort/dragsort',
      title: 'Dragsort 拖动排序',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cropper/cropper',
      title: 'cropper 图片裁剪',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/loadmore/loadmore',
      title: 'Loadmore 加载更多',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/readMore/readMore',
      title: 'ReadMore 展开阅读更多',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/lazyLoad/lazyLoad',
      title: 'LazyLoad 懒加载',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/gap/gap',
      title: 'Gap 间隔槽',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsC/avatar/avatar',
      title: 'Avatar 头像',
      group: ExampleRouteGroup.componentsC,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/link/link',
      title: 'Link 超链接',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsA/transition/transition',
      title: 'transition 动画',
      group: ExampleRouteGroup.componentsA,
      available: true),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/qrcode/qrcode',
      title: 'Qrcode 二维码',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/coupon/coupon',
      title: 'Coupon 优惠券',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/barcode/barcode',
      title: 'Barcode 条码',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/colorPicker/colorPicker',
      title: 'ColorPicker 颜色选择器',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/poster/poster',
      title: 'Poster 海报生成',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/goodsSku/goodsSku',
      title: 'GoodsSku 商品SKU',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/cityLocate/cityLocate',
      title: 'CityLocate 城市定位',
      group: ExampleRouteGroup.componentsD,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/componentsD/pdfReader/pdfReader',
      title: 'PdfReader PDF阅读器',
      group: ExampleRouteGroup.componentsD,
      available: false),
];

const List<int> componentGroupLengths = <int>[11, 20, 7, 17, 15, 12, 20];

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
      title: 'Coupon 优惠券',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/wxCenter/index',
      title: 'WxCenter 仿微信个人中心',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/keyboardPay/index',
      title: 'KeyboardPay 自定义键盘支付模板',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/mallMenu/index1',
      title: 'MallMenu 垂直分类(左右独立)',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/mallMenu/index2',
      title: 'MallMenu 垂直分类(左右联动)',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/submitBar/index',
      title: 'SubmitBar 提交订单栏',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/comment/index',
      title: 'Comment 评论列表',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/order/index',
      title: 'Order 订单列表',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/login/index',
      title: 'Login 登录界面',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/address/index',
      title: 'Address 收货地址',
      group: ExampleRouteGroup.template,
      available: false),
  ExamplePreviewRoute(
      sourcePath: 'pages/template/citySelect/index',
      title: 'CitySelect 城市选择',
      group: ExampleRouteGroup.template,
      available: false),
];
