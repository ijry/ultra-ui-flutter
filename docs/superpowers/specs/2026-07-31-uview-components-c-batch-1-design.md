# Components C First Source-Order Batch Design

**Date:** 2026-07-31

**Status:** Approved for implementation

## Goal

Migrate the first five registered uView Plus Components C source pages into the
Flutter example:

1. `pages/componentsC/form/form`
2. `pages/componentsC/textarea/textarea`
3. `pages/componentsC/noNetwork/noNetwork`
4. `pages/componentsC/loadmore/loadmore`
5. `pages/componentsC/text/text`

The pages must preserve source order, navigation titles, visible Chinese labels,
representative default state, principal interaction, and Android/iOS-only
runtime behavior. Flutter component class names continue to use the `UP` prefix.

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsC/form/form.nvue`
- `src/pages/componentsC/textarea/textarea.nvue`
- `src/pages/componentsC/noNetwork/noNetwork.nvue`
- `src/pages/componentsC/loadmore/loadmore.nvue`
- `src/pages/componentsC/text/text.nvue`

No preview route is marked available before its real catalog route and page
builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_c/`. Register the routes immediately after
`componentsB/table2/table2` in `example_catalog.dart`; enable the existing
preview rows without reordering the preview catalog.

The pages use real package widgets where they exist:

- `FormPage`: `UPForm`, `UPFormItem`, `UPInput`, `UPRadioGroup`,
  `UPCheckboxGroup`, `UPTextarea`, `UPActionSheet`, `UPCalendar`,
  `UPDatetimePicker`, `UPCode`, and `UPButton`.
- `TextareaPage`: `UPTextarea`.
- `NoNetworkPage`: `UPNoNetwork`, `UPIcon`.
- `LoadmorePage`: `UPLoadmore`.
- `TextPage`: `UPText`.

The corresponding package widget files are already present in the untracked
package set and should be included in the implementation commit only if they are
needed by these example pages or verification finds a real gap:

- `up_form.dart`
- `up_textarea.dart`
- `up_no_network.dart`
- `up_loadmore.dart`
- `up_text.dart`

No new shared abstraction is needed. Each page owns only the minimal state
required to make source interactions visible and testable.

## Form Page

Create `FormPage` with route title `表单` and page key
`example-page-componentsC/form/form`.

Render the source `基础使用` block with the same field order:

1. `姓名`
2. `性别`
3. `年龄`
4. `水果`
5. `兴趣爱好`
6. `简介`
7. `住店时间`
8. `验证码`
9. `生日`

The model starts with source values: name `楼兰`, fruit `苹果`, empty sex,
empty hobbies, empty intro, empty hotel, empty code, and empty birthday. Inputs
update the local model and the `UPFormState` model through `setModelValue`.

Validation uses source-shaped rules supported by `UPForm`: required, string,
array, min/max, and fixed length. The source async name validator is represented
as a synchronous source-compatible check that rejects non-Chinese input; the
delayed `异步规则` branch is not reproduced because this example must remain
deterministic in widget tests. Submitting with incomplete required fields shows
`校验失败`; once required representative fields are populated, submit shows
`校验通过`.

`性别` opens a real `UPActionSheet` with `男`, `女`, and `保密`; selecting `保密`
keeps the source validation failure path visible, while `男` or `女` writes the
field and validates it. `住店时间` opens a range `UPCalendar` and writes a visible
`YYYY-MM-DD / YYYY-MM-DD` style value on confirm. `生日` opens a
`UPDatetimePicker(mode: 'date')` and writes a source-style date string on
confirm. `验证码` uses `UPCode(seconds: 20)`; clicking the mini button shows
`验证码已发送`, starts the countdown, and disables while running. The source's
2-second backend wait is collapsed to an immediate action to keep tests fast.

The reset button calls `resetFields()` and `clearValidate()` and restores the
visible model to the initial source state.

## Textarea Page

Create `TextareaPage` with route title `文本域` and page key
`example-page-componentsC/textarea/textarea`.

Render source blocks in order:

1. `基础使用`
2. `字数统计`
3. `自动增高`
4. `禁用状态`
5. `下划线模式`

Each block uses a real `UPTextarea`. The first and second examples expose their
model values as visible text under the input, matching the source interpolation.
The second example starts with `统计字数` and `count: true`. The disabled example
uses `disabled: true` and placeholder `文本域已被禁用`; the bottom-border example
uses `border: 'bottom'`.

## NoNetwork Page

Create `NoNetworkPage` with route title `无网络提示` and page key
`example-page-componentsC/noNetwork/noNetwork`.

Render a real `UPNoNetwork` plus the source normal-network content:

- green success circle with `checkbox-mark`
- `网络正常`
- `请您断开设备的WiFi和数据连接(或开启飞行模式)，即可看到效果`

Because Flutter tests and examples cannot safely toggle host WiFi/data state,
the page keeps the source event callbacks as visible counters:
`断开：0`, `连接：0`, and `重试：0`. If `UPNoNetwork` exposes public show/retry
behavior in the existing package API, the page includes a small deterministic
test control to show the no-network panel and trigger retry; otherwise the
default normal-network content is still rendered and callbacks remain wired.

## Loadmore Page

Create `LoadmorePage` with route title `加载更多` and page key
`example-page-componentsC/loadmore/loadmore`.

Render source blocks in order:

1. `基础使用`
2. `无更多数据`
3. `加载更多(点击触发事件)`
4. `自定义图标`
5. `显示点`
6. `自定义提示语`
7. `自定义线条颜色`

Each block uses a real `UPLoadmore` with the source props: loading status,
nomore line, loadmore line, circle loading icon, dot display, custom loading
text, dashed line, and custom line color. The clickable loadmore block calls
its `onLoadmore` callback, increments a visible `加载次数：N` counter, and shows
the source `加载更多` toast.

## Text Page

Create `TextPage` with route title `文本` and page key
`example-page-componentsC/text/text`.

Render source blocks in order:

1. `基础功能`
2. `设置主题`
3. `拨打电话`
4. `日期格式化`
5. `姓名脱敏`
6. `超链接`
7. `显示金额`
8. `前后图标`
9. `超出隐藏`
10. `小程序开放能力`

Use real `UPText` examples with the source text values and props. The phone
example stays display-only by default because mobile dialing is host-owned. The
link example uses the existing `UPLink` behavior under `UPText(mode: 'link')`.
The source `openType="share"` path is represented with an Android/iOS fallback:
tapping `分享到微信` shows `请在微信小程序内查看效果`.

## Data Flow And State

- Form owns a local mutable model plus a `GlobalKey<UPFormState>` for validation,
  field reset, and source method calls.
- Textarea owns one string per source textarea example.
- NoNetwork owns event counters only.
- Loadmore owns a load-more click count.
- Text owns only source feedback status for click/share fallback.

Callbacks update only their own route page. No page shares mutable state with
another route.

## Error And Lifecycle Handling

- No new dependencies, permissions, remote image loads, or network calls are
  introduced.
- Form popup-like components are kept inside the page stack and expose explicit
  close/update-show callbacks so tests can dismiss them deterministically.
- Form countdown controllers and any timers are disposed through existing widget
  lifecycle behavior; tests hide toast overlays after assertions.
- NoNetwork does not attempt to mutate device network state.
- Text link opening remains controlled by the existing `UPLink` host hook.

## Testing

Add a new `example/test/components_c_pages_test.dart` before implementation.

Focused tests:

- Form page renders `基础使用`, opens the sex action sheet, selects `女`, and
  verifies visible `性别：女`.
- Form page submits incomplete data and verifies `校验失败`; after representative
  required fields are filled, submit verifies `校验通过`; reset restores
  `姓名：楼兰`.
- Textarea page edits the basic textarea and verifies the interpolated value.
- NoNetwork page renders `网络正常` and the source device-disconnect hint.
- Loadmore page taps the clickable loadmore row and verifies `加载次数：1`, then
  hides the toast.
- Text page renders mode examples, including the encrypted name, formatted
  price, icon labels, and the share fallback toast.
- Route catalog test updates completed total from 55 to 60 and verifies source
  order through `form`, `textarea`, `noNetwork`, `loadmore`, and `text`.

At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_c/form_page.dart lib/pages/components_c/textarea_page.dart lib/pages/components_c/no_network_page.dart lib/pages/components_c/loadmore_page.dart lib/pages/components_c/text_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_form.dart lib/src/widgets/up_textarea.dart lib/src/widgets/up_no_network.dart lib/src/widgets/up_loadmore.dart lib/src/widgets/up_text.dart test/widgets_test.dart
flutter test test/widgets_test.dart --reporter expanded
```

Install the resulting APK to MuMu at `127.0.0.1:16384`, launch
`com.example.ultra_ui_example/.MainActivity`, and verify it is focused.

## Commit Boundary

The design commit contains only this spec file.

The implementation commit contains only:

- The five new example pages.
- Route, preview, and test updates.
- Any package widget files from this batch that are required by the examples or
  changed to fix a verified gap.
- The implementation plan for this batch.

Existing unrelated modifications and untracked files remain untouched.
