# Ultra UI Flutter Gap Matrix

Source: uview-plus 3.8.82  
Package: `packages/ultra_ui`  
Prefix: `UP*`

## Status legend

- **Supported**: implemented with equivalent Flutter behavior
- **Emulated**: closest Flutter behavior, documented difference
- **No-op retained**: API accepted, ignored on Flutter
- **Shell**: API + basic UI present, advanced source behavior still partial

## Coverage snapshot

| Area | Status |
|---|---|
| Config / theme / utils / icons | Supported |
| Base display (Button/Icon/Text/Tag/Badge/Cell/Image/Avatar...) | Supported |
| Form set (Input/Textarea/Switch/Checkbox/Radio/Form/Search...) | Supported |
| Feedback (Popup/Modal/Toast/Notify/Overlay/ActionSheet...) | Supported |
| Navigation (Navbar/Tabs/Tabbar/Steps/Subsection...) | Supported |
| Data complex (Swiper/Picker/Calendar/Upload/Waterfall/VirtualList...) | Supported / Emulated |
| Advanced (Canvas/Signature/Cropper/Poster/Qrcode/Barcode/Parse...) | Supported / Emulated |
| Host-only (openType / mini-program share / pdf native view) | No-op retained / host inject |

## Notable emulations

| Component | Difference |
|---|---|
| `UPDragSort` | Vertical/horizontal modes use Flutter `ReorderableListView`; `direction=all` uses a wrapped grid with long-press drag targets rather than uni `movable-view` absolute positioning |
| `UPSelect` | Anchored Flutter root-overlay panel and dismiss barrier replace uni `u-overlay`/absolute-position DOM layering |
| `UPPdfReader` | Host injects real viewer via `viewerBuilder` |

| `UPGoodsSku` | SKU matching supports nested `s/sku/specs` and flat source keys; confirm payload includes both Flutter and source keys (`sku/num/selectedText`) |
| `UPCityLocate` | Host inject via `locationHandler` instead of `uni.getLocation`; autoLocate default true |
| `UPGuide` | Source defaults and page visual scale are aligned; in-memory once cache plus optional `readPersisted/writePersisted/removePersisted` host hooks. The `zIndex` prop is retained, but true global fixed layering needs a state-preserving portal rather than the current simple root-overlay registry |
| `UPCalendarStrip` | Horizontal month-day strip + expand embeds `UPCalendar` pageInline; swipe gestures emulated by month buttons |
| `UPTree` | Source methods (get/set checked/expand) supported; recursive parent/child selection renders a Flutter tri-state checkbox for indeterminate parents |
| `UPCascader` | Public open/close/reset/setValue; optionsCols=2 dual pane emulated |
| `UPTable2` | Tree expand/selection cascade and public selection/sort/expand APIs; fixed header and fixed-left use Flutter scroll/clip overlays rather than uni `scroll-view` DOM/CSS sticky behavior |
| `UPCoupon` | Slot builders (`unit/amount/title/action/...`) map source named slots |
| `UPShortVideo` | Host inject player via `videoBuilder`; public `playVideo/pauseCurrentVideo` |
| `UPCateTab` | follow mode uses Flutter scroll-position section tracking rather than uni intersection observers; source scroll snapshots and public `switchMenu` are synchronized |
| `UPPopover` | Built on UPTooltip; public open/close/toggle + onUpdateShow. Click/long-press triggers use source one-way open behavior, and `show` is controlled only when `triggerMode=manual` |
| `UPDatetimePicker` | Public setValue/open/close; modes mapped through UPPicker columns |
| `UPNoNetwork` | Host owns real connectivity; public show/hide/retry |
| `UPFloatButton` | Public open/close/toggle for menu mode |
| `UPPullRefresh` | Public startRefresh/finishRefresh/scrollTo; refresh events are emitted only by a qualifying pull-release gesture, while imperative/controlled state transitions remain silent; `scrollTop` stays synchronized with the internal Flutter scroll position |
| `UPRefreshVirtualList` | Composes PullRefresh + VirtualList; public finishRefresh/scrollTo |
| `UPList` | Public scrollTo/scrollToTop/scrollToBottom/scrollIntoViewById + refresher start/finish |
| `UPIndexList` | Public jumpTo/jumpToLetter/setActiveIndex + activeLetter getters |
| `UPPagination` | Stateful public goTo/prev/next/changeSize APIs |
| `UPAlbum` | Stateful; host `previewHandler` maps uni.previewImage; public previewAt |
| `UPScrollList` | Public scrollTo/scrollToLeft/scrollToRight + edge getters |
| `UPVirtualList` | Public scrollTo/scrollToIndex/scrollToTop + firstVisibleIndex |
| `UPSwiper` | Public swipeTo/next/prev/startAutoplay/stopAutoplay |
| `UPTabs` | Public setCurrent/next/prev |
| `UPCollapse` | Public open/close/toggle/setValue |
| `UPReadMore` | Public open/close/toggle + canToggle |
| `UPCode` | Public State (start/reset) aligned with controller |
| `UPLazyLoad` | Public loadNow/recheck |
| `UPSticky` | Public isFixed/setFixed/init/refresh + stickyTop |
| `UPSubsection` | Public setCurrent/next/prev + currentIndex |
| `UPSearch` | Public setValue/clear/focus/blur/search/custom |
| `UPWaterfall` | Public rebuild/clear/remove/modify + column metrics |
| `UPInput` | Public setValue/clear/focus/blur |
| `UPTextarea` | Public setValue/clear/focus/blur |
| `UPNoticeBar` | Public close/open/toggle + isClosed |
| `UPMessageInput` | Public setValue/clear/focus/blur + isFinished |
| `UPTransition` | Public open/close/toggle + isShown |
| `UPPopup` | Stateful public open/close/toggle + isShown |
| `UPAlert` | Public open/close/toggle + isShown |
| `UPCodeInput` | Public setValue/clear/focus/blur + isFinished |
| `UPSkeleton` | Public show/hide/startAnimate/stopAnimate |
| `UPLoadingIcon` | Public start/stop + isAnimating |
| `UPButton` | Public click/setLoading + isLoading |
| `UPCarKeyboard` | Public input/backspace/mode switch |
| `UPNumberKeyboard` | Public input/backspace + keys |
| `UPStatusBar` | Public statusHeight/refreshHeight |
| `UPCanvas` | Public State aliases clear/refresh/draw |
| `UPNumberBox` | Public init/setValue/plus/minus/focus/blur/clear |
| `UPCalendar` | Public prev/next/prevYear/nextYear/today/setSelected/confirm |
| `UPSlider` | Stateful public setValue/setRange/init |
| `UPKeyboard` | Stateful public open/close/change/backspace |
| `UPDragSort` | Public setValue/move/insert/removeAt/reset |
| `UPUpload` | Public lists/clear/setFileList + success alias |
| `UPColorPicker` | Public open/close/setValue/gradient helpers |
| `UPSelect` | Public open/close/toggle/setCurrent |
| `UPCityLocate` | Public setCurrentCity/location getters |
| `UPSignature` | Public clearCanvas alias |
| `UPRate` | Stateful public setValue/clickHandler/init |
| `UPSwitch` | Stateful public toggle/clickHandler/setValue |
| `UPDropdown` | Public init/toggle/highlightIndexes |
| `UPTooltip` | Public toggle/setClipboardData/clearActiveTooltip; source singleton mutual exclusion, one-way click/long-press opening, and copy `click(0)` event semantics are retained |
| `UPFormItem` | Public init/setRules/clearValidate/resetField/clickHandler |
| `UPPoster` | Public exportImage/generate/generateImage aliases |
| `UPModal` | Public open/close/toggle + confirm/cancel handlers |
| `UPActionSheet` | Stateful public open/close/selectHandler/cancel |
| `UPCarKeyboard` | Public carInputClick/changeCarInputMode aliases |
| `UPNumberKeyboard` | Public keyboardClick/backspaceClick aliases |
| `UPNoNetwork` | Public settings no-ops + emitEvent/network |
| `UPStatusBar` | Public init/updateHeight |
| `UPPicker` | Public open/close/confirm/cancel/changeHandler |
| `UPPopup` | Public overlayClick/clickHandler/afterEnter |
| `UPTabs` | Public clickHandler/longPressHandler/init/resize |
| `UPSwiper` | Public change/clickHandler/getSource/getItemType; circular paging uses seamless sentinel pages with deduplicated public change emits |
| `UPPagination` | Public handleSizeChange/onInputPage/onConfirmPage |
| `UPGuide` | Public bootstrap/onSkip/onPrimaryAction/isLastPage |
| `UPDatetimePicker` | Public confirm/cancel/getInputValue/init |
| `UPCountDown` | Public setRemainTime/getRemainTime/init/clearTimeout |
| `UPCountTo` | Public formatNumber/count/destroyed |
| `UPLoadingIcon` | Public startAnimate/init aliases |
| `UPSignature` | Public touchStart/Move/End + selectColor/redraw |
| `UPAlert` | Public clickHandler/closeHandler |
| `UPCascader` | Public getSelectedValues/setDefaultValue/handleConfirm/handleCancel |
| `UPGoodsSku` | Public onNumChange/getSelectedSkuComb |
| `UPInput` | Public setFormatter/inputHandler/clickHandler/doFocus/doBlur |
| `UPCodeInput` | Public inputHandler |
| `UPMessageInput` | Public getVal |
| `UPTooltip` | Public overlayClickHandler/btnClickHandler |
| `UPCalendarStrip` | Public setSelectedDate/setFullVisible/onPanelConfirm/getWeekLabel |
| `UPRate` | Public getActiveIndex/getCountValue/getMinCountValue |
| `UPCropper` | Public select/chooseImage aliases |
| `UPSlider` | Public getSliderStep/toSliderNumber/normalizeSliderValue/formatByStep + changing/change/touch handlers |
| `UPPullRefresh` | Public resetRefresh/isScrollViewAtTop/handleScroll/handleScrollToLower + touch aliases |
| `UPSearch` | Public inputChange/clickHandler/isShowClear/showActionBtn |
| `UPTextarea` | Public formatter/setFormatter/onInput/normalizeValue/valueLength + keyboard shells |
| `UPTag` | Public clickHandler/closeHandler/getBagColor |
| `UPCell` | Public clickHandler |
| `UPNumberBox` | Public check/emitChange/longPressStep + touch shells |
| `UPDropdown` | Public maskClick/getContentHeight |
| `UPReadMore` | Public toggleReadMore |
| `UPSelect` | Public overlayClick/selectItem/adjustOptionsWrapPosition |
| `UPCheckbox` / `UPRadio` | Public emitEvent/click handlers/setRadioCheckedStatus (+ usedAlone emit) |
| `UPUpload` | Public formatFileList/getDetail/onPreviewImage/onPreviewVideo + video shells |
| `UPTree` | Public handleNodeClick/handleExpandClick/handleCheckboxChange/getParentNode |
| `UPIndexList` | Public uIndexList/touch helpers/letter+rect shells |
| `UPCalendar` | Public getConfirmValue/monthSelected/clickHandler/close/init/setFormatter + time shells |
| `UPSwipeAction` | Public setOpendItem/itemCount; item openHandler/closeHandler/isOpen/updateParentData |
| `UPColorPicker` | Public initColor/openColorPickerForGradient/direction helpers/parse shells |
| `UPPopup` | Public onTouchStart/Move/End with runtime drag-resize layout; noop/retryComputedComponentRect retained |
| `UPNavbar` | Public leftClick/rightClick (+ interceptor path) |
| `UPBackTop` | Public backToTop |
| `UPFloatButton` | Public clickHandler/itemClick (list items) |
| `UPOverlay` | Public clickHandler |
| `UPToolbar` | Public cancel/confirm |
| `UPCoupon` | Public handleClick |
| `UPAgreement` | Public showModal/close/urlClick |
| `UPCopy` | Public handleClick; alertStyle `none` skips toast |
| `UPAlbum` | Public getSrc/onPreviewTap/getImageRect |
| `UPLazyLoad` | Public init/loadNow/clickImg + load shells |
| `UPScrollList` | Public init/scrollHandler/scrolltoupper/tolower + scrollTo* |
| `UPTransition` | Public open/close/toggle/clickHandler |
| `UPCode` | Public start/reset/changeEvent/setTimeToStorage |
| `UPChoose` | Public change |
| `UPNoNetwork` | Public show/hide/retry/emitEvent/settings shells |
| `UPForm` | Public error/setProperty/resetModel (cached messages) |
| `UPRefreshVirtualList` | Public handleRefresh/handleScroll/scrollTo* |
| `UPSticky` | Public getStickyTop/init/observe shells/setFixed |
| `UPShortVideo` | Public play/pause aliases + progress/like/share shells |
| `UPList` | Public onScroll/scrolltolower/toupper + refresher aliases |
| `UPVirtualList` | Public lastVisibleIndex/getVisibleRange/handleScroll helpers |
| `UPWaterfall` | Public minHeightColumnIndex/initColumnList/clear/remove/modify |
| `UPToast` | Public clearTimer/clearTimeout |
| `UPNotify` | Public clearTimeout + type helpers |
| `UPTable2` | Public initDefaultExpandAll/getSortValueBy + rendered style/span support |
| Platform openType / share cards | No-op retained props where present |


| `UPQrcode` | Public makeCode/clearCode/saveCode/preview/selectClick/toTempFilePath/longpress/initCanvas shells + encodeMatrix |
| `UPBarcode` | Public generateBarcode/encodeBarcode/renderToCanvas/renderToImage/calculateCanvasSize/getCanvasRef |
| `UPTabbar` | Public updateChildren/updatePlaceholder/setPlaceholderHeight |
| `UPTabbarItem` | Public init/updateParentData/updateFromParent/clickHandler |
| `UPSteps` | Public updateChildData/updateFromChild |
| `UPParse` | Public setContent/getText/normalizeHref/isExternalLink/openExternalLink/navigateTo/getRect/pauseMedia/setPlaybackRate |
| `UPMarkdown` | Public parseMarkdown + emitLoad/Ready/Imgtap/Linktap/Play/Error |
| `UPSkeleton` | Public init alias (show + animate) |
| `UPAvatar` | Public init/isImg/errorHandler/clickHandler |
| `UPSubsection` | Public init/sleep/getText/getRect/clickHandler |
| `UPPopover` | Public onOpen/onClose/onClick method aliases |
| `UPNoticeBar` | Public click alias |
| `UPSwiper` | getItemType/getSource/getPoster already public (Batch E verified) |
| `UPPdfReader` | Public load/reload shells around notify |

| `UPAvatarGroup` | Public clickHandler |
| `UPButton` | Public clickHandler + openType shells (getphonenumber/getuserinfo/...) |
| `UPCard` | Public click/headClick/bodyClick/footClick |
| `UPCircleProgress` | Public init/getProgress |
| `UPCollapse` | Public init/onChange method alias |
| `UPIcon` | Public clickHandler/isImg |
| `UPImage` | Public clickHandler/onClickHandler/load/error shells |
| `UPText` | Public clickHandler/onClickHandler |
| `UPView` | Public clickHandler/onClickHandler |
| `UPLineProgress` | Public init/getProgressWidth/getPercentage |
| `UPReadMore` | Public init/getContentHeight |
| `UPSearch` | Public getFocus/blurFunc aliases |
| `UPTable` | Public change shell |
| `UPTooltip` | Public init/getElRect/longpressHandler |
| `UPTree` | Public toggle/updateChildCheckStatus/updateParentCheckStatus |
| `UPIndexList` | Public init/scrollHandler/setValueForTouch |
| `UPCropper` | Public close/start/preview/getImgData |
| `UPActionSheet` | Public getItemHoverStyle |
| `UPTabs` | Public getAllItemRect/getTabsRect/setLineLeft |
| `UPWaterfall` | Public handleData/redistributeData |
| `UPSlider` | Public updateValue alias |
| `UPRate` | Public emitEvent/getElRect/getIconRect |

## customStyle

- Default: `BoxDecoration? customStyle` on widget roots
- Exception: `UPLink.customStyle` remains `TextStyle?` (source text style)
- `UPToast` is helper API, not a widget

## Verification

- `flutter test` in `packages/ultra_ui` (target: all green)
- Example gallery under `example/`


| `UPLoadmore` | Public loadMore/loadmore |
| `UPLink` | Public openLink/clickHandler |
| `UPLineProgress` | Public resizeProgressWidth |
| `UPSearch` | Public clickIcon |
| `UPInput`/`UPTextarea`/`UPNumberBox` | Public onFocus/onBlur aliases |
| `UPImage` | Public removeBgColor shell |
| `UPCropper` | Public hideImg shell |
| `UPCateTab`/`UPTooltip`/`UPTabs` | Public getElRect/queryRect |
| `UPPopup` | Public getWindowInfo |
| `UPCascader` | Public initLevelList/genTabsList/emitChange/toFatherIndex/tabsChange/levelChange |
| `UPGoodsSku` | Public getSelectedSku/getSelectedSkuComb aliases |
| `UPTree` | Public initTree/toggleExpand/setNodeChecked/getNodeByKey/getCurrentKey/emitCheck/walkNodes |
| `UPDatetimePicker` | Public correctValue/getRanges/getBoundary/generateArray/updateColumns/onShowByClickInput |
| `UPCalendarStrip` | Public getDateId/dayStyle/scrollToDate/syncByValue/getMonths/date helpers |
| `UPCanvas` | Public getCanvasElement/getRawContext/getWidth/getHeight/callContext/getImageData/putImageData |
| `UPBarcode` | Public encodeCode128/39/EAN/UPC/drawBarcode aliases |
| `UPRate` | Public normalizeActiveIndex/touchMove/touchEnd/getFallbackRateWidth |
| `UPSignature` | Public resolveStrokeColor/getCanvasInstance/getCanvasPoint |
| `UPMarkdown` | Public handleCodeBlock/applyTheme |
| `UPShortVideo` | Public onLoadedMetadata/onTimeUpdate/onVideo* method aliases |
| `UPTable2` | Public selectChildren/unselectChildren/loadLazyChildren/getSortIcon/getSortValue/headerColStyle/setCellStyle |



| `UPCalendar` | Public subtitle/currentMonths/singleDateLabel/range*Label/todayDisabled/switch*YearDisabled/selectedChange + time-panel shells |
| `UPColorPicker` | Public displayColor/gradientStyle/saturation+hue touch shells/initDirectionPointer |
| `UPInput` | Public onInput/onConfirm/onClear/valueChange/isPassword/isShowClear/keyboard shells |
| `UPTextarea` | Public valueChange/onConfirm |
| `UPNumberBox` | Public isDisabled/format/filter/onInput/onChange/add |
| `UPCropper` | Public move/end/complete/success/fail/btop/imageResize/avatarSrc |
| `UPPoster` | Public getTextStyle/convertRpxToPx/generateQRCode/draw shells/dataURLToBlob |
| `UPUpload` | Public popupShow/onBeforeRead/fail/onClickPreview |
| `UPCountTo` | Public countDown/easingFn/requestAnimationFrame/cancelAnimationFrame |
| `UPAlbum` | Public showUrls/imageStyle/imageWidth/imageHeight |
| `UPSwitch` | Public switchStyle/nodeStyle/bgStyle/resolved color shells |
| `UPSelect` | Public resolved style shells + options style maps |
| `UPTree` | Public cloneNodes/collectVisibleNodes/getNodeClass/getNodeContentStyle/getIndentValue |
| `UPTabs` | Public showLine/shapeModeClass/itemComputedStyle/propsBadge/animation |

| `UPCalendar` | Public prevMonth/nextMonth/getMonths/monthTitle/dateSame/isSelectedDate/isForbid/getDefaultMonthIndex/getDefaultTimeValue/initTimeOptions/appendTime/selectDate/selectToday/scrollIntoDefaultMonth + month rect shells |
| `UPColorPicker` | Public alpha/direction/pointer touch shells + hslToRgb/hue2rgb/round/updateDirection/confirmDirection |
| `UPSlider` | Public canNotDo/format/formatStep/getRange/getSliderRect/getTouchX/initX/setTouchStatus/updateSliderPlacement/emitEvent/digitLength/sleep |
| `UPSwipeActionItem` | Public init/initialize/openSwipeAction/closeSwipeAction/setStatus/moveSwipeAction/buttonClickHandler/clickHandler/queryRect/getContentRef/getDuration + touch shells |
| `UPCountDown` | Public toTick/macroTick/microTick |
| `UPCanvas` | Public initCanvas/getCanvasElement/getCanvasNode/exportImage/complete/success/fail + onTouch* |
| `UPDragSort` | Public initList/handleAllModeChange/onChange/reorderItems/updatePositions + touch/sleep shells |
| `UPUpload` | Public afterRead/onAfterRead/toast |
| `UPNavbarMini` | Public leftClick/homeClick |
| `UPCateTab` | Public swichMenu/getMenuItemTop/leftMenuStatus/observer/rightScroll |
| `UPCalendarStrip` | Public findFirstEnabledDate/onTouchStart/onTouchEnd |
| `UPCollapse` | Public clickHandler/queryRect/setContentAnimate/updateParentData |
| `UPTransition` | Public getClassNames/vueEnter/vueLeave/nvueEnter/nvueLeave/onTransitionEnd/waitTick |
| `UPButton` | Public launchapp shell |

| `UPCalendar` | Public setMonth/setDefaultDate/timeToSecond/pickerValueToTime/validateSameDayRangeTime |
| `UPGrid`/`UPGridItem` | Public init/childClick/clickHandler/gridItemClasses |
| `UPSteps`/`UPStepsItem` | Public init/getStepsItemRect |
| `UPNoticeBar` | Public init/clickHandler/getNvueRect |
| `UPList`/`UPListItem` | Public init/queryRect |
| `UPCityLocate` | Public success/fail shells |
| `UPCopy` | Public success/fail shells |
| `UPCountTo` | Public callback/clearTimeout |
| `UPDatetimePicker` | Public formatter/intercept |
| `UPParse` | Public fail/traversal |
| `UPPoster` | Public getPosterCanvas/drawItem |
| `UPRate` | Public getRateItemRect/toNumber |
| `UPTree` | Public toggleCheck/callback |
| `UPNumberBox` | Public handler alias |
| `UPButton` | Public upThemeVar |
| `UPBarcode` | Public encodeEAN52/encodeUPCE/validator |
| `UPNoNetwork` | Public openSettings |
| `UPLink` | Public toast shell |
| `UPCarKeyboard` | Public clearInterval |
| `UPInput` | Public formValidate |
| `UPCode` | Public clearInterval |
| `UPCropper` | Public initCanvasRefs/drawInit/colorChange/prvUpload |

| `UPCalendarStrip` | Public hasMinDate/hasMaxDate/innerMinDate/innerMaxDate/minDateDay/maxDateDay/panelMinDate/panelMaxDate/panelMonthNum/todayDate/monthLabel/monthDays/switchPrevDisabled/switchNextDisabled/rangeChange |
| `UPCalendar` | Public innerMinDate/innerMaxDate/todayDate/switchPrevDisabled/switchNextDisabled/buttonDisabled; init baseMonth prefers defaultDate then clamps to min/max |
| `UPPagination` | Public pageSizeIndex/pageSizeLabel |
| `UPVirtualList` | Public visibleItems |
| `UPCodeInput` | Public codeLength/codeArray |
| `UPPicker` | Public inputValue/inputLabel/inputPropsInner/maskStyleInner |
| `UPNumberBox` | Public getCursorSpacing |
| `UPButton` | Public iconColorCom |
| `UPToast` | Public static iconName |
| `UPTable2` | Public filteredData/visibleFixedLeftColumns/cellStyleInner |
| `UPPopup` | Public position/contentStyleWrap |
| `UPIndexList` | Public indicatorTop |
| `UPTabbar` | Public updateChild |
| `UPTree` | Public labelKey/childrenKey/disabledKey/keyField |
| `UPCascader` | Public isChange |

| `UPCalendar` | Public dayStyle/daySelectStyle/textStyle/getBottomInfo/getWrapperWidth/handler/resolve/resolvedTodayColor/sleep |
| `UPCalendarStrip` | Public pullHintText |
| `UPQrcode` | Public getUTF8Bytes/unicodeFormat8/setFillStyle/setStrokeStyle/setLineWidth/drawRoundedRect |
| `UPUpload` | Public formatFile/formatImage/formatVideo/formatMedia/pickExclude |
| `UPParse` | Public decodeEntity/makeMap/mergeNodes |
| `UPScrollList` | Public barStyle/lineStyle |
| `UPTransition` | Public mergeStyle/setTimeout |
| `UPDatetimePicker` | Public times |

| `UPTabsItem` | Added source alias content pane widget |
| `UPSwiperIndicator` | Added standalone indicator widget + lineStyle/dotStyle |

Last update: 2026-07-25 (Batch M alias widgets; flutter test 446 green)

| `UPInput` | modelValue/onUpdateModelValue/effectiveValue + host props (adjustPosition/autoBlur/...) |
| `UPTextarea` | modelValue/onUpdateModelValue/effectiveValue + adjustPosition |
| `UPSearch` | modelValue/onUpdateModelValue/effectiveValue + adjustPosition/autoBlur |
| `UPSlider` | modelValue/onUpdateModelValue/effectiveValue + innerStyle/useNative |
| `UPPicker` | modelValue/onUpdateModelValue/effectiveValue + maskStyle/maskClass |
| `UPBadge` | modelValue preferred over value |
| `UPPopup` | overlayStyle |
| `UPText` | iconStyle/openType |
| `UPIcon` | hoverClass/imgMode |
| `UPActionSheet` | openType |
| `UPSwitch` | onUpdateModelValue dual emit |
| `UPRate` | onUpdateModelValue dual emit |

Last update: 2026-07-25 (Batch N modelValue aliases; flutter test 447 green)

| `UPCodeInput` | modelValue/onUpdateModelValue/effectiveValue |
| `UPDatetimePicker` | modelValue/onUpdateModelValue/effectiveValue |
| `UPNumberBox` | modelValue/onUpdateModelValue/effectiveValue |
| `UPCheckboxGroup` | modelValue/onUpdateModelValue/effectiveValue |
| `UPRadioGroup` | modelValue/onUpdateModelValue/effectiveValue |
| `UPDropdownItem` | modelValue/onUpdateModelValue/effectiveValue |

Last update: 2026-07-25 (Batch O modelValue aliases; flutter test 448 green)

| `UPPopup` | onUpdateShow dual emit on open/close |
| `UPCalendar` | onUpdateShow on close |
| `UPSelect` | onUpdateShow on openSelect/closeSelect |
| `UPOverlay` | onUpdateShow retained host prop |
| `UPNotify` | onUpdateShow on show/close |
| `UPNoNetwork` | onUpdateShow on show/hide |
| `UPTooltip` | onUpdateShow on open/close |

Last update: 2026-07-25 (Batch P onUpdateShow aliases; flutter test 449 green)

| `UPTabbar` | modelValue/onUpdateValue/onUpdateModelValue/effectiveValue |
| `UPMessageInput` | modelValue/onUpdateModelValue/effectiveValue |
| `UPColorPicker` | onUpdateValue/onUpdateModelValue dual emit |
| `UPSteps` | modelValue/onUpdateCurrent/onUpdateModelValue/setCurrent |
| `UPCityLocate` | onUpdateCurrent |
| `UPShortVideo` | onUpdateCurrentTab/onUpdateCurrentVideo |
| `UPPagination` | modelValue/onUpdateModelValue for current page |

Last update: 2026-07-25 (Batch Q modelValue/current aliases; flutter test 450 green)

| `UPTransition` | onUpdateShow on open/close |
| `UPCollapse` | modelValue/onUpdateModelValue/effectiveValue |
| `UPWaterfall` | modelValue/onUpdateModelValue/effectiveValue dual emit with onUpdateValue |

Last update: 2026-07-25 (Batch R aliases; flutter test 451 green)

| `UPCascader` | modelValue/onUpdateModelValue/effectiveValue dual emit |
| `UPCheckbox` | onUpdateChecked dual emit + group uses effectiveValue |
| `UPStatusBar` | onUpdateHeight dual emit with onHeight |
| `UPActionSheetData` | Added source alias data shell widget |
| `UPPickerData` | Added source alias data shell widget |
| `UPPickerColumn` | Added source alias column shell widget |

Last update: 2026-07-25 (Batch S residual aliases; flutter test 452 green)

| `UPTabs` | modelValue/onUpdateModelValue/effectiveCurrent dual emit with onUpdateCurrent |
| `UPSubsection` | modelValue/onUpdateModelValue/effectiveCurrent dual emit |
| `UPSwiper` | modelValue/onUpdateModelValue/effectiveCurrent dual emit |
| `UPSelect` | modelValue/onUpdateModelValue/effectiveCurrent dual emit |
| `UPCateTab` | modelValue/onUpdateModelValue/effectiveCurrent dual emit |

Last update: 2026-07-25 (Batch T current modelValue aliases; flutter test 453 green)

| `UPCalendar` | forbidDays/maxRange/rangePrompt/rangeResultMode/monthSwitch/showSwitch/monthFormat/overlayStyle/safeAreaInsetTop + helpers |
| `UPForm` | formRules/setFormRules aliases |
| `UPCityLocate` | onUpdateModelValue/onUpdateCurrentCity dual emit |
| `UPShortVideo` | onUpdateModelValue dual emit with onUpdateCurrentVideo |

Last update: 2026-07-25 (Batch U residual host props; flutter test 454 green)

| `UPNumberBox` | iconStyle retained host prop |
| `UPTransition` | viewStyle retained host prop |
| `UPImage` | backgroundStyle retained host prop |
| `UPDropdown` | contentStyle retained host prop |
| `UPDatetimePicker` | filter/maskStyle/maskClass retained |
| `UPLoadingIcon` | show/inactiveColor/textColor/timingFunction/styles + show gate |
| `UPSlider` | barStyle/barStyle0 retained |
| `UPSteps` | options retained host data mode |
| `UPGrid` | options retained host data mode |
| `UPCalendarStrip` | collapseAfterSelect/pullDownThreshold retained |
| `UPTabs` | styles retained host prop |
| `UPCalendar` | scrollIntoView retained host prop |

Last update: 2026-07-25 (Batch V retained host-only props; flutter test 455 green)

| `UPBarcode` | marginTop/Bottom/Left/Right + useCanvas |
| `UPTooltip` | tooltipInfo/triggerInfo/indicatorStyle/tooltipStyle |
| `UPColorPicker` | currentDirection/solidColorState/gradientColorState/saturationPosition/directionPointer/gradientDirections |
| `UPCropper` | imgSrc alias + imgStyle/selStyle |
| `UPToast` | config/params/tmpConfig shells |
| `UPIndexList` | options/sys/letterInfo retained |
| `UPScrollList` | scrollInfo shell |
| `UPTable2` | cellClassName/headerCellClassName/rowClassName/showOverflowTooltip/filters/sortMethod/spanMethod/tableContext |
| `UPParse` | entities/svgDict retained |
| `UPSkeleton` | styles retained |
| `UPCircleProgress` | styles retained |

Last update: 2026-07-25 (Batch W residual host props; flutter test 456 green)

| `UPCropper` | lockWidth/lockHeight/stretch/lock/index + confirm index |
| `UPNotify` | config/tmpConfig public getters/setters |
| `UPSelect` | optionsWrapLeft/optionsWrapRight shells |
| `UPList` | sys retained host prop |
| `UPShortVideo` | speedOptions shell |
| `UPCalendar` | hourOptions/minuteOptions/secondOptions |
| `UPTransition` | classes shell |
| `UPCheckbox` | parentData shell |
| `UPRadio` | parentData shell |

Last update: 2026-07-25 (Batch X residual data shells; flutter test 457 green)

| `UPCropper` | cvsStyleHeight/styleDisplay/styleTop layout data shells + start/close/hideImg sync |

Last update: 2026-07-25 (Batch Y cropper layout shells; flutter test 458 green)

| `UPCropper` | instanceId/prvTop/showOper + windowResize |
| `UPSlider` | changeFromInside/touching/status/distance*/start*/newValue/info/sliderRect |
| `UPCountTo` | displayValue/printVal/localStartVal/localDuration/paused/remaining/lastTime/startTime/timestamp/rAF |
| `UPInput` | innerValue/focused/showPassword/blurValue/changeFromInner/clearInput/firstChange/innerFormatter |
| `UPTextarea` | innerValue/focused/changeFromInner/firstChange/innerFormatter |
| `UPTabs` | lineShow/lineOffsetLeft/scrollLeft/scrollViewWidth/tabList/tabsRect |
| `UPPopup` | currentHeight/isTouching/overlayDuration/touchStartHeight/touchStartY |
| `UPTooltip` | showTooltip/textId/tooltipId/tooltipTop |
| `UPTree` | currentKey/nodeMap/privateKeySeed/treeData |
| `UPCountDown` | endTime/runing/timer/formattedTime |
| `UPPullRefresh` | isRefreshing/touching/currentY/startY/contentTranslateY/refreshDistance |
| `UPRate` | moving/rateWidth/rateBoxLeft/elClass/elId |
| `UPColorPicker` | currentColor/lightness/alphaPosition/huePosition/draggingPointerIndex/showDirectionPicker |
| `UPShortVideo` | progressValue/showSpeedSheet/currentSpeedVideoIndex |
| `UPLazyLoad` | isShow/isError/loadStatus/elIndex/time |
| `UPSignature` | canvasId/canvasInstance/canvasWidth/canvasHeight/isDrawing/lastPoint/currentPath/pathStack/lineColor/lineWidth |

Last update: 2026-07-25 (Batch Z residual internal data shells; flutter test 459 green)

| `UPCalendar` | innerFormatter/listHeight/monthIndex/range*Time/scroll*/singleTime/timePicker* |
| `UPCateTab` | arr/itemId/menuHeight/menuItemHeight/menuItemPos/oldScrollTop/rects/scroll*/timer |
| `UPBarcode` | canvasId/tempCanvasId/canvasWidth/canvasHeight/calcSizeDone/showCanvas/barcodeImage/error |
| `UPPoster` | canvasId/canvasWidth/canvasHeight/showCanvas/qrCode* |
| `UPTable2` | fixedLeftColumns/headerHeight/scrollLeft/scrollWidth/showFixedColumnShadow/tableHeight |
| `UPUpload` | currentItemIndex/isInCount/successIcon/videoThumbCanvas* |
| `UPCalendarStrip` | innerSelectedDate/innerShowFull/scrollIntoView/touchStartX/touchStartY |
| `UPCanvas` | ctx/dpr/heightLocal/widthLocal/rootId |
| `UPImage` | durationTime/isError/loading/opacity/show |
| `UPDatetimePicker` | innerDefaultIndex/innerFormatter/inputValue/showByClickInput |
| `UPDropdown` | menuList/opacity/showDropdown/zIndex |
| `UPQrcode` | list/loading/name/popupShow |
| `UPCodeInput` | inputValue/isFocus/timer |
| `UPTransition` | display/inited/transitionEnded |
| `UPWaterfall` | initialized/windowHeight/windowWidth |
| `UPAlbum` | singleHeight/singlePercent/singleWidth |

Last update: 2026-07-25 (Batch AA residual data shells wave2; flutter test 460 green)

| `UPAvatar` | allowMp/avatarUrl data shells |
| `UPCascader` | popupShow/selectedValueIndexs data shells |
| `UPCircleProgress` | leftBorderColor data shell |
| `UPGuide` | closing/innerShow data shells |
| `UPIndexList` | touchmoveIndex data shell |
| `UPLoadingIcon` | array12/length + setTimeout shell |
| `UPNoNetwork` | isConnected data shell |
| `UPNumberKeyboard` | cardX/dot data shells |
| `UPPicker` | showByClickInput/innerIndex data shells |
| `UPScrollList` | scrollWidth data shell |
| `UPSearch` | focused/show data shells |
| `UPSticky` | cssSticky + checkSupportCssSticky |
| `UPForm` | originalModel data shell |
| `UPList` | innerScrollTop data shell |
| `UPMessageInput` | valueModel data shell |
| `UPNumberBox` | longPressTimer data shell |
| `UPPagination` | currentPageInput data shell |
| `UPPdfReader` | baseUrlInner data shell |
| `UPReadMore` | elId data shell |
| `UPStatusBar` | isH5 data shell |
| `UPSubsection` | itemRect data shell |
| `UPCanvas` | parseSize/rootId/setTimeout shells |
| `UPButton` | resolveNvueColor shell |
| `UPCheckbox`/`UPRadio`/`UPBackTop` | error shells |
| `UPToast` | isShow/complete/typeof shells |
| `UPEmpty`/`UPGrid`/`UPLineProgress`/`UPLoadmore`/`UPMarkdown`/`UPQrcode`/`UPSafeBottom` | residual data shells |

Last update: 2026-07-25 (Batch AB residual shells cleanup; flutter test 461 green)

| residual data | UPTabbar.placeholderHeight / UPTable.show |
| residual methods | setTimeout/sleep/resolve/reject/error/parseFloat/getComponentWidth/applyFont/selectCommonColor/updateGradientColor/updateSolidColor/formValidate/exportSignature/getTextViewDisableClass/clickHander/clearTimeout + parse/qrcode private shells |

Last update: 2026-07-25 (Batch AC residual methods cleanup; flutter test 462 green)

| residual props | UPCalendar nav disables / UPLazyLoad.isEffect / UPTable2.parentRow / UPTree.depth |
| residual emits | onInput aliases / canvas touch aliases / markdown+parse emit aliases / input platform shells / signature confirm+error / table2 onFilterChange / qrcode onLongpressCallback |

Last update: 2026-07-25 (Batch AD residual props emits; flutter test 463 green)

| residual props | UPCalendar.todayColor / UPNumberBox.cursorSpacing |
| residual emits | calendar nav+monthSelected / button openType emits / slider drag-* / qrcode preview+result / table2 toggleExpand+toggleSelect |

Last update: 2026-07-25 (Batch AE residual props emits wave2; flutter test 464 green)

| residual aliases | UPSearch.onInput / UPUpload.beforeRead |
| note | remaining prop/emit scan hits are comment false-positives (https/HH/display) or already covered (swipe onOpendItemUpdate) |

Last update: 2026-07-25 (Batch AF residual alias cleanup; flutter test 465 green)

| residual computed | first wave style shells on button/cell/input/numberBox/search/subsection/text/canvas/navbar/actionSheet/textarea + method shells slider.initButtonStyle/table2.getComponentWidth/canvas.rgba/text.formatName |

Last update: 2026-07-25 (Batch AG residual computed style shells; flutter test 466 green)

| residual computed | second wave style shells across ~49 widgets (checkbox/radio/dropdown/messageInput/table/tag/toast/datetimePicker/icon/image/indexList/popup/rate/signature/sticky/backTop/badge/cascader/circleProgress/codeInput/coupon/empty/grid/guide/lazyLoad/lineProgress/loadmore/noticeBar/notify/numberKeyboard/skeleton/slider/tooltip/tree/upload/virtualList/alert/avatar/avatarGroup/collapse/form/keyboard/link/list/loadingIcon/loadingPage/modal/numberBox/overlay...) |

Last update: 2026-07-25 (Batch AH residual computed style shells wave2; flutter test 467 green)

| residual computed | third wave nested/layout shells: tabbar/tabbarItem/steps/gap/line/divider/row/col/indexAnchor/rowNotice/columnNotice/formItem/radioGroup/cellGroup/checkboxGroup/dragSort/dropdownItem/gridItem/pickerData/readMore/safeBottom/statusBar/swiper/tabs/view/waterfall |

Last update: 2026-07-25 (Batch AI residual computed style shells wave3; flutter test 468 green)

| residual computed | final cleanup: UPEmpty.isSrc / UPStepsItem.statusClass / UPTag.closeSize |

Last update: 2026-07-25 (Batch AJ residual computed style shells final; flutter test 469 green)

| residual props/emits | UPCollapseItem cell/title/icon styles; UPStepsItem.itemStyle; radio/checkbox/dropdown onInput aliases |

Last update: 2026-07-25 (Batch AK residual props emits cleanup; flutter test 470 green)

| residual methods | dragSort size helpers / gridItem width helpers / rowNotice nvue+vue / divider.click / radioGroup.unCheckedOther / row.getComponentWidth |

Last update: 2026-07-25 (Batch AL residual method shells cleanup; flutter test 471 green)

| residual methods/computed/data | test* helpers; alert/badge/button/popup/tag computed; cropper/dragSort/indexList/qrcode/collapseItem/rowNotice/tooltip/col/dropdown/formItem/loadingIcon/subsection/tabbarItem/tabs/colorPicker/gridItem/indexItem/slider/stepsItem/td data shells |

Last update: 2026-07-25 (Batch AM residual methods computed data shells; flutter test 472 green)

| style parity | UPButton computed real values (bemClass/themeTypeColor/baseColor/textSize/loadingColor); UPAlert.alert; UPGridItem.onUGridItem |
| residual scan | methods/computed/data = 0; props/emits near-zero (alert/grid done) |

Last update: 2026-07-25 (Batch AN button style parity and residual props; flutter test 473 green)

Last update: 2026-07-25 (Batch AO tag badge style parity; flutter test 474 green)

| style parity | UPTag/UPBadge real computed (style/textColor/imgStyle/closeSize/iconSize/showValue/badgeStyle) |

Last update: 2026-07-25 (Batch AO tag badge style parity; flutter test 474 green)

| style parity | UPTag/UPBadge real computed (style/textColor/imgStyle/closeSize/iconSize/showValue/badgeStyle) |

Last update: 2026-07-25 (Batch AP cell input search number style parity; flutter test 475 green)

| style parity | UPCell/UPInput/UPSearch/UPNumberBox computed real values; UPUtils.addUnit/colorToHex |

Last update: 2026-07-25 (Batch AQ popup tabs textarea subsection navbar action style parity; flutter test 476 green)

| style parity | UPPopup/UPTabs/UPTextarea/UPSubsection/UPNavbar/UPActionSheet computed real values |

Last update: 2026-07-25 (Batch AR alert empty icon rate notice checkbox radio toast style parity; flutter test 477 green)

| style parity | UPAlert/UPEmpty/UPIcon/UPRate/UPNoticeBar/UPCheckbox/UPRadio/UPToast computed real values |

Last update: 2026-07-25 (Batch AS loadmore skeleton image backTop link progress code upload loading modal overlay slider style parity; flutter test 478 green)

| style parity | UPLoadmore/UPSkeleton/UPImage/UPBackTop/UPLink/UPLineProgress/UPCodeInput/UPUpload/UPLoadingIcon/UPLoadingPage/UPModal/UPOverlay/UPSlider computed real values; UPUtils.colorGradient |

Last update: 2026-07-25 (Batch AT tabbar layout steps sticky list text swiper style parity; flutter test 479 green)

| style parity | UPTabbar/UPTabbarItem/UPGap/UPLine/UPDivider/UPRow/UPCol/UPSteps/UPStepsItem/UPSticky/UPStatusBar/UPSafeBottom/UPList/UPText/UPSwiper computed real values |

Last update: 2026-07-25 (Batch AU dropdown form grid index notice radio checkbox notify style parity; flutter test 480 green)

| style parity | UPDropdown/UPDropdownItem/UPFormItem/UPGrid/UPGridItem/UPCellGroup/UPRadioGroup/UPCheckboxGroup/UPNotify/UPIndexList/UPIndexAnchor/UPRowNotice/UPColumnNotice computed real values |

Last update: 2026-07-25 (Batch AV residual style parity cleanup; flutter test 481 green)

| style parity | UPTable/UPMessageInput/UPSignature/UPNumberKeyboard/UPKeyboard/UPCircleProgress/UPCoupon/UPTooltip/UPReadMore/UPLazyLoad/UPAvatar/UPAvatarGroup/UPDragSort/UPView/UPCollapse/UPCascader/UPDatetimePicker/UPGuide/UPVirtualList/UPWaterfall/UPTree/UPCanvas/UPPickerData computed real values |

Last update: 2026-07-25 (Batch AW residual data shells defaults; flutter test 482 green)

| residual data | high-traffic defaults aligned to source data(): loadingIcon/tooltip/cropper/slider/colorPicker/gridItem/rowNotice/formItem/collapseItem/tabs/subsection/qrcode/indexList/dragSort/radio/checkbox |
| note | Source data shell markers cleared; remaining state fields retained as Source data |

Last update: 2026-07-25 (Batch AX residual method shells real defaults; flutter test 483 green)

| residual methods | formatName/displayValue, colorPicker update/select, radio unCheckedOther, signature exportSignature, canvas rgba, slider initButtonStyle, dragSort calculate* |
| note | Source method shell markers still present for host-only helpers (setTimeout/sleep/resolve/reject/test*) |

Last update: 2026-07-25 (Batch AY residual method shells; flutter test 484 green)

| residual methods | tooltip clickHander/btnClick offset, sticky checkSupportCssSticky, subsection getTextViewDisableClass, grid getItemWidth/getParentWidth, formValidate wiring, getComponentWidth measured |
| note | Pure host helpers (setTimeout/sleep/resolve/reject/test*) relabeled Source host helper; Source method shell markers cleared (0 remaining) |

Last update: 2026-07-25 (Batch AZ residual polish shells; flutter test 485 green)

| residual polish | lazy getThreshold rpx sign, dropdown getContentHeight, album getImageRect, tree isExpanded query, tabbar placeholderHeight, action hideKeyboard |
| note | Source computed shell markers: 0 after tree relabel; remaining host helpers intentional |

Last update: 2026-07-25 (Batch BA residual shell polish; flutter test 486 green)

| residual polish | form/datetime/tooltip propsChange lists, rate ensureRateMetrics, subsection getRect live-measure, image removeBgColor, markdown applyTheme (Expando), picker hideKeyboard |
| note | UPMarkdown keeps const ctor; appliedTheme stored via Expando for API parity |

Last update: 2026-07-25 (Batch BB residual shell polish; flutter test 487 green)

| residual polish | parse getRect/openExternalLink, qrcode utf8/export context, barcode canvas/ref, lazy load status handlers, popup getWindowInfo, calendarStrip dayStyle |
| note | old BatchE null expects updated for real canvas context/ref maps |

Last update: 2026-07-25 (Batch BC residual shell polish; flutter test 488 green)

| residual polish | select adjustOptionsWrapPosition measure, tabbar updatePlaceholder height, steps updateChildData snapshot, upload popupShow state, canvas getImageData/putImageData |
| note | remaining named shells mostly host/no-op lifecycle (init/updateParent*) or platform-only media/canvas |

Last update: 2026-07-25 (Batch BD residual shell polish; flutter test 489 green)

| residual polish | checkbox/radio parentData from props, numberBox long-press state, table change payload, pdf load, calendar selectedChange; mass shell-comment cleanup |
| note | remaining "shell" comments mostly host-only/platform no-ops and retained fields |

Last update: 2026-07-25 (Batch BE residual shell polish; flutter test 490 green)

| residual polish | textarea onKeyboardheightchange/keyboardHeight, upload videoErrorCallback/loadedVideoMetadata + onError; residual shell-comment cleanup |
| note | host-only/platform no-ops retained; next: calendar time picker + strip gestures + color alpha |

Last update: 2026-07-25 (Batch BF residual shell polish; flutter test 491 green)

| residual polish | calendar enableTime/timePrecision/defaultTime + open/confirm/change time picker, applySelectedTimes on confirm; strip rangeChange/onTouch swipe expand; colorPicker alpha set/touch |
| note | pickerValueToTime respects precision (minute default => HH:mm); host-only empty methods remain |

Last update: 2026-07-25 (Batch BG residual shell polish; flutter test 492 green)

| residual polish | input keyboardheightchange, image onLoad/onError Expando, checkboxGroup unCheckedOther, checkbox/avatar/copy/grid init state, dropdownItem cellClick emit, countTo callback/onEnd, collapse setContentAnimate timer + updateParentData |
| note | collapse Future.delayed replaced with cancelable Timer to avoid pending-timer test failure |


Last update: 2026-07-25 (Batch BH residual shell polish; flutter test 493 green)

| residual polish | datetime setFormatter, slider touch, swipeAction touch/anim, indexList rects, cropper/canvas success, notice loop, virtualList measure, radio/list/tabbar init Expando, dragSort touch, tree callback |
| note | fixed tabbar import order + BH IndexList children typing + cropper/datetime layout constraints |


Last update: 2026-07-25 (Batch BI residual shell polish; flutter test 494 green)

| residual polish | popup afterEnter/touch resize, markdown emitPlay/Error, textarea lineCount, shortVideo speed panel, sticky disconnect, city fail, form/col/steps init Expando, progress init, poster/qrcode draw shells, cropper imageResize, noNetwork settings flags, keyboard/waterfall clear flags, colorPicker touchPhase ends |
| note | host-only platform openType/media shells retained |


Last update: 2026-07-25 (Batch BJ residual shell polish; flutter test 495 green)

| residual polish | button contact/chooseavatar, calendar toast/scroll/monthTop, canvas applyFont, parse media/fail, refresh handleScroll, skeleton nvue, swiper pauseVideo, table2 onScroll, upload/link/noNetwork toast, backTop/checkbox/radio/datetime error, loading webview listener, swipe unbind, popup noopCount |
| note | host-only platform openType/media shells retained; remaining pure no-ops should be intentional |


Last update: 2026-07-25 (Batch BK residual shell polish; flutter test 496 green)

| residual polish | parse _set/_onMessage/_hook, qrcode loading/popup/result/canvasHost/ctx/_empty, barcode image/error, scrollList scrollHandler, datetime inputValue, safeBottom measured height, loading webviewHide/loading, tabs moving, tooltip calcReacted, indexList scrollTop/scrolling |
| note | host-only platform openType/media shells retained; remaining pure no-ops should be intentional |

Last update: 2026-07-25 (Batch BL residual shell polish; flutter test 497 green)

| residual polish | choose currentIndex, cropper ar/exp/safeBottom measure, dragSort measure/touch/move, dropdown contentHeight, skeleton width, collapse expanded/showBorder/parentData, radio checked, tabbar isActive, steps index/parentData |
| note | fixed UPStepsItem duplicate _state + missing _upTabbarItemActive Expando; host-only platform openType/media shells retained |

Last update: 2026-07-25 (Batch BM residual shell polish; flutter test 498 green)

| residual polish | formItem itemRules/parentData, gridItem classes, virtualList placeholders, tdStyle from props, dropdown highlightIndexList, tabbarItem parentData, index pageY/indicator/scrollIntoView, tabs propsBadge defaults |
| note | const defaults preserved via Expando/widget-level snapshots; host-only platform openType/media shells retained |

Last update: 2026-07-25 (Batch BN residual shell polish; flutter test 499 green)

| residual polish | badge boxStyle, cell group/title/label/value styles, empty icons list, keyboard popupStyle, rowNotice animationDuration/playState, collapse animationData, formItem labelDynamicStyle |
| note | const defaults preserved; host-only platform openType/media shells retained |

Last update: 2026-07-25 (Batch BO residual shell polish; flutter test 500 green)

| residual polish | popup contentStyleWrap height/min/max, subsection barStyle measured, col parentData from row gutter, qrcode canvasObj, toast contentStyle position offset, table2 row/span/fixed styles |
| note | const defaults preserved; host-only platform openType/media shells retained |

Last update: 2026-07-25 (Batch BP popup/table2 render parity; flutter test 501 green)

| style/render parity | UPPopup touch drag constrains and renders runtime height, including percentage maxHeight; UPTable2 applies rowStyle/cellStyle and rowspan/colspan geometry in its Flutter render tree |

Last update: 2026-07-25 (Batch BQ swiper circular render parity; flutter test 502 green)

| behavior parity | UPSwiper circular navigation uses boundary clone pages for seamless first/last transitions; change and model update callbacks emit once per logical index transition; string video URLs are detected consistently |

Last update: 2026-07-25 (Batch BR drag-sort grid behavior parity; flutter test 503 green)

| behavior parity | UPDragSort `direction=all` renders and reorders a real column-constrained grid; handler-only initiation, per-item `draggable:false`, haptic feedback, final drag-end emission, and grid `x/y` position snapshots are retained |

Last update: 2026-07-25 (Batch BS table2 fixed-left behavior parity; flutter test 504 green)

| behavior parity | UPTable2 horizontal scrolling updates source-compatible scroll fields and renders an interactive, clipped fixed-left column overlay with shadow after scrolling |

Last update: 2026-07-25 (Batch BT cate-tab follow scroll state parity; flutter test 505 green)

| behavior parity | UPCateTab `follow` tracks rendered section positions, keeps `menuItemPos`/`rects` and right-scroll snapshots current, updates the active menu from user scroll, and records `itemN` scroll targets for menu navigation |

Last update: 2026-07-25 (Batch BU table2 fixed-header behavior parity; flutter test 506 green)

| behavior parity | UPTable2 constrained-height tables keep the header visible while only the body vertically scrolls; fixed-left overlays retain the same body scroll offset |

Last update: 2026-07-25 (Batch BV tree indeterminate selection parity; flutter test 507 green)

| behavior parity | UPTree renders parent partial selection as a real tri-state checkbox, while existing cascade, disabled-node handling, checked/half-checked APIs, and check callbacks remain synchronized |

Last update: 2026-07-25 (Batch BW select portal overlay parity; flutter test 508 green)

| behavior parity | UPSelect options render in a root anchored OverlayEntry, survive clipped ancestors, track the trigger, align away from the right edge, and dismiss through a page-level barrier while retaining open/close/select APIs |

Last update: 2026-07-25 (Batch BX overlay zIndex parity; flutter test 509 green)

| behavior parity | UPOverlay uses a root-overlay registry sorted by numeric zIndex, with declaration order as the same-zIndex tie breaker; visible masks now paint and receive input according to source fixed-position CSS layering |

Last update: 2026-07-25 (Batch BY loading-page zIndex parity; flutter test 510 green)

| behavior parity | UPLoadingPage uses the same root-overlay zIndex registry as UPOverlay, so its fixed page background, loading content, input blocking, and custom child slot layer correctly against other visible masks |

Last update: 2026-07-25 (Batch BZ sticky zIndex parity; flutter test 511 green)

| behavior parity | Fixed UPSticky entries retain their independent Flutter OverlayEntry subtrees while OverlayState.rearrange sorts them by numeric zIndex, keeping same-zIndex insertion order and the application route beneath pinned content |

Last update: 2026-07-25 (Batch CA guide defaults and persistence parity; flutter test 513 green)

| behavior/style parity | UPGuide now uses the source defaults (`once=true`, `finishText=立即体验`, dark `bgColor`), source `rpx` page/footer/indicator/button styling, resolved default storage keys, and optional persisted-key removal on `reset`; constrained-height hosts scroll the page content rather than overflowing |

Last update: 2026-07-25 (Batch CB tooltip trigger and singleton parity; flutter test 515 green)

| behavior parity | UPTooltip singleton instances now close the previous active tooltip, click/long-press triggers only open as in the source component, disposal clears the active singleton, and the copy action emits `click(0)` before writing to the clipboard and closing |

Last update: 2026-07-25 (Batch CC popover trigger and controlled-show parity; flutter test 518 green)

| behavior parity | UPPopover now follows the wrapped tooltip contract: click/long-press trigger callbacks open without reversing an already-open panel, manual triggers do not bind a gesture, and external `show` transitions drive open/close/update callbacks only in `manual` mode |

Last update: 2026-07-25 (Batch CD pull-refresh state-machine parity; flutter test 520 green)

| behavior parity | UPPullRefresh separates refresh state transitions from refresh events: `startRefresh` and controlled `refreshing` update state only, while a threshold-crossing release emits exactly one refresh; source `scrollTop` input is applied after mount and after updates, and the default indicator remains layout-safe for small thresholds |

Last update: 2026-07-25 (Batch CE dropdown mask dismissal parity; flutter test 521 green)

| behavior parity | UPDropdown `maskClick()` now honors `closeOnClickMask`, matching both the source public method and rendered-mask interaction; callers can safely invoke it without bypassing dismissal configuration |

Last update: 2026-07-25 (Batch CF dropdown lifecycle, item-event, and overlay parity; flutter test 525 green)

| behavior/render parity | UPDropdown now rebuilds source menu metadata without resetting active or highlighted state, emits every explicit close call, permits source-compatible programmatic opening of disabled menus, and renders the popup/mask in a menu-anchored viewport overlay so it no longer reflows later page content; UPDropdownItem uses source selection ordering (model update, close, change), selected text color, and unconditionally selectable source option objects |

Last update: 2026-07-25 (Batch CG pagination picker, input, and navigation parity; flutter test 527 green)

| behavior/render parity | UPPagination now follows source picker events by resolving `detail.value` as an option index (with first-option fallback), caches page-input text until confirmation, updates that cache on controlled-page changes, keeps source previous/next buttons visible independently of `layout` and `hideOnSinglePage`, omits the source-commented jumper UI, and lets programmatic `goTo` preserve source callback semantics |

Last update: 2026-07-25 (Batch CH scroll-list event-state and indicator parity; flutter test 527 green)

| behavior/style parity | UPScrollList now preserves source `scrollInfo.scrollLeft`/`scrollInfo.scrollWidth` event data, records the measured component width in `scrollWidth`, accepts source scroll-event payloads and edge-status dispatch through `scrollEvent`, mirrors edge handlers' indicator offsets, and exposes source `barStyle`/`lineStyle` width and color values while retaining Flutter scroll-controller helpers |

Last update: 2026-07-25 (Batch CI list scroll, edge, and refresher event parity; flutter test 528 green)

| behavior parity | UPList now accepts source scroll event payloads and synchronizes `innerScrollTop` for both external and controller-driven scrolls, exposes source `offset` data updated by children without forcing controller jumps, delays paired upper/lower event aliases by the source 30ms, resets offset at the top edge, and keeps public refresher handlers as event forwarding while Flutter refresh state remains controlled by explicit refresh APIs and `RefreshIndicator` |

Last update: 2026-07-25 (Batch CJ collapse event and render parity; flutter test 531 green)

| behavior/render parity | UPCollapse now emits the source-ordered `{name, status}` array from `change`, falls back to a child index for an empty name, keeps Flutter controlled value synchronization on `onUpdateValue`/`onUpdateModelValue`, and preserves source event order before the matching open/close callback. UPCollapseItem follows the source disabled-animation click guard, parent/item border framing, expanded header divider, source cell sizing, and 12px content padding. |

Last update: 2026-07-25 (Batch CK collapse item-state parity; flutter test 532 green)

| behavior parity | UPCollapse now tracks expanded state per rendered item, matching the source component's child-owned `expanded` flags. Multiple empty-name items can be opened and closed independently through normal interaction while change payloads retain their source index fallback. |

Last update: 2026-07-25 (Batch CL swipe-action state, gesture, and option-style parity; flutter test 537 green)

| behavior/render parity | UPSwipeAction now emits one source-compatible state update per actual item transition, keeps explicit `setOpendItem()` as a pure parent update event, separates programmatic open from gesture-start sibling closing, and commits drag state only on release after the source direction/threshold rule. UPSwipeActionItem option buttons now honor `iconSize`, rounded wrapper behavior, text line height, and the source dark-mode default button background. |

Last update: 2026-07-25 (Batch CM read-more measurement and overlay parity; flutter test 539 green)

| behavior/render parity | UPReadMore now measures a single rendered child rather than mounting duplicate Offstage content, so keyed descendants are supported. Its source-style shadow has zero net layout height for the default 100px/-100px padding-margin combination, and public `init()` performs the source-compatible delayed height re-measure before restoring long-content toggle state. |

Last update: 2026-07-25 (Batch CN sticky position and overlay-update parity; flutter test 541 green)

| behavior/render parity | UPSticky `setFixed(top)` now accepts the source element-top position, including event-shaped top payloads, and pins only at or above `offsetTop + customNavHeight`; its fixed Overlay refreshes position, background, and z-index after source property changes through a coalesced post-frame update, avoiding build-phase Overlay invalidation while retaining boolean Flutter-call compatibility. |

Last update: 2026-07-25 (Batch CO status-bar host-height parity; flutter test 541 green)

| behavior/render parity | UPStatusBar now derives both its rendered height and `update:height` payload exclusively from the Flutter host top safe-area inset, matching source `getWindowInfo().statusBarHeight`. The retained source `height` prop remains accepted for construction compatibility but no longer overrides host geometry; zero-height hosts set the source-equivalent H5 flag. |

Last update: 2026-07-25 (Batch CP gap dark-theme fallback parity; flutter test 542 green)

| render parity | UPGap now mirrors the source dark-theme fallback: empty or `transparent` `bgColor` renders as `#111111` under a dark Flutter theme, while explicit colors and `customStyle.color` retain source merge precedence. |

Last update: 2026-07-25 (Batch CQ divider layout-order parity; flutter test 543 green)

| render parity | UPDivider now preserves the source `u-line`, content, `u-line` order for every `textPosition`. Left/right alignment only changes the matching line segment to the fixed 80rpx width, rather than moving text to a divider edge. |

Last update: 2026-07-25 (Batch CR line CSS-margin parity; flutter test 544 green)

| render parity | UPLine now expands its source CSS-style `margin` shorthand using the standard one-, two-, three-, and four-value rules, preserving distinct vertical and horizontal spacing instead of collapsing every string to a single all-sides margin. |

Last update: 2026-07-25 (Batch CS row/col twelve-grid parity; flutter test 545 green)

| render parity | UPRow now exposes its constrained width to UPCol, and UPCol derives left offset and column width from the source fixed twelve-column grid. A lone `span: 3, offset: 3` column therefore remains one quarter wide and begins one quarter across the row instead of being expanded against only its rendered siblings. |

Last update: 2026-07-26 (Batch CT empty layout and constrained PDF placeholder parity; flutter test 547 green)

| render/layout parity | UPEmpty now uses the source `20rpx` text gap, removes Flutter-only root padding, and leaves the source slot directly after its text. The Flutter-only UPPdfReader empty-address placeholder is safely clipped inside a constrained reader viewport, matching the source web-view's bounded layout rather than producing a RenderFlex overflow. |

Last update: 2026-07-26 (Batch CU title intrinsic-layout parity; flutter test 548 green)

| render parity | UPTitle now keeps its default or slotted content at its natural width, matching the source flex row rather than forcing it through a Flutter `Expanded`. The component can therefore be used inside horizontal shrink-wrap layouts without unbounded-flex exceptions. |

Last update: 2026-07-26 (Batch CV view reverse-flex parity; flutter test 549 green)

| render parity | UPView now maps source `row-reverse` and `column-reverse` values to Flutter's reverse main-axis directions, so children render in source order from right-to-left or bottom-to-top while preserving existing alignment and container style behavior. |

Last update: 2026-07-26 (Batch CW box short-color-array parity; flutter test 550 green)

| render parity | UPBox now preserves the source direct `bgColors[index]` behavior. When callers provide fewer than three colors, only supplied cells receive a background color; missing entries remain transparent instead of falling back to the first default blue. |

Last update: 2026-07-26 (Batch CX loadmore dot-text parity; flutter test 550 green)

| API/render parity | UPLoadmore now exposes the source `dotText` value `●` and routes its rendered status label through `showText`, keeping the public computed value and the `nomore + isDot` visual state aligned. |

Last update: 2026-07-26 (Batch CY agreement URL-selector parity; flutter test 550 green)

| API parity | UPAgreement `urlClick` now accepts the source template selectors `urlProtocol` and `urlPrivacy`, resolving them to the configured destination before invoking the Flutter navigation callback. Existing direct URL calls remain supported for Flutter consumers. |

Last update: 2026-07-26 (Batch CZ lazy-load defaults and state parity; flutter test 550 green)

| API/render parity | UPLazyLoad now uses the source `200` height, `ease-in-out` effect, and empty initial load status. Its Flutter opacity transition uses the matching ease-in-out curve, preserving the source default image-load presentation. |

Last update: 2026-07-26 (Batch DA copy falsey-content parity; flutter test 551 green)

| behavior parity | UPCopy now mirrors the source JavaScript `if (!content)` guard for null, empty strings, false booleans, zero, and NaN values. Source-truthy Dart collections and objects continue to be copied through their string representation. |

Last update: 2026-07-26 (Batch DB action-sheet close-path parity; flutter test 552 green)

| behavior parity | UPActionSheet now keeps source close paths independent: `closeHandler` only acts when overlay dismissal is enabled, while cancel and enabled action selection close through their own source conditions and emit one `update:show(false)` plus `close`. |

Last update: 2026-07-26 (Batch DC action-sheet header-divider parity; flutter test 553 green)

| render parity | UPActionSheet now inserts the header-to-actions divider only when a description is rendered, matching the source template. A title by itself no longer creates an extra separator. |

Last update: 2026-07-26 (Batch DD cell-group title and border parity; flutter test 554 green)

| render/API parity | UPCellGroup now matches the source group container and title rules: group style contains only the card background, titles use 15px main-color text with `16px 16px 8px` padding, and `border` controls one leading hairline inside the wrapper instead of synthetic container borders. |

Last update: 2026-07-26 (Batch DE cell disabled-opacity parity; flutter test 555 green)

| render parity | UPCell disabled rendering no longer applies a Flutter-only opacity wrapper to its complete subtree. Custom slots, divider, and container retain source opacity while native title, label, value, and arrow color branches continue to use the disabled color. |

Last update: 2026-07-26 (Batch DF card structural-slot parity; flutter test 556 green)

| render parity | UPCard now preserves the source template's default head and foot containers whenever `showHead` or `showFoot` is enabled. Empty heads keep the configured padding and divider; empty feet retain their optional top divider with zero padding. Subtitle rendering is limited to the source title row. |

Last update: 2026-07-26 (Batch DG toolbar right-slot parity; flutter test 557 green)

| render parity | UPToolbar now lets `rightSlot` alone select the source right-side slot branch. With no Flutter right widget supplied, the default confirm control is absent rather than being rendered as a fallback. |

Last update: 2026-07-26 (Batch DH alert close-event parity; flutter test 559 green)

| event parity | UPAlert now follows the source watcher lifecycle: every close synchronizes `update:modelValue(false)`, `closed` is emitted only for a positive auto-close duration, and that `closed` event occurs before the explicit `close` callback. |

Last update: 2026-07-26 (Batch DI badge value-source parity; flutter test 560 green)

| API/render parity | UPBadge now follows the source template by deriving its displayed value and zero-visibility condition exclusively from `value`. The retained `modelValue` compatibility prop no longer overrides rendered badge content. |

Last update: 2026-07-26 (Batch DJ tag disabled-prop parity; flutter test 561 green)

| API/render parity | UPTag now preserves the source component's inert `disabled` prop: it retains normal type colors, opacity, click behavior, and close behavior because the uview-plus template and event handlers do not branch on that prop. |

Last update: 2026-07-26 (Batch DK link line-color parity; flutter test 562 green)

| render parity | UPLink now follows the active uview-plus `linkStyle` implementation: its underlining inherits the link text color, while the retained `lineColor` prop remains inactive because the source's line-color border implementation is commented out. |

Last update: 2026-07-26 (Batch DL avatar helper parity; flutter test 563 green)

| API parity | UPAvatar now retains the source non-mini-program defaults: `allowMp` is false in Flutter, and `isImg()` reports whether `src` contains `/` exactly as the source helper does instead of treating every nonempty source or fallback URL as an image. |

Last update: 2026-07-26 (Batch DM button numeric-text parity; flutter test 564 green)

| API/render parity | UPButton now accepts numeric `text` and `loadingText` values like the source prop definitions. Loading text follows the source `loadingText || text` behavior, including fallback from zero, and the loading/default template branches retain their fixed text-node spacing. |

Last update: 2026-07-26 (Batch DN text price-value parity; flutter test 566 green)

| API/render parity | UPText now routes rendered values through the source mode formatter. Price mode displays the `￥` prefix and source-equivalent two-decimal, comma-separated amount; the `format` prop now accepts source function formatters as well as strings. |

Last update: 2026-07-26 (Batch DO text phone-name formatter parity; flutter test 567 green)

| API/render parity | UPText now applies function-valued `format` callbacks in phone and name modes before rendering, matching the shared `value.js` branch used by the source component while retaining its built-in encrypt options. |

Last update: 2026-07-26 (Batch DP text date-mode parity; flutter test 568 green)

| API/render parity | UPText date mode now renders the source `value.js` output: default `yyyy-mm-dd`, source token-based format strings, callback formatters, and the source's second- and millisecond-timestamp parsing behavior. |

Last update: 2026-07-26 (Batch DQ text link-mode parity; flutter test 569 green)

| render/event parity | UPText `mode: 'link'` now renders the source `UPLink` branch with its default underline and href behavior. Link taps are handled by the inner link and no longer invoke UPText's outer click callback. |

Last update: 2026-07-26 (Batch DR divider falsey-text parity; flutter test 570 green)

| render parity | UPDivider now follows the source template's `v-if="!dot && text"` condition. Falsey text values such as numeric zero no longer render a middle label, while dot rendering remains the higher-priority branch. |

Last update: 2026-07-26 (Batch DS text price-prefix-size parity; flutter test 570 green)

| render parity | UPText price-mode `￥` prefix now uses the same resolved `size` as the source `valueStyle` instead of a Flutter-only fixed 14px font size. |

Last update: 2026-07-26 (Batch DT empty icon-template parity; flutter test 571 green)

| render parity | UPEmpty now follows the source template: `icon` only switches to the image branch when it contains `/`; any non-path icon value still renders the built-in `empty-${mode}` icon (with the source `message` to `chat` exception). |

Last update: 2026-07-26 (Batch DU line-progress initial-data parity; flutter test 572 green)

| API parity | UPLineProgress `lineWidth` now exposes the source `data()` initial value `0`. Flutter continues to calculate rendered active-track width directly from layout constraints, so visual progress behavior remains unchanged. |

Last update: 2026-07-26 (Batch DV empty unknown-mode text parity; flutter test 573 green)

| render parity | UPEmpty now mirrors the source `icons[mode]` interpolation for unrecognized modes: without an explicit `text`, it renders an empty text value rather than applying a Flutter-only `data` fallback. |

Last update: 2026-07-26 (Batch DW empty source-data structure parity; flutter test 573 green)

| API/render parity | UPEmpty `icons` now retains the source data shape: a mode-keyed map of localized empty-state text. Rendering reads that same map, so the exposed data and the template-equivalent fallback stay synchronized. |

Last update: 2026-07-26 (Batch DX line-progress measured-width parity; flutter test 573 green)

| API parity | UPLineProgress now updates its source `lineWidth` data from initial `0` to the measured CSS pixel string used by `progressStyle`, while retaining Flutter's existing numeric return from `resizeProgressWidth`. |

Last update: 2026-07-26 (Batch DY line direction-branch parity; flutter test 574 green)

| API/render parity | UPLine now uses the source's exact direction branch: only `direction: 'row'` renders a horizontal line; every other value, including the former Flutter-only `horizontal` alias, renders the vertical branch. |

Last update: 2026-07-26 (Batch DZ divider default-slot parity; flutter test 575 green)

| API/render parity | UPDivider now accepts a Flutter `child` as the source default slot. The child replaces the fallback text but does not suppress the independent `dot` branch, retaining the source line → dot → slot/text → line structure. |

Last update: 2026-07-26 (Batch EA col unbounded-span-offset parity; flutter test 576 green)

| render parity | UPCol no longer applies Flutter-only `0..12` clamping to source `span` and `offset` inputs. It preserves the source percentage calculation for arbitrary values and emulates negative CSS left margin with a paint translation. |

Last update: 2026-07-26 (Batch EB view template-click parity; flutter test 576 green)

| event parity | UPView no longer binds an automatic Flutter tap callback because the source template has no `@tap` binding. Its source `clickHandler` and `onClickHandler` methods remain available for explicit invocation. |

Last update: 2026-07-26 (Batch EC title slot-color inheritance parity; flutter test 577 green)

| render parity | UPTitle now supplies the source `.u-title` main color to default-slot text through Flutter's inherited text style, while retaining its existing default prefix and text convenience rendering. |

Last update: 2026-07-26 (Batch ED box template interaction and empty-icon spacing parity; flutter test 579 green)

| render/event parity | UPBox cells no longer create Flutter-only tap behavior because the source template declares no tap handlers or emitted events. Its retained callback fields are therefore inert during ordinary cell taps; default title content also keeps the source `ml-2` 8px title spacing even when the icon name is empty. |

Last update: 2026-07-26 (Batch EE popover and tooltip slot parity; flutter test 586 green)

| API/render/event parity | UPPopover now follows its thin source wrapper: its empty trigger slot remains empty, `direction` controls placement while inactive `placement` is not forwarded, unsupported trigger modes stay inert, and trigger taps only open the underlying tooltip without emitting Popover `click`. The wrapper no longer applies inactive custom style or forwards `update:show`; content inherits the configured text color, and the shared UPTooltip content-slot path now likewise inherits the source popup-list color. |

Last update: 2026-07-26 (Batch EF pull-refresh state and loadmore-prop parity; flutter test 593 green)

| API/render/event parity | UPPullRefresh now retains the source state fields and touch-coordinate state machine: the non-immediate `refreshing` watcher only reacts to later prop changes, `resetRefresh` returns content without ending an active refresh, and top detection remains source-equivalent. It drives its UPLoadmore child solely from `loadmoreProps` (including status), emits `loadmore` only for the scroll-to-lower path, and matches the source's vertical 14px pull/release/refresh indicators. Retained Flutter-only `loadmoreStatus` and `customStyle` remain inactive because the source component declares neither behavior. |

Last update: 2026-07-26 (Batch EG refresh-virtual-list wrapper parity; flutter test 596 green)

| API/render parity | UPRefreshVirtualList now sets `refreshing` before emitting its source `refresh` event, retains UPPullRefresh's source scroll-wrapper default, forwards virtual-list scrolling through its state handler, and ignores undeclared Flutter-only custom styling. UPVirtualList now schedules declarative `scrollTop` controller synchronization after the current build frame, preserving source-style update flow without Flutter build-phase reentrancy. |

Last update: 2026-07-26 (Batch EH virtual-list fixed-height and slot parity; flutter test 601 green)

| API/render parity | UPVirtualList now follows the source fixed-height algorithm: visible items use `itemHeight`, source maps receive `_virtualIndex`, and `keyField` selects each item key. Its visible-range and default-height helpers derive from declarative `scrollTop`/height inputs, the source's commented-out touch handler remains inert, and undeclared Flutter-only custom styles no longer wrap the list. |

Last update: 2026-07-26 (Batch EI waterfall incremental-layout parity; flutter test 606 green)

| API/render/event parity | UPWaterfall now preserves source incremental allocation: `handleData` appends to the existing columns, `getMinHeightColumnIndex(columnHeights)` uses the supplied heights and breaks ties by each column's data count, and auto columns reserve the source 7px gap without a Flutter-only maximum. Columns render with that 7px inter-column gap, while source-inactive `customStyle` remains unbound. Mutations now select the Vue3 `update:modelValue` callback when `modelValue` is in use, instead of also emitting the retained value alias. |

Last update: 2026-07-26 (Batch EJ waterfall watcher, slot, and event-payload parity; flutter test 611 green)

| API/render/event parity | UPWaterfall now mirrors its source watcher with deep input snapshots: replacement and in-place list growth append only the new tail, same-length changes do not reshuffle existing columns, and empty input clears the columns. The Flutter port provides `columnBuilder` and `leftBuilder` counterparts for the source named slots, each receiving `colIndex` and its column list; either suppresses default item rendering while both still render when supplied. `copyFlowList` now deep-clones source data, and `after-add-one`/`after-add-all` carry source-shaped height and `{columnHeights, newData}` payloads. |

Last update: 2026-07-26 (Batch EK waterfall imperative-method parity; flutter test 614 green)

| API/render/event parity | UPWaterfall now separates the source imperative operations: `initColumnList` clears only column storage, `redistributeData` performs the explicit full allocation, and `cloneData(data)` deep-clones its supplied data. `remove` and `modify` mutate their existing column entry without rebalancing the remaining columns, while still emitting a deep-copied parent value. `handleWindowResize(res)` consumes the source `{size: {windowWidth, windowHeight}}` shape, observes the 300ms debounce, and redistributes only after the resolved column count changes. Item measurement callbacks capture their rendered item rather than a mutable column index, eliminating stale-list range failures during state changes. |

Last update: 2026-07-26 (Batch EL drag-sort source-state parity; flutter test 616 green)

| API/render/event parity | UPDragSort now stores source-style `x`/`y` coordinates directly on map items after layout and accepts the source `onTouchStart(index, event)` and `onChange(index, event)` call shapes. Change events only reorder for `detail.source: 'touch'`; named handler content gates drag start; reordering updates positions but defers `drag-end` until the source-equivalent 50ms touch-end settlement, then keeps the dragged index for 600ms before reset. The Flutter grid target bridge treats accepted drops as that same end boundary, preserving one final callback despite Flutter's differing callback order. Source-inactive `customStyle` no longer decorates the widget. |

Last update: 2026-07-26 (Batch EM drag-sort template render parity; flutter test 618 green)

| render/event parity | UPDragSort now mirrors the source item template: default content renders only `item.label`, and every item content container uses the source white background, `rgba(125, 126, 128, 0.35)` border, and 8px radius without Flutter-only padding or margin. In list modes, a supplied handler slot alone is wrapped by the drag-start listener, so body/default-slot content cannot begin a drag. Existing test fixtures now use source-shaped label maps and account for the source-derived `x`/`y` coordinates. |

Last update: 2026-07-26 (Batch EN loading-page props and computed-style parity; flutter test 620 green)

| API/render parity | UPLoadingPage now follows the source `props.js` runtime default path: absent `iconSize` resolves through `loadingPage.fontSize`, yielding 19px despite the configuration's separate 28px value. Its exposed `overlayStyle` now reflects the source template's `...customStyle` merge for the supported Flutter `BoxDecoration.color` field, while its existing rendered overlay and root z-index behavior remain unchanged. |

Last update: 2026-07-26 (Batch EO safe-bottom undeclared-prop parity; flutter test 621 green)

| render parity | UPSafeBottom now follows the source template and empty props definition: its retained Flutter `bgColor` constructor argument no longer paints the safe-area spacer, while source `customStyle` remains the sole decoration path and MediaQuery-derived safe-area height remains unchanged. |

Last update: 2026-07-26 (Batch EP loadmore text-only tap parity; flutter test 622 green)

| event parity | UPLoadmore now mirrors the source template's event surface: only the status text binds `loadMore`, so optional separator lines, loading icon, and outer spacing cannot emit `loadmore`; text taps still emit only when `status` is `loadmore`. |

Last update: 2026-07-26 (Batch EQ card regional event bubbling parity; flutter test 623 green)

| event parity | UPCard now mirrors the source nested tap propagation: tapping its head, body, or foot emits the regional callback first (`head-click`, `body-click`, or `foot-click`) and then the root `click`, with the source `index` payload for both events. |

Last update: 2026-07-26 (Batch ER card inactive custom-style parity; flutter test 624 green)

| render parity | UPCard retains the globally mixed-in `customStyle` constructor parameter for API compatibility, but no longer renders it because the source card template never merges that shared prop into its root style. |

Last update: 2026-07-26 (Batch ES title inactive custom-style parity; flutter test 625 green)

| render parity | UPTitle retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source title component neither mixes in the shared uview props nor merges that style into its root template. |

Last update: 2026-07-26 (Batch ET copy inactive custom-style parity; flutter test 626 green)

| render parity | UPCopy retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source copy component declares only its copy props and its root template binds only the click handler. |

Last update: 2026-07-26 (Batch EU coupon inactive custom-style parity; flutter test 628 green)

| render parity | UPCoupon retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source coupon root consumes only `couponStyle` from `bgColor` and `color`. The source-backed coupon colors remain rendered. |

Last update: 2026-07-26 (Batch EV choose inactive custom-style parity; flutter test 629 green)

| render parity | UPChoose retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source choose component declares its own props without the shared mixin and its root scroll-view has no custom-style binding. Source option selection, `modelValue`, and `customClick` behavior remain unchanged. |

Last update: 2026-07-26 (Batch EW barcode inactive custom-style parity; flutter test 630 green)

| render parity | UPBarcode retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source barcode component declares its own props without the shared mixin and its conditional root view has no style binding. Source barcode labels, module encoding, canvas rendering, and callbacks remain unchanged. |

Last update: 2026-07-26 (Batch EX qrcode inactive custom-style parity; flutter test 631 green)

| render parity | UPQrcode retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source QR-code component declares its own props without the shared mixin and its root view binds only root-size dimensions. Source QR matrix generation, canvas behavior, colors, and callback aliases remain unchanged. |

Last update: 2026-07-26 (Batch EY circle-progress inactive custom-style parity; flutter test 632 green)

| render parity | UPCircleProgress retains the shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source template binds styles only to the two circle border-color nodes and never consumes the shared prop. Flutter circle rendering, source border-color helpers, percentage behavior, and child content remain unchanged. |

Last update: 2026-07-26 (Batch EZ toolbar inactive custom-style parity; flutter test 633 green)

| render parity | UPToolbar retains the shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source toolbar template binds only visibility, touch prevention, and its individual text colors. Source cancel/confirm events, title, colors, and right-slot behavior remain unchanged. |

Last update: 2026-07-26 (Batch FA parse inactive custom-style parity; flutter test 634 green)

| render parity | UPParse retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the standalone source parser template declares and binds `containerStyle`, not `customStyle`. Source HTML rendering, selectable content, callbacks, and helper APIs remain unchanged. `containerStyle` is an active source API that still needs a dedicated CSS-string-to-Flutter-style mapping. |

Last update: 2026-07-26 (Batch FB picker inactive custom-style parity; flutter test 635 green)

| render parity | Main UPPicker retains the shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source picker template never binds that prop. Source popup, input trigger, toolbar, model updates, and active `bgColor`/`maskStyle` paths remain unchanged. Separate UPPickerColumn and UPPickerData shells are outside this scope. |

Last update: 2026-07-26 (Batch FC table inactive custom-style parity; flutter test 636 green)

| render parity | UPTable retains the shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root binds only computed `tableStyle`. Source-backed table borders, background color, header/cell layout, and the `change` helper remain unchanged. |

Last update: 2026-07-26 (Batch FD collapse inactive custom-style parity; flutter test 637 green)

| render parity | UPCollapse and UPCollapseItem retain shared `customStyle` constructor parameters for API compatibility, but neither renders them because their Vue root templates never consume the shared prop. The source-backed collapse borders, expansion and event behavior remain unchanged; UPCollapseItem's distinct active `cellCustomStyle` path remains rendered. |

Last update: 2026-07-26 (Batch FE navbar-mini inactive custom-style parity; flutter test 638 green)

| render parity | UPNavbarMini retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source template uses `customClass` on its root and binds only `height` and `bgColor` on its content node. Existing navbar content, slots, icons, and click behavior remain unchanged. |

Last update: 2026-07-26 (Batch FF swiper inactive custom-style parity; flutter test 639 green)

| render parity | Main UPSwiper retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root consumes only active background, height, and radius styles. The source-backed loading, paging, indicator, circular, and event paths remain unchanged; standalone UPSwiperIndicator is outside this batch. |

Last update: 2026-07-26 (Batch FG view inactive custom-style parity; flutter test 640 green)

| render parity | UPView retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root binds only explicit layout properties including background, text color, flex, size, spacing, and border color. Existing Flutter mapping of those active source styles remains unchanged. |

Last update: 2026-07-26 (Batch FH avatar-group inactive custom-style parity; flutter test 641 green)

| render parity | UPAvatarGroup retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root template never consumes that prop. Source-backed avatar resolution, overlap, max-count handling, more badge, and show-more event behavior remain unchanged. |

Last update: 2026-07-26 (Batch FI agreement inactive custom-style parity; flutter test 642 green)

| render parity | UPAgreement retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source component declares and consumes no such prop. Its source-backed controller, modal, agreement links, URL routing, cancel, and confirmation behavior remain unchanged. |

Last update: 2026-07-26 (Batch FJ canvas inactive custom-style parity; flutter test 643 green)

| render/API parity | UPCanvas retains its Flutter `customStyle` constructor parameter for compatibility, but no longer renders it because the source component declares and consumes no such prop; its dimensions, background paint, pointer paths, controller, drawing, and export behavior remain unchanged. Its retained `rgba()` helper now uses current normalized Color channels while preserving the source-compatible output strings. |

Last update: 2026-07-26 (Batch FK car-keyboard inactive custom-style parity; flutter test 644 green)

| render parity | UPCarKeyboard retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root keyboard template never consumes the prop. Source-backed Chinese/English key groups, random ordering, mode changes, auto-change, input events, and backspace behavior remain unchanged. |

Last update: 2026-07-26 (Batch FL code inactive custom-style parity; flutter test 645 green)

| render parity | UPCode retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source is a logic-only component whose root template and local props never consume that prop. Source-backed countdown callbacks, start/reset behavior, and keep-running storage behavior remain unchanged. |

Last update: 2026-07-26 (Batch FM action-sheet inactive custom-style parity; flutter test 646 green)

| render parity | UPActionSheet retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source action-sheet template never consumes the prop. Source-backed popup behavior, header and description, action selection, cancellation, loading/disabled actions, and update-show callbacks remain unchanged. The separate UPActionSheetData component is outside this batch. |

Last update: 2026-07-26 (Batch FN album inactive custom-style parity; flutter test 647 green)

| render parity | UPAlbum retains its shared `customStyle` constructor parameter for API compatibility, but no longer renders it because the source album root never consumes the prop. This applies to both empty and populated album paths; source image layout, overflow counter, previews, wrapping, and album-width callbacks remain unchanged. The source template's fixed `customStyle` on its internal overflow-text component is unrelated to the album root API. |

Last update: 2026-07-26 (Batch FO action-sheet-data inactive custom-style parity; flutter test 648 green)

| render parity | UPActionSheetData retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its separate source template neither declares nor consumes the prop. Source-backed trigger rendering, option selection, model updates, and nested action-sheet behavior remain unchanged. |

Last update: 2026-07-26 (Batch FP calendar-strip inactive custom-style parity; flutter test 649 green)

| render parity | UPCalendarStrip retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root never consumes the prop; source style bindings apply only to individual date cells. Source-backed selection, month navigation, range handling, full-calendar expansion, gestures, and callback aliases remain unchanged. |

Last update: 2026-07-26 (Batch FQ calendar inactive custom-style parity; flutter test 650 green)

| render parity | UPCalendar retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source template and props never consume the prop; source inline style bindings target only internal scroll/month containers. Source-backed selection, confirmation, range rules, navigation, popup behavior, inline rendering, and callback aliases remain unchanged. `flutter analyze lib/src/widgets/up_calendar.dart` retains the pre-existing unused private `_innerFormatter` API-shell warning, outside this batch's scope. |

Last update: 2026-07-26 (Batch FR cascader inactive custom-style parity; flutter test 651 green)

| render parity | UPCascader retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source declares no such prop and its root popup never consumes it. Source-backed popup lifecycle, hierarchy panes, tab navigation, selection, auto-close, confirmations, cancellations, and model aliases remain unchanged. |

Last update: 2026-07-26 (Batch FS cate-tab inactive custom-style parity; flutter test 652 green)

| render parity | UPCateTab retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source root consumes only active height styling. Source-backed two-pane layout, category selection, right-pane scrolling, item rendering, model aliases, and menu helpers remain unchanged. |

Last update: 2026-07-26 (Batch FT city-locate inactive custom-style parity; flutter test 653 green)

| render parity | UPCityLocate retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and props never consume the prop. Source-backed city selection, current-city updates, location success/failure handling, index-list content, and model aliases remain unchanged. |

Last update: 2026-07-26 (Batch FU code-input inactive custom-style parity; flutter test 654 green)

| render parity | UPCodeInput retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed input, cursor, focus, dot, line/box mode, callback, and model alias behavior remain unchanged. |

Last update: 2026-07-26 (Batch FV color-picker inactive custom-style parity; flutter test 655 green)

| render parity | UPColorPicker retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and props never consume the prop. Source-backed popup lifecycle, solid/gradient selection, color controls, callbacks, and model aliases remain unchanged. `flutter analyze lib/src/widgets/up_color_picker.dart` retains three unrelated `deprecated_member_use` infos for `Color.red`, `Color.green`, and `Color.blue` in `_toHex`. |

Last update: 2026-07-26 (Batch FW count-down inactive custom-style parity; flutter test 656 green)

| render parity | UPCountDown retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed countdown timing, formatting, start/reset controls, and callbacks remain unchanged. |

Last update: 2026-07-26 (Batch FX count-to inactive custom-style parity; flutter test 657 green)

| render parity | UPCountTo retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source text root and local props never consume the prop. Source-backed number animation, formatting, lifecycle controls, and end callback behavior remain unchanged. |

Last update: 2026-07-26 (Batch FY cropper inactive custom-style parity; flutter test 658 green)

| render parity | UPCropper retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root never consumes the prop. Source-backed crop layout, canvas gestures, image export, public aliases, and callbacks remain unchanged. `flutter analyze lib/src/widgets/up_cropper.dart` retains one unrelated `deprecated_member_use` info for `Color.alpha` in its existing image color handling. |

Last update: 2026-07-26 (Batch FZ datetime-picker inactive custom-style parity; flutter test 659 green)

| render parity | UPDatetimePicker retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed input trigger, popup lifecycle, date columns, formatter, callbacks, and model aliases remain unchanged. |

Last update: 2026-07-26 (Batch GA dropdown inactive custom-style parity; flutter test 660 green)

| render parity | UPDropdown retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed `contentStyle`, `popupStyle`, menu selection, anchored overlay, callbacks, and public controls remain unchanged. |

Last update: 2026-07-26 (Batch GB float-button inactive custom-style parity; flutter test 661 green)

| render parity | UPFloatButton retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and inline prop definition never consume the prop. Source-backed fixed positioning, menu lifecycle, item callbacks, colors, slots, and public controls remain unchanged. This also removes Flutter's invalid `Positioned`-below-`Container` tree when `customStyle` is supplied. |

Last update: 2026-07-26 (Batch GC goods-sku inactive custom-style parity; flutter test 662 green)

| render parity | UPGoodsSku retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because neither source root path nor its local props consume the prop. Source-backed page-inline and popup SKU content, matching, disabled combinations, quantity logic, callbacks, and model aliases remain unchanged. |

Last update: 2026-07-26 (Batch GD guide inactive custom-style parity; flutter test 663 green)

| render parity | UPGuide retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed `zIndex`, page navigation, persistence, callbacks, controls, and public lifecycle methods remain active. |

Last update: 2026-07-26 (Batch GE index-list inactive custom-style parity; flutter test 664 green)

| render parity | UPIndexList retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed scrolling, index-letter rail, touch selection, indicator, navigation, and callbacks remain active. |

Last update: 2026-07-26 (Batch GF keyboard inactive custom-style parity; flutter test 665 green)

| render parity | UPKeyboard retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source component passes only its internally computed `popupStyle` to `u-popup` and its local props never declare the public prop. Source-backed popup background, overlay, keyboard modes, tooltips, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GG lazy-load inactive custom-style parity; flutter test 666 green)

| render parity | UPLazyLoad retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because neither its source root nor inline local props consume the prop. Source-backed placeholder, lazy loading, image state, transition, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GH message-input inactive custom-style parity; flutter test 667 green)

| render parity | UPMessageInput retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because neither its source root nor inline local props consume the prop. Source-backed input, code-cell modes, focus, breathing cursor, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GI modal inactive custom-style parity; flutter test 668 green)

| render parity | UPModal retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source component passes only an internal literal style to `u-popup` and its local props never declare the public prop. Source-backed popup layout, content style, actions, overlay, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GJ no-network inactive custom-style parity; flutter test 669 green)

| render parity | UPNoNetwork retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because the source passes only an internal literal style to `u-overlay` and its local props never declare the public prop. Source-backed white overlay, image, tips, retry button, connectivity callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GK number-box inactive custom-style parity; flutter test 670 green)

| render parity | UPNumberBox retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed buttons, input, disabled state, long press, callbacks, and public controls remain active; its separate internal `iconStyle` remains source-active. |

Last update: 2026-07-26 (Batch GL number-keyboard inactive custom-style parity; flutter test 671 green)

| render parity | UPNumberKeyboard retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed item styles, randomized ordering, backspace behavior, callbacks, and public method aliases remain active. |

Last update: 2026-07-26 (Batch GM pagination inactive custom-style parity; flutter test 672 green)

| render parity | UPPagination retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and inline props never consume the prop. Source-backed navigation, displayed pages, total and size layouts, button styling, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GN pdf-reader inactive custom-style parity; flutter test 673 green)

| render parity | UPPdfReader retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root binds only height and its local props never consume the prop. Source-backed PDF target resolution, height, viewer injection, callbacks, toolbar behavior, and public lifecycle controls remain active. |

Last update: 2026-07-26 (Batch GO poster inactive custom-style parity; flutter test 674 green)

| render parity | UPPoster retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and inline props never consume the prop. Source-backed JSON rendering, canvas/export flow, image and QR-code helpers, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GP read-more inactive custom-style parity; flutter test 675 green)

| render parity | UPReadMore retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed content measurement, shadow style, expand/collapse behavior, callbacks, slots, and public controls remain active. |

Last update: 2026-07-26 (Batch GQ scroll-list inactive custom-style parity; flutter test 676 green)

| render parity | UPScrollList retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed scrolling, indicator styles, edge callbacks, content rendering, and public scroll controls remain active. |

Last update: 2026-07-26 (Batch GR select inactive custom-style parity; flutter test 677 green)

| render parity | UPSelect retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and inline props never consume the prop. Source-backed overlay style, trigger and panel positioning, options, selection callbacks, disabled state, slots, and public controls remain active. |

Last update: 2026-07-26 (Batch GS short-video inactive custom-style parity; flutter test 678 green)

| render parity | UPShortVideo retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and inline props never consume the prop. Source-backed tabs, video host injection, play/pause controls, callbacks, action handlers, progress events, and public aliases remain active. |

Last update: 2026-07-26 (Batch GT signature inactive custom-style parity; flutter test 679 green)

| render parity | UPSignature retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and inline props never consume the prop. Source-backed canvas, `bgColor`, toolbar, drawing, export, callbacks, brush settings, and public controls remain active. |

Last update: 2026-07-26 (Batch GU skeleton inactive custom-style parity; flutter test 680 green)

| render parity | UPSkeleton retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and active mixins never consume the prop. Source-backed loading transitions, avatar, title, rows, dimensions, animation, child slot, and public controls remain active. |

Last update: 2026-07-26 (Batch GV slider active custom-style audit; flutter test 680 green)

| render parity | UPSlider continues to render `customStyle` at its root because `u-slider.vue` explicitly binds `addStyle(customStyle)` alongside its vertical-width style. Source-backed vertical layout, range mode, track and block styling, interactions, callbacks, and value aliases remain active. |

Last update: 2026-07-26 (Batch GW sticky active custom-style audit; flutter test 680 green)

| render parity | UPSticky continues to render `customStyle` at its root because its source `style` computed property explicitly merges `addStyle(this.customStyle)` with sticky position and background behavior. Source-backed placeholder, background, z-index, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GX subsection active custom-style audit; flutter test 680 green)

| render parity | UPSubsection continues to render `customStyle` at its root because `u-subsection.vue` explicitly binds `addStyle(customStyle)` with `wrapperStyle`. Source-backed button/subsection modes, colors, sliding bar, disabled state, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch GY swipe-action inactive custom-style parity; flutter test 681 green)

| render parity | UPSwipeAction and UPSwipeActionItem retain their Flutter `customStyle` constructor parameters for API compatibility, but no longer render them because their source roots and local props never consume the prop. Source-backed group coordination, open/close behavior, drag thresholds, options, callbacks, style maps, and public controls remain active. |

Last update: 2026-07-26 (Batch GZ switch active custom-style audit; flutter test 681 green)

| render parity | UPSwitch continues to render `customStyle` at its root because `u-switch.vue` explicitly binds `switchStyle` together with `addStyle(customStyle)`. Source-backed dimensions, active/inactive state, loading, disabled state, callbacks, and aliases remain active. |

Last update: 2026-07-26 (Batch HA table2 inactive custom-style parity; flutter test 682 green)

| render parity | UPTable2 retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root and local props never consume the prop. Source-backed borders, scrolling, headers, rows, sorting, selection, trees, fixed columns, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch HB tabs inactive custom-style parity; flutter test 683 green)

| render parity | UPTabs retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root never consumes the prop. Source-backed tabs, shape modes, item/icon styles, badges, line animation, callbacks, slots, and public controls remain active. |

Last update: 2026-07-26 (Batch HC tooltip active custom-style audit; flutter test 683 green)

| render parity | UPTooltip continues to render `customStyle` at its root because `u-tooltip.vue` explicitly binds `addStyle(customStyle)` independently from its computed popup-position style. Source-backed trigger, overlay, popup positioning, copy/buttons, singleton semantics, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch HD transition active custom-style audit; flutter test 683 green)

| render parity | UPTransition continues to render `customStyle` at its root because `u-transition.vue` merges `addStyle(customStyle)` with its transition `viewStyle` before applying it to the root node. Source-backed animation mode, duration, visibility, transforms, opacity, callbacks, and child behavior remain active. |

Last update: 2026-07-26 (Batch HE tree inactive custom-style parity; flutter test 684 green)

| render parity | UPTree retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root never consumes the prop inherited from the shared mixin. Source-backed hierarchy, selection, checkbox cascade, expansion, callbacks, slots, and public methods remain active. |

Last update: 2026-07-26 (Batch HF upload active custom-style audit; flutter test 684 green)

| render parity | UPUpload continues to render `customStyle` at its root because `u-upload.vue` explicitly binds `[addStyle(customStyle)]` there. Source-backed preview, picker, upload state, popup, callbacks, file-list mutation helpers, and public controls remain active. |

Last update: 2026-07-26 (Batch HG avatar active custom-style audit; flutter test 684 green)

| render parity | UPAvatar continues to render `customStyle` at its root because `u-avatar.vue` explicitly merges `addStyle(customStyle)` with its size and background style. Source-backed size, shape, image/text/icon modes, random background, click callback, and image fallback behavior remain active. |

Last update: 2026-07-26 (Batch HH box active custom-style audit; flutter test 684 green)

| render parity | UPBox continues to render `customStyle` at its root because `u-box.vue` explicitly binds `addStyle(customStyle)` alongside its root height. Source-backed height, gap, backgrounds, corner radii, default slots, and cell content remain active. |

Last update: 2026-07-26 (Batch HI button custom-style merge parity; flutter test 685 green)

| render parity | UPButton continues to render `customStyle` because `u-button.vue` applies it after `baseColor` in its root style array. Flutter now overlays non-null caller decoration fields onto the source-derived base color, border, and radius instead of replacing them wholesale; source-backed button states, dimensions, interactions, and platform aliases remain active. |

Last update: 2026-07-26 (Batch HJ cell active custom-style audit; flutter test 685 green)

| render parity | UPCell and UPCellGroup continue to render `customStyle` at their roots because their Vue templates explicitly bind `addStyle(customStyle)`; the group combines it after its computed theme background. Source-backed cell slots, label/value/icon styles, links, interactions, group title, and borders remain active. |

Last update: 2026-07-26 (Batch HK checkbox-group inactive custom-style parity; flutter test 686 green)

| render parity | UPCheckboxGroup retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root never consumes the inherited prop. Source-backed group layout, selection propagation, disabled state, callbacks, and model aliases remain active; per-item UPCheckbox `customStyle` remains source-active. |

Last update: 2026-07-26 (Batch HL checkbox/icon active custom-style audit; flutter test 686 green)

| render parity | UPCheckbox and UPIcon continue to render `customStyle` because their Vue sources explicitly merge it into the checkbox row and apply it to the icon glyph/image node, respectively. Source-backed check state, placement, borders, callbacks, glyph/image, label, and click behavior remain active. |

Last update: 2026-07-26 (Batch HM form inactive custom-style parity; flutter test 687 green)

| render parity | UPForm retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because its source root never consumes the inherited prop. Source-backed validation, rules, reset/clear methods, field coordination, labels, and model aliases remain active; UPFormItem has its own separate source-active style path. |

Last update: 2026-07-26 (Batch HN empty/grid active custom-style audit; flutter test 687 green)

| render parity | UPEmpty, UPGrid, and UPGridItem continue to render `customStyle` because their Vue sources explicitly merge it into their respective computed root styles. Source-backed empty content, grid alignment, columns, cell styles, borders, interactions, and callbacks remain active. |

Last update: 2026-07-26 (Batch HO image/layout active custom-style audit; flutter test 687 green)

| render parity | UPImage, UPLineProgress, UPGap, UPLine, UPDivider, UPRow, and UPCol continue to render `customStyle` because their Vue sources explicitly merge or bind it on their rendered nodes. Source-backed image state, progress geometry, layout alignment, gutters, line styles, divider content, and callbacks remain active. |

Last update: 2026-07-26 (Batch HP markdown inactive custom-style parity; flutter test 688 green)

| render parity | UPMarkdown retains its Flutter `customStyle` constructor parameter for API compatibility, but no longer renders it because `up-markdown.vue` neither declares the prop nor imports the shared mixin or binds root style. Source-backed Markdown parsing, theme, code blocks, parse forwarding, and callbacks remain active. |

Last update: 2026-07-26 (Batch HQ loading/list/notice active custom-style audit; flutter test 688 green)

| render parity | UPLoadingIcon, UPList, and the main UPNoticeBar continue to render `customStyle` because their Vue sources explicitly bind or merge it into their roots. Source-backed animation, scrolling, styling, content, close/click callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch HR popup visible custom-style merge parity; flutter test 689 green)

| render parity | UPPopup merges non-null `customStyle` decoration fields with the source-derived content-panel background and radii, then renders the Material layer transparent so caller color, gradient, border, and shadow remain visible. The decoration applies directly to the source-equivalent `.u-popup__content` panel in both page-inline and normal overlay modes; source-backed sizing, safe-area, gestures, close controls, transitions, overlay behavior, callbacks, and aliases remain active. |

Last update: 2026-07-26 (Batch HS overlay visible custom-style merge parity; flutter test 690 green)

| render parity | UPOverlay now merges non-null `customStyle` decoration fields with its source-derived translucent-black mask decoration and paints that merged result on the visible tappable mask. This matches `u-overlay.vue`'s `deepMerge(style, addStyle(customStyle))`, so caller color, gradient, border, image, radius, shadow, blend mode, and shape override only their corresponding default fields without a second black layer; source-backed transition, opacity, z-index ordering, click behavior, child slot, and root-overlay placement remain active. |

Last update: 2026-07-26 (Batch HT rate/radio/safe-bottom active custom-style audit; flutter test 690 green)

| render parity | UPRate, UPRadio, UPRadioGroup, and UPSafeBottom continue to render `customStyle` because their Vue sources explicitly bind it to their respective rendered roots, with UPRadio, UPRadioGroup, and UPSafeBottom merging intrinsic layout fields first. Flutter retains decorations on the matching rate root, radio item/group roots, and safe-area height node; source-backed selection, placement, gap, safe-area behavior, callbacks, and aliases remain active. |

Last update: 2026-07-26 (Batch HU steps/section/swiper/tabbar custom-style parity; flutter test 695 green)

| render parity | UPSteps, UPSection, and UPSwiperIndicator retain Flutter `customStyle` fields for API compatibility but no longer render them: their uView sources either have no binding/local prop or, for UPSection, no Vue render component at all. UPTabbar now merges caller decoration fields into the source-equivalent visible `.u-tabbar__content` node rather than the outer placeholder layout. UPTabbarItem now exposes its source-supported `customStyle` API and merges it into the clickable item root after its source active/inactive background. Steps, section content, swiper indicators, tab selection, safe-area, placeholder, and callbacks remain active. |

Last update: 2026-07-26 (Batch HV search/text custom-style target parity; flutter test 696 green)

| render parity | UPSearch retains `customStyle` on its source-equivalent `.u-search` root because the Vue template explicitly binds it there. UPText now applies `customStyle` only to the source value style paths: regular value/content and price symbol/value nodes; it does not decorate the outer row, prefix/suffix icons, or link-mode `UPLink` branch because `u-text.vue` intentionally omits the prop from that branch. Source-backed input behavior, formatted values, price display, icons, links, clicks, and aliases remain active. |

Last update: 2026-07-26 (Batch HW picker column/data inactive custom-style parity; flutter test 698 green)

| render parity | UPPickerColumn and UPPickerData retain their Flutter `customStyle` constructor parameters and fields for API compatibility but no longer render them. `u-picker-column.vue` inherits the shared prop without binding it in its template, while `u-picker-data.vue` neither declares nor consumes it. Source-backed picker column values, selected indexes, trigger, modal, option mapping, callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch HX tabs-item inactive custom-style parity; flutter test 699 green)

| render parity | UPTabsItem retains its Flutter `customStyle` constructor parameter and field for API compatibility but no longer renders it. The independent `u-tabs-item.vue` source inherits the shared prop without binding it and renders only its `swiper-item` slot. Source-backed child pane rendering and public aliases remain active. |

Last update: 2026-07-26 (Batch HY notice/tag/transition custom-style parity; flutter test 702 green)

| render parity | UPRowNotice and UPColumnNotice retain Flutter `customStyle` API fields but no longer render them because their independent source templates and props never consume the field. UPTag likewise ignores the inherited shared field, deriving its root decoration only from source `style` inputs. UPTransition now places its source-active custom decoration inside its animated root, so fade, slide, and zoom states affect it together with the child as `u-transition.vue` does. Source notice interactions, tag presentation/callbacks, and transition lifecycle/mode behavior remain active. |

Last update: 2026-07-26 (Batch HZ navbar inactive custom-style parity; flutter test 703 green)

| render parity | UPNavbar retains the Flutter `customStyle` constructor parameter and field for API compatibility but no longer renders it. The independent `u-navbar.vue` template binds only `navbarInnerStyle`, whose computed source value contains the resolved navbar background and never merges the shared field. Source backgrounds, borders, safe-area, fixed placeholders, slots, title styling, and click behavior remain active. |

Last update: 2026-07-26 (Batch IA badge custom-style precedence parity; flutter test 704 green)

| render parity | UPBadge retains source-active `customStyle`, but now follows `u-badge.vue` style-array ordering: caller decoration fields can override CSS defaults while explicit non-inverted source `bgColor` from the later `badgeStyle` overrides caller `customStyle.color`. Badge types, shapes, number modes, offsets, inversion, and child positioning remain active. |

Last update: 2026-07-26 (Batch IB avatar visible-root custom-style merge; flutter test 706 green)

| render parity | UPAvatar now merges source background and shape with caller decoration fields directly on its visible, sized avatar root, matching the single `.u-avatar` node that binds the Vue style array. Flutter no longer hides caller color, border, gradient, shadow, or radius behind a separate outer wrapper and opaque inner avatar container. Source size, clipping, image/text/icon modes, random backgrounds, callbacks, and image fallback remain active. |

Last update: 2026-07-26 (Batch IC icon glyph custom-style target parity; flutter test 707 green)

| render parity | UPIcon retains source-active `customStyle`, but now decorates only the source-equivalent glyph/image node. Its optional label remains a sibling outside that decoration, matching the separate `u-icon.vue` style bindings. Source glyph/image resolution, label positions, spacing, translation, click callback, and public helpers remain active. |

Last update: 2026-07-26 (Batch ID image visible-root custom-style merge; flutter test 708 green)

| render parity | UPImage now merges caller `customStyle` into its fixed-size, visible `.u-image` equivalent rather than wrapping that root in a Flutter-only decoration. Caller color, border, gradient, shadow, and radius therefore share the image, loading, and error node with source sizing; source `shape`, `radius`, `aspectFill`, and `aspectFit` still determine overflow clipping as `wrapStyle` does. Image fitting, placeholders, fade behavior, callbacks, and host helpers remain active. |

Last update: 2026-07-26 (Batch IE loading-icon custom-style root audit; flutter test 709 green)

| render parity | UPLoadingIcon keeps `customStyle` on the source-equivalent outer loading root, which contains both spinner and optional text just as `.u-loading-icon` does in `u-loading-icon.vue`. The existing Flutter decoration scope is already correct, so this batch adds a regression without changing production code; show behavior, orientation, text, color resolution, animation, and host helpers remain active. |

Last update: 2026-07-26 (Batch IF box visible-root custom-style merge; flutter test 710 green)

| render parity | UPBox now applies caller `customStyle` and its source `height` on one visible root, matching the `.u-box` style array. Flutter no longer places a decorated wrapper around a separate fixed-height `SizedBox`, which had made a 2px caller border expand an 80px root to 84px. The three source cells, gaps, backgrounds, border radii, default slots, and inert source callbacks remain active. |

Last update: 2026-07-26 (Batch IG grid custom-style root audit; flutter test 711 green)

| render parity | UPGrid retains `customStyle` on the source-equivalent outer grid root, which includes every grid item just as `.u-grid` receives `gridStyle` in `u-grid.vue`. The existing Flutter decoration scope is already correct, so this batch adds a regression without production code changes; columns, gaps, alignment, item borders, clicks, and parent data helpers remain active. |

Last update: 2026-07-26 (Batch IH line custom-style margin-root merge; flutter test 712 green)

| render parity | UPLine now applies caller `customStyle` to the source-equivalent line root before its CSS margin wrapper. Caller color, border, radius, gradient, and shadow therefore decorate the line's configured length instead of spilling across `margin` space; source horizontal/vertical sizing, hairline, dashed rendering, and margin shorthand remain active. |

Last update: 2026-07-26 (Batch II divider custom-style margin-root merge; flutter test 713 green)

| render parity | UPDivider now applies caller `customStyle` to the source-equivalent divider content root before the stylesheet's 15px vertical margin wrapper. Caller decoration covers the line/text/dot/slot area without painting through the source outer margin; click behavior, text positions, source line order, slots, and hairline/dashed options remain active. |

Last update: 2026-07-26 (Batch IJ row/col custom-style root audit; flutter test 715 green)

| render parity | UPRow retains its source-equivalent decorated row root. UPCol now attaches caller `customStyle` to the fixed-width column root before source positive or negative offset positioning, so caller borders, colors, gradients, and shadows start at the actual column rather than covering the offset gap. Source gutter padding, width/span, offsets, alignment, text alignment, and clicks remain active. |

Last update: 2026-07-26 (Batch IK line-progress visible-root custom-style merge; flutter test 716 green)

| render parity | UPLineProgress now merges caller `customStyle` with the source root's default pill radius on one clipped progress container, matching `.u-line-progress` with `overflow: hidden`. Caller color, border, gradient, shadow, and radius are no longer separated from the inactive/active track; source percentage clamping, animation, inner text, child slot, and from-right placement remain active. |

Last update: 2026-07-26 (Batch IL link custom-style root audit; flutter test 717 green)

| render parity | UPLink keeps caller `customStyle` on the single source-equivalent text node. Flutter's `TextStyle.merge(customStyle)` applies caller color, font size, decoration, and related text fields after intrinsic `linkStyle`, matching `:style="[linkStyle, addStyle(customStyle)]"`; its gesture handler remains non-visual. Link opening behavior, source underline handling, and the intentionally inactive `lineColor` prop remain active. |

Last update: 2026-07-26 (Batch IM back-top content-root custom-style merge; flutter test 718 green)

| render parity | UPBackTop now deep-merges caller `customStyle` fields with the source default gray/radius decoration on the inner 40px content root, while its position and fade remain on the outer transition equivalent. A caller gradient suppresses the source gray color to satisfy Flutter `BoxDecoration` rules, and caller image, border, radius, shadow, blend mode, and shape preserve the same source precedence. The custom-child branch remains unstyled because the Vue slot replaces `.u-back-top`; threshold visibility, offsets, icon style, and scroll callback remain active. |

Last update: 2026-07-26 (Batch IN cell-group/cell custom-style root merge; flutter test 720 green)

| render parity | UPCellGroup now merges caller decoration fields with its source card background on one outer root containing both the optional title and wrapper, matching `.u-cell-group`. UPCell keeps caller `customStyle` on `.u-cell`; when one is supplied, the Flutter-only internal body background becomes transparent so caller colors, gradients, borders, radii, images, shadows, blend modes, and shapes stay visible across the source body and lower line. Source titles, slots, disabled/click behavior, icon placement, separators, and navigation hooks remain active. |

Last update: 2026-07-26 (Batch IO empty custom-style root audit; flutter test 721 green)

| render parity | UPEmpty retains caller `customStyle` on the one visible empty-state root containing its icon, text, and optional child. The source `marginTop` remains an outside layout margin, matching Flutter's decorated `Container` with `margin`; no production change was required. Source mode/image selection, visibility, text resolution, colors, sizing, and slot behavior remain active. |

Last update: 2026-07-26 (Batch IP loading-page overlay-root custom-style merge; flutter test 722 green)

| render parity | UPLoadingPage now merges caller `customStyle` fields into its fixed full-page transition-root equivalent after the source page background, matching `overlayStyle`'s final object spread. A caller gradient suppresses the default page color to meet Flutter `BoxDecoration` constraints; caller image, border, radius, shadow, blend mode, and shape remain on the same overlay root. Overlay visibility, root z-index ordering, loading placement, image/icon selection, slots, and text behavior remain active. |

Last update: 2026-07-26 (Batch IQ list custom-style root audit; flutter test 723 green)

| render parity | UPList retains caller `customStyle` on its single source-equivalent scroll viewport root, sharing the same configured width and height as the contained ListView. No production change was required: source list sizing, scroll state, thresholds, refresh behavior, anchors, lower/upper aliases, and callbacks remain active. |

Last update: 2026-07-26 (Batch IR rate custom-style root audit; flutter test 724 green)

| render parity | UPRate keeps caller `customStyle` on its source-equivalent outer `.u-rate` root, containing the inner gesture layer and every generated star. No production change was required: full and half-star presentation, padding/gutter, touch selection, disabled/readonly behavior, model aliases, and callbacks remain active. |

Last update: 2026-07-26 (Batch IS sticky custom-style root merge; flutter test 725 green)

| render parity | UPSticky now merges caller `customStyle` with source `bgColor` on one outer `.u-sticky` placeholder root, so Flutter no longer uses an inner background layer that hides caller gradients and radii. Source `style` is merged after caller style, so `bgColor` remains authoritative for plain color conflicts; caller gradient, image, border, radius, shadow, blend mode, and shape remain visible at the root. In the source JS fallback, only `.u-sticky__content` is fixed, so the Flutter Overlay continues to carry the unstyled content node; fixed/unfixed callbacks, offsets, dimensions, and z-index ordering remain active. |

Last update: 2026-07-26 (Batch IT subsection custom-style root merge; flutter test 726 green)

| render parity | UPSubsection now merges caller `customStyle` with source wrapper fields on one clipped `.u-subsection` equivalent containing the active bar and items. In button mode, source `wrapperStyle.backgroundColor` follows the caller style and therefore remains authoritative for plain-color conflicts; a caller gradient suppresses the Flutter decoration color because `BoxDecoration` cannot paint both. Source radius, padding, bar motion, item borders, text states, selection, disabled behavior, and model/callback aliases remain active. |

Last update: 2026-07-26 (Batch IU switch custom-style root merge; flutter test 727 green)

| render parity | UPSwitch now merges caller `customStyle` into the source-equivalent animated `.u-switch` root rather than decorating a separate wrapper. Caller color, border, radius, image, shadow, blend mode, and shape follow `addStyle(customStyle)` after `switchStyle`; a caller gradient suppresses the source color because Flutter `BoxDecoration` cannot paint both. The same root retains source dimensions, pill clipping, active/inactive animation, background-transition layer, node, loading indicator, disabled opacity, and callbacks. |

Last update: 2026-07-26 (Batch IV tooltip custom-style root audit; flutter test 728 green)

| render parity | UPTooltip keeps caller `customStyle` on the outer `.u-tooltip` equivalent in both hidden-trigger and visible-popup states. The decoration contains the trigger and, when visible, the positioned popup content, while tooltip positioning, indicator styling, and popup color remain separate source-owned layers. No production change was needed; trigger modes, transparent overlay, copy/buttons, singleton ownership, callbacks, and public controls remain active. |

Last update: 2026-07-26 (Batch IW upload custom-style root audit; flutter test 729 green)

| render parity | UPUpload keeps caller `customStyle` on the outer `.u-upload` equivalent, outside the source-like wrapping preview/picker content. The decoration therefore includes all preview cards and the add trigger without replacing their individual backgrounds, borders, dimensions, status overlays, or callbacks. No production change was needed; picker, preview, upload progress, mutation helpers, popup behavior, and callback aliases remain active. |

Last update: 2026-07-26 (Batch IX search custom-style root audit; flutter test 730 green)

| render parity | UPSearch keeps caller `customStyle` on the `.u-search` equivalent before its source `margin` layout wrapper, so the root contains both the field and optional action. The source-owned content container remains an inner layer controlling input background, border, radius, and clipping; no production change was needed. Search input, focus/clear behavior, icon/action callbacks, animation, style props, and model aliases remain active. |

Last update: 2026-07-26 (Batch IY slider disabled custom-style root parity; flutter test 731 green)

| render parity | UPSlider now keeps caller `customStyle` on the outer `.u-slider` equivalent while applying disabled opacity only to the source-equivalent internal slider surface. Range mode dims both its internal track and source-owned range labels; single-value mode dims only the inner slider, leaving the sibling value label and caller root decoration unaffected. Length, vertical orientation, range values, thumb/track style inputs, interaction callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch IZ safe-bottom custom-style root audit; flutter test 732 green)

| render parity | UPSafeBottom keeps caller `customStyle` on the full-width `.u-safe-bottom` equivalent that also carries the source safe-area height. The retained `bgColor` API remains inactive because the Vue template and props do not render it. No production change was needed; MediaQuery-derived inset height, source style precedence, and public state helpers remain active. |

Last update: 2026-07-26 (Batch JA radio custom-style border-root parity; flutter test 733 green)

| render parity | UPRadio now keeps caller `customStyle` on the clipped `.u-radio` equivalent, matching source `overflow: hidden`. For column `borderBottom`, Flutter mirrors the global `.u-border-bottom !important` class: it forces the root border color and bottom border width/style while preserving caller top/left/right widths and styles. Caller gradients, radii, images, shadows, selection, disabled state, label placement, group propagation, and callbacks remain active. |

Last update: 2026-07-26 (Batch JB radio-group custom-style root audit; flutter test 734 green)

| render parity | UPRadioGroup keeps caller `customStyle` on the source-equivalent `.u-radio-group` root, enclosing every child radio and source-owned row-wrap or column layout gap. No production change was required: the existing Flutter `Wrap`/`Column` layout and root decoration scope already match the Vue template's `radioGroupStyle` binding. Source `flex: 1` remains intentionally unforced because it only participates under a flex parent and a universal Flutter `Expanded` would be invalid in non-Flex layouts. Group selection, parent propagation, placement, gap, callbacks, and aliases remain active. |

Last update: 2026-07-26 (Batch JC checkbox custom-style border-root parity; flutter test 735 green)

| render parity | UPCheckbox now keeps caller `customStyle` on the clipped `.u-checkbox` equivalent, matching source `overflow: hidden`. For column `borderBottom`, Flutter mirrors the global `.u-border-bottom !important` class: it forces the root border color and bottom border width/style while preserving caller top/left/right widths and styles. UPCheckboxGroup continues to retain but not render its source-inactive `customStyle` API because `u-checkbox-group.vue` does not bind it. Caller gradients, radii, images, shadows, selection, disabled state, label placement, group propagation, and callbacks remain active. |

Last update: 2026-07-26 (Batch JD form-item custom-style body-root parity; flutter test 736 green)

| render parity | UPFormItem now applies caller `customStyle`, its source 10px vertical body padding, and the body click handler only to the inner `.u-form-item__body` equivalent. Error-message and border-bottom nodes remain following unstyled siblings, matching `u-form-item.vue` instead of placing them inside the caller decoration and gesture target. Label positions, slots, right icons, validation, parent form propagation, error modes, and lower-line rendering remain active. |

Last update: 2026-07-26 (Batch JE textarea visible-root custom-style merge; flutter test 737 green)

| render parity | UPTextarea keeps caller `customStyle` merged into its single visible `.u-textarea` root, containing both the editable field and optional count indicator. When caller style supplies a gradient, Flutter clears the incompatible source fallback color because `BoxDecoration` cannot paint both; caller color, border, radius, image, shadow, blend mode, and shape otherwise retain source merge precedence. Source sizing, padding, border modes, focus state, counters, formatter, callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch JF input visible-root custom-style merge; flutter test 738 green)

| render parity | UPInput keeps caller `customStyle` merged into its single visible `.u-input` root, containing prefix, editable field, clear control, password toggle, and suffix content. When caller style supplies a gradient, Flutter clears the incompatible source fallback color because `BoxDecoration` cannot paint both; caller color, border, radius, image, shadow, blend mode, and shape otherwise retain source merge precedence. Source padding, border modes, disabled/read-only behavior, focus, formatting, callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch JG number-box inactive custom-style audit; flutter test 738 green)

| render parity | UPNumberBox retains the Flutter `customStyle` API but does not render it, matching `u-number-box.vue`, whose root has no shared-style binding and whose buttons, input, and icons each use dedicated source style paths. The caller decoration therefore does not leak onto the group root or generated controls; step behavior, bounds, long press, input formatting, disabled states, callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch JH code-input inactive custom-style audit; flutter test 738 green)

| render parity | UPCodeInput retains the Flutter `customStyle` API but does not render it, matching `u-code-input.vue`, whose root has no shared-style binding and whose individual cells, cursor, line, and hidden input have dedicated source style paths. The caller decoration therefore does not leak onto the layout root or code cells; code length, box/line modes, focus, dot display, callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch JI message-input inactive custom-style audit; flutter test 738 green)

| render parity | UPMessageInput retains the Flutter `customStyle` API but does not render it, matching `u-message-input.vue`, whose centered layout root, hidden input, and generated cells have no shared-style binding. The caller decoration therefore does not leak onto the layout root or code cells; code length, box/middle-line/bottom-line modes, focus, breathing cursor, callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch JJ action-sheet inactive custom-style re-audit; flutter test 738 green)

| render parity | UPActionSheet retains the Flutter `customStyle` API but does not render it, matching `u-action-sheet.vue`, whose popup call, panel root, action cells, and cancellation region have no shared-style binding. The caller decoration therefore does not leak onto the visible popup panel or generated action content; popup behavior, title/description, selection, disabled/loading actions, cancellation, and update-show callbacks remain active. |

Last update: 2026-07-26 (Batch JK action-sheet-data inactive custom-style re-audit; flutter test 738 green)

| render parity | UPActionSheetData retains the Flutter `customStyle` API but does not render it, matching its separate `u-action-sheet-data.vue` template, which neither declares nor binds the prop on its root, trigger, cover, or nested action sheet. The caller decoration therefore does not leak onto the trigger or visible nested popup panel; option selection, model updates, and nested action-sheet behavior remain active. |

Last update: 2026-07-26 (Batch JL tag inactive custom-style re-audit; flutter test 738 green)

| render parity | UPTag retains the Flutter `customStyle` API but does not render it, matching `u-tag.vue`, which derives the visible tag from its local `style` binding and never binds the inherited shared prop. The caller decoration therefore does not leak onto the animated transition wrapper or tag body; local color/background/border overrides, size, shape, icon, close control, callbacks, and visibility remain active. |

Last update: 2026-07-26 (Batch JM tabs/tabs-item inactive custom-style re-audit; flutter test 738 green)

| render parity | UPTabs and UPTabsItem retain their Flutter `customStyle` APIs but do not render them, matching `u-tabs.vue` and `u-tabs-item.vue`, neither of which binds the inherited shared prop. Caller decoration therefore does not leak onto the tabs root, shape-mode wrapper, navigation, generated tabs, line, or content pane; current selection, shape modes, scrolling, badges, callbacks, model aliases, and pane content remain active. |

Last update: 2026-07-26 (Batch JN navbar inactive custom-style re-audit; flutter test 738 green)

| render parity | UPNavbar retains the Flutter `customStyle` API but does not render it, matching `u-navbar.vue`, whose fixed placeholder, inner root, safe-area, and content nodes bind only source-computed background and local styles. Caller decoration therefore does not leak onto the placeholder, safe-area region, inner navbar, border, or left/center/right content; source background, slots, title styling, fixed layout, and click behavior remain active. |

Last update: 2026-07-26 (Batch JO modal inactive custom-style re-audit; flutter test 738 green)

| render parity | UPModal retains the Flutter `customStyle` API but does not render it, matching `u-modal.vue`, which passes only a fixed internal style to `u-popup` and does not bind the shared prop. Caller decoration therefore does not leak onto the overlay, animated modal panel, reversed action controls, or popup-bottom content; source modal presentation, content, async behavior, callbacks, and visibility updates remain active. |

Last update: 2026-07-26 (Batch JP collapse inactive custom-style re-audit; flutter test 738 green)

| render parity | UPCollapse and UPCollapseItem retain their inherited Flutter `customStyle` APIs without rendering them, matching the unstyled source roots in `u-collapse.vue` and `u-collapse-item.vue`. Caller decoration therefore does not leak onto group lines, item roots, or expanded content. The independent source-active `cellCustomStyle` still decorates only the header cell root; expansion, borders, callbacks, model aliases, and accordion behavior remain active. |

Last update: 2026-07-26 (Batch JQ steps inactive custom-style re-audit; flutter test 738 green)

| render parity | UPSteps retains the Flutter `customStyle` API but does not render it, matching `u-steps.vue`, whose root and child templates bind only source-owned direction, item, marker, line, and content styles. Caller decoration therefore does not leak onto vertical/horizontal layout, dot or icon markers, error connectors, or text content; current state, colors, icons, item styles, and model aliases remain active. |

Last update: 2026-07-26 (Batch JR count-down inactive custom-style re-audit; flutter test 738 green)

| render parity | UPCountDown retains the Flutter `customStyle` API but does not render it, matching `u-count-down.vue`, whose root has no shared-style binding and whose default-slot fallback is an independently styled text node. Caller decoration therefore does not leak onto the countdown root or formatted time text; source time parsing, tick cadence, formatting, start/pause/reset controls, and callbacks remain active. |

Last update: 2026-07-26 (Batch JS count-to inactive custom-style re-audit; flutter test 738 green)

| render parity | UPCountTo retains the Flutter `customStyle` API but does not render it, matching `u-count-to.vue`, whose sole text node binds only local font-size, weight, and color props. Caller decoration therefore does not leak onto the animated number; source numeric formatting, easing, start/stop/resume/reset controls, and end callback behavior remain active. |

Last update: 2026-07-26 (Batch JT toolbar inactive custom-style re-audit; focused regressions green)

| render parity | UPToolbar retains the Flutter `customStyle` API but does not render it, matching `u-toolbar.vue`, whose root, action wrappers, title, and right-slot branch have no shared-style binding. Caller decoration therefore does not leak onto the toolbar layout, cancel/confirm controls, title, or right-slot content; show state, local action colors, right-slot replacement, and callbacks remain active. |

Last update: 2026-07-26 (Batch JU read-more inactive custom-style re-audit; focused regressions green)

| render parity | UPReadMore retains the Flutter `customStyle` API but does not render it, matching `u-read-more.vue`, whose root, content container, source shadow, default toggle, and named toggle slot do not bind the shared prop. Caller decoration therefore does not leak onto collapsed content, the source shadow overlay, default control, or custom toggle content; measurement, indent, expand/collapse behavior, callbacks, and toggle configuration remain active. |

Last update: 2026-07-26 (Batch JV section inactive custom-style re-audit; focused regressions green)

| render parity | UPSection retains the Flutter `customStyle` API but does not render it. The source `u-section` module supplies only default props and no Vue render component or style binding, so Flutter must not invent one. Caller decoration therefore does not leak onto the Flutter title, accent line, subtitle, or arrow presentation; source defaults and native click behavior remain active. |

Last update: 2026-07-26 (Batch JW card inactive custom-style re-audit; focused regressions green)

| render parity | UPCard retains the Flutter `customStyle` API but does not render it, matching `u-card.vue`, which binds only source-owned root radius, margin, and shadow fields plus separate head/body/foot style props. Caller decoration therefore does not leak onto the card root or custom head/body/foot content; borders, local region styles, slots, and source nested click propagation remain active. |

Last update: 2026-07-26 (Batch JX pagination inactive custom-style re-audit; focused regressions green)

| render parity | UPPagination retains the Flutter `customStyle` API as a compatible extra but does not render it, matching `u-pagination.vue`, which neither imports the shared mixin nor declares the prop. Caller decoration therefore does not leak onto pager items, totals, size controls, or previous/next buttons; source local button colors, page selection, size callbacks, and model aliases remain active. |

Last update: 2026-07-26 (Batch JY dropdown inactive custom-style re-audit; focused regressions green)

| render parity | UPDropdown retains the Flutter `customStyle` API but does not render it, matching `u-dropdown.vue`, whose menu, content layer, popup, mask, and item option paths bind only local styles. Caller decoration therefore does not leak onto the menu, open overlay, mask, popup panel, selected option, or disabled item; source local colors, selection, highlight, close, and callbacks remain active. |

Last update: 2026-07-26 (Batch JZ avatar-group inactive custom-style re-audit; focused regressions green)

| render parity | UPAvatarGroup retains the Flutter `customStyle` API but does not render it, matching `u-avatar-group.vue`, whose group root has no shared-style binding and whose only caller-independent decoration is the per-item overlap and source more overlay. Caller decoration therefore does not leak onto group layout, resolved avatars, or circle/square more badges; URL resolution, max-count, overlap, extra-value, and show-more callback behavior remain active. |

Last update: 2026-07-26 (Batch KA float-button inactive custom-style re-audit; flutter test 738 green)

| render parity | UPFloatButton retains the Flutter `customStyle` API but does not render it, matching `u-float-button.vue`, whose fixed root, trigger, expanded item circles, and named list slot bind only local offsets, colors, dimensions, and borders. Caller decoration therefore does not leak onto the trigger, expanded default items, or custom list-slot content; fixed placement, menu lifecycle, item callbacks, and local color/border overrides remain active. |

Last update: 2026-07-26 (Batch KB scroll-list inactive custom-style re-audit; flutter test 738 green)

| render parity | UPScrollList retains the Flutter `customStyle` API but does not render it, matching `u-scroll-list.vue`, whose root, horizontal content, and optional indicator bind only source-owned layout and the dedicated `indicatorStyle`, `lineStyle`, and `barStyle` values. Caller decoration therefore does not leak onto either indicator state or scrollable slot content; scrolling, indicator colors and placement, edge callbacks, and public scroll controls remain active. |

Last update: 2026-07-26 (Batch KC index-list inactive custom-style re-audit; flutter test 738 green)

| render parity | UPIndexList retains the Flutter `customStyle` API but does not render it, matching `u-index-list.vue`, whose root, scroll-view, header/footer slots, letter rail, and transition-wrapped touch indicator bind only source-owned layout and local color/state values. Caller decoration therefore does not leak onto scroll content, object index labels, active rail items, or the touch indicator; source header/footer slots, index navigation, touch selection, and callbacks remain active. |

Last update: 2026-07-26 (Batch KD title inactive custom-style re-audit; flutter test 738 green)

| render parity | UPTitle retains the Flutter `customStyle` API but does not render it, matching the standalone `u-title.vue`, which defines no props or shared mixin and renders only a root row, named prefix slot/default prefix fallback, and default content slot. Caller decoration therefore does not leak onto default or custom-prefix title content; source main-color inheritance and natural-width row layout remain active. |

Last update: 2026-07-26 (Batch KE view inactive custom-style re-audit; flutter test 738 green)

| render parity | UPView retains the Flutter `customStyle` API but does not render it, matching `u-view.vue`, whose shared-mixin root binds only direct background, text color, flex, size, spacing, and border props. Caller decoration therefore does not leak onto single-child or multi-child layouts; source active container styles, flex placement, and manual click handler remain active. |

Last update: 2026-07-26 (Batch KF picker inactive custom-style re-audit; flutter test 738 green)

| render parity | Main UPPicker retains the shared `customStyle` API but does not render it, matching `u-picker.vue`, whose wrapper, input trigger, popup, toolbar, columns, and loading layer bind only source-owned props. Caller decoration therefore does not leak onto inline popup, toolbar slots, object/text columns, loading, or input-trigger paths; active `bgColor`, popup, toolbar, model, callback, and input behavior remain active. |

Last update: 2026-07-26 (Batch KG number-keyboard inactive custom-style re-audit; flutter test 738 green)

| render parity | UPNumberKeyboard retains the Flutter `customStyle` API but does not render it, matching `u-number-keyboard.vue`, whose root, numeric key wrappers, width rule, gray-key rule, and backspace path bind only local keyboard state. Caller decoration therefore does not leak onto default numeric, dot-disabled, or card-mode keys; source-owned dot/X entries, wide zero key, gray backspace key, callbacks, and aliases remain active. |

Last update: 2026-07-26 (Batch KH keyboard inactive custom-style re-audit; flutter test 738 green)

| render parity | UPKeyboard retains the Flutter `customStyle` API but does not render it, matching `u-keyboard.vue`, which passes only internal `popupStyle` to its nested popup and never binds the caller style. Caller decoration therefore does not leak onto card toolbar/slot or no-toolbar car-keyboard paths; source popup background, tooltips, callbacks, card X key, and car keyboard remain active. |

Last update: 2026-07-26 (Batch KI datetime-picker inactive custom-style re-audit; flutter test 738 green)

| render parity | UPDatetimePicker retains the shared Flutter `customStyle` API but does not render or forward it, matching `u-datetime-picker.vue`, whose unstyled root conditionally renders only its input trigger and supplies its nested picker with explicit source-owned props. Caller decoration therefore does not leak onto the custom input trigger, toolbar, or `timesecond` columns; source trigger, popup, title, confirmation control, column generation, callbacks, and model aliases remain active. Dedicated `maskStyle` is a separate source prop and is outside this shared-style conclusion. |

Last update: 2026-07-26 (Batch KJ calendar inactive custom-style re-audit; flutter test 738 green)

| render parity | UPCalendar retains the shared Flutter `customStyle` API but does not render or forward it, matching `u-calendar.vue`, whose popup and unstyled calendar root bind only explicit source-owned properties while inline styles target calendar-list height. Caller decoration therefore does not leak onto page-inline range boundaries, title, week header, month cells, or confirmation action; source popup, selection, range rules, labels, navigation, and callbacks remain active. |

Last update: 2026-07-26 (Batch KK table inactive custom-style re-audit; flutter test 738 green)

| render parity | UPTable retains the shared Flutter `customStyle` API but does not render or forward it, matching `u-table.vue`, whose root binds only computed `tableStyle`. Caller decoration therefore does not leak onto table, header, or cell containers; source `borderColor`, `bgColor`, alignment, left/top table borders, header/cell layout, and `change` helper remain active. |

Last update: 2026-07-26 (Batch KL code inactive custom-style re-audit; flutter test 738 green)

| render parity | UPCode retains the shared Flutter `customStyle` API but does not render or forward it, matching the logic-only `u-code.vue` component whose empty root and timer methods never consume the prop. Caller decoration therefore does not leak into any widget tree; source start/change/end callbacks, countdown state, controller start/reset APIs, and keep-running storage behavior remain active. |

Last update: 2026-07-26 (Batch KM copy inactive custom-style re-audit; flutter test 738 green)

| render parity | UPCopy retains the Flutter `customStyle` API but does not render or forward it, matching `u-copy.vue`, which declares only copy props and binds its root solely to the click handler. Caller decoration therefore does not leak onto the default or custom-slot content; source clipboard write, toast/modal choice, success callback, falsey-content guard, and result helpers remain active. |

Last update: 2026-07-26 (Batch KN album inactive custom-style re-audit; flutter test 738 green)

| render parity | UPAlbum retains the shared Flutter `customStyle` API but does not render or forward it, matching `u-album.vue`, whose root, rows, image wrappers, and images bind only source-owned layout values. Caller decoration therefore does not leak onto empty, fixed-row, overflow, preview, or auto-wrap paths; source image sizing, spacing, `+N` counter, preview callbacks, and album-width behavior remain active. The template's fixed internal overflow-text `customStyle` is unrelated to this caller API. |

Last update: 2026-07-26 (Batch KO upload custom-style root re-audit; flutter test 738 green)

| render parity | UPUpload applies caller `customStyle` to the outer `.u-upload` equivalent, matching the explicit `addStyle(customStyle)` root binding in `u-upload.vue`. The decoration contains successful previews, upload/failed overlays, and the add trigger without replacing their source-owned dimensions, borders, backgrounds, status layers, or callbacks; preview, picker, file-list mutation, delete, upload, popup, and callback paths remain active. |

Last update: 2026-07-26 (Batch KP select inactive custom-style re-audit; flutter test 738 green)

| render parity | UPSelect retains the shared Flutter `customStyle` API but does not render or forward it, matching `u-select.vue`, whose root and inline props bind only source-owned trigger, overlay, and options-panel styles. Caller decoration therefore does not leak onto bordered labels or anchored overlay panels; source current-label display, option width, disabled behavior, selection callbacks, panel positioning, and close behavior remain active. Dedicated `overlayStyle` is separate from this shared-style conclusion. |

Last update: 2026-07-26 (Batch KQ table2 inactive custom-style re-audit; flutter test 738 green)

| render parity | UPTable2 retains the Flutter `customStyle` API but does not render or forward it, matching `u-table2.vue`, whose local-prop root binds only the `border` class while scroll regions, headers, rows, and fixed-column overlays use source-owned styles. Caller decoration therefore does not leak onto bordered table roots, headers, body cells, or fixed-left overlays; source sorting, selection, trees, row/cell style hooks, fixed columns, fixed headers, scrolling, callbacks, and public APIs remain active. |

Last update: 2026-07-26 (Batch KR virtual-list inactive custom-style re-audit; flutter test 738 green)

| render parity | UPVirtualList retains its Flutter `customStyle` field as a compatible extra but does not render it, matching `u-virtual-list.vue`, which declares only local virtualization props and binds root height, scroll position, item heights, and placeholders directly. Caller decoration therefore does not leak onto the list root, scroll viewport, item slots, or spacer nodes; source fixed-height virtualization, visible metadata, key selection, scroll callbacks, declarative scroll position, and range helpers remain active. |

Last update: 2026-07-26 (Batch KS refresh-virtual-list inactive custom-style re-audit; flutter test 738 green)

| render parity | UPRefreshVirtualList retains its Flutter `customStyle` field as a compatible extra but does not render or forward it, matching `u-refresh-virtual-list.vue`, whose template forwards only explicit refresh and virtualization props to nested `u-pull-refresh` and `u-virtual-list`. Caller decoration therefore does not leak onto the refresh wrapper, virtual-list root, viewport, item slots, or spacer nodes; source refresh state, refresh event, scroll forwarding, fixed-height items, visible metadata, and public finish/scroll controls remain active. |

Last update: 2026-07-26 (Batch KT pull-refresh inactive custom-style re-audit; flutter test 738 green)

| render parity | UPPullRefresh retains its Flutter `customStyle` field as a compatible extra but does not render or forward it, matching `u-pull-refresh.vue`, whose root handles touch events and whose indicator, translated content, scroll wrapper, and optional load-more bind only source-owned state and explicit props. Caller decoration therefore does not leak onto the gesture root, pull/release/refresh indicator, content viewport, child slot, or load-more region; source pull lifecycle, thresholds, damping, scroll behavior, load-more configuration, callbacks, slots, and public refresh controls remain active. |

Last update: 2026-07-26 (Batch KU loadmore custom-style root re-audit; flutter test 739 green)

| render parity | UPLoadmore applies caller `customStyle` to the outer `.u-loadmore` equivalent, matching the explicit first `addStyle(customStyle)` root binding in `u-loadmore.vue`. Caller gradient remains on the root decoration while source `bgColor` remains the root base color; nested loading icon, status text, line dividers, margins, height, and load-more click behavior remain source-owned and independent. |

Last update: 2026-07-26 (Batch KV loading-icon custom-style root re-audit; flutter test 739 green)

| render parity | UPLoadingIcon applies caller `customStyle` to the outer `.u-loading-icon` equivalent, matching the explicit `addStyle(customStyle)` source root binding. The decoration contains the spinner and optional text in either horizontal or vertical layout without changing their source-owned color, size, mode, timing, or visibility behavior. |

Last update: 2026-07-26 (Batch KW loading-page transition custom-style re-audit; flutter test 739 green)

| render parity | UPLoadingPage applies caller `customStyle` to its full-page transition root, matching `u-loading-page.vue`, which supplies computed overlay geometry, background, display, and z-index before spreading caller style into `u-transition`. A caller gradient remains scoped to the visible page layer while source loading icon and text remain nested source content; loading visibility, image/icon choice, text/color/size props, source z-index, and overlay ordering remain active. |

Last update: 2026-07-26 (Batch KX overlay visible custom-style re-audit; flutter test 739 green)

| render parity | UPOverlay merges caller `customStyle` into the visible mask, matching `u-overlay.vue`, whose computed `overlayStyle` applies fixed mask geometry and opacity before deep-merging caller style into its transition root. Caller gradients and borders remain on the keyed tappable mask rather than the optional slot child; source visibility, transition timing, opacity, z-index ordering, click handling, touch blocking, and root-overlay placement remain active. |

Last update: 2026-07-26 (Batch KY transition custom-style root re-audit; flutter test 741 green)

| render parity | UPTransition applies caller `customStyle` to its transition root, matching `u-transition.vue`, whose `mergeStyle` places caller styles on the root before source-owned animation `viewStyle`. Caller gradient and border contain only the slot child in both animated and `none` branches; source animation mode, transforms, opacity, timing, visibility, callbacks, touch behavior, and internal style precedence remain active. |

Last update: 2026-07-26 (Batch KZ popup template-style re-audit; flutter test 741 green)

| render parity | UPPopup keeps caller `customStyle` on the source-equivalent `.u-popup__content` panel only, merging it after the source background and directional radius so the decorated panel contains popup content, safe-area behavior, gesture area, and close control without affecting the transition or mask. Separately, source `overlayStyle` now forwards to the visible `UPOverlay` mask when expressed as Flutter's supported `BoxDecoration`, and that mask uses the source `duration + 50ms` timing. Popup modes, content transitions, overlay opacity/z-index, close handling, callbacks, and page-inline behavior remain independent. |

Last update: 2026-07-26 (Batch LA popover manual-show re-audit; flutter test 742 green)

| behavior parity | UPPopover now applies initial `show` only in source-supported `manual` trigger mode, matching the delegated `u-tooltip.vue` watcher. Click and long-press modes remain gesture-driven even when constructed with `show: true`; manual external updates and public open/close/toggle behavior remain intact. The thin wrapper still leaves its source-inactive `customStyle` and `update:show` paths unrendered and unforwarded, while trigger/content slots, direction, colors, positioning, and callbacks retain their source-specific behavior. |

Last update: 2026-07-26 (Batch LB calendar popup-forwarding re-audit; flutter test 744 green)

| render parity | UPCalendar keeps its shared `customStyle` API inert, matching the unstyled source calendar root, while now forwarding every source-explicit popup chrome path: `overlayStyle` reaches the visible mask, `safeAreaInsetTop` reaches popup content, and `closeable` is enabled only when `pageInline` is false. Calendar selection, ranges, title/header, confirmation, inline mode, existing safe-bottom handling, timing, opacity, z-index, close policy, and callbacks remain source-owned and independent. |

Last update: 2026-07-26 (Batch LC picker/datetime-picker mask-forwarding re-audit; flutter test 750 green)

| behavior parity | UPPicker now treats `maskStyle` as the source picker-view mask rather than deriving it from popup `overlayOpacity`: supported Flutter decorations and simple color values render in an input-transparent layer scoped only to the wheel viewport, and the source dark-theme gradient remains active when no explicit mask is supplied. UPDatetimePicker now owns its source `hasInput` trigger toggle and forwards its template-explicit `toolbarRightSlot`, `maskClass`, and resolved `maskStyle` to the nested picker without creating a second picker input trigger. `maskClass` remains API-compatible as a string; Flutter cannot apply CSS-class rules without a CSS engine. Popup, toolbar, columns, callbacks, model aliases, custom-style non-rendering, and close policy remain independent. |

Last update: 2026-07-26 (Batch LD datetime-picker filter/format re-audit; flutter test 752 green)

| behavior parity | UPDatetimePicker now applies source `filter(type, values)` to every generated date/time column before default-index resolution, including safe index-zero fallback when filtering removes the current value. Its built-in date input now honors the explicit source `format` with supported numeric Day.js tokens (`YYYY`, `YY`, `MM`, `M`, `DD`, `D`, `HH`, `H`, `mm`, `m`, `ss`, `s`); `time` and `timesecond` retain their source raw-value display. Source range generation, formatter hooks, popup/mask forwarding, input trigger behavior, confirmation and model callbacks remain independent. |

Last update: 2026-07-26 (Batch LE datetime-picker date-boundaries re-audit; flutter test 754 green)

| behavior parity | UPDatetimePicker now follows source `getBoundary` hierarchy for date modes: year limits constrain months, matching year/month constrains days, and matching day constrains hours, minutes, and seconds. Initial, updated, programmatic, and wheel-composed date values clamp to the configured `minDate`/`maxDate`; selecting a date rebuilds later columns with its new active range. Independent `time`/`timesecond` limits, filtering, input formatting, formatter hooks, popup/mask forwarding, and callbacks remain unchanged. |

Last update: 2026-07-26 (Batch LF picker immediate-change re-audit; flutter test 755 green)

| behavior parity | UPPicker now maps `immediateChange=false` to Flutter wheel lifecycle: selected state updates during scrolling but the source-compatible `change` callback waits for that wheel's scroll-end notification and reports only the final values/indexes/changed column. The default immediate path and public imperative `changeHandler` remain immediate; popup lifecycle, confirmation, cancellation, columns, masks, input behavior, model aliases, and datetime-picker integration remain independent. |

Last update: 2026-07-26 (Batch LG picker input-state re-audit; flutter test 759 green)

| behavior parity | With `hasInput`, UPPicker now combines external `show`, command-driven visibility, and source-style `showByClickInput` instead of letting the input path override external visibility. Its default trigger is a read-only `UPInput` with source default/input-prop merging and a label derived from confirmed `modelValue`/`value`; object values resolve `valueName` back to `keyName` labels and primitive values remain slash-joined. Custom and default triggers toggle only local input-popup state; pending wheel values remain separate until confirmation. |

Last update: 2026-07-26 (Batch LH picker reactivity/payload re-audit; flutter test 766 green)

| behavior parity | UPPicker now mirrors source deep prop watchers: nested `columns` changes are observed without resetting current indexes; initial matched `modelValue` overrides `defaultIndex`, while a later default-index-only update applies independently; simultaneous updates preserve source watcher order. `setColumnValues` resets selections after the last wheel changed, enabling source-style cascades. `closeHandler` is inert when overlay close is disabled, and `inputProps.disabled` styles the internal input without disabling the picker trigger. `change`/`confirm` return raw selected items while update callbacks return value-field arrays. Wheel text and the loading cover now use active theme `mainColor` and `cardBgColor`, including dark mode. |

Last update: 2026-07-26 (Batch LI picker/datetime-picker template-reactivity re-audit; flutter test 785 green)

| behavior parity | UPPicker now uses only configured `keyName` and `valueName` for object columns, reports the source first-unconfirmed changed column, exposes `toolbarBottom`, and keeps a controlled `show: true` visually authoritative while still emitting source `update:show(false)` for an allowed overlay close. UPPickerData uses the source single `[options]` column and disabled input defaults, overlays a real click cover above the disabled Flutter input, keeps raw confirmation data long enough to emit configured value and label fields, and does not close local state for source `close` or unbound nested `update:show` events. UPDatetimePicker now forwards toolbar/input template paths, restores controlled values on reopen, accepts source time strings, and applies public `formatter(type, value)` throughout generated-column and index handling. |

Last update: 2026-07-26 (Batch LJ picker-data/datetime-picker event re-audit; flutter test 787 green)

| behavior parity | UPPickerData now watches only its effective model value, matching the source's sole `modelValue` watcher: replacing options updates the nested single-column picker but preserves the wrapper's displayed label and default index until the model value changes. UPDatetimePicker's command-style `setFormatter` retains source delayed-rebuild semantics. Its `onUpdateShow` Dart parameter remains accepted for source-facing API tolerance but is intentionally inactive, because the source component neither declares `update:show` nor binds that nested picker event; close, cancel, confirm, change, model callbacks, controlled visibility, and has-input state remain source-specific. |

Last update: 2026-07-26 (Batch LK picker-data model-value re-audit; flutter test 789 green)

| behavior parity | UPPickerData now follows its source `modelValue` truthiness and matching branches exactly: empty, false, zero, and NaN-style values clear its wrapper label/index, while a truthy value only changes them after matching an option's configured `valueKey`; a missing truthy value preserves an established selection. Options remain an independently propagated nested picker column, and confirmation, aliases, click cover, cancel, and close behavior remain unchanged. |

Last update: 2026-07-26 (Batch LL datetime-picker confirm/input re-audit; flutter test 792 green)

| behavior parity | UPDatetimePicker now keeps source input-cover semantics when its default input is disabled through `inputProps`: component-level `disabled` alone controls opening. Both command and toolbar confirmation clear has-input local popup state while emitting value/confirm callbacks without incorrectly invoking the overlay-only `close` path. Cancel, overlay close, controlled show, formatted values, and nested picker callbacks retain their distinct source event behavior. |

Last update: 2026-07-26 (Batch LM datetime-picker controlled-value/event re-audit; flutter test 799 green)

| behavior parity | UPDatetimePicker now runs source value normalization on initial, controlled, props, and external-show paths: empty time values select configured minimum parts, empty or invalid date values select `minDate`, and an external hide clears local has-input visibility. Its public `correctValue` follows the source pure return contract. Nested wheel change synchronizes internal selection and columns, and change/confirm now emit source `{ value, mode }` payloads while model-value callbacks retain the normalized raw value. |

Last update: 2026-07-26 (Batch LN datetime-picker input-event-timing re-audit; flutter test 801 green)

| behavior parity | UPDatetimePicker nested wheel changes now update internal selection, rebuild constrained columns, and emit only `{ value, mode }` through `onChange`; nested toolbar confirmation and public command `confirm()` emit the normalized raw value through `onInput` after model-value callbacks. This conclusion is limited to those source-derived interaction paths and does not redefine the existing Flutter-specific `setValue()` API. Confirmation payloads, has-input popup closing, controlled visibility, range rebuilding, and other picker events remain independent. |

Last update: 2026-07-26 (Batch LO datetime-picker boundary/input-display re-audit; flutter test 803 green)

| behavior parity | UPDatetimePicker now exposes source-shaped `getBoundary(type, innerValue)` results with `minYear` through `minSecond` or `maxYear` through `maxSecond`, including the source nested boundary rules for the supplied date. Its built-in `hasInput` display is now a distinct confirmed value: initialization and controlled-value changes populate it, wheel changes retain it while updating internal selection and columns, and toolbar or command confirmation refreshes it. Existing Flutter-specific `setValue()` behavior is intentionally outside this source-method conclusion. |
