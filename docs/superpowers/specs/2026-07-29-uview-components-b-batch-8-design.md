# Components B Eighth Source-Order Batch Design

**Date:** 2026-07-29

**Status:** Approved for implementation

## Goal

Migrate the next three registered uView Plus Components B source pages after
Progress into the Flutter example:

1. `pages/componentsB/tabbar/tabbar`
2. `pages/componentsB/tabbar/tabbar2`
3. `pages/componentsB/waterfall/waterfall`

The pages must preserve source order, navigation titles, visible Chinese labels,
representative default state, principal interaction, and Android/iOS-only
runtime behavior. Flutter component class names continue to use the `UP` prefix.

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsB/tabbar/tabbar.nvue`
- `src/pages/componentsB/tabbar/tabbar2.vue`
- `src/pages/componentsB/waterfall/waterfall.nvue`

No preview route is marked available before its real catalog route and page
builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_b/`. Register the routes immediately after
Progress in `example_catalog.dart`; enable existing preview rows for Tabbar and
Waterfall without reordering the preview catalog.

Both Tabbar pages use real `UPTabbar` and `UPTabbarItem`. Waterfall uses real
`UPWaterfall` and `UPLoadmore`. The corresponding package widget files are
currently untracked and must be included in the implementation commit:

- `up_tabbar.dart`
- `up_waterfall.dart`
- `up_loadmore.dart`

The two Tabbar source pages share similar examples but differ in their extended
style blocks and fixed-bottom behavior. Keep them as separate route pages so
route identity and page titles remain 1:1 with source.

## Tabbar Page

Create `TabbarPage` with route title `Tabbar` and page key
`example-page-componentsB/tabbar/tabbar`.

Render source blocks in order:

1. `基础功能`
2. `显示徽标`
3. `匹配标签的名称`
4. `自定义图标/颜色`
5. `拦截切换事件(点击第二个标签)`
6. `去除上边框`
7. `首页导航推荐：胶囊风格`
8. `首页导航推荐：上浮风格`
9. `中间按钮自定义背景色`
10. `中间按钮自定义图标`
11. `首页导航推荐：发光风格`
12. `固定在底部及中间按钮`

Each block owns the same source initial value. Because the Flutter
`UPTabbarItem` API requires explicit names for deterministic selection, numeric
source index examples pass `name: 0`, `name: 1`, and so on. The string-name
example passes `home`, `photo`, `play-right`, and `account`.

The intercept block follows the source `change5`: tapping the second tab shows
`请您先登录` and leaves the value unchanged; other tabs update the value. Fixed
bottom and middle-button examples expose visible status text for `goNext` and
`clickMidButton`, with `goNext` navigating to `tabbar2` through the existing
catalog helper.

Source network/static tabbar image icons are represented with local icon names
or `UPIcon`-based placeholders. This keeps Android/iOS examples directly
runnable without network image dependencies while retaining the same tab
structure and style props.

## Tabbar-vue Page

Create `Tabbar2Page` with route title `Tabbar-vue` and page key
`example-page-componentsB/tabbar/tabbar2`.

Render source blocks in order:

1. `基础功能`
2. `显示徽标`
3. `匹配标签的名称`
4. `自定义图标/颜色`
5. `拦截切换事件(点击第二个标签)`
6. `去除上边框`
7. `首页导航推荐：胶囊风格`
8. `首页导航推荐：上浮风格`
9. `中间按钮自定义背景色`
10. `中间按钮自定义图标`
11. `卡片风格 + 脉冲反馈`
12. `下划线风格`
13. `圆点风格`
14. `首页导航推荐：发光风格`
15. `固定在底部(固定在屏幕最下方)`

The interaction behavior matches Tabbar where the source methods match:
`change1` updates the basic value, `change5` intercepts the second tab with
`请您先登录`, and fixed bottom updates its own selected value.

## Waterfall Page

Create `WaterfallPage` with route title `瀑布流` and page key
`example-page-componentsB/waterfall/waterfall`.

Render the source waterfall product cards and load-more control:

- Initialize the list with 10 deterministic items derived from the source seed
  data, each with `id`, `price`, `title`, `shop`, `image`, and a synthetic
  `height` field so `UPWaterfall(columns: 'auto')` can balance columns
  consistently.
- Use local `assets/uview/swiper/swiper1.png`, `swiper2.png`, and
  `swiper3.png` instead of remote URLs.
- Card layout preserves source text, tags `自营` and `放心购`, price suffix `元`,
  shop text, rounded card, and close icon.
- Tapping the close icon calls `UPWaterfallState.remove(id)` through a
  `GlobalKey` and updates the visible `商品数量：N`.
- `UPLoadmore(status: loadStatus)` calls the same deterministic add method.
  The loadmore text is immediately testable; a page-level `加载更多` tap adds 10
  items and returns status to `loadmore`.

The source `onReachBottom` delayed loading is represented by the explicit
load-more control because Flutter widget tests and direct Android/iOS example
usage need a deterministic trigger.

## Data Flow And State

- Tabbar pages store one value per source block and visible status strings for
  intercepted tabs, fixed-bottom navigation, and middle-button taps.
- Waterfall stores `flowList`, `loadStatus`, and a deterministic cursor into the
  source seed list.
- No page shares mutable state with another route.

Callbacks update only their own demo row. Link navigation uses the existing
example catalog and does not introduce a new router.

## Error And Lifecycle Handling

- No new dependencies, permissions, remote image loads, or network calls are
  introduced.
- Waterfall timers are not needed; load more is immediate and deterministic.
- Fixed Tabbar examples are rendered inline in the scrollable example page
  rather than permanently overlaying the whole app, so tests can scroll through
  all blocks.
- Toasts are hidden in tests after assertions to avoid leakage between cases.

## Testing

Add focused widget tests before implementation:

- Tabbar page test taps the basic `放映厅` tab and verifies `基础值：1`.
- Tabbar page test taps the intercepted second tab and verifies `请您先登录` while
  `拦截值：0` remains visible.
- Tabbar2 page test renders its extra style blocks, taps the `圆点风格` example,
  and verifies `圆点值：1`.
- Waterfall page test renders source cards, closes one item, and verifies
  `商品数量：9`.
- Waterfall page test taps `加载更多` and verifies `商品数量：20`.
- Route catalog test updates completed total from 49 to 52 and verifies
  Components B order through `tabbar`, `tabbar2`, and `waterfall`.

At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_b/tabbar_page.dart lib/pages/components_b/tabbar2_page.dart lib/pages/components_b/waterfall_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_tabbar.dart lib/src/widgets/up_waterfall.dart lib/src/widgets/up_loadmore.dart test/widgets_test.dart
flutter test test/widgets_test.dart --reporter expanded
```

Install the resulting APK to MuMu at `127.0.0.1:16384`, launch
`com.example.ultra_ui_example/.MainActivity`, and verify it is focused.

## Commit Boundary

The design commit contains only this spec file.

The implementation commit contains only:

- The three new example pages.
- Route, preview, and test updates.
- The package widget files demonstrated by this batch.
- The implementation plan for this batch.

Existing unrelated modifications and untracked files remain untouched.
