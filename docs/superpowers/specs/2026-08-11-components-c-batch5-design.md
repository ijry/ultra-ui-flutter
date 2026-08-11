# Components C Batch 5 Design

## Goal

Implement the next five source-order Components C example pages:

1. `componentsC/swiper/swiper`
2. `componentsC/scrollList/scrollList`
3. `componentsC/codeInput/codeInput`
4. `componentsC/modal/modal`
5. `componentsC/picker/picker`

The pages must preserve the source Chinese titles, representative defaults,
principal interactions, and route order while keeping all test data local and
deterministic.

## Existing Context

Components C currently has 20 completed Flutter routes through Batch 4:

`form`, `textarea`, `noNetwork`, `loadmore`, `text`, `steps`, `navbar`,
`skeleton`, `input`, `album`, `avatar`, `readMore`, `layout`, `indexList`,
`indexList2`, `tooltip`, `guide`, `popover`, `tabs`, and `list`.

The next source-order routes are `swiper`, `scrollList`, `codeInput`, `modal`,
`picker`, followed by `calendar`, `datetimePicker`, and `subsection`.

The implementation follows the existing example patterns:

- One dedicated page file per route under `example/lib/pages/components_c/`.
- `ExamplePageScaffold` for page shells.
- `ExampleDemoBlock` for normal component demonstrations.
- `ultra_ui` public widgets and state APIs.
- Local assets under `example/assets`.
- Focused page tests plus route catalog regression tests.

The current worktree's modified `README.md` and historical untracked files
remain untouched.

## Scope

### Swiper page

Create `SwiperPage` with route title `轮播` and the following source sections:

- `基础功能`
- `纵向滑动`
- `带标题`
- `带指示器`
- `加载中`
- `嵌入视频`
- `自定义内容`
- `自定义指示器`
- `卡片式`

Use the existing local `swiper1.png`, `swiper2.png`, and `swiper3.png`
assets. Video data remains a local poster/type placeholder; no network video
is loaded. The page exposes deterministic current-index and click-count labels
for tests.

The source's vertical example requires a package API addition:

```dart
UPSwiper(vertical: true)
```

The page will not introduce a page-only replacement for `UPSwiper`.

### ScrollList page

Create `ScrollListPage` with route title `横向滚动列表` and source sections:

- `基础使用`
- `多菜单扩展`

Use fixed local goods and menu data. Existing local image assets may be
reused for the visual samples; network URLs from the source are not required.
The page exposes:

- a `查看更多` action count;
- left-edge and right-edge callback counts;
- stable keys for the scroll list and the action trigger.

The page uses `UPScrollList` and its existing public state methods for edge
and offset verification.

### CodeInput page

Create `CodeInputPage` with route title `验证码输入` and source sections:

- `基础使用`
- `横线模式`
- `设置长度`
- `设置间距`
- `细边框`
- `调整颜色`
- `点模式`
- `预置内容`

Use the source representative values, including preset values `123` and
`34`. The basic input exposes its current value and finish count. Tests cover
both the public `UPCodeInputState` path and a visible input interaction.

### Modal page

Create `ModalPage` with route title `模态框` and the ten source entries:

- `基础使用`
- `无标题`
- `带取消按钮`
- `异步关闭`
- `对调取消和确认按钮`
- `允许点击遮罩关闭`
- `传入slot`
- `自定义按钮`
- `淡入淡出动画`
- `带底部关闭按钮`

Use local deterministic state for all ten modal instances. The common source
content is:

`模态框，常用于消息提示、消息确认、在当前页面内完成特定的交互操作`

The async-confirm example uses a short deterministic delay and exposes its
loading/closed state. Slot, custom button, no-zoom, reverse-button, and
overlay-close variants remain visible and testable.

### Picker page

Create `PickerPage` with route title `选择器` and the six source entries:

- `基础使用`
- `设置默认项`
- `多列联动`
- `加载中状态(切换第一列)`
- `设置标题`
- `允许点击遮罩关闭`

Use local columns:

- single column: `中国`, `美国`, `日本`;
- linked second column: `深圳`, `厦门`, `上海`, `拉萨`;
- linked first-column values: `中国`, `美国`;
- linked replacement data: `深圳`, `厦门`, `上海`, `拉萨`;
- object-value sample: `苹果`, `橘子`, `香蕉`, using `keyName: 'label'` and
  `valueName: 'value'`.

The page uses `UPPickerState.setColumnValues` for linked columns, a short
deterministic loading delay for the loading example, and stable labels for
confirmed values and selected indexes.

## Routes and Catalogs

Add the five routes immediately after `componentsC/list/list` in source order:

```text
componentsC/swiper/swiper
componentsC/scrollList/scrollList
componentsC/codeInput/codeInput
componentsC/modal/modal
componentsC/picker/picker
```

Each route uses the source title from the existing manifest:

| Route | Title |
| --- | --- |
| `componentsC/swiper/swiper` | `轮播` |
| `componentsC/scrollList/scrollList` | `横向滚动列表` |
| `componentsC/codeInput/codeInput` | `验证码输入` |
| `componentsC/modal/modal` | `模态框` |
| `componentsC/picker/picker` | `选择器` |

Update the route catalog, preview catalog, route source-order assertions, and
completed-source-path assertions. Enable only these five preview records.
Do not reorder existing routes, add a generic route abstraction, or change
unrelated catalog group lengths.

## Package Boundary

First add a focused package regression test for vertical `UPSwiper`
behavior. If it fails because the public widget has no vertical mode, add the
smallest compatible API:

- `final bool vertical = false` on `UPSwiper`;
- a vertical `PageView` path selected by that flag;
- existing horizontal behavior unchanged;
- existing callbacks and public state methods unchanged.

No package change is planned for `UPScrollList`, `UPCodeInput`, `UPModal`, or
`UPPicker` unless a focused page test demonstrates an actual behavior gap.
Any such change must preserve existing constructor names and callbacks and
must include a focused package regression test.

## Testing

Add five page tests to `example/test/components_c_pages_test.dart`:

- `swiper page changes index and renders source variants`;
- `scroll list page reports edge actions and more action`;
- `code input page edits value and reports finish`;
- `modal page opens variants and handles async confirmation`;
- `picker page confirms defaults and linked columns`.

The tests use stable keys and public state APIs where timing or overlay layout
would otherwise make coordinate-based interaction unreliable.

Update `example/test/route_catalog_test.dart` to assert:

- 25 completed Components C routes;
- exact source order through `picker`;
- registered route IDs resolve to the expected catalog entries;
- the five preview records are available.

Run the following validation after implementation:

```text
dart format <changed Dart files>
flutter test test/components_c_pages_test.dart --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
flutter test
flutter analyze
cd ..\packages\ultra_ui
flutter test
flutter analyze
cd ..\..\example
flutter build apk --debug --target-platform android-arm64
cd ..
git diff --check
git status --short
git log -8 --oneline
```

The example analyzer must report no issues. The package analyzer may retain
the repository's existing warning/info baseline, but must report zero errors
from this batch. The Android debug APK must be generated successfully.

## Non-Goals

- No network image, video, or API dependency.
- No persistent storage or new dependency.
- No broad redesign of existing package widgets.
- No generic demo-page abstraction.
- No implementation of the following Components C routes in this batch:
  `calendar`, `datetimePicker`, or `subsection`.
- No cleanup or reversion of unrelated worktree files.

## Acceptance Criteria

The batch is accepted when:

1. All five pages render their source sections and local representative data.
2. The five routes are registered in exact source order and enabled in the
   preview catalog.
3. The focused page tests and route catalog tests pass.
4. The vertical swiper behavior is covered by a package regression test if the
   existing API lacks it.
5. Full package and example tests pass.
6. Example analysis has no issues; package analysis has no errors attributable
   to this batch.
7. Android debug build succeeds.
8. Existing `README.md` modifications and historical untracked files remain
   untouched.
