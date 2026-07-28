# Components B Fifth Source-Order Batch Design

**Date:** 2026-07-28

**Status:** Approved for implementation

## Goal

Migrate the next three registered uView Plus Components B source pages after
CountTo into the Flutter example:

1. `pages/componentsB/search/search`
2. `pages/componentsB/badge/badge`
3. `pages/componentsB/tag/tag`

The pages must preserve source order, navigation titles, visible Chinese labels,
default values, principal interactions, and Android/iOS-only runtime behavior.
Flutter component class names continue to use the `UP` prefix.

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsB/search/search.nvue`
- `src/pages/componentsB/badge/badge.nvue`
- `src/pages/componentsB/tag/tag.nvue`

No preview route is marked available before its real catalog route and page
builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_b/`. Register the routes immediately after
CountTo in `example_catalog.dart`; enable their existing preview rows without
reordering the preview catalog.

Search, Badge, and Tag examples use real `UPSearch`, `UPBadge`, and `UPTag`
widgets. The corresponding package widget files are currently untracked and
must be included in the implementation commit, matching the previous batch
pattern for newly demonstrated package components.

`UPSearch` will gain a source-compatible `clearable` alias while retaining the
existing `clearabled` property. Runtime behavior uses `clearable ?? clearabled`
so old Flutter callers remain compatible and the source page can be written
with the uView Plus prop spelling.

## Search Page

Create `SearchPage` with route title `搜索` and page key
`example-page-componentsB/search/search`.

Render source blocks in order:

1. `基础功能`
2. `设置初始值`
3. `搜索框形状`
4. `右侧控件`
5. `可清空内容(仅focus时显示清除图标)`
6. `可清空内容(始终显示清除图标)`
7. `禁用输入框`
8. `点击左侧图标`
9. `搜索框内容水平对齐`
10. `自定义`

Each source search input is a controlled `UPSearch`. Initial values match the
source: `value2` starts as `天山雪莲`; other values start empty. The clearable
sections share the source initial value.

The left-icon click block calls `UPToast.show(context, message: '点击了左侧图标')`.
The right-action block leaves `showAction` enabled and `animation: true`.
The disabled block uses source placeholder text and emits only the disabled
click path. The custom block covers border color, search icon color,
placeholder color, text color, `label: '手机'`, and `searchIcon: 'scan'`.

## Badge Page

Create `BadgePage` with route title `徽标数` and page key
`example-page-componentsB/badge/badge`.

Render source blocks in order:

1. `直角边形状`
2. `徽标数显示方式`
3. `显示圆点`
4. `自定义主题`
5. `反转色`

All examples use real `UPBadge`. Layout follows the source row/wrap pattern
with top spacing and item gaps. The number display block must visibly include
ellipsis, overflow, and limit behavior for values `5132`, `1011`, `1500`, and
`45187`.

## Tag Page

Create `TagPage` with route title `标签` and page key
`example-page-componentsB/tag/tag`.

Render source blocks in order:

1. `基础功能`
2. `自定义主题`
3. `圆形标签`
4. `镂空标签`
5. `镂空带背景色`
6. `自定义尺寸`
7. `可关闭标签`
8. `带图片和图标`
9. `单选标签`
10. `多选标签`

All examples use real `UPTag`. The closeable section owns three booleans and
sets them false from `onClose`, matching the source. The radio section owns
three checked states and allows exactly one selected tag. The checkbox section
owns three checked states and toggles each independently.

The source image icon URL is replaced with the already packaged local asset
`assets/uview/demo/cell/tag.png`, passed through `UPTag.iconWidget` so runtime
does not use `Image.network`.

## Data Flow And State

- Search stores one string per source input and updates the matching value from
  `UPSearch.onChange`.
- Badge is stateless.
- Tag stores only closeable, radio, and checkbox state.
- Toast state remains owned by `UPToast`.

Callbacks update only their own demo row. No page shares mutable state with
another route.

## Error And Lifecycle Handling

- No new dependencies, permissions, remote image loads, or network calls are
  introduced.
- Search icon toast uses the existing `UPToast` overlay and does not schedule
  delayed work.
- Tag image icon uses an existing local asset already declared in
  `example/pubspec.yaml`.
- `UPSearch.clearable` is nullable so existing `clearabled` callers retain the
  same default behavior.

## Testing

Add focused widget tests before implementation:

- `UPSearch` component test proves `clearable: false` hides the clear icon while
  preserving the old `clearabled` default path.
- Search page test types into the basic source input and taps the left icon to
  show the source toast.
- Badge page test verifies the source limit formatting block renders `1.5k` and
  `4.51w`.
- Tag page test closes one closeable tag, switches radio selection, and toggles
  one checkbox.
- Route catalog test updates completed total from 40 to 43 and verifies
  Components B order through `search`, `badge`, and `tag`.

At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_b/search_page.dart lib/pages/components_b/badge_page.dart lib/pages/components_b/tag_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_search.dart lib/src/widgets/up_badge.dart lib/src/widgets/up_tag.dart test/widgets_test.dart
flutter test test/widgets_test.dart --reporter expanded
```

Install the resulting APK to MuMu at `127.0.0.1:16384`, launch
`com.example.ultra_ui_example/.MainActivity`, and verify it is focused.

## Commit Boundary

The implementation commit contains only:

- The three new example pages.
- Route, preview, and test updates.
- The `UPSearch` `clearable` alias and package test.
- The package widget files demonstrated by this batch.
- The implementation plan for this batch.

Existing unrelated modifications and untracked files remain untouched.
