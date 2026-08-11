# Components C Batch 6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the source-order Components C `calendar`, `datetimePicker`, and `subsection` example pages with fixed offline data, route registration, focused tests, and no speculative package changes.

**Architecture:** Add one independent StatefulWidget page per source route under `example/lib/pages/components_c/`. Reuse the existing `ExamplePageScaffold`, `ExampleDemoBlock`, `UPCell`, `UPCalendar`, `UPCalendarStrip`, `UPDatetimePicker`, and `UPSubsection` APIs. Keep page state local and modify package widgets only after a focused page test proves a concrete compatibility gap.

**Tech Stack:** Flutter SDK, Dart, Material 3 page shell, local `ultra_ui` package, `flutter_test`, existing example route catalogs, and Android Gradle debug build.

## Global Constraints

- The batch contains exactly `componentsC/calendar/calendar`, `componentsC/datetimePicker/datetimePicker`, and `componentsC/subsection/subsection`.
- Preserve source Chinese titles, source section labels, representative defaults, principal interactions, and source-order route registration.
- Use fixed date and time fixtures. The fixed calendar baseline is `2026-08-11`; do not read the system clock for page values or test assertions.
- Keep all fixtures local and deterministic. Do not add network image, video, API, persistence, or dependency requirements.
- Use `ExamplePageScaffold` and `ExampleDemoBlock`; do not add a generic demo-page framework or shared calendar/picker controller abstraction.
- Reuse public package APIs. Modify `UPCalendar`, `UPDatetimePicker`, or `UPSubsection` only after a focused test demonstrates a behavior gap.
- Preserve the modified `README.md`, generated artifacts, helper scripts, and historical untracked files. Do not clean or revert unrelated worktree content.
- Work directly on the approved `main` workspace; do not create another worktree.
- Append the three routes after the existing Components C `picker` route in the exact order `calendar`, `datetimePicker`, `subsection`.
- Update existing preview rows only; do not reorder preview groups or add duplicate preview entries.
- The completed route count must change from `80` to `83`; Components C must contain `28` routes after this batch.
- The example analyzer must report no issues. Package analyzer may retain the existing warning/info baseline but must report zero batch-specific errors.
- Complete focused tests, route tests, package tests, example tests, analyzers, `git diff --check`, and the Android debug build before completion.

## File Map

Create:

- `example/lib/pages/components_c/calendar_page.dart`: fixed-date Calendar source variants, inline calendar, calendar strip, and result state.
- `example/lib/pages/components_c/datetime_picker_page.dart`: fixed-value DatetimePicker source variants, input/inline examples, and result state.
- `example/lib/pages/components_c/subsection_page.dart`: Subsection button/subsection, theme, per-item color, and disabled examples.

Modify:

- `example/test/components_c_pages_test.dart`: three page-level widget tests and imports for the new page classes.
- `example/lib/routes/example_catalog.dart`: three page imports, route records, and builders.
- `example/lib/routes/example_preview_catalog.dart`: set the existing Calendar, DatetimePicker, and Subsection preview rows to `available: true`.
- `example/test/route_catalog_test.dart`: source-order, count, completed-path, and preview-availability assertions.

Modify only for a confirmed package gap:

- The affected file under `packages/ultra_ui/lib/src/widgets/`.
- The related focused test area in `packages/ultra_ui/test/widgets_test.dart`.

---

### Task 1: Implement the Calendar Page

**Files:**
- Create: `example/lib/pages/components_c/calendar_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPCalendar`, `UPCalendarStrip`, `UPCell`, `ExamplePageScaffold`, and `ExampleDemoBlock`.
- Produces: `const CalendarPage()`, root key `example-page-componentsC/calendar/calendar`, open keys `calendar-page-open-0` through `calendar-page-open-11`, picker keys `calendar-page-widget-0` through `calendar-page-widget-11`, inline key `calendar-page-inline`, strip key `calendar-page-strip`, and strip-value key `calendar-page-strip-value`.
- Callback contract: `UPCalendar.onConfirm` receives `List<DateTime>` and `UPCalendar.onClose` is a `VoidCallback`.

- [ ] **Step 1: Add the failing Calendar page test**

Add the page import to `example/test/components_c_pages_test.dart`:

```dart
import '../lib/pages/components_c/calendar_page.dart';
```

Append this test:

```dart
testWidgets('calendar page opens variants and confirms fixed dates',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const CalendarPage(),
    ),
  );
  await tester.pump();

  for (final title in const [
    '单个日期',
    '多个日期',
    '日期范围',
    '自定义主题颜色',
    '自定义文案',
    '日期最大范围',
    '显示农历',
    '默认日期',
    '日期最小范围',
    '单月切换-单选',
    '单月切换-日期区间',
    '单月切换-多选',
  ]) {
    expect(find.text(title), findsOneWidget);
  }
  expect(find.text('页面行内模式'), findsOneWidget);
  expect(find.text('单行日历（支持切月、下拉展开完整月历）'), findsOneWidget);
  expect(find.byKey(const ValueKey('calendar-page-strip-value')),
      findsOneWidget);
  expect(find.text('2026-08-11'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('calendar-page-open-0')));
  await tester.pump(const Duration(milliseconds: 350));
  final single = tester.state<UPCalendarState>(
    find.byKey(const ValueKey('calendar-page-widget-0')),
  );
  single.selectDate(DateTime(2026, 8, 12));
  single.confirm();
  await tester.pump();
  expect(find.text('单个日期：2026-08-12'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('calendar-page-open-2')));
  await tester.pump(const Duration(milliseconds: 350));
  final range = tester.state<UPCalendarState>(
    find.byKey(const ValueKey('calendar-page-widget-2')),
  );
  range.setSelected([
    DateTime(2026, 8, 12),
    DateTime(2026, 8, 15),
  ]);
  range.confirm();
  await tester.pump();
  expect(find.text('日期范围：2026-08-12~2026-08-15'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run from `example`:

```text
flutter test test/components_c_pages_test.dart --plain-name "calendar page opens variants and confirms fixed dates" --reporter expanded
```

Expected: compilation fails because `CalendarPage` is not defined.

- [ ] **Step 3: Implement the fixed calendar state and source variants**

Create `CalendarPage` as a StatefulWidget:

```dart
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}
```

In `_CalendarPageState`:

- Keep `_activeIndex` as `int?`.
- Keep `_values` as a 12-item `List<String>` initialized to empty strings.
- Use `_open(index)` to set `_activeIndex`, and `_close(index)` to clear it
  only when the same index is active.
- Use `_confirm(index, dates)` to format single dates as one date, multiple
  dates as semicolon-separated dates, and range dates as `start~end`, then
  clear `_activeIndex`.
- Format dates with a private helper that returns
  `${year}-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}`.

Render `ExamplePageScaffold` with title `日历` and root key
`example-page-componentsC/calendar/calendar`. Put the twelve source rows in one
`UPCellGroup`. Each row is an `UPCell` with `isLink: true`,
the source title, the stored result as its label, and `onClick: () => _open(i)`.

Render one `UPCalendar` per source row. Its `show` is
`_activeIndex == i`, its key is `calendar-page-widget-i`, and its callbacks
are:

```dart
onConfirm: (dates) => _confirm(i, dates),
onClose: () => _close(i),
```

Use these fixed source configurations:

```dart
// 0 single
mode: 'single', defaultDate: '2026-08-11'
// 1 multiple
mode: 'multiple', defaultDate: ['2026-08-11', '2026-08-12', '2026-08-13']
// 2 range
mode: 'range', defaultDate: ['2026-08-11']
// 3 themed range
mode: 'range', color: '#f56c6c',
defaultDate: ['2026-08-11', '2026-08-15']
// 4 custom text
mode: 'range', startText: '住店', endText: '离店',
confirmDisabledText: '请选择离店日期', defaultDate: ['2026-08-11']
// 5 maximum date
maxDate: '2026-08-21', defaultDate: '2026-08-11'
// 6 lunar
showLunar: true, defaultDate: '2026-08-11'
// 7 default multiple
mode: 'multiple', defaultDate: ['2026-08-11', '2026-08-12', '2026-08-13']
// 8 minimum/maximum date
minDate: '2026-08-01', maxDate: '2026-08-21',
defaultDate: '2026-08-11'
// 9 month-switch single
defaultDate: '2026-08-15', monthNum: 36, monthSwitch: true,
minDate: '2026-01-01', maxDate: '2026-12-31'
// 10 month-switch range
mode: 'range', defaultDate: ['2026-06-15', '2026-06-20'],
monthNum: 36, monthSwitch: true
// 11 month-switch multiple
mode: 'multiple',
defaultDate: ['2026-06-15', '2026-07-15', '2026-08-15'],
monthNum: 36, monthSwitch: true
```

Also render:

```dart
UPCalendar(
  key: const ValueKey('calendar-page-inline'),
  show: true,
  pageInline: true,
  showTitle: false,
  showConfirm: false,
  defaultDate: '2026-08-11',
)
```

and:

```dart
UPCalendarStrip(
  key: const ValueKey('calendar-page-strip'),
  value: '2026-08-11',
  minDate: '2026-01-01',
  maxDate: '2026-12-31',
)
```

Render the strip value under key `calendar-page-strip-value`. Keep any source
remote icon URLs out of the page; use text/available local icon widgets for
the row leading content.

- [ ] **Step 4: Format and run the focused Calendar test**

Run:

```text
dart format lib/pages/components_c/calendar_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "calendar page opens variants and confirms fixed dates" --reporter expanded
```

Expected: PASS. If the test exposes a concrete package behavior gap, stop
before changing the package and record the smallest focused package regression
needed for Task 5.

- [ ] **Step 5: Commit the Calendar page**

```text
git add -- lib/pages/components_c/calendar_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add calendar page"
```

The commit must contain only the Calendar page and its focused example test
changes.

---

### Task 2: Implement the DatetimePicker Page

**Files:**
- Create: `example/lib/pages/components_c/datetime_picker_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPDatetimePicker`, `UPInput` through `hasInput`, `UPCell`, `ExamplePageScaffold`, and `ExampleDemoBlock`.
- Produces: `const DatetimePickerPage()`, root key `example-page-componentsC/datetimePicker/datetimePicker`, open keys `datetime-picker-page-open-0` through `datetime-picker-page-open-6`, picker keys `datetime-picker-page-widget-0` through `datetime-picker-page-widget-6`, input key `datetime-picker-page-input`, inline key `datetime-picker-page-inline`, and result key `datetime-picker-page-result`.
- Callback contract: `UPDatetimePicker.onConfirm` receives a map with `value` and `mode`; `UPDatetimePickerState.setValue(dynamic)` accepts fixed strings or epoch milliseconds; `confirm()` emits the current value.

- [ ] **Step 1: Add the failing DatetimePicker page test**

Add:

```dart
import '../lib/pages/components_c/datetime_picker_page.dart';
```

Append:

```dart
testWidgets('datetime picker page confirms fixed values and keeps variants',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const DatetimePickerPage(),
    ),
  );
  await tester.pump();

  for (final title in const [
    '完整日期时间',
    '年月日',
    '年月',
    '时间',
    '过滤器(保留偶数年)',
    '格式化',
    '限制最大最小值',
  ]) {
    expect(find.text(title), findsOneWidget);
  }
  expect(find.byKey(const ValueKey('datetime-picker-page-input')),
      findsOneWidget);
  expect(find.byKey(const ValueKey('datetime-picker-page-inline')),
      findsOneWidget);

  final formatted = tester.widget<UPDatetimePicker>(
    find.byKey(const ValueKey('datetime-picker-page-widget-5')),
  );
  expect(formatted.formatter, isA<Function>());
  final filtered = tester.widget<UPDatetimePicker>(
    find.byKey(const ValueKey('datetime-picker-page-widget-4')),
  );
  expect(filtered.filter, isA<Function>());

  await tester.tap(find.byKey(const ValueKey('datetime-picker-page-open-0')));
  await tester.pump(const Duration(milliseconds: 350));
  final datetime = tester.state<UPDatetimePickerState>(
    find.byKey(const ValueKey('datetime-picker-page-widget-0')),
  );
  datetime.setValue(DateTime(2026, 8, 11, 14, 30).millisecondsSinceEpoch);
  datetime.confirm();
  await tester.pump();
  expect(find.text('结果：2026-08-11 14:30'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run from `example`:

```text
flutter test test/components_c_pages_test.dart --plain-name "datetime picker page confirms fixed values and keeps variants" --reporter expanded
```

Expected: compilation fails because `DatetimePickerPage` is not defined.

- [ ] **Step 3: Implement fixed datetime values and picker variants**

Create `DatetimePickerPage` as a StatefulWidget:

```dart
class DatetimePickerPage extends StatefulWidget {
  const DatetimePickerPage({super.key});

  @override
  State<DatetimePickerPage> createState() => _DatetimePickerPageState();
}
```

In `_DatetimePickerPageState`:

- Keep `_activeIndex` as `int?`.
- Keep one result string initialized to `结果：未选择`.
- Use fixed constants:

```dart
static final int _fixedDate =
    DateTime(2026, 8, 11).millisecondsSinceEpoch;
static final int _fixedDatetime =
    DateTime(2026, 8, 11, 14, 30).millisecondsSinceEpoch;
static const String _fixedTime = '05:28';
static const int _minDate = 1767225600000;
static const int _maxDate = 1798761540000;
```

- Use `_open(index)` and `_close(index)` to control only the seven popup
  pickers.
- Convert the confirm map's `value` to a `DateTime` for date modes and format
  it as `yyyy-MM-dd HH:mm`, `yyyy-MM-dd`, or `yyyy-MM` according to `mode`.
- Keep time mode as the returned `HH:mm` string.

Render `ExamplePageScaffold` with title
`datetimePicker 时间日期选择器` and root key
`example-page-componentsC/datetimePicker/datetimePicker`. Use source labels
with `UPCell` rows keyed `datetime-picker-page-open-0` through
`datetime-picker-page-open-6`.

Render seven `UPDatetimePicker` widgets with corresponding keys and
`show: _activeIndex == i`, `closeOnClickOverlay: true`, fixed `value` or
`modelValue`, `onConfirm`, `onCancel`, and `onClose` callbacks. Configure:

```dart
// 0
mode: 'datetime', value: _fixedDatetime
// 1
mode: 'date', value: _fixedDate
// 2
mode: 'year-month', value: _fixedDate
// 3
mode: 'time', value: _fixedTime
// 4
mode: 'date', value: _fixedDate,
filter: (type, options) => type == 'year'
    ? options.where((value) => int.parse('$value').isEven).toList()
    : options
// 5
mode: 'date', value: _fixedDate,
formatter: (type, value) {
  if (type == 'year') return '${value}年';
  if (type == 'month') return '${value}月';
  if (type == 'day') return '${value}日';
  return value;
}
// 6
mode: 'datetime', value: _fixedDatetime,
minDate: _minDate, maxDate: _maxDate
```

The first picker also supplies `toolbarRight: const Text('右侧')`.

Render the input variant with key `datetime-picker-page-input`:

```dart
UPDatetimePicker(
  key: const ValueKey('datetime-picker-page-input'),
  hasInput: true,
  value: _fixedDatetime,
  placeholder: '请选择日期',
  inputProps: const {'border': 'surround', 'suffixIcon': 'calendar'},
)
```

Render the inline variant with key `datetime-picker-page-inline`,
`pageInline: true`, `show: true`, `mode: 'datetime'`,
`showToolbar: false`, and `value: _fixedDatetime`. Render the last result in
key `datetime-picker-page-result`.

- [ ] **Step 4: Format and run the focused DatetimePicker test**

Run:

```text
dart format lib/pages/components_c/datetime_picker_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "datetime picker page confirms fixed values and keeps variants" --reporter expanded
```

Expected: PASS. If the test identifies a package behavior gap, retain the
failing evidence and defer the minimal package regression to Task 5.

- [ ] **Step 5: Commit the DatetimePicker page**

```text
git add -- lib/pages/components_c/datetime_picker_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add datetime picker page"
```

The commit must contain only the DatetimePicker page and its focused example
test changes.

---

### Task 3: Implement the Subsection Page

**Files:**
- Create: `example/lib/pages/components_c/subsection_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPSubsection`, `ExamplePageScaffold`, and `ExampleDemoBlock`.
- Produces: `const SubsectionPage()`, root key `example-page-componentsC/subsection/subsection`, enabled widget keys `subsection-page-basic`, `subsection-page-button`, `subsection-page-theme`, `subsection-page-default`, `subsection-page-custom-colors`, and disabled widget keys `subsection-page-disabled-button` and `subsection-page-disabled-subsection`.
- Callback contract: `UPSubsection.onChange` receives the selected integer; `UPSubsectionState.setCurrent(int, {bool emit = true})` changes enabled selections.

- [ ] **Step 1: Add the failing Subsection page test**

Add:

```dart
import '../lib/pages/components_c/subsection_page.dart';
```

Append:

```dart
testWidgets('subsection page changes enabled state and preserves disabled state',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const SubsectionPage(),
    ),
  );
  await tester.pump();

  for (final title in const [
    '基础使用',
    '按钮模式',
    '更换主题',
    '默认位置',
    '按钮模式通过list自定义颜色',
    '禁用',
  ]) {
    expect(find.text(title), findsOneWidget);
  }

  final basic = tester.state<UPSubsectionState>(
    find.byKey(const ValueKey('subsection-page-basic')),
  );
  basic.setCurrent(2);
  await tester.pump();
  expect(basic.currentIndex, 2);
  expect(find.text('基础索引：2'), findsOneWidget);
  expect(find.text('基础变化次数：1'), findsOneWidget);

  final disabledButton = tester.state<UPSubsectionState>(
    find.byKey(const ValueKey('subsection-page-disabled-button')),
  );
  expect(disabledButton.currentIndex, 0);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('subsection-page-disabled-button')),
      matching: find.text('启用'),
    ),
  );
  await tester.pump();
  expect(disabledButton.currentIndex, 0);

  final custom = tester.widget<UPSubsection>(
    find.byKey(const ValueKey('subsection-page-custom-colors')),
  );
  expect(custom.activeColorKeyName, 'textColor');
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run from `example`:

```text
flutter test test/components_c_pages_test.dart --plain-name "subsection page changes enabled state and preserves disabled state" --reporter expanded
```

Expected: compilation fails because `SubsectionPage` is not defined.

- [ ] **Step 3: Implement the Subsection page**

Create `SubsectionPage` as a StatefulWidget:

```dart
class SubsectionPage extends StatefulWidget {
  const SubsectionPage({super.key});

  @override
  State<SubsectionPage> createState() => _SubsectionPageState();
}
```

In `_SubsectionPageState`:

- Use `const ['未付款', '待评价', '已付款']` for the shared list.
- Use fixed maps:

```dart
const customItems = [
  {'name': '禁用', 'textColor': '#FF4D4D'},
  {'name': '启用', 'textColor': '#00CC88'},
  {'name': '未激活文字', 'inactiveColorKey': 'pink'},
];
```

- Keep separate current indexes for the five enabled examples, initializing
  the default-position example to `1`.
- Keep separate change counts and update them from each `onChange`.

Render `ExamplePageScaffold(title: '分段器')` with root key
`example-page-componentsC/subsection/subsection`. Add one
`ExampleDemoBlock` for each source title:

```dart
UPSubsection(
  key: const ValueKey('subsection-page-basic'),
  list: _items,
  mode: 'subsection',
  current: _basicIndex,
  onChange: (index) => _setBasic(index),
)
```

Configure the other enabled widgets as follows:

- `subsection-page-button`: `mode: 'button'`, `current: _buttonIndex`.
- `subsection-page-theme`: `mode: 'subsection'`, `activeColor: '#f56c6c'`.
- `subsection-page-default`: `mode: 'button'`, `current: 1`,
  `activeColor: '#f9ae3d'`.
- `subsection-page-custom-colors`: `list: _customItems`,
  `mode: 'button'`, `activeColorKeyName: 'textColor'`.

In the `禁用` block render both:

- `subsection-page-disabled-button`: custom color list, `mode: 'button'`,
  `disabled: true`, `activeColorKeyName: 'textColor'`.
- `subsection-page-disabled-subsection`: shared list,
  `mode: 'subsection'`, `disabled: true`.

Render stable labels `基础索引：N`, `基础变化次数：N`, and equivalent
current-index labels for the other enabled examples. Do not add custom tap
handlers around the disabled widgets; the package's disabled behavior must
own the interaction.

- [ ] **Step 4: Format and run the focused Subsection test**

Run:

```text
dart format lib/pages/components_c/subsection_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "subsection page changes enabled state and preserves disabled state" --reporter expanded
```

Expected: PASS. Defer any confirmed package gap to Task 5.

- [ ] **Step 5: Commit the Subsection page**

```text
git add -- lib/pages/components_c/subsection_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add subsection page"
```

The commit must contain only the Subsection page and its focused example test
changes.

---

### Task 4: Register Routes, Enable Previews, and Update Catalog Tests

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Consumes: `CalendarPage`, `DatetimePickerPage`, and `SubsectionPage`.
- Produces: route IDs and source paths in source order, builders
  `_buildCalendar`, `_buildDatetimePicker`, and `_buildSubsection`, and
  available preview entries for all three source paths.

- [ ] **Step 1: Add the failing route assertions**

In `example/test/route_catalog_test.dart`:

- Change `expect(exampleRoutes, hasLength(80));` to
  `expect(exampleRoutes, hasLength(83));`.
- Append the three IDs to the Components C expected list after
  `componentsC/picker/picker`:

```dart
'componentsC/calendar/calendar',
'componentsC/datetimePicker/datetimePicker',
'componentsC/subsection/subsection',
```

- Add these source paths to the completed path set:

```dart
'pages/componentsC/calendar/calendar',
'pages/componentsC/datetimePicker/datetimePicker',
'pages/componentsC/subsection/subsection',
```

- Extend the focused preview availability set with the same three paths.

Run:

```text
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
```

Expected: FAIL because the route records are not registered yet.

- [ ] **Step 2: Add the three page imports and route records**

Add imports beside the other Components C page imports:

```dart
import '../pages/components_c/calendar_page.dart';
import '../pages/components_c/datetime_picker_page.dart';
import '../pages/components_c/subsection_page.dart';
```

Insert these records immediately after the existing `picker` record:

```dart
const ExampleRoute(
  id: 'componentsC/calendar/calendar',
  sourcePath: 'pages/componentsC/calendar/calendar',
  title: '日历',
  group: ExampleRouteGroup.componentsC,
  builder: _buildCalendar,
),
const ExampleRoute(
  id: 'componentsC/datetimePicker/datetimePicker',
  sourcePath: 'pages/componentsC/datetimePicker/datetimePicker',
  title: '时间选择',
  group: ExampleRouteGroup.componentsC,
  builder: _buildDatetimePicker,
),
const ExampleRoute(
  id: 'componentsC/subsection/subsection',
  sourcePath: 'pages/componentsC/subsection/subsection',
  title: '分段器',
  group: ExampleRouteGroup.componentsC,
  builder: _buildSubsection,
),
```

Add builders beside the existing Components C builders:

```dart
Widget _buildCalendar(BuildContext context) => const CalendarPage();
Widget _buildDatetimePicker(BuildContext context) =>
    const DatetimePickerPage();
Widget _buildSubsection(BuildContext context) => const SubsectionPage();
```

- [ ] **Step 3: Enable the existing preview rows**

In `example/lib/routes/example_preview_catalog.dart`, change only these
records from `available: false` to `available: true`:

```text
pages/componentsC/calendar/calendar
pages/componentsC/datetimePicker/datetimePicker
pages/componentsC/subsection/subsection
```

Do not add preview records or reorder `componentPreviewGroups`.

- [ ] **Step 4: Format and run route regressions**

Run:

```text
dart format lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
flutter test test/route_catalog_test.dart --plain-name "route ids resolve to their registered catalog entries" --reporter expanded
```

Expected: both route tests pass, including the `83` route count and
availability invariant.

- [ ] **Step 5: Commit route registration**

```text
git add -- lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
git commit -m "test(example): register components c batch 6 routes"
```

The commit must contain only catalog and route-test changes.

---

### Task 5: Handle Confirmed Package Gaps and Run Full Validation

**Files:**
- Modify only the specific affected file under
  `packages/ultra_ui/lib/src/widgets/` if a focused page test proves a gap.
- Modify only the corresponding focused area in
  `packages/ultra_ui/test/widgets_test.dart` if a package regression is needed.
- No package implementation change is expected by default.

**Interfaces:**
- The three pages use existing public package constructors and state methods.
- Any package fix must preserve public constructor names, callback names, and
  unrelated widget behavior.

- [ ] **Step 1: Run all focused Components C tests**

From `example`:

```text
flutter test test/components_c_pages_test.dart --reporter expanded
```

Expected: all existing Components C tests and the three new tests pass. If a
failure points into a package widget, reproduce the smallest behavior in a
package test before editing package code.

- [ ] **Step 2: Add a failing package regression only for a confirmed gap**

Place the regression beside the related existing tests in
`packages/ultra_ui/test/widgets_test.dart`. Use the smallest state-level test
matching the page failure. For example, a confirmed Calendar selection issue
must be reduced to:

```dart
testWidgets('UPCalendar fixed date selection confirms source value',
    (tester) async {
  final key = GlobalKey<UPCalendarState>();
  List<DateTime>? confirmed;
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: UPCalendar(
        key: key,
        show: true,
        pageInline: true,
        defaultDate: '2026-08-11',
        onConfirm: (dates) => confirmed = dates,
      ),
    ),
  );
  await tester.pump();
  key.currentState!.selectDate(DateTime(2026, 8, 12));
  key.currentState!.confirm();
  expect(confirmed, <DateTime>[DateTime(2026, 8, 12)]);
});
```

Use an equivalent focused test for a DatetimePicker or Subsection gap only
when that exact gap is observed. Run the new test and verify it fails before
touching the implementation.

- [ ] **Step 3: Implement only the confirmed package fix**

Change the smallest package implementation surface that explains the failing
regression. Keep the existing Flutter API and source callback aliases intact.
Run the new focused package test first:

```text
cd packages/ultra_ui
flutter test test/widgets_test.dart --plain-name "UPCalendar fixed date selection confirms source value" --reporter expanded
```

Replace the `--plain-name` text with the exact regression name if the
confirmed gap is in another widget. Expected: PASS.

- [ ] **Step 4: Run package tests and analysis**

From the repository root:

```text
flutter test packages/ultra_ui
flutter analyze packages/ultra_ui
```

Expected: all package tests pass. Existing analyzer warnings/infos may remain,
but no new package error may be introduced by this batch.

- [ ] **Step 5: Run example formatting, tests, and analysis**

Run:

```text
dart format example/lib/pages/components_c/calendar_page.dart example/lib/pages/components_c/datetime_picker_page.dart example/lib/pages/components_c/subsection_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_c_pages_test.dart example/test/route_catalog_test.dart
flutter test example
flutter analyze example
```

Expected: all example tests pass and the example analyzer reports
`No issues found!`.

- [ ] **Step 6: Build the Android debug artifact**

From `example`:

```text
flutter build apk --debug --target-platform android-arm64
```

Expected: `example/build/app/outputs/flutter-apk/app-debug.apk` exists. Do
not add the build output to Git; an iOS build is not required on Windows.

- [ ] **Step 7: Review the final diff and working tree**

From the repository root:

```text
git diff --check
git status --short
git log -8 --oneline
git diff --name-only -- packages/ultra_ui/lib/src/widgets packages/ultra_ui/test/widgets_test.dart example/lib/pages/components_c example/lib/routes example/test/components_c_pages_test.dart example/test/route_catalog_test.dart
```

Confirm that only the planned Batch 6 files are in the new commits. Leave
`README.md`, generated artifacts, helper scripts, and historical untracked
files untouched. Do not stage build outputs.

- [ ] **Step 8: Commit a confirmed validation fix only when required**

If no package gap was found, make no validation-fix commit. If a package gap
was confirmed and fixed, inspect the exact package implementation path named
by the failing test and stage that path together with the focused test file.
Because the repository intentionally contains historical untracked package
files, do not use a wildcard or stage all three possible widget paths. The
staging command must name only the confirmed implementation file and the
focused test file, followed by:

```text
git commit -m "fix: preserve components c widget behavior"
```

Do not use this commit for unrelated formatting or cleanup.
