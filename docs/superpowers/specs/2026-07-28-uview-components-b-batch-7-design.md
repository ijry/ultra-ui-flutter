# Components B Seventh Source-Order Batch Design

**Date:** 2026-07-28

**Status:** Approved for implementation

## Goal

Migrate the next three registered uView Plus Components B source pages after
Collapse into the Flutter example:

1. `pages/componentsB/code/code`
2. `pages/componentsB/noticeBar/noticeBar`
3. `pages/componentsB/progress/progress`

The pages must preserve source order, navigation titles, visible Chinese labels,
representative default state, principal interaction, and Android/iOS-only
runtime behavior. Flutter component class names continue to use the `UP` prefix.

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsB/code/code.nvue`
- `src/pages/componentsB/noticeBar/noticeBar.nvue`
- `src/pages/componentsB/progress/progress.nvue`

No preview route is marked available before its real catalog route and page
builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_b/`. Register the routes immediately after
Collapse in `example_catalog.dart`; enable their existing preview rows without
reordering the preview catalog.

Code, NoticeBar, and Progress examples use real `UPCode`, `UPNoticeBar`, and
`UPLineProgress` widgets. The corresponding package widget files are currently
untracked and must be included in the implementation commit, matching the
previous batch pattern for newly demonstrated package components.

No new shared abstraction is needed. Each page owns only the minimal state
required to make the source interaction visible and testable.

## Code Page

Create `CodePage` with route title `验证码` and page key
`example-page-componentsB/code/code`.

Render source blocks in order:

1. `基础功能`
2. `保持倒计时(开始后，左上角返退出此页面再进入，会发现倒计时还在继续)`
3. `文本样式`

Each block uses a real logic-only `UPCode` with its own `UPCodeController`.
Visible controls are the source `UPButton` or tappable text. The first block
uses `seconds: 20` and `changeText: 'XS获取'`; the keep-running block uses
`keepRunning: true`, `uniqueKey: 'code-page-keep'`, and
`changeText: '倒计时XS'`; the text-style block uses
`startText: '点我获取验证码'` and primary colored text.

The source simulates a 2 second backend request before calling `start()`. The
Flutter example shows the same `验证码已发送` toast immediately when the user can
request a code, then starts the countdown. This keeps widget tests fast while
preserving the visible behavior after the request succeeds. If the countdown is
already running, the page shows `倒计时结束后再发送`.

## NoticeBar Page

Create `NoticeBarPage` with route title `滚动通知` and page key
`example-page-componentsB/noticeBar/noticeBar`.

Render source blocks in order:

1. `基础功能`
2. `可关闭`
3. `自定义横向滚动速度`
4. `可跳转(点击右箭头)`
5. `横向步进滚动`
6. `纵向滚动`
7. `纵向滚动(文字居中)`
8. `自定义样式`

Use the exact source notice text values and poem list. The source `mode`,
`fontSize`, `speed`, `direction`, `step`, `justifyContent`, `color`, and
`bgColor` props map directly to `UPNoticeBar`.

The link example routes `/pages/componentsB/tag/tag` to the completed Flutter
Tag page using the existing example catalog navigation helper. Step and column
examples store the last clicked poem index as a visible `点击索引：N` status so
their `onClick` behavior is testable without reading console output. The
closable example uses component close behavior and exposes `关闭事件：1` after
closing.

## Progress Page

Create `ProgressPage` with route title `进度条` and page key
`example-page-componentsB/progress/progress`.

Render source blocks in order:

1. `默认配置`
2. `基础功能`
3. `不显示百分比`
4. `从右往左`
5. `自定义高度`
6. `自定义颜色`
7. `自定义样式(不支持安卓环境的nvue)`
8. `手动加减`

All examples use real `UPLineProgress`. Initial percentages match the source:
`30`, `40`, `50`, `60`, `70`, and manual `50`. The source updates the basic
percentage to `120` after 2500 ms; the Flutter page performs the same delayed
state update and relies on `UPLineProgress` to clamp display width and text to
100%.

The custom-style slot uses a Flutter child widget styled like the source
`u-percentage-slot`. The Android nvue exclusion does not apply because this
example targets Flutter Android/iOS, not uni-app nvue.

Manual buttons use circular green controls labeled `减少` and `增加`, changing
the manual value by 10 and clamping it to `0..100`. The visible
`手动值：N` status makes the interaction deterministic in tests.

## Data Flow And State

- Code stores only each displayed tip string and disabled button state.
- NoticeBar stores close count and the last clicked notice index.
- Progress stores the source percentages and updates only the values shown by
  the demo rows.
- Link navigation uses the existing route catalog and does not introduce a new
  router.

Callbacks update only their own demo row. No page shares mutable state with
another route.

## Error And Lifecycle Handling

- No new dependencies, permissions, remote image loads, or network calls are
  introduced.
- Code controllers are disposed with their page by the widget lifecycle; no
  extra timer is owned by the page.
- The Progress delayed update checks `mounted` before calling `setState`.
- NoticeBar restores the previous global `UPNoticeBar.openPageHandler` when the
  page is disposed.
- Tests avoid `pumpAndSettle` around marquee notices because row notices contain
  intentionally repeating animations.

## Testing

Add focused widget tests before implementation:

- Code page test starts the first source countdown, sees `验证码已发送`, observes
  the `XS获取` countdown text, and verifies the button disables.
- NoticeBar page test closes the closable notice and verifies `关闭事件：1`.
- NoticeBar page test taps the link notice and verifies navigation to the
  completed Tag page.
- Progress page test taps `增加` and verifies `手动值：60`; it also verifies the
  custom slot `70%` is rendered.
- Route catalog test updates completed total from 46 to 49 and verifies
  Components B order through `code`, `noticeBar`, and `progress`.

At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_b/code_page.dart lib/pages/components_b/notice_bar_page.dart lib/pages/components_b/progress_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_code.dart lib/src/widgets/up_notice_bar.dart lib/src/widgets/up_line_progress.dart test/widgets_test.dart
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
