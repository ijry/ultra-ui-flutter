# ultra-ui-flutter

uview-plus 接口兼容的 Flutter 版本（1:1 样式目标，组件前缀 `UP*`）。

## 结构

- `packages/ultra_ui`：组件库（零原生依赖）
- `packages/ultra_ui_media`：PDF 与视频真实后端（可选，按需引入）
- `example`：演示对照 App
- [`docs/replication-progress.md`](docs/replication-progress.md)：组件与演示页面总进度
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

## PDF 与视频

`UPPdfReader` 和 `UPShortVideo` 默认渲染占位内容，因为核心包不引入任何原生依赖。
需要真实能力时引入 `ultra_ui_media`，通过组件已有的 builder 钩子接入：

```dart
UPPdfReader(
  src: 'https://example.com/doc.pdf',
  viewerBuilder: (viewerUrl) => UPPdfView(target: resolvePdfTarget(viewerUrl)),
)

UPShortVideo(
  videoList: items,
  videoBuilder: (item, index, playing) =>
      UPVideoView(src: '${item['videoUrl']}', playing: playing),
)
```

PDF 基于 pdfrx（PDFium），首次构建会从 GitHub 下载对应平台的 PDFium 二进制；
视频基于官方 `video_player`。

## 测试

`packages/ultra_ui`：`flutter test` 目标持续保持全绿。

## 目标

全量 uview-plus 组件 1:1 兼容（约 140 个），按源码 props/scss 分批推进。
