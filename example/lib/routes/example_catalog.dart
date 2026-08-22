import 'package:flutter/material.dart';

import '../pages/home/ad_page.dart';
import '../pages/home/components_home_page.dart';
import '../pages/home/mine_page.dart';
import '../pages/home/templates_home_page.dart';
import '../pages/components_a/cell_page.dart';
import '../pages/components_a/back_top_page.dart';
import '../pages/components_a/checkbox_page.dart';
import '../pages/components_a/divider_page.dart';
import '../pages/components_a/empty_page.dart';
import '../pages/components_a/gap_page.dart';
import '../pages/components_a/grid_page.dart';
import '../pages/components_a/icon_page.dart';
import '../pages/components_a/image_page.dart';
import '../pages/components_a/line_page.dart';
import '../pages/components_a/link_page.dart';
import '../pages/components_a/loading_icon_page.dart';
import '../pages/components_a/loading_page_page.dart';
import '../pages/components_a/overlay_page.dart';
import '../pages/components_a/popup_page.dart';
import '../pages/components_a/radio_page.dart';
import '../pages/components_a/rate_page.dart';
import '../pages/components_a/lazy_load_page.dart';
import '../pages/components_a/sticky_page.dart';
import '../pages/components_a/swipe_action_page.dart';
import '../pages/components_a/test_list_page.dart';
import '../pages/components_a/button_page.dart';
import '../pages/components_a/transition_page.dart';
import '../pages/components_b/dropdown_page.dart';
import '../pages/components_b/action_sheet_page.dart';
import '../pages/components_b/parse_jump_page.dart';
import '../pages/components_b/parse_page.dart';
import '../pages/components_b/toast_page.dart';
import '../pages/components_b/keyboard_page.dart';
import '../pages/components_b/slider_page.dart';
import '../pages/components_b/upload_page.dart';
import '../pages/components_b/notify_page.dart';
import '../pages/components_b/count_down_page.dart';
import '../pages/components_b/color_page.dart';
import '../pages/components_b/number_box_page.dart';
import '../pages/components_b/count_to_page.dart';
import '../pages/components_b/search_page.dart';
import '../pages/components_b/badge_page.dart';
import '../pages/components_b/tag_page.dart';
import '../pages/components_b/alert_page.dart';
import '../pages/components_b/switch_page.dart';
import '../pages/components_b/collapse_page.dart';
import '../pages/components_b/code_page.dart';
import '../pages/components_b/notice_bar_page.dart';
import '../pages/components_b/progress_page.dart';
import '../pages/components_b/tabbar_page.dart';
import '../pages/components_b/tabbar2_page.dart';
import '../pages/components_b/waterfall_page.dart';
import '../pages/components_b/card_page.dart';
import '../pages/components_b/table_page.dart';
import '../pages/components_b/table2_page.dart';
import '../pages/components_c/form_page.dart';
import '../pages/components_c/album_page.dart';
import '../pages/components_c/input_page.dart';
import '../pages/components_c/loadmore_page.dart';
import '../pages/components_c/navbar_page.dart';
import '../pages/components_c/navbar_ios_page.dart';
import '../pages/components_c/no_network_page.dart';
import '../pages/components_c/skeleton_page.dart';
import '../pages/components_c/steps_page.dart';
import '../pages/components_c/text_page.dart';
import '../pages/components_c/textarea_page.dart';
import '../pages/components_c/avatar_page.dart';
import '../pages/components_c/read_more_page.dart';
import '../pages/components_c/layout_page.dart';
import '../pages/components_c/index_list_page.dart';
import '../pages/components_c/index_list2_page.dart';
import '../pages/components_c/tooltip_page.dart';
import '../pages/components_c/guide_page.dart';
import '../pages/components_c/popover_page.dart';
import '../pages/components_c/tabs_page.dart';
import '../pages/components_c/list_page.dart';
import '../pages/components_c/swiper_page.dart';
import '../pages/components_c/scroll_list_page.dart';
import '../pages/components_c/code_input_page.dart';
import '../pages/components_c/calendar_page.dart';
import '../pages/components_c/datetime_picker_page.dart';
import '../pages/components_c/modal_page.dart';
import '../pages/components_c/picker_page.dart';
import '../pages/components_c/subsection_page.dart';
import '../pages/components_d/barcode_page.dart';
import '../pages/components_d/box_page.dart';
import '../pages/components_d/novel_reader_page.dart';
import '../pages/components_d/cate_tab_page.dart';
import '../pages/components_d/city_locate_page.dart';
import '../pages/components_d/copy_page.dart';
import '../pages/components_d/dragsort_page.dart';
import '../pages/components_d/float_button_page.dart';
import '../pages/components_d/navbar_mini_page.dart';
import '../pages/components_d/pagination_page.dart';
import '../pages/components_d/pull_refresh_page.dart';
import '../pages/components_d/qrcode_page.dart';
import '../pages/components_d/select_page.dart';
import '../pages/components_d/title_page.dart';
import '../pages/components_d/tree_page.dart';
import '../pages/components_d/root_toast_host_page.dart';
import '../pages/components_d/tabs_pro_page.dart';
import '../pages/components_d/cascader_page.dart';
import '../pages/components_d/choose_page.dart';
import '../pages/components_d/signature_page.dart';
import '../pages/components_d/agreement_page.dart';
import '../pages/components_d/short_video_page.dart';
import '../pages/components_d/markdown_page.dart';
import '../pages/components_d/cropper_page.dart';
import '../pages/components_d/coupon_page.dart';
import '../pages/components_d/color_picker_page.dart';
import '../pages/components_d/poster_page.dart';
import '../pages/components_d/goods_sku_page.dart';
import '../pages/components_d/pdf_reader_page.dart';
import '../pages/template/submit_bar_page.dart';
import '../pages/template/wx_center_page.dart';
import '../pages/template/keyboard_pay_page.dart';
import '../pages/template/login_page.dart';
import '../pages/template/login_code_page.dart';
import '../pages/template/address_page.dart';
import '../pages/template/add_site_page.dart';
import '../pages/components_d/virtual_list_page.dart';
import 'example_route.dart';

const List<String> componentARouteIds = <String>[
  'componentsA/transition/transition',
  'componentsA/test/test',
  'componentsA/icon/icon',
  'componentsA/cell/cell',
  'componentsA/line/line',
  'componentsA/image/image',
  'componentsA/link/link',
  'componentsA/button/button',
  'componentsA/loading-icon/loading-icon',
  'componentsA/overlay/overlay',
  'componentsA/loading-page/loading-page',
  'componentsA/popup/popup',
  'componentsA/swipeAction/swipeAction',
  'componentsA/sticky/sticky',
  'componentsA/radio/radio',
  'componentsA/checkbox/checkbox',
  'componentsA/empty/empty',
  'componentsA/backtop/backtop',
  'componentsA/divider/divider',
  'componentsA/rate/rate',
  'componentsA/gap/gap',
  'componentsA/grid/grid',
  'componentsA/lazyLoad/lazyLoad',
];

final List<ExampleRoute> exampleRoutes = <ExampleRoute>[
  const ExampleRoute(
    id: 'example/components',
    sourcePath: 'pages/example/components',
    title: 'uview-plus',
    group: ExampleRouteGroup.main,
    builder: _buildComponentsHome,
  ),
  const ExampleRoute(
    id: 'example/template',
    sourcePath: 'pages/example/template',
    title: '模板',
    group: ExampleRouteGroup.main,
    builder: _buildTemplatesHome,
  ),
  const ExampleRoute(
    id: 'example/mine',
    sourcePath: 'pages/example/mine',
    title: '我的',
    group: ExampleRouteGroup.main,
    builder: _buildMine,
  ),
  const ExampleRoute(
    id: 'example/ad',
    sourcePath: 'pages/example/ad',
    title: '广告',
    group: ExampleRouteGroup.main,
    builder: _buildAd,
  ),
  const ExampleRoute(
    id: 'componentsA/transition/transition',
    sourcePath: 'pages/componentsA/transition/transition',
    title: '过渡动画',
    group: ExampleRouteGroup.componentsA,
    builder: _buildTransition,
  ),
  const ExampleRoute(
    id: 'componentsA/test/test',
    sourcePath: 'pages/componentsA/test/test',
    title: '测试',
    group: ExampleRouteGroup.componentsA,
    builder: _buildTestList,
  ),
  const ExampleRoute(
    id: 'componentsA/icon/icon',
    sourcePath: 'pages/componentsA/icon/icon',
    title: '图标',
    group: ExampleRouteGroup.componentsA,
    builder: _buildIcon,
  ),
  const ExampleRoute(
    id: 'componentsA/cell/cell',
    sourcePath: 'pages/componentsA/cell/cell',
    title: '单元格',
    group: ExampleRouteGroup.componentsA,
    builder: _buildCell,
  ),
  const ExampleRoute(
    id: 'componentsA/line/line',
    sourcePath: 'pages/componentsA/line/line',
    title: '线条',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLine,
  ),
  const ExampleRoute(
    id: 'componentsA/image/image',
    sourcePath: 'pages/componentsA/image/image',
    title: '图片',
    group: ExampleRouteGroup.componentsA,
    builder: _buildImage,
  ),
  const ExampleRoute(
    id: 'componentsA/link/link',
    sourcePath: 'pages/componentsA/link/link',
    title: '超链接',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLink,
  ),
  const ExampleRoute(
    id: 'componentsA/button/button',
    sourcePath: 'pages/componentsA/button/button',
    title: '按钮',
    group: ExampleRouteGroup.componentsA,
    builder: _buildButton,
  ),
  const ExampleRoute(
    id: 'componentsA/loading-icon/loading-icon',
    sourcePath: 'pages/componentsA/loading-icon/loading-icon',
    title: '加载中图标',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLoadingIcon,
  ),
  const ExampleRoute(
    id: 'componentsA/overlay/overlay',
    sourcePath: 'pages/componentsA/overlay/overlay',
    title: '遮罩层',
    group: ExampleRouteGroup.componentsA,
    builder: _buildOverlay,
  ),
  const ExampleRoute(
    id: 'componentsA/loading-page/loading-page',
    sourcePath: 'pages/componentsA/loading-page/loading-page',
    title: '加载页',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLoadingPage,
  ),
  const ExampleRoute(
    id: 'componentsA/popup/popup',
    sourcePath: 'pages/componentsA/popup/popup',
    title: '弹窗',
    group: ExampleRouteGroup.componentsA,
    builder: _buildPopup,
  ),
  const ExampleRoute(
    id: 'componentsA/swipeAction/swipeAction',
    sourcePath: 'pages/componentsA/swipeAction/swipeAction',
    title: '滑动单元格',
    group: ExampleRouteGroup.componentsA,
    builder: _buildSwipeAction,
  ),
  const ExampleRoute(
    id: 'componentsA/sticky/sticky',
    sourcePath: 'pages/componentsA/sticky/sticky',
    title: '吸顶',
    group: ExampleRouteGroup.componentsA,
    builder: _buildSticky,
  ),
  const ExampleRoute(
    id: 'componentsA/radio/radio',
    sourcePath: 'pages/componentsA/radio/radio',
    title: '单选框',
    group: ExampleRouteGroup.componentsA,
    builder: _buildRadio,
  ),
  const ExampleRoute(
    id: 'componentsA/checkbox/checkbox',
    sourcePath: 'pages/componentsA/checkbox/checkbox',
    title: '复选框',
    group: ExampleRouteGroup.componentsA,
    builder: _buildCheckbox,
  ),
  const ExampleRoute(
    id: 'componentsA/empty/empty',
    sourcePath: 'pages/componentsA/empty/empty',
    title: '内容为空',
    group: ExampleRouteGroup.componentsA,
    builder: _buildEmpty,
  ),
  const ExampleRoute(
    id: 'componentsA/backtop/backtop',
    sourcePath: 'pages/componentsA/backtop/backtop',
    title: '返回顶部',
    group: ExampleRouteGroup.componentsA,
    builder: _buildBackTop,
  ),
  const ExampleRoute(
    id: 'componentsA/divider/divider',
    sourcePath: 'pages/componentsA/divider/divider',
    title: '分割线',
    group: ExampleRouteGroup.componentsA,
    builder: _buildDivider,
  ),
  const ExampleRoute(
    id: 'componentsA/rate/rate',
    sourcePath: 'pages/componentsA/rate/rate',
    title: '评分',
    group: ExampleRouteGroup.componentsA,
    builder: _buildRate,
  ),
  const ExampleRoute(
    id: 'componentsA/gap/gap',
    sourcePath: 'pages/componentsA/gap/gap',
    title: '间隔槽',
    group: ExampleRouteGroup.componentsA,
    builder: _buildGap,
  ),
  const ExampleRoute(
    id: 'componentsA/grid/grid',
    sourcePath: 'pages/componentsA/grid/grid',
    title: '宫格',
    group: ExampleRouteGroup.componentsA,
    builder: _buildGrid,
  ),
  const ExampleRoute(
    id: 'componentsA/lazyLoad/lazyLoad',
    sourcePath: 'pages/componentsA/lazyLoad/lazyLoad',
    title: '懒加载',
    group: ExampleRouteGroup.componentsA,
    builder: _buildLazyLoad,
  ),
  const ExampleRoute(
    id: 'componentsB/dropdown/dropdown',
    sourcePath: 'pages/componentsB/dropdown/dropdown',
    title: '下拉菜单',
    group: ExampleRouteGroup.componentsB,
    builder: _buildDropdown,
  ),
  const ExampleRoute(
    id: 'componentsB/actionSheet/actionSheet',
    sourcePath: 'pages/componentsB/actionSheet/actionSheet',
    title: '上拉菜单',
    group: ExampleRouteGroup.componentsB,
    builder: _buildActionSheet,
  ),
  const ExampleRoute(
    id: 'componentsB/parse/parse',
    sourcePath: 'pages/componentsB/parse/parse',
    title: '富文本解析器',
    group: ExampleRouteGroup.componentsB,
    builder: _buildParse,
  ),
  const ExampleRoute(
    id: 'componentsB/parse/jump',
    sourcePath: 'pages/componentsB/parse/jump',
    title: '内部链接',
    group: ExampleRouteGroup.componentsB,
    builder: _buildParseJump,
  ),
  const ExampleRoute(
    id: 'componentsB/toast/toast',
    sourcePath: 'pages/componentsB/toast/toast',
    title: '提示消息',
    group: ExampleRouteGroup.componentsB,
    builder: _buildToast,
  ),
  const ExampleRoute(
    id: 'componentsB/keyboard/keyboard',
    sourcePath: 'pages/componentsB/keyboard/keyboard',
    title: '键盘',
    group: ExampleRouteGroup.componentsB,
    builder: _buildKeyboard,
  ),
  const ExampleRoute(
    id: 'componentsB/slider/slider',
    sourcePath: 'pages/componentsB/slider/slider',
    title: '滑动选择器',
    group: ExampleRouteGroup.componentsB,
    builder: _buildSlider,
  ),
  const ExampleRoute(
    id: 'componentsB/upload/upload',
    sourcePath: 'pages/componentsB/upload/upload',
    title: '上传',
    group: ExampleRouteGroup.componentsB,
    builder: _buildUpload,
  ),
  const ExampleRoute(
    id: 'componentsB/notify/notify',
    sourcePath: 'pages/componentsB/notify/notify',
    title: '消息提示',
    group: ExampleRouteGroup.componentsB,
    builder: _buildNotify,
  ),
  const ExampleRoute(
    id: 'componentsB/countDown/countDown',
    sourcePath: 'pages/componentsB/countDown/countDown',
    title: '倒计时',
    group: ExampleRouteGroup.componentsB,
    builder: _buildCountDown,
  ),
  const ExampleRoute(
    id: 'componentsB/color/color',
    sourcePath: 'pages/componentsB/color/color',
    title: '色彩',
    group: ExampleRouteGroup.componentsB,
    builder: _buildColor,
  ),
  const ExampleRoute(
    id: 'componentsB/numberBox/numberBox',
    sourcePath: 'pages/componentsB/numberBox/numberBox',
    title: '步进器',
    group: ExampleRouteGroup.componentsB,
    builder: _buildNumberBox,
  ),
  const ExampleRoute(
    id: 'componentsB/countTo/countTo',
    sourcePath: 'pages/componentsB/countTo/countTo',
    title: '数字滚动',
    group: ExampleRouteGroup.componentsB,
    builder: _buildCountTo,
  ),
  const ExampleRoute(
    id: 'componentsB/search/search',
    sourcePath: 'pages/componentsB/search/search',
    title: '搜索',
    group: ExampleRouteGroup.componentsB,
    builder: _buildSearch,
  ),
  const ExampleRoute(
    id: 'componentsB/badge/badge',
    sourcePath: 'pages/componentsB/badge/badge',
    title: '徽标数',
    group: ExampleRouteGroup.componentsB,
    builder: _buildBadge,
  ),
  const ExampleRoute(
    id: 'componentsB/tag/tag',
    sourcePath: 'pages/componentsB/tag/tag',
    title: '标签',
    group: ExampleRouteGroup.componentsB,
    builder: _buildTag,
  ),
  const ExampleRoute(
    id: 'componentsB/alert/alert',
    sourcePath: 'pages/componentsB/alert/alert',
    title: '警告',
    group: ExampleRouteGroup.componentsB,
    builder: _buildAlert,
  ),
  const ExampleRoute(
    id: 'componentsB/switch/switch',
    sourcePath: 'pages/componentsB/switch/switch',
    title: '开关',
    group: ExampleRouteGroup.componentsB,
    builder: _buildSwitch,
  ),
  const ExampleRoute(
    id: 'componentsB/collapse/collapse',
    sourcePath: 'pages/componentsB/collapse/collapse',
    title: '折叠面板',
    group: ExampleRouteGroup.componentsB,
    builder: _buildCollapse,
  ),
  const ExampleRoute(
    id: 'componentsB/code/code',
    sourcePath: 'pages/componentsB/code/code',
    title: '验证码',
    group: ExampleRouteGroup.componentsB,
    builder: _buildCode,
  ),
  const ExampleRoute(
    id: 'componentsB/noticeBar/noticeBar',
    sourcePath: 'pages/componentsB/noticeBar/noticeBar',
    title: '滚动通知',
    group: ExampleRouteGroup.componentsB,
    builder: _buildNoticeBar,
  ),
  const ExampleRoute(
    id: 'componentsB/progress/progress',
    sourcePath: 'pages/componentsB/progress/progress',
    title: '进度条',
    group: ExampleRouteGroup.componentsB,
    builder: _buildProgress,
  ),
  const ExampleRoute(
    id: 'componentsB/tabbar/tabbar',
    sourcePath: 'pages/componentsB/tabbar/tabbar',
    title: 'Tabbar',
    group: ExampleRouteGroup.componentsB,
    builder: _buildTabbar,
  ),
  const ExampleRoute(
    id: 'componentsB/tabbar/tabbar2',
    sourcePath: 'pages/componentsB/tabbar/tabbar2',
    title: 'Tabbar-vue',
    group: ExampleRouteGroup.componentsB,
    builder: _buildTabbar2,
  ),
  const ExampleRoute(
    id: 'componentsB/waterfall/waterfall',
    sourcePath: 'pages/componentsB/waterfall/waterfall',
    title: '瀑布流',
    group: ExampleRouteGroup.componentsB,
    builder: _buildWaterfall,
  ),
  const ExampleRoute(
    id: 'componentsB/card/card',
    sourcePath: 'pages/componentsB/card/card',
    title: '卡片',
    group: ExampleRouteGroup.componentsB,
    builder: _buildCard,
  ),
  const ExampleRoute(
    id: 'componentsB/table/table',
    sourcePath: 'pages/componentsB/table/table',
    title: '表格',
    group: ExampleRouteGroup.componentsB,
    builder: _buildTable,
  ),
  const ExampleRoute(
    id: 'componentsB/table2/table2',
    sourcePath: 'pages/componentsB/table2/table2',
    title: '表格2',
    group: ExampleRouteGroup.componentsB,
    builder: _buildTable2,
  ),
  const ExampleRoute(
    id: 'componentsC/form/form',
    sourcePath: 'pages/componentsC/form/form',
    title: '表单',
    group: ExampleRouteGroup.componentsC,
    builder: _buildForm,
  ),
  const ExampleRoute(
    id: 'componentsC/textarea/textarea',
    sourcePath: 'pages/componentsC/textarea/textarea',
    title: '文本域',
    group: ExampleRouteGroup.componentsC,
    builder: _buildTextarea,
  ),
  const ExampleRoute(
    id: 'componentsC/noNetwork/noNetwork',
    sourcePath: 'pages/componentsC/noNetwork/noNetwork',
    title: '无网络提示',
    group: ExampleRouteGroup.componentsC,
    builder: _buildNoNetwork,
  ),
  const ExampleRoute(
    id: 'componentsC/loadmore/loadmore',
    sourcePath: 'pages/componentsC/loadmore/loadmore',
    title: '加载更多',
    group: ExampleRouteGroup.componentsC,
    builder: _buildLoadmore,
  ),
  const ExampleRoute(
    id: 'componentsC/text/text',
    sourcePath: 'pages/componentsC/text/text',
    title: '文本',
    group: ExampleRouteGroup.componentsC,
    builder: _buildText,
  ),
  const ExampleRoute(
    id: 'componentsC/steps/steps',
    sourcePath: 'pages/componentsC/steps/steps',
    title: '步骤条',
    group: ExampleRouteGroup.componentsC,
    builder: _buildSteps,
  ),
  const ExampleRoute(
    id: 'componentsC/navbar/navbar',
    sourcePath: 'pages/componentsC/navbar/navbar',
    title: '导航栏',
    group: ExampleRouteGroup.componentsC,
    builder: _buildNavbar,
  ),
  const ExampleRoute(
    id: 'componentsC/navbarIos/navbarIos',
    sourcePath: 'pages/componentsC/navbarIos/navbarIos',
    title: 'iOS 大标题',
    group: ExampleRouteGroup.componentsC,
    builder: _buildNavbarIos,
  ),
  const ExampleRoute(
    id: 'componentsC/skeleton/skeleton',
    sourcePath: 'pages/componentsC/skeleton/skeleton',
    title: '骨架屏',
    group: ExampleRouteGroup.componentsC,
    builder: _buildSkeleton,
  ),
  const ExampleRoute(
    id: 'componentsC/input/input',
    sourcePath: 'pages/componentsC/input/input',
    title: '输入框',
    group: ExampleRouteGroup.componentsC,
    builder: _buildInput,
  ),
  const ExampleRoute(
    id: 'componentsC/album/album',
    sourcePath: 'pages/componentsC/album/album',
    title: '相册',
    group: ExampleRouteGroup.componentsC,
    builder: _buildAlbum,
  ),
  const ExampleRoute(
    id: 'componentsC/avatar/avatar',
    sourcePath: 'pages/componentsC/avatar/avatar',
    title: '头像',
    group: ExampleRouteGroup.componentsC,
    builder: _buildAvatar,
  ),
  const ExampleRoute(
    id: 'componentsC/readMore/readMore',
    sourcePath: 'pages/componentsC/readMore/readMore',
    title: '阅读更多',
    group: ExampleRouteGroup.componentsC,
    builder: _buildReadMore,
  ),
  const ExampleRoute(
    id: 'componentsC/layout/layout',
    sourcePath: 'pages/componentsC/layout/layout',
    title: '布局',
    group: ExampleRouteGroup.componentsC,
    builder: _buildLayout,
  ),
  const ExampleRoute(
    id: 'componentsC/indexList/indexList',
    sourcePath: 'pages/componentsC/indexList/indexList',
    title: '索引列表',
    group: ExampleRouteGroup.componentsC,
    builder: _buildIndexList,
  ),
  const ExampleRoute(
    id: 'componentsC/indexList/indexList2',
    sourcePath: 'pages/componentsC/indexList/indexList2',
    title: '索引列表(弹窗)',
    group: ExampleRouteGroup.componentsC,
    builder: _buildIndexList2,
  ),
  const ExampleRoute(
    id: 'componentsC/tooltip/tooltip',
    sourcePath: 'pages/componentsC/tooltip/tooltip',
    title: '长按提示',
    group: ExampleRouteGroup.componentsC,
    builder: _buildTooltip,
  ),
  const ExampleRoute(
    id: 'componentsC/guide/guide',
    sourcePath: 'pages/componentsC/guide/guide',
    title: '首屏引导',
    group: ExampleRouteGroup.componentsC,
    builder: _buildGuide,
  ),
  const ExampleRoute(
    id: 'componentsC/popover/popover',
    sourcePath: 'pages/componentsC/popover/popover',
    title: 'Popover弹窗',
    group: ExampleRouteGroup.componentsC,
    builder: _buildPopover,
  ),
  const ExampleRoute(
    id: 'componentsC/tabs/tabs',
    sourcePath: 'pages/componentsC/tabs/tabs',
    title: '标签',
    group: ExampleRouteGroup.componentsC,
    builder: _buildTabs,
  ),
  const ExampleRoute(
    id: 'componentsC/list/list',
    sourcePath: 'pages/componentsC/list/list',
    title: '列表',
    group: ExampleRouteGroup.componentsC,
    builder: _buildList,
  ),
  const ExampleRoute(
    id: 'componentsC/swiper/swiper',
    sourcePath: 'pages/componentsC/swiper/swiper',
    title: '轮播',
    group: ExampleRouteGroup.componentsC,
    builder: _buildSwiper,
  ),
  const ExampleRoute(
    id: 'componentsC/scrollList/scrollList',
    sourcePath: 'pages/componentsC/scrollList/scrollList',
    title: '横向滚动列表',
    group: ExampleRouteGroup.componentsC,
    builder: _buildScrollList,
  ),
  const ExampleRoute(
    id: 'componentsC/codeInput/codeInput',
    sourcePath: 'pages/componentsC/codeInput/codeInput',
    title: '验证码输入',
    group: ExampleRouteGroup.componentsC,
    builder: _buildCodeInput,
  ),
  const ExampleRoute(
    id: 'componentsC/modal/modal',
    sourcePath: 'pages/componentsC/modal/modal',
    title: '模态框',
    group: ExampleRouteGroup.componentsC,
    builder: _buildModal,
  ),
  const ExampleRoute(
    id: 'componentsC/picker/picker',
    sourcePath: 'pages/componentsC/picker/picker',
    title: '选择器',
    group: ExampleRouteGroup.componentsC,
    builder: _buildPicker,
  ),
  const ExampleRoute(
    id: 'componentsC/calendar/calendar',
    sourcePath: 'pages/componentsC/calendar/calendar',
    title: '日历',
    group: ExampleRouteGroup.componentsC,
    builder: _buildCalendar,
  ),
  const ExampleRoute(
    id: 'componentsC/datetimePicker/datetimePicker',
    sourcePath: 'pages/componentsC/datetimePicker/datetimePicker',
    title: '时间选择',
    group: ExampleRouteGroup.componentsC,
    builder: _buildDatetimePicker,
  ),
  const ExampleRoute(
    id: 'componentsC/subsection/subsection',
    sourcePath: 'pages/componentsC/subsection/subsection',
    title: '分段器',
    group: ExampleRouteGroup.componentsC,
    builder: _buildSubsection,
  ),
  const ExampleRoute(
    id: 'componentsD/qrcode/qrcode',
    sourcePath: 'pages/componentsD/qrcode/qrcode',
    title: '二维码',
    group: ExampleRouteGroup.componentsD,
    builder: _buildQrcode,
  ),
  const ExampleRoute(
    id: 'componentsD/copy/copy',
    sourcePath: 'pages/componentsD/copy/copy',
    title: '复制',
    group: ExampleRouteGroup.componentsD,
    builder: _buildCopy,
  ),
  const ExampleRoute(
    id: 'componentsD/navbarMini/navbarMini',
    sourcePath: 'pages/componentsD/navbarMini/navbarMini',
    title: '迷你导航栏',
    group: ExampleRouteGroup.componentsD,
    builder: _buildNavbarMini,
  ),
  const ExampleRoute(
    id: 'componentsD/box/box',
    sourcePath: 'pages/componentsD/box/box',
    title: '盒子',
    group: ExampleRouteGroup.componentsD,
    builder: _buildBox,
  ),
  const ExampleRoute(
    id: 'componentsD/floatButton/floatButton',
    sourcePath: 'pages/componentsD/floatButton/floatButton',
    title: '悬浮按钮',
    group: ExampleRouteGroup.componentsD,
    builder: _buildFloatButton,
  ),
  const ExampleRoute(
    id: 'componentsD/cateTab/cateTab',
    sourcePath: 'pages/componentsD/cateTab/cateTab',
    title: '垂直TAB',
    group: ExampleRouteGroup.componentsD,
    builder: _buildCateTab,
  ),
  const ExampleRoute(
    id: 'componentsD/select/select',
    sourcePath: 'pages/componentsD/select/select',
    title: '经典下拉框',
    group: ExampleRouteGroup.componentsD,
    builder: _buildSelect,
  ),
  const ExampleRoute(
    id: 'componentsD/pagination/pagination',
    sourcePath: 'pages/componentsD/pagination/pagination',
    title: '分页器',
    group: ExampleRouteGroup.componentsD,
    builder: _buildPagination,
  ),
  const ExampleRoute(
    id: 'componentsD/tree/tree',
    sourcePath: 'pages/componentsD/tree/tree',
    title: '树形',
    group: ExampleRouteGroup.componentsD,
    builder: _buildTree,
  ),
  const ExampleRoute(
    id: 'componentsD/dragsort/dragsort',
    sourcePath: 'pages/componentsD/dragsort/dragsort',
    title: '拖动排序',
    group: ExampleRouteGroup.componentsD,
    builder: _buildDragsort,
  ),
  const ExampleRoute(
    id: 'componentsD/cityLocate/cityLocate',
    sourcePath: 'pages/componentsD/cityLocate/cityLocate',
    title: '城市定位',
    group: ExampleRouteGroup.componentsD,
    builder: _buildCityLocate,
  ),
  const ExampleRoute(
    id: 'componentsD/title/title',
    sourcePath: 'pages/componentsD/title/title',
    title: '标题',
    group: ExampleRouteGroup.componentsD,
    builder: _buildTitle,
  ),
  const ExampleRoute(
    id: 'componentsD/pullRefresh/pullRefresh',
    sourcePath: 'pages/componentsD/pullRefresh/pullRefresh',
    title: '下拉刷新',
    group: ExampleRouteGroup.componentsD,
    builder: _buildPullRefresh,
  ),
  const ExampleRoute(
    id: 'componentsD/virtualList/virtualList',
    sourcePath: 'pages/componentsD/virtualList/virtualList',
    title: '虚拟列表',
    group: ExampleRouteGroup.componentsD,
    builder: _buildVirtualList,
  ),
  const ExampleRoute(
    id: 'componentsD/barcode/barcode',
    sourcePath: 'pages/componentsD/barcode/barcode',
    title: '条码',
    group: ExampleRouteGroup.componentsD,
    builder: _buildBarcode,
  ),
  const ExampleRoute(
    id: 'componentsD/tabsPro/tabsPro',
    sourcePath: 'pages/componentsD/tabsPro/tabsPro',
    title: '增强标签',
    group: ExampleRouteGroup.componentsD,
    builder: _buildTabsPro,
  ),
  const ExampleRoute(
    id: 'componentsD/rootToastHost/rootToastHost',
    sourcePath: 'pages/componentsD/rootToastHost/rootToastHost',
    title: '全局提示宿主',
    group: ExampleRouteGroup.componentsD,
    builder: _buildRootToastHost,
  ),
  const ExampleRoute(
    id: 'componentsD/novelReader/novelReader',
    sourcePath: 'pages/componentsD/novelReader/novelReader',
    title: '小说阅读器',
    group: ExampleRouteGroup.componentsD,
    builder: _buildNovelReader,
  ),
  const ExampleRoute(
    id: 'componentsD/cascader/cascader',
    sourcePath: 'pages/componentsD/cascader/cascader',
    title: '级联选择器',
    group: ExampleRouteGroup.componentsD,
    builder: _buildCascader,
  ),
  const ExampleRoute(
    id: 'componentsD/choose/choose',
    sourcePath: 'pages/componentsD/choose/choose',
    title: '选项选择器',
    group: ExampleRouteGroup.componentsD,
    builder: _buildChoose,
  ),
  const ExampleRoute(
    id: 'componentsD/signature/signature',
    sourcePath: 'pages/componentsD/signature/signature',
    title: '签名',
    group: ExampleRouteGroup.componentsD,
    builder: _buildSignature,
  ),
  const ExampleRoute(
    id: 'componentsD/agreement/agreement',
    sourcePath: 'pages/componentsD/agreement/agreement',
    title: '协议',
    group: ExampleRouteGroup.componentsD,
    builder: _buildAgreement,
  ),
  const ExampleRoute(
    id: 'componentsD/shortVideo/shortVideo',
    sourcePath: 'pages/componentsD/shortVideo/shortVideo',
    title: '短视频',
    group: ExampleRouteGroup.componentsD,
    builder: _buildShortVideo,
  ),
  const ExampleRoute(
    id: 'componentsD/markdown/markdown',
    sourcePath: 'pages/componentsD/markdown/markdown',
    title: 'Markdown',
    group: ExampleRouteGroup.componentsD,
    builder: _buildMarkdown,
  ),
  const ExampleRoute(
    id: 'componentsD/cropper/cropper',
    sourcePath: 'pages/componentsD/cropper/cropper',
    title: '图片裁剪',
    group: ExampleRouteGroup.componentsD,
    builder: _buildCropper,
  ),
  const ExampleRoute(
    id: 'componentsD/coupon/coupon',
    sourcePath: 'pages/componentsD/coupon/coupon',
    title: '优惠券',
    group: ExampleRouteGroup.componentsD,
    builder: _buildCoupon,
  ),
  const ExampleRoute(
    id: 'componentsD/colorPicker/colorPicker',
    sourcePath: 'pages/componentsD/colorPicker/colorPicker',
    title: '颜色选择器',
    group: ExampleRouteGroup.componentsD,
    builder: _buildColorPicker,
  ),
  const ExampleRoute(
    id: 'componentsD/poster/poster',
    sourcePath: 'pages/componentsD/poster/poster',
    title: '海报',
    group: ExampleRouteGroup.componentsD,
    builder: _buildPoster,
  ),
  const ExampleRoute(
    id: 'componentsD/goodsSku/goodsSku',
    sourcePath: 'pages/componentsD/goodsSku/goodsSku',
    title: '商品SKU',
    group: ExampleRouteGroup.componentsD,
    builder: _buildGoodsSku,
  ),
  const ExampleRoute(
    id: 'componentsD/pdfReader/pdfReader',
    sourcePath: 'pages/componentsD/pdfReader/pdfReader',
    title: 'PDF阅读器',
    group: ExampleRouteGroup.componentsD,
    builder: _buildPdfReader,
  ),
  const ExampleRoute(
    id: 'template/submitBar/index',
    sourcePath: 'pages/template/submitBar/index',
    title: '提交订单栏',
    group: ExampleRouteGroup.template,
    builder: _buildSubmitBar,
  ),
  const ExampleRoute(
    id: 'template/wxCenter/index',
    sourcePath: 'pages/template/wxCenter/index',
    title: '仿微信个人中心',
    group: ExampleRouteGroup.template,
    builder: _buildWxCenter,
  ),
  const ExampleRoute(
    id: 'template/keyboardPay/index',
    sourcePath: 'pages/template/keyboardPay/index',
    title: '自定义键盘支付',
    group: ExampleRouteGroup.template,
    builder: _buildKeyboardPay,
  ),
  const ExampleRoute(
    id: 'template/login/index',
    sourcePath: 'pages/template/login/index',
    title: '登录',
    group: ExampleRouteGroup.template,
    builder: _buildLogin,
  ),
  const ExampleRoute(
    id: 'template/login/code',
    sourcePath: 'pages/template/login/code',
    title: '验证码',
    group: ExampleRouteGroup.template,
    builder: _buildLoginCode,
  ),
  const ExampleRoute(
    id: 'template/address/index',
    sourcePath: 'pages/template/address/index',
    title: '收货地址',
    group: ExampleRouteGroup.template,
    builder: _buildAddress,
  ),
  const ExampleRoute(
    id: 'template/address/addSite',
    sourcePath: 'pages/template/address/addSite',
    title: '新建收货地址',
    group: ExampleRouteGroup.template,
    builder: _buildAddSite,
  ),
];

Widget _buildTabsPro(BuildContext context) => const TabsProPage();
Widget _buildRootToastHost(BuildContext context) => const RootToastHostPage();
Widget _buildNovelReader(BuildContext context) => const NovelReaderPage();
Widget _buildNavbarIos(BuildContext context) => const NavbarIosPage();
Widget _buildSubmitBar(BuildContext context) => const SubmitBarPage();
Widget _buildWxCenter(BuildContext context) => const WxCenterPage();
Widget _buildKeyboardPay(BuildContext context) => const KeyboardPayPage();
Widget _buildLogin(BuildContext context) => const LoginPage();
Widget _buildLoginCode(BuildContext context) => const LoginCodePage();
Widget _buildAddress(BuildContext context) => const AddressPage();
Widget _buildAddSite(BuildContext context) => const AddSitePage();
Widget _buildCascader(BuildContext context) => const CascaderPage();
Widget _buildChoose(BuildContext context) => const ChoosePage();
Widget _buildSignature(BuildContext context) => const SignaturePage();
Widget _buildAgreement(BuildContext context) => const AgreementPage();
Widget _buildShortVideo(BuildContext context) => const ShortVideoPage();
Widget _buildMarkdown(BuildContext context) => const MarkdownPage();
Widget _buildCropper(BuildContext context) => const CropperPage();
Widget _buildCoupon(BuildContext context) => const CouponPage();
Widget _buildColorPicker(BuildContext context) => const ColorPickerPage();
Widget _buildPoster(BuildContext context) => const PosterPage();
Widget _buildGoodsSku(BuildContext context) => const GoodsSkuPage();
Widget _buildPdfReader(BuildContext context) => const PdfReaderPage();
Widget _buildComponentsHome(BuildContext context) => const ComponentsHomePage();
Widget _buildTemplatesHome(BuildContext context) => const TemplatesHomePage();
Widget _buildMine(BuildContext context) => const MinePage();
Widget _buildAd(BuildContext context) => const AdPage();
Widget _buildIcon(BuildContext context) => const IconPage();
Widget _buildCell(BuildContext context) => const CellPage();
Widget _buildLine(BuildContext context) => const LinePage();
Widget _buildImage(BuildContext context) => const ImagePage();
Widget _buildButton(BuildContext context) => const ButtonPage();
Widget _buildLink(BuildContext context) => const LinkPage();
Widget _buildLoadingIcon(BuildContext context) => const LoadingIconPage();
Widget _buildDivider(BuildContext context) => const DividerPage();
Widget _buildEmpty(BuildContext context) => const EmptyPage();
Widget _buildGap(BuildContext context) => const GapPage();
Widget _buildGrid(BuildContext context) => const GridPage();
Widget _buildRadio(BuildContext context) => const RadioPage();
Widget _buildCheckbox(BuildContext context) => const CheckboxPage();
Widget _buildRate(BuildContext context) => const RatePage();
Widget _buildTransition(BuildContext context) => const TransitionPage();
Widget _buildOverlay(BuildContext context) => const OverlayPage();
Widget _buildLoadingPage(BuildContext context) => const LoadingPagePage();
Widget _buildPopup(BuildContext context) => const PopupPage();
Widget _buildSwipeAction(BuildContext context) => const SwipeActionPage();
Widget _buildSticky(BuildContext context) => const StickyPage();
Widget _buildBackTop(BuildContext context) => const BackTopPage();
Widget _buildLazyLoad(BuildContext context) => const LazyLoadPage();
Widget _buildTestList(BuildContext context) => const TestListPage();
Widget _buildDropdown(BuildContext context) => const DropdownPage();
Widget _buildActionSheet(BuildContext context) => const ActionSheetPage();
Widget _buildParse(BuildContext context) => const ParsePage();
Widget _buildParseJump(BuildContext context) => const ParseJumpPage();
Widget _buildToast(BuildContext context) => const ToastPage();
Widget _buildKeyboard(BuildContext context) => const KeyboardPage();
Widget _buildSlider(BuildContext context) => const SliderPage();
Widget _buildUpload(BuildContext context) => const UploadPage();
Widget _buildNotify(BuildContext context) => const NotifyPage();
Widget _buildCountDown(BuildContext context) => const CountDownPage();
Widget _buildColor(BuildContext context) => const ColorPage();
Widget _buildNumberBox(BuildContext context) => const NumberBoxPage();
Widget _buildCountTo(BuildContext context) => const CountToPage();
Widget _buildSearch(BuildContext context) => const SearchPage();
Widget _buildBadge(BuildContext context) => const BadgePage();
Widget _buildTag(BuildContext context) => const TagPage();
Widget _buildAlert(BuildContext context) => const AlertPage();
Widget _buildSwitch(BuildContext context) => const SwitchPage();
Widget _buildCollapse(BuildContext context) => const CollapsePage();
Widget _buildCode(BuildContext context) => const CodePage();
Widget _buildNoticeBar(BuildContext context) => const NoticeBarPage();
Widget _buildProgress(BuildContext context) => const ProgressPage();
Widget _buildTabbar(BuildContext context) => const TabbarPage();
Widget _buildTabbar2(BuildContext context) => const Tabbar2Page();
Widget _buildWaterfall(BuildContext context) => const WaterfallPage();
Widget _buildCard(BuildContext context) => const CardPage();
Widget _buildTable(BuildContext context) => const TablePage();
Widget _buildTable2(BuildContext context) => const Table2Page();
Widget _buildForm(BuildContext context) => const FormPage();
Widget _buildTextarea(BuildContext context) => const TextareaPage();
Widget _buildNoNetwork(BuildContext context) => const NoNetworkPage();
Widget _buildLoadmore(BuildContext context) => const LoadmorePage();
Widget _buildText(BuildContext context) => const TextPage();
Widget _buildSteps(BuildContext context) => const StepsPage();
Widget _buildNavbar(BuildContext context) => const NavbarPage();
Widget _buildSkeleton(BuildContext context) => const SkeletonPage();
Widget _buildInput(BuildContext context) => const InputPage();
Widget _buildAlbum(BuildContext context) => const AlbumPage();
Widget _buildAvatar(BuildContext context) => const AvatarPage();
Widget _buildReadMore(BuildContext context) => const ReadMorePage();
Widget _buildLayout(BuildContext context) => const LayoutPage();
Widget _buildIndexList(BuildContext context) => const IndexListPage();
Widget _buildIndexList2(BuildContext context) => const IndexList2Page();
Widget _buildTooltip(BuildContext context) => const TooltipPage();
Widget _buildGuide(BuildContext context) => const GuidePage();
Widget _buildPopover(BuildContext context) => const PopoverPage();
Widget _buildTabs(BuildContext context) => const TabsPage();
Widget _buildList(BuildContext context) => const ListPage();
Widget _buildSwiper(BuildContext context) => const SwiperPage();
Widget _buildScrollList(BuildContext context) => const ScrollListPage();
Widget _buildCodeInput(BuildContext context) => const CodeInputPage();
Widget _buildModal(BuildContext context) => const ModalPage();
Widget _buildPicker(BuildContext context) => const PickerPage();
Widget _buildCalendar(BuildContext context) => const CalendarPage();
Widget _buildDatetimePicker(BuildContext context) => const DatetimePickerPage();
Widget _buildSubsection(BuildContext context) => const SubsectionPage();
Widget _buildQrcode(BuildContext context) => const QrcodePage();
Widget _buildCopy(BuildContext context) => const CopyPage();
Widget _buildNavbarMini(BuildContext context) => const NavbarMiniPage();
Widget _buildBox(BuildContext context) => const BoxPage();
Widget _buildFloatButton(BuildContext context) => const FloatButtonPage();
Widget _buildCateTab(BuildContext context) => const CateTabPage();
Widget _buildSelect(BuildContext context) => const SelectPage();
Widget _buildPagination(BuildContext context) => const PaginationPage();
Widget _buildTree(BuildContext context) => const TreePage();
Widget _buildDragsort(BuildContext context) => const DragsortPage();
Widget _buildCityLocate(BuildContext context) => const CityLocatePage();
Widget _buildTitle(BuildContext context) => const TitlePage();
Widget _buildPullRefresh(BuildContext context) => const PullRefreshPage();
Widget _buildVirtualList(BuildContext context) => const VirtualListPage();
Widget _buildBarcode(BuildContext context) => const BarcodePage();

ExampleRoute findExampleRoute(String id) {
  return exampleRoutes.firstWhere(
    (route) => route.id == id,
    orElse: () =>
        throw StateError('No completed example route registered for $id'),
  );
}

Future<void> pushExampleRoute(BuildContext context, ExampleRoute route) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: route.sourcePath),
      builder: route.builder,
    ),
  );
}
