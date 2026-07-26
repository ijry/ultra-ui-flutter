$ErrorActionPreference = 'Stop'
$exampleRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = 'D:\Repos\xyito\open\uview-plus\src'
$assetsRoot = Join-Path $exampleRoot 'assets\uview'

New-Item -ItemType Directory -Force -Path (Join-Path $assetsRoot 'common') | Out-Null
Copy-Item -LiteralPath (Join-Path $sourceRoot 'static\uview\common\logo.png') `
  -Destination (Join-Path $assetsRoot 'common\logo.png') -Force

$assets = [ordered]@{
  'album\1.jpg' = 'https://uview-plus.jiangruyi.com/uview/album/1.jpg'
  'demo\cell\tag.png' = 'https://uview-plus.jiangruyi.com/uview/example/tag.png'
  'demo\transition\fade.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fade.png'
  'demo\transition\fadeUp.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeUp.png'
  'demo\transition\zoom.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/zoom.png'
  'demo\transition\fadeZoom.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeZoom.png'
  'demo\transition\fadeDown.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeDown.png'
  'demo\transition\fadeLeft.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeLeft.png'
  'demo\transition\fadeRight.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/fadeRight.png'
  'demo\transition\slideUp.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideUp.png'
  'demo\transition\slideDown.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideDown.png'
  'demo\transition\slideLeft.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideLeft.png'
  'demo\transition\slideRight.png' = 'https://uview-plus.jiangruyi.com/uview/demo/transition/slideRight.png'
  'demo\overlay\baseCases.png' = 'https://uview-plus.jiangruyi.com/uview/demo/overlay/baseCases.png'
  'demo\overlay\embeddedContent.png' = 'https://uview-plus.jiangruyi.com/uview/demo/overlay/embeddedContent.png'
  'demo\overlay\setTransparency.png' = 'https://uview-plus.jiangruyi.com/uview/demo/overlay/setTransparency.png'
  'demo\loading-page\promptContent.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/promptContent.png'
  'demo\loading-page\customPicture.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/customPicture.png'
  'demo\loading-page\customMode.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/customMode.png'
  'demo\loading-page\customBgColor.png' = 'https://uview-plus.jiangruyi.com/uview/demo/loading-page/customBgColor.png'
  'demo\popup\modeTop.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeTop.png'
  'demo\popup\modeRight.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeRight.png'
  'demo\popup\modeBottom.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeBottom.png'
  'demo\popup\modeLeft.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeLeft.png'
  'demo\popup\modeCenter.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/modeCenter.png'
  'demo\popup\showRadis.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/showRadis.png'
  'demo\popup\noClose.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/noClose.png'
  'demo\popup\showCloseBtn.png' = 'https://uview-plus.jiangruyi.com/uview/demo/popup/showCloseBtn.png'
  'swiper\swiper1.png' = 'https://uview-plus.jiangruyi.com/uview/swiper/swiper1.png'
  'swiper\swiper2.png' = 'https://uview-plus.jiangruyi.com/uview/swiper/swiper2.png'
  'swiper\swiper3.png' = 'https://uview-plus.jiangruyi.com/uview/swiper/swiper3.png'
  'test\list-item.jpg' = 'https://img2020.cnblogs.com/blog/35695/202112/35695-20211222112522991-1769312387.jpg'
}

foreach ($entry in $assets.GetEnumerator()) {
  $destination = Join-Path $assetsRoot $entry.Key
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Invoke-WebRequest -Uri $entry.Value -OutFile $destination
}

$emptyModes = 'address', 'car', 'comment', 'coupon', 'data', 'history', 'list', 'message', 'news', 'order', 'page', 'permission', 'search', 'wifi'
foreach ($mode in $emptyModes) {
  $destination = Join-Path $assetsRoot "empty\$mode.png"
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Invoke-WebRequest -Uri "https://uview-plus.jiangruyi.com/uview/empty/$mode.png" -OutFile $destination
}

$emptyDemoModes = 'car', 'data', 'comment', 'coupon', 'history', 'list', 'message', 'news', 'order', 'page', 'permission', 'search', 'wifi'
foreach ($mode in $emptyDemoModes) {
  $destination = Join-Path $assetsRoot "demo\empty\$mode.png"
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Invoke-WebRequest -Uri "https://uview-plus.jiangruyi.com/uview/demo/empty/$mode.png" -OutFile $destination
}
