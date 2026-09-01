# Ultra UI Flutter 复刻进度

源码：uview-plus（`src/uni_modules/uview-plus`） · 目标包：`packages/ultra_ui` · 组件前缀 `UP*`

> 本文档由 `tool/gen_progress_doc.py` 生成，数据来自对源码 `props.js` / `.vue`
> 的 props、emits、methods 静态扫描与 Dart 侧符号比对。请勿手工编辑；改动代码后重新生成：
>
> ```bash
> python tool/coverage_scan.py > .scan/cov.json
> python tool/extract_groups.py
> python tool/gen_progress_doc.py
> ```
>
> 本表只覆盖 **API 面**（props / emits / methods 是否存在）。**配色一致性**由另一个
> 独立脚本核对 —— 它解析源码 `libs/css/theme-vars-core.scss` 的 CSS 变量，与
> `UPThemeTokens` 的 light / dark 双色板逐项比对：
>
> ```bash
> python tool/theme_parity_scan.py   # 期望 mismatches 0、unmapped 为空
> ```
>
> 该脚本只能证明 token 取值一致，不能证明组件读了正确的 token；后者由
> `packages/ultra_ui/test/theme_parity_test.dart` 断言。
>
> Vue/uni-app 平台内部实现（例如 NVUE JSBridge、canvas watcher 调度器）以及
> 仅生成 CSS style map 的 computed，会在 `coverage_scan.py` 中按组件和符号逐项
> 列入 `excluded_methods`。这些项计为已对齐，但不会按下划线或命名模式整体忽略，
> 以免掩盖真实的宿主可见方法缺口。
>
> **prop 默认值**由第三个脚本核对 —— 本表只看 prop 是否存在，存在但默认值写错
> （尺寸、间距、时长差几个单位）是名称比对查不出的：
>
> ```bash
> python tool/prop_default_scan.py   # 期望 mismatches 0
> ```
>
> 刻意不同的默认值（如源码内联 base64 图片、`'-1'` 字符串 vs Dart int）在脚本里
> 逐条注明原因并单独计数，不会掩盖真实回归。
>
> **插槽（slot）**由第四个脚本核对 —— props / emits / methods 全绿也可能没有提供
> 替换某段标记的入口。写演示页时就是这样暴露的：`u-cate-tab` 的 `itemList` 插槽在
> 本表里显示"已复刻"，实际 Dart 侧没有对应参数，导致 choose 演示写不出来：
>
> ```bash
> python tool/slot_scan.py
> ```
>
> 该脚本靠命名约定匹配（`<name>Builder` / `<name>Slot` / `<name>Widget`），因此
> **只能证明缺失，不能证明正确**：报出来的是真缺口，没报出来的只说明存在一个名字
> 对得上的参数。命名刻意不同的（如 `pageItem` → `itemBuilder`）在脚本里逐条列出。

## 总览

| 指标 | 数值 |
|---|---|
| 源组件总数 | 141 |
| ✅ 已复刻 | 141 |
| 🟡 部分 | 0 |
| ⛔ 未复刻 | 0 |
| props 覆盖 | 1582/1582 |
| emits 覆盖 | 332/332 |
| methods + computed 覆盖 | 1346/1346 |

### 状态含义

- ✅ 已复刻：Flutter 类存在，且扫描到的 props / emits / methods 全部有对应符号
- 🟡 部分：Flutter 类存在，但仍有未覆盖的源码成员（见备注）
- ⛔ 未复刻：尚无对应 Flutter 类

### 扫描口径与已知误差

- `props` 列排除纯宿主属性（`customClass`、`openType`、`sendMessage*`、`lang` 等），
  它们在 Flutter 无对应语义。
- `methods` 列同时统计源码 `methods` 与 `computed`，因为该移植把 computed 也作为
  公开 API 暴露以保持调用兼容。
- 比对基于符号名（含 `snake_case`、`onXxx` 事件前缀等价形式），因此**只能证明缺失，
  不能证明行为正确**。行为与样式一致性由 `packages/ultra_ui/test` 的用例保证。
- `UPNovelReader` 的 4 个子面板已改为公开类（`UPNovelReaderTopToolbar` /
  `BottomToolbar` / `Catalog` / `Settings`），其 handler 与 computed 亦已暴露；
  核心算法（分页/测量/持久化）在 `test/novel_reader_core_test.dart` 中对齐真实源码
  JS 输出。12 个 **CSS 样式映射** computed（`readerStyle`、`toolbarStyle`、
  `articleStyle` 等）按精确符号列入 `excluded_methods`，不计为缺失；源码用它们把
  主题色注入 CSS 自定义属性，Flutter 则由 `themeTokens` 直接传给各子组件。
- 当前平台内部排除仅包括 `UPParse` 的 NVUE web-view/JSBridge 方法、`UPQrcode` 的
  命令式 canvas watcher 队列，以及上述 NovelReader CSS style-map computed。排除项
  按组件和符号逐条维护；扫描器回归测试确保无关的宿主可见方法仍会报告为真实缺口。
- 分组与排序镜像源码 `src/pages/example/components.config.js`，
  子组件缩进显示在父组件下方。

## 基础组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-icon` | `UPIcon` | ✅ 已复刻 | 16/16 | 1/1 | 6/6 | 接口与样式对齐 |
| `u-image` | `UPImage` | ✅ 已复刻 | 16/16 | 3/3 | 7/7 | 接口与样式对齐 |
| `u-button` | `UPButton` | ✅ 已复刻 | 20/20 | 7/7 | 21/21 | 接口与样式对齐 |
| `u-text` | `UPText` | ✅ 已复刻 | 21/21 | 1/1 | 5/5 | 接口与样式对齐 |
| `u-row` | `UPRow` | ✅ 已复刻 | 3/3 | 1/1 | 4/4 | 接口与样式对齐 |
| `↳ u-col` | `UPCol` | ✅ 已复刻 | 5/5 | 1/1 | 5/5 | 接口与样式对齐 |
| `u-cell` | `UPCell` | ✅ 已复刻 | 20/20 | 1/1 | 6/6 | 接口与样式对齐 |
| `↳ u-cell-group` | `UPCellGroup` | ✅ 已复刻 | 2/2 | — | 1/1 | 接口与样式对齐 |
| `u-badge` | `UPBadge` | ✅ 已复刻 | 14/14 | — | 3/3 | 接口与样式对齐 |
| `u-tag` | `UPTag` | ✅ 已复刻 | 21/21 | 2/2 | 10/10 | 接口与样式对齐 |
| `u-loading-icon` | `UPLoadingIcon` | ✅ 已复刻 | 11/11 | — | 5/5 | 接口与样式对齐 |
| `u-loading-page` | `UPLoadingPage` | ✅ 已复刻 | 10/10 | — | 1/1 | 接口与样式对齐 |

## 表单组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-form` | `UPForm` | ✅ 已复刻 | 8/8 | — | 6/6 | 接口与样式对齐 |
| `↳ u-form-item` | `UPFormItem` | ✅ 已复刻 | 10/10 | 1/1 | 8/8 | 接口与样式对齐 |
| `u-calendar` | `UPCalendar` | ✅ 已复刻 | 59/59 | 5/5 | 68/68 | 接口与样式对齐 |
| `u-keyboard` | `UPKeyboard` | ✅ 已复刻 | 16/16 | 6/6 | 6/6 | 接口与样式对齐 |
| `u-number-keyboard` | `UPNumberKeyboard` | ✅ 已复刻 | 3/3 | 2/2 | 6/6 | 接口与样式对齐 |
| `u-car-keyboard` | `UPCarKeyboard` | ✅ 已复刻 | 2/2 | 2/2 | 6/6 | 接口与样式对齐 |
| `u-picker` | `UPPicker` | ✅ 已复刻 | 33/33 | 7/7 | 18/18 | 接口与样式对齐 |
| `↳ u-picker-column` | `UPPickerColumn` | ✅ 已复刻 | — | — | — | 接口与样式对齐 |
| `↳ u-picker-data` | `UPPickerData` | ✅ 已复刻 | 6/6 | 5/5 | 6/6 | 接口与样式对齐 |
| `u-select` | `UPSelect` | ✅ 已复刻 | 19/19 | 2/2 | 14/14 | 根 Overlay 锚定面板替代绝对定位 DOM 层叠 |
| `u-cascader` | `UPCascader` | ✅ 已复刻 | 12/12 | 5/5 | 15/15 | 接口与样式对齐 |
| `u-choose` | `UPChoose` | ✅ 已复刻 | 10/10 | 2/2 | 1/1 | 接口与样式对齐 |
| `u-datetime-picker` | `UPDatetimePicker` | ✅ 已复刻 | 37/37 | 6/6 | 23/23 | 接口与样式对齐 |
| `u-rate` | `UPRate` | ✅ 已复刻 | 14/14 | 2/2 | 16/16 | 接口与样式对齐 |
| `u-search` | `UPSearch` | ✅ 已复刻 | 28/28 | 9/9 | 14/14 | 接口与样式对齐 |
| `u-number-box` | `UPNumberBox` | ✅ 已复刻 | 27/27 | 7/7 | 24/24 | 接口与样式对齐 |
| `u-upload` | `UPUpload` | ✅ 已复刻 | 34/34 | 8/8 | 15/15 | 接口与样式对齐 |
| `u-code` | `UPCode` | ✅ 已复刻 | 6/6 | 3/3 | 5/5 | 接口与样式对齐 |
| `u-input` | `UPInput` | ✅ 已复刻 | 39/39 | 8/8 | 19/19 | 接口与样式对齐 |
| `u-textarea` | `UPTextarea` | ✅ 已复刻 | 24/24 | 7/7 | 16/16 | 接口与样式对齐 |
| `u-checkbox` | `UPCheckbox` | ✅ 已复刻 | 14/14 | 2/2 | 20/20 | 接口与样式对齐 |
| `↳ u-checkbox-group` | `UPCheckboxGroup` | ✅ 已复刻 | 16/16 | 2/2 | 3/3 | 接口与样式对齐 |
| `u-radio` | `UPRadio` | ✅ 已复刻 | 13/13 | 1/1 | 20/20 | 接口与样式对齐 |
| `↳ u-radio-group` | `UPRadioGroup` | ✅ 已复刻 | 18/18 | 2/2 | 4/4 | 接口与样式对齐 |
| `u-switch` | `UPSwitch` | ✅ 已复刻 | 13/13 | 2/2 | 11/11 | 接口与样式对齐 |
| `u-slider` | `UPSlider` | ✅ 已复刻 | 20/20 | 4/4 | 18/18 | 接口与样式对齐 |
| `u-album` | `UPAlbum` | ✅ 已复刻 | 16/16 | 2/2 | 8/8 | 接口与样式对齐 |

## 数据组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-list` | `UPList` | ✅ 已复刻 | 19/19 | 9/9 | 10/10 | 接口与样式对齐 |
| `↳ u-list-item` | `UPListItem` | ✅ 已复刻 | 1/1 | — | 4/4 | 接口与样式对齐 |
| `u-virtual-list` | `UPVirtualList` | ✅ 已复刻 | 6/6 | 2/2 | 13/13 | 接口与样式对齐 |
| `u-line-progress` | `UPLineProgress` | ✅ 已复刻 | 6/6 | — | 5/5 | 接口与样式对齐 |
| `u-circle-progress` | `UPCircleProgress` | ✅ 已复刻 | 1/1 | — | 3/3 | 接口与样式对齐 |
| `u-table` | `UPTable` | ✅ 已复刻 | 7/7 | — | 5/5 | 接口与样式对齐 |
| `↳ u-td` | `UPTd` | ✅ 已复刻 | 5/5 | — | — | 接口与样式对齐 |
| `↳ u-th` | `UPTh` | ✅ 已复刻 | 1/1 | — | — | 接口与样式对齐 |
| `↳ u-tr` | `UPTr` | ✅ 已复刻 | — | — | — | 接口与样式对齐 |
| `u-table2` | `UPTable2` | ✅ 已复刻 | 50/50 | 14/14 | 34/34 | 固定表头/左固定列用 Flutter 滚动裁剪覆盖层替代 CSS sticky |
| `u-count-down` | `UPCountDown` | ✅ 已复刻 | 4/4 | 2/2 | 9/9 | 接口与样式对齐 |
| `u-count-to` | `UPCountTo` | ✅ 已复刻 | 11/11 | 1/1 | 13/13 | 接口与样式对齐 |

## 反馈组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-tooltip` | `UPTooltip` | ✅ 已复刻 | 16/16 | 4/4 | 10/10 | 接口与样式对齐 |
| `u-guide` | `UPGuide` | ✅ 已复刻 | 11/11 | 5/5 | 12/12 | `zIndex` 保留；真正全局固定层叠需状态保持 portal |
| `u-popover` | `UPPopover` | ✅ 已复刻 | 10/10 | — | 5/5 | 接口与样式对齐 |
| `u-action-sheet` | `UPActionSheet` | ✅ 已复刻 | 12/12 | 4/4 | 13/13 | 接口与样式对齐 |
| `↳ u-action-sheet-data` | `UPActionSheetData` | ✅ 已复刻 | 6/6 | 1/1 | 2/2 | 接口与样式对齐 |
| `u-alert` | `UPAlert` | ✅ 已复刻 | 12/12 | 4/4 | 4/4 | 接口与样式对齐 |
| `u-toast` | `UPToast` | ✅ 已复刻 | — | — | 8/8 | 接口与样式对齐 |
| `u-notice-bar` | `UPNoticeBar` | ✅ 已复刻 | 14/14 | 2/2 | 4/4 | 接口与样式对齐 |
| `↳ u-column-notice` | `UPColumnNotice` | ✅ 已复刻 | 11/11 | 2/2 | 5/5 | 接口与样式对齐 |
| `↳ u-row-notice` | `UPRowNotice` | ✅ 已复刻 | 7/7 | 2/2 | 8/8 | 接口与样式对齐 |
| `u-notify` | `UPNotify` | ✅ 已复刻 | 8/8 | — | 6/6 | 接口与样式对齐 |
| `u-swipe-action` | `UPSwipeAction` | ✅ 已复刻 | 2/2 | 1/1 | 4/4 | 接口与样式对齐 |
| `↳ u-swipe-action-item` | `UPSwipeActionItem` | ✅ 已复刻 | 9/9 | 4/4 | 8/8 | 接口与样式对齐 |
| `u-collapse` | `UPCollapse` | ✅ 已复刻 | 3/3 | 3/3 | 3/3 | 接口与样式对齐 |
| `↳ u-collapse-item` | `UPCollapseItem` | ✅ 已复刻 | 17/17 | — | 3/3 | 接口与样式对齐 |
| `u-popup` | `UPPopup` | ✅ 已复刻 | 19/19 | 5/5 | 17/17 | 接口与样式对齐 |
| `u-modal` | `UPModal` | ✅ 已复刻 | 21/21 | 5/5 | 4/4 | 接口与样式对齐 |
| `u-copy` | `UPCopy` | ✅ 已复刻 | 3/3 | 1/1 | 1/1 | 接口与样式对齐 |
| `u-float-button` | `UPFloatButton` | ✅ 已复刻 | 10/10 | 2/2 | 2/2 | 接口与样式对齐 |
| `u-pull-refresh` | `UPPullRefresh` | ✅ 已复刻 | 10/10 | 3/3 | 9/9 | 接口与样式对齐 |
| `u-signature` | `UPSignature` | ✅ 已复刻 | 6/6 | — | 16/16 | 接口与样式对齐 |
| `u-agreement` | `UPAgreement` | ✅ 已复刻 | 2/2 | 1/1 | 4/4 | 接口与样式对齐 |

## 布局组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-scroll-list` | `UPScrollList` | ✅ 已复刻 | 6/6 | 2/2 | 7/7 | 接口与样式对齐 |
| `u-line` | `UPLine` | ✅ 已复刻 | 6/6 | — | 1/1 | 接口与样式对齐 |
| `u-card` | `UPCard` | ✅ 已复刻 | 26/26 | 4/4 | 4/4 | 接口与样式对齐 |
| `u-overlay` | `UPOverlay` | ✅ 已复刻 | 4/4 | 1/1 | 2/2 | 接口与样式对齐 |
| `u-no-network` | `UPNoNetwork` | ✅ 已复刻 | 3/3 | 2/2 | 8/8 | 宿主拥有真实连通性检测 |
| `u-grid` | `UPGrid` | ✅ 已复刻 | 4/4 | 1/1 | 3/3 | 接口与样式对齐 |
| `↳ u-grid-item` | `UPGridItem` | ✅ 已复刻 | 2/2 | 1/1 | 6/6 | 接口与样式对齐 |
| `u-swiper` | `UPSwiper` | ✅ 已复刻 | 25/25 | 3/3 | 7/7 | 接口与样式对齐 |
| `↳ u-swiper-indicator` | `UPSwiperIndicator` | ✅ 已复刻 | 5/5 | — | 2/2 | 接口与样式对齐 |
| `u-skeleton` | `UPSkeleton` | ✅ 已复刻 | 11/11 | — | 3/3 | 接口与样式对齐 |
| `u-sticky` | `UPSticky` | ✅ 已复刻 | 6/6 | — | 11/11 | 接口与样式对齐 |
| `u-waterfall` | `UPWaterfall` | ✅ 已复刻 | 7/7 | 3/3 | 12/12 | 接口与样式对齐 |
| `u-divider` | `UPDivider` | ✅ 已复刻 | 8/8 | 1/1 | 4/4 | 接口与样式对齐 |
| `u-box` | `UPBox` | ✅ 已复刻 | 10/10 | — | — | 接口与样式对齐 |
| `u-cate-tab` | `UPCateTab` | ✅ 已复刻 | 6/6 | 1/1 | 1/1 | `follow` 用滚动位置跟踪替代 IntersectionObserver |
| `u-title` | `UPTitle` | ✅ 已复刻 | — | — | — | 接口与样式对齐 |
| `u-short-video` | `UPShortVideo` | ✅ 已复刻 | 4/4 | — | 17/17 | 宿主通过 `videoBuilder` 注入播放器 |

## 导航组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-dropdown` | `UPDropdown` | ✅ 已复刻 | 11/11 | 2/2 | 11/11 | 接口与样式对齐 |
| `↳ u-dropdown-item` | `UPDropdownItem` | ✅ 已复刻 | 7/7 | 2/2 | 3/3 | 接口与样式对齐 |
| `u-tabbar` | `UPTabbar` | ✅ 已复刻 | 17/17 | — | 5/5 | 接口与样式对齐 |
| `↳ u-tabbar-item` | `UPTabbarItem` | ✅ 已复刻 | 17/17 | 2/2 | 27/27 | 接口与样式对齐 |
| `u-navbar` | `UPNavbar` | ✅ 已复刻 | 20/20 | 2/2 | 15/15 | 接口与样式对齐 |
| `u-navbar-mini` | `UPNavbarMini` | ✅ 已复刻 | 9/9 | 2/2 | 2/2 | 接口与样式对齐 |
| `u-tabs` | `UPTabs` | ✅ 已复刻 | 14/14 | 4/4 | 15/15 | 接口与样式对齐 |
| `↳ u-tabs-item` | `UPTabsItem` | ✅ 已复刻 | — | — | — | 接口与样式对齐 |
| `u-subsection` | `UPSubsection` | ✅ 已复刻 | 12/12 | 2/2 | 15/15 | 接口与样式对齐 |
| `u-index-list` | `UPIndexList` | ✅ 已复刻 | 7/7 | — | 15/15 | 接口与样式对齐 |
| `↳ u-index-anchor` | `UPIndexAnchor` | ✅ 已复刻 | 5/5 | — | 4/4 | 接口与样式对齐 |
| `↳ u-index-item` | `UPIndexItem` | ✅ 已复刻 | — | — | 2/2 | 接口与样式对齐 |
| `u-steps` | `UPSteps` | ✅ 已复刻 | 7/7 | — | 3/3 | 接口与样式对齐 |
| `↳ u-steps-item` | `UPStepsItem` | ✅ 已复刻 | 6/6 | — | 10/10 | 接口与样式对齐 |
| `u-empty` | `UPEmpty` | ✅ 已复刻 | 11/11 | — | 3/3 | 接口与样式对齐 |
| `u-pagination` | `UPPagination` | ✅ 已复刻 | 10/10 | 4/4 | 11/11 | 接口与样式对齐 |
| `u-tree` | `UPTree` | ✅ 已复刻 | 20/20 | 6/6 | 47/47 | 接口与样式对齐 |

## 其他组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-parse` | `UPParse` | ✅ 已复刻 | 12/12 | 6/6 | 13/13 | HTML 子集渲染为 Flutter 组件树，无 CSS 引擎；NVUE web-view/JSBridge 内部方法不适用 |
| `u-markdown` | `UPMarkdown` | ✅ 已复刻 | 6/6 | 6/6 | 9/9 | Markdown → HTML 后交由 UPParse 渲染（与源码同架构） |
| `u-code-input` | `UPCodeInput` | ✅ 已复刻 | 16/16 | 3/3 | 5/5 | 接口与样式对齐 |
| `u-dragsort` | `UPDragSort` | ✅ 已复刻 | 5/5 | 1/1 | 11/11 | `direction=all` 用受约束网格 + 长按拖拽替代 `movable-view` 绝对定位 |
| `u-cropper` | `UPCropper` | ✅ 已复刻 | 1/1 | 2/2 | 14/14 | 接口与样式对齐 |
| `u-loadmore` | `UPLoadmore` | ✅ 已复刻 | 18/18 | 1/1 | 3/3 | 接口与样式对齐 |
| `u-read-more` | `UPReadMore` | ✅ 已复刻 | 9/9 | 2/2 | 2/2 | 接口与样式对齐 |
| `u-lazy-load` | `UPLazyLoad` | ✅ 已复刻 | 11/11 | 3/3 | 8/8 | 接口与样式对齐 |
| `u-gap` | `UPGap` | ✅ 已复刻 | 4/4 | — | 1/1 | 接口与样式对齐 |
| `u-avatar` | `UPAvatar` | ✅ 已复刻 | 14/14 | 1/1 | 5/5 | 接口与样式对齐 |
| `↳ u-avatar-group` | `UPAvatarGroup` | ✅ 已复刻 | 9/9 | 1/1 | 2/2 | 接口与样式对齐 |
| `u-link` | `UPLink` | ✅ 已复刻 | 7/7 | 1/1 | 2/2 | 接口与样式对齐 |
| `u-transition` | `UPTransition` | ✅ 已复刻 | 4/4 | 7/7 | 1/1 | 接口与样式对齐 |
| `u-qrcode` | `UPQrcode` | ✅ 已复刻 | 19/19 | 3/3 | 8/8 | Flutter `CustomPainter` 声明式重绘替代 Vue canvas watcher 队列；保留源码空值语义 |
| `u-coupon` | `UPCoupon` | ✅ 已复刻 | 15/15 | — | 3/3 | 接口与样式对齐 |
| `u-barcode` | `UPBarcode` | ✅ 已复刻 | 20/20 | — | 12/12 | 接口与样式对齐 |
| `u-color-picker` | `UPColorPicker` | ✅ 已复刻 | 2/2 | 4/4 | 40/40 | 接口与样式对齐 |
| `u-poster` | `UPPoster` | ✅ 已复刻 | 1/1 | — | 8/8 | 接口与样式对齐 |
| `u-goods-sku` | `UPGoodsSku` | ✅ 已复刻 | 7/7 | 4/4 | 15/15 | 接口与样式对齐 |
| `u-city-locate` | `UPCityLocate` | ✅ 已复刻 | 5/5 | 2/2 | 4/4 | 宿主通过 `locationHandler` 替代 `uni.getLocation` |
| `u-pdf-reader` | `UPPdfReader` | ✅ 已复刻 | 3/3 | — | — | 宿主通过 `viewerBuilder` 注入真实 PDF 视图 |
| `u-novel-reader` | `UPNovelReader` | ✅ 已复刻 | 35/35 | 24/24 | 80/80 | 分页测量用源码 measure-adapter 启发式宽度；持久化经宿主钩子；CSS computed 映射为 Flutter 主题与布局对象 |

## 未在演示分组中出现的组件

| 源组件 | Flutter 类 | 状态 | props | emits | methods | 备注 |
|---|---|---|---|---|---|---|
| `u-back-top` | `UPBackTop` | ✅ 已复刻 | 10/10 | 1/1 | 4/4 | 接口与样式对齐 |
| `u-calendar-strip` | `UPCalendarStrip` | ✅ 已复刻 | 15/15 | 5/5 | 37/37 | 滑动手势用月份按钮模拟 |
| `u-canvas` | `UPCanvas` | ✅ 已复刻 | 7/7 | 4/4 | 70/70 | Flutter `CustomPainter` 替代 uni canvas context |
| `u-message-input` | `UPMessageInput` | ✅ 已复刻 | 12/12 | 2/2 | 5/5 | 接口与样式对齐 |
| `u-refresh-virtual-list` | `UPRefreshVirtualList` | ✅ 已复刻 | 5/5 | — | 5/5 | 接口与样式对齐 |
| `u-root-toast-host` | `UPRootToastHost` | ✅ 已复刻 | — | — | — | 替代 `uni.$u.setRootToastRef`，注册全局 toast/notify 宿主 |
| `u-safe-bottom` | `UPSafeBottom` | ✅ 已复刻 | — | — | 1/1 | 接口与样式对齐 |
| `u-section` | `UPSection` | ✅ 已复刻 | — | — | — | 接口与样式对齐 |
| `u-status-bar` | `UPStatusBar` | ✅ 已复刻 | 2/2 | 1/1 | 1/1 | 接口与样式对齐 |
| `u-tabs-pro` | `UPTabsPro` | ✅ 已复刻 | 19/19 | 4/4 | 9/9 | 接口与样式对齐 |
| `u-toolbar` | `UPToolbar` | ✅ 已复刻 | 7/7 | 2/2 | 2/2 | 接口与样式对齐 |
| `u-view` | `UPView` | ✅ 已复刻 | — | 1/1 | 2/2 | 接口与样式对齐 |
