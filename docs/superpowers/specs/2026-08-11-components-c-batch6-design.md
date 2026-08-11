# Components C Batch 6 Design

**Date:** 2026-08-11

## Goal

Add the next three source-order Components C example pages to the Flutter
gallery:

1. `componentsC/calendar/calendar`
2. `componentsC/datetimePicker/datetimePicker`
3. `componentsC/subsection/subsection`

The pages must preserve the source titles, representative variants, principal
interactions, route order, and existing public `UP*` APIs while remaining
offline and deterministic.

## Confirmed Decisions

- The batch contains all three pages as one implementation unit.
- Page-first implementation is preferred. Existing package widgets are reused
  and changed only when a focused test demonstrates a concrete behavior gap.
- All date and time fixtures are fixed. The pages do not depend on the system
  clock for displayed values or assertions.
- The fixed calendar baseline is `2026-08-11`; related date ranges use explicit
  values such as `2026-08-15` and `2026-12-31`.
- No network image, video, API, persistence, or new dependency is required.
- Existing `ExamplePageScaffold` and `ExampleDemoBlock` patterns remain the
  page structure.
- Work continues on the approved `main` workspace. The modified `README.md`,
  generated artifacts, helper scripts, and historical untracked files remain
  untouched.

## Architecture

Each page is an independent StatefulWidget under
`example/lib/pages/components_c/`. Page state owns only the values needed to
control its demos and render status text. The page does not introduce a shared
calendar or picker controller abstraction.

The route catalog remains the source-order registry. The three new route
records are appended after the existing Components C `picker` record:

```text
componentsC/calendar/calendar
componentsC/datetimePicker/datetimePicker
componentsC/subsection/subsection
```

The existing preview rows for the three source paths are marked available.
Their order and grouping are unchanged.

## Calendar Page

### Source Coverage

The page title is `日历`. It renders the source entries in this order:

1. `单个日期`
2. `多个日期`
3. `日期范围`
4. `自定义主题颜色`
5. `自定义文案`
6. `日期最大范围`
7. `显示农历`
8. `默认日期`
9. `日期最小范围`
10. `单月切换-单选`
11. `单月切换-日期区间`
12. `单月切换-多选`

Each entry has a stable key:
`calendar-page-open-0` through `calendar-page-open-11`. Each entry controls
one `UPCalendar` instance with a matching
`calendar-page-widget-0` through `calendar-page-widget-11` key. A page-level
active index ensures that only the selected calendar is open.

The configurations are:

- Entry 0: `mode: 'single'`, `defaultDate: '2026-08-11'`.
- Entry 1: `mode: 'multiple'`, default dates
  `['2026-08-11', '2026-08-12', '2026-08-13']`.
- Entry 2: `mode: 'range'`, default date `['2026-08-11']`.
- Entry 3: `mode: 'range'`, `color: '#f56c6c'`,
  default range `['2026-08-11', '2026-08-15']`.
- Entry 4: `mode: 'range'`, `startText: '住店'`, `endText: '离店'`,
  `confirmDisabledText: '请选择离店日期'`, default date
  `['2026-08-11']`.
- Entry 5: `maxDate: '2026-08-21'`, `defaultDate: '2026-08-11'`.
- Entry 6: `showLunar: true`, `defaultDate: '2026-08-11'`.
- Entry 7: `mode: 'multiple'`, default dates
  `['2026-08-11', '2026-08-12', '2026-08-13']`.
- Entry 8: `minDate: '2026-08-01'`, `maxDate: '2026-08-21'`,
  `defaultDate: '2026-08-11'`.
- Entry 9: `defaultDate: '2026-08-15'`, `monthNum: 36`, `monthSwitch: true`,
  `minDate: '2026-01-01'`, `maxDate: '2026-12-31'`.
- Entry 10: `mode: 'range'`, default range
  `['2026-06-15', '2026-06-20']`, `monthNum: 36`, `monthSwitch: true`.
- Entry 11: `mode: 'multiple'`, default dates
  `['2026-06-15', '2026-07-15', '2026-08-15']`, `monthNum: 36`,
  `monthSwitch: true`.

The page also preserves the source inline demonstrations:

- `UPCalendar` with key `calendar-page-inline`, `pageInline: true`,
  `showTitle: false`, `showConfirm: false`, and `defaultDate: '2026-08-11'`.
- `UPCalendarStrip` with key `calendar-page-strip`, fixed value
  `2026-08-11`, `minDate: '2026-01-01'`, and `maxDate: '2026-12-31'`.
- The strip value is rendered under key `calendar-page-strip-value`.

### State and Events

The page stores one formatted result string per entry and a single active
calendar index. `onConfirm` formats single values as one date, multiple values
as semicolon-separated dates, and ranges as `start~end`. `onClose` only clears
the active visibility state. Confirming a calendar closes it after recording
the result.

## DatetimePicker Page

### Source Coverage

The page title is `datetimePicker 时间日期选择器`. It renders seven keyed
source entries:

1. `完整日期时间`
2. `年月日`
3. `年月`
4. `时间`
5. `过滤器(保留偶数年)`
6. `格式化`
7. `限制最大最小值`

Open triggers use keys `datetime-picker-page-open-0` through
`datetime-picker-page-open-6`; the corresponding picker widgets use
`datetime-picker-page-widget-0` through `datetime-picker-page-widget-6`.

The fixed initial values are:

- Date modes: `2026-08-11`.
- Datetime mode: `2026-08-11 14:30`.
- Time mode: `05:28`.

The picker configurations are:

- Entry 0: `mode: 'datetime'`.
- Entry 1: `mode: 'date'`.
- Entry 2: `mode: 'year-month'`.
- Entry 3: `mode: 'time'`, value `05:28`.
- Entry 4: `mode: 'date'`, filter that retains even years only.
- Entry 5: `mode: 'date'`, formatter that appends `年`, `月`, and `日` to
  the corresponding visible columns.
- Entry 6: `mode: 'datetime'`, `minDate: 1767225600000`,
  `maxDate: 1798761540000` (the fixed UTC millisecond bounds for
  `2026-01-01 00:00` through `2026-12-31 23:59`).

The page also contains:

- A `hasInput` picker with key `datetime-picker-page-input`, placeholder
  `请选择日期`, and a calendar input suffix.
- A `pageInline` picker with key `datetime-picker-page-inline`,
  `mode: 'datetime'`, and `showToolbar: false`.
- A result label keyed `datetime-picker-page-result`.

### State and Events

The page stores one active picker index and the last confirmed result. The
`onConfirm` payload is interpreted by its `mode` and formatted into a stable
Chinese status line. `onCancel` and `onClose` clear visibility without
changing the last confirmed result. The filter and formatter remain functions
passed to the widget, so tests can inspect the configured public API directly.

## Subsection Page

### Source Coverage

The page title is `分段器` and contains these source sections:

1. `基础使用`
2. `按钮模式`
3. `更换主题`
4. `默认位置`
5. `按钮模式通过list自定义颜色`
6. `禁用`

The shared base list is:

```text
未付款, 待评价, 已付款
```

The custom-color list is:

```text
禁用 (#FF4D4D), 启用 (#00CC88), 未激活文字 (inactiveColor: pink)
```

Stable widget keys are:

- `subsection-page-basic`
- `subsection-page-button`
- `subsection-page-theme`
- `subsection-page-default`
- `subsection-page-custom-colors`
- `subsection-page-disabled-button`
- `subsection-page-disabled-subsection`

The page renders current-index labels and a change count for enabled examples.
The custom-color examples use `activeColorKeyName: 'textColor'`. Disabled
examples use `disabled: true` and retain their initial indexes when tapped.

## Testing Design

### Page Tests

Add these tests to `example/test/components_c_pages_test.dart`:

#### Calendar

`calendar page opens variants and confirms fixed dates`

- Build `componentsC/calendar/calendar`.
- Assert the twelve source titles, `页面行内模式`, and `单行日历`.
- Tap `calendar-page-open-0`, obtain its `UPCalendarState`, select
  `DateTime(2026, 8, 12)`, and call `confirm()`.
- Assert that the first result is `2026-08-12` and the calendar is closed.
- Open the range or multiple example, confirm fixed dates through its public
  state API, and assert the page's formatted result.
- Assert the strip value is `2026-08-11`.

#### DatetimePicker

`datetime picker page confirms fixed values and keeps variants`

- Build `componentsC/datetimePicker/datetimePicker`.
- Assert all seven source titles, the input trigger, and the inline picker.
- Inspect the keyed widgets for `mode`, filter, formatter, and fixed boundary
  props.
- Open the datetime entry, set the fixed value through
  `UPDatetimePickerState`, confirm it, and assert the result label.
- Assert the input and inline variants remain in the widget tree.

#### Subsection

`subsection page changes enabled state and preserves disabled state`

- Build `componentsC/subsection/subsection`.
- Assert all six source section titles.
- Obtain `UPSubsectionState` from `subsection-page-basic`, call
  `setCurrent(2)`, and assert the index and change count.
- Tap the disabled button and disabled subsection examples and assert their
  indexes remain unchanged.
- Inspect the custom-color widget's `activeColorKeyName`.

### Route and Preview Tests

Update `example/test/route_catalog_test.dart`:

- Components C expected route order ends with `picker`, `calendar`,
  `datetimePicker`, `subsection`.
- Completed route count is `83`.
- Completed source paths include:
  `pages/componentsC/calendar/calendar`,
  `pages/componentsC/datetimePicker/datetimePicker`, and
  `pages/componentsC/subsection/subsection`.
- The existing preview rows for those paths are available.
- Preview order, group lengths, uniqueness, and availability invariants remain
  unchanged.

### Full Verification

Run the focused page tests and route tests first. Then run:

```text
dart format example/lib/pages/components_c/calendar_page.dart example/lib/pages/components_c/datetime_picker_page.dart example/lib/pages/components_c/subsection_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_c_pages_test.dart example/test/route_catalog_test.dart
flutter test packages/ultra_ui
flutter analyze packages/ultra_ui
flutter test example
flutter analyze example
git diff --check
flutter build apk --debug --target-platform android-arm64
```

The package analyzer may retain the existing warning/info baseline but must
report no batch-specific errors. No package implementation change is
expected unless a focused page test proves a gap; any such change must have a
focused package regression test and a separate minimal commit.

## Acceptance Criteria

- All three routes render dedicated, non-placeholder pages.
- Page tests pass with fixed values and no network fixtures.
- Route and preview catalogs preserve source order and invariants.
- Existing package and example tests remain green.
- Example analyzer reports no issues.
- Android debug APK is generated.
- No unrelated user or historical files are staged or reverted.
