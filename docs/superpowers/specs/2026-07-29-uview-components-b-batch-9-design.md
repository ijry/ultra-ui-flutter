# Components B Ninth Source-Order Batch Design

**Date:** 2026-07-29

**Status:** Approved for implementation

## Goal

Migrate the final three registered uView Plus Components B source pages after
Waterfall into the Flutter example:

1. `pages/componentsB/card/card`
2. `pages/componentsB/table/table`
3. `pages/componentsB/table2/table2`

The pages must preserve source order, navigation titles, visible Chinese labels,
representative default state, principal interactions, and Android/iOS-only
runtime behavior. Flutter component class names continue to use the `UP` prefix.

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsB/card/card.vue`
- `src/pages/componentsB/table/table.nvue`
- `src/pages/componentsB/table2/table2.nvue`

No preview route is marked available before its real catalog route and page
builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_b/`. Register the routes immediately after
Waterfall in `example_catalog.dart`; enable existing preview rows for Card,
Table, and Table2 without reordering the preview catalog.

Use real package widgets for all three pages:

- Card uses `UPCard`, `UPTitle`, `UPSubsection`, `UPIcon`, and `UPImage`.
- Table uses `UPTable`, `UPTr`, `UPTh`, `UPTd`, and `UPSubsection`.
- Table2 uses `UPTable2`, `UPButton`, `UPPopup`, `UPTag`, and `UPToast`.

The corresponding package widget files are currently untracked and must be
included in the implementation commit:

- `up_card.dart`
- `up_table.dart`
- `up_table2.dart`

## Card Page

Create `CardPage` with route title `卡片` and page key
`example-page-componentsB/card/card`.

Render source content in order:

1. `基础卡片`
2. `高级卡片`
3. `参数配置`
4. `左上角图标`
5. `内边距`
6. `底部`
7. `外边框`

The base card uses `showHead: false` and the source copy:
`尊敬的客户您好，您有来自的开票。如果有疑问请联系您的客户经理。`

The advanced card preserves the source title, subtitle, thumb URL, two body
rows, comment footer (`30评论`), border toggle, thumb toggle, footer toggle, and
padding options `10`, `15`, `20`. Interactions update visible state text so tests
and Android/iOS users can confirm that each source subsection changes the card.

Network card images may use the source URL because the page remains functional
without relying on image-load success; the visible text and layout are the test
surface.

## Table Page

Create `TablePage` with route title `表格` and page key
`example-page-componentsB/table/table`.

Render source content in order:

1. `演示效果`
2. `边框颜色`
3. `对齐方式`

The table preserves the source headers and rows:

- Headers: `姓名`, `年龄`, `籍贯`, `性别`
- Rows: `吕布/22/楚河/男`, `项羽/28/汉界/男`, `木兰/24/南国/女`

The border color subsection maps source options to:

- `gray` -> `#e4e7ed`
- `primary` -> `#2979ff`
- `warning` -> `#ff9900`

The alignment subsection maps source options to `left`, `center`, and `right`.
Visible status text shows the current border option and alignment.

## Table2 Page

Create `Table2Page` with route title `表格2` and page key
`example-page-componentsB/table2/table2`.

Render source content in order:

1. `基础表格（斑马纹 + 边框）`
2. `表格样式自定义`
3. `支持单选的表格`
4. `支持复选框的表格`
5. `支持排序与筛选`
6. `列固定`
7. `树形结构`
8. `单元格合并`
9. `弹窗中使用表格`

Use the source data and columns as the visible example shape. Long horizontal
tables are wrapped in bounded containers so Android/iOS pages remain scrollable
and tests can find each block deterministically.

Principal interactions:

- Row click stores the selected row id/name in visible text.
- Single-selection table uses `highlightCurrentRow` and `currentRowKey`.
- Selection table emits selected rows and shows a selected count.
- Sortable table emits current sort conditions and shows the latest field/order.
- Tree table starts expanded for key `1`, exposes expand-change text, and renders
  the `编辑` tag in the action column.
- Span table uses the source `arraySpanMethod` rules.
- Popup table opens from `打开弹窗表格`, clicking a row shows the selected row name,
  displays a toast-compatible status, and closes the popup.

The source filter prop is preserved as an input to `UPTable2`, but the visible
demo focuses on sort and row interaction because those are the actionable
behaviors in the Flutter widget.

## Data Flow And State

- Card stores `thumb`, `padding`, `bottomSlot`, `border`, and click status.
- Table stores `borderColor`, source border option label, and `align`.
- Table2 stores `currentRowId`, selected rows, latest sort/filter/expand text,
  popup visibility, and popup selection text.

State is local to each route page. No page shares mutable state with another
route.

## Error And Lifecycle Handling

- No new dependencies, permissions, or platform channels are introduced.
- Source MP-WEIXIN-only table behavior is ignored because the target runtime is
  Android/iOS Flutter only.
- Popup examples use the existing `UPPopup` behavior and avoid unbounded table
  heights inside overlays.
- Tests use fixed pumps where popup/overlay transitions are involved.

## Testing

Add focused widget tests before implementation:

- Card page test toggles thumb, padding, footer, and border and verifies visible
  state text plus source card copy.
- Table page test switches border color and alignment and verifies the source
  table row content remains visible.
- Table2 page test taps a base row and verifies row-click status.
- Table2 page test toggles selection and sort, then verifies selected count and
  sort status.
- Table2 page test opens the popup table, taps a row, verifies popup selection
  status, and confirms the popup closes.
- Route catalog test updates completed total from 52 to 55 and verifies
  Components B order through `card`, `table`, and `table2`.

At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_b/card_page.dart lib/pages/components_b/table_page.dart lib/pages/components_b/table2_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_card.dart lib/src/widgets/up_table.dart lib/src/widgets/up_table2.dart test/widgets_test.dart
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
