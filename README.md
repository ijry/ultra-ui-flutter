# ultra-ui-flutter

uview-plus 接口兼容的 Flutter 版本（1:1 样式目标，组件前缀 `UP*`）。

## 结构

- `packages/ultra_ui`：组件库
- `example`：演示对照 App
- `docs/superpowers/specs`：设计文档
- `docs/superpowers/plans`：实现计划

## 快速开始

```bash
cd packages/ultra_ui
flutter pub get
flutter test

cd ../../example
flutter pub get
flutter run
```

## 当前已实现

### 基础
`UPIcon` `UPLoadingIcon` `UPButton` `UPText` `UPTag` `UPBadge` `UPGap` `UPLine` `UPDivider` `UPCell` `UPCellGroup` `UPImage` `UPAvatar` `UPAvatarGroup` `UPLink` `UPSection` `UPStatusBar` `UPSafeBottom` `UPCard` `UPRow` `UPCol` `UPTitle` `UPView` `UPBox`

### 表单
`UPSwitch` `UPInput` `UPSearch` `UPCheckbox` `UPCheckboxGroup` `UPRadio` `UPRadioGroup` `UPNumberBox` `UPRate` `UPSlider` `UPTextarea` `UPCodeInput` `UPMessageInput` `UPSubsection` `UPForm` `UPFormItem` `UPNumberKeyboard` `UPCarKeyboard` `UPKeyboard` `UPDatetimePicker` `UPCalendar` `UPCalendarStrip` `UPCode` `UPSelect` `UPCascader` `UPUpload`

### 反馈 / 导航 / 展示
`UPOverlay` `UPPopup` `UPToast` `UPNotify` `UPModal` `UPNavbar` `UPNavbarMini` `UPTabs` `UPTabbar` `UPTabbarItem` `UPEmpty` `UPLoadmore` `UPActionSheet` `UPSkeleton` `UPGrid` `UPGridItem` `UPSwiper` `UPSteps` `UPStepsItem` `UPCollapse` `UPCollapseItem` `UPAlert` `UPNoticeBar` `UPLineProgress` `UPCircleProgress` `UPCountDown` `UPCountTo` `UPLoadingPage` `UPBackTop` `UPToolbar` `UPList` `UPListItem` `UPSwipeAction` `UPSwipeActionItem` `UPDropdown` `UPDropdownItem` `UPTooltip` `UPTransition` `UPSticky` `UPReadMore` `UPNoNetwork` `UPPagination` `UPFloatButton` `UPPopover` `UPScrollList` `UPIndexList` `UPIndexItem` `UPIndexAnchor` `UPPullRefresh` `UPPicker` `UPTable` `UPTr` `UPTh` `UPTd` `UPTable2` `UPAlbum` `UPCopy` `UPAgreement` `UPWaterfall` `UPVirtualList` `UPChoose` `UPCoupon` `UPTree` `UPSignature` `UPGuide` `UPDragSort` `UPLazyLoad` `UPQrcode` `UPBarcode` `UPColorPicker` `UPGoodsSku` `UPCateTab` `UPCityLocate` `UPParse` `UPMarkdown` `UPPoster` `UPCropper` `UPPdfReader` `UPShortVideo` `UPCanvas` `UPRefreshVirtualList`

## 测试

`packages/ultra_ui`：`flutter test` 目标持续保持全绿。

## 目标

全量 uview-plus 组件 1:1 兼容（约 140 个），按源码 props/scss 分批推进。
