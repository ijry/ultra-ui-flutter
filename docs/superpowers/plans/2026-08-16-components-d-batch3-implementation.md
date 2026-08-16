# Components D Batch 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add five source-order Components D gallery pages: CityLocate, Title,
PullRefresh, VirtualList, and Barcode.

**Architecture:** Create one focused page per source route under
`example/lib/pages/components_d/`, keeping all controlled state local to the
page. Reuse `ExamplePageScaffold`, `ExampleDemoBlock`, and the public
`ultra_ui` widgets; then register the five existing source-manifest records
in the example and enable their existing preview records.

**Tech Stack:** Flutter SDK, Dart, Material 3, local `ultra_ui` package,
`flutter_test`, existing route/preview catalogs, and deterministic local data.

## Global Constraints

- Scope is exactly `componentsD/cityLocate/cityLocate`,
  `componentsD/title/title`, `componentsD/pullRefresh/pullRefresh`,
  `componentsD/virtualList/virtualList`, and
  `componentsD/barcode/barcode`, in this source order.
- Preserve source titles, representative defaults, source-visible labels, and
  principal interactions. The route count changes from `93` to `98`.
- Keep all demonstrations offline and deterministic. Do not request real GPS,
  add a dependency, make a network request, or use the source remote GIF.
- Reuse public `UPCityLocate`, `UPTitle`, `UPPullRefresh`,
  `UPVirtualList`, `UPBarcode`, `UPCell`, `UPIcon`, and
  `UPLoadingIcon` APIs.
- Do not modify `packages/ultra_ui` unless a focused page test demonstrates
  a concrete package defect. Any such change requires a focused package test
  and a separate commit; this plan expects no package change.
- Retain `UPBarcode`'s current deterministic visual fallback for EAN5 and
  EAN2. Do not add their standard encoders in this batch.
- Do not modify `README.md`, `example_source_manifest.dart`, historical
  untracked files, generated artifacts, or unrelated package files.
- Do not stage build output. Stage each listed task's exact files only.

---

## File Map

Create:

- `example/lib/pages/components_d/city_locate_page.dart`: deterministic city
  location and city-selection example.
- `example/lib/pages/components_d/title_page.dart`: default and custom-prefix
  title examples.
- `example/lib/pages/components_d/pull_refresh_page.dart`: bounded refresh,
  custom indicator, nested virtual-list, and load-more examples.
- `example/lib/pages/components_d/virtual_list_page.dart`: 10,000-item
  fixed-height virtual-list example.
- `example/lib/pages/components_d/barcode_page.dart`: eight source barcode
  variants.

Modify:

- `example/test/components_d_pages_test.dart`: one focused direct-mount test
  per new page.
- `example/lib/routes/example_catalog.dart`: imports, five source-order
  route records, and five builders.
- `example/lib/routes/example_preview_catalog.dart`: only five
  `available: false` to `available: true` changes.
- `example/test/route_catalog_test.dart`: route total/order, completed paths,
  preview availability, and smoke coverage.

Do not modify:

- `example/lib/routes/example_source_manifest.dart`: it already contains all
  five source records.
- `packages/ultra_ui/**`: the required public widgets and their package tests
  already exist.

### Task 1: Add CityLocate Page and Focused Test

**Files:**

- Create: `example/lib/pages/components_d/city_locate_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const CityLocatePage()`.
- Root key: `example-page-componentsD/cityLocate/cityLocate`.
- Demo keys: `city-locate-page-basic` and
  `city-locate-page-selection`.
- Uses `UPCityLocate.locationHandler` with
  `Future<Map?> Function(String)`, `onLocationSuccess`, and
  `onSelectCity`.

- [ ] **Step 1: Add the failing direct-mount test and page import**

Add the import:

```dart
import '../lib/pages/components_d/city_locate_page.dart';
```

Append this test:

```dart
testWidgets('city locate page resolves local location and selects a city',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const CityLocatePage(),
    ),
  );
  await tester.pump();
  await tester.pump();

  expect(
    find.byKey(
      const ValueKey('example-page-componentsD/cityLocate/cityLocate'),
    ),
    findsOneWidget,
  );
  expect(find.byKey(const ValueKey('city-locate-page-basic')), findsOneWidget);
  expect(find.text('当前定位：南京'), findsOneWidget);

  final shanghai = find.descendant(
    of: find.byKey(const ValueKey('city-locate-page-basic')),
    matching: find.text('上海'),
  );
  expect(shanghai, findsWidgets);
  await tester.tap(shanghai.first);
  await tester.pump();

  expect(find.text('已选择：上海'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run from the repository root:

```text
flutter test example/test/components_d_pages_test.dart --plain-name "city locate page resolves local location and selects a city" --reporter expanded
```

Expected: FAIL at compilation because `CityLocatePage` and its import target
do not exist.

- [ ] **Step 3: Implement `CityLocatePage` with a deterministic host callback**

Create `city_locate_page.dart` using the established Components D imports
and this page-local data/state contract:

```dart
const List<List<Map<String, String>>> _cityGroups =
    <List<Map<String, String>>>[
  <Map<String, String>>[
    <String, String>{'name': '北京', 'value': 'beijing'},
    <String, String>{'name': '上海', 'value': 'shanghai'},
    <String, String>{'name': '广州', 'value': 'guangzhou'},
  ],
  <Map<String, String>>[
    <String, String>{'name': '北京', 'value': 'beijing'},
    <String, String>{'name': '上海', 'value': 'shanghai'},
    <String, String>{'name': '广州', 'value': 'guangzhou'},
    <String, String>{'name': '深圳', 'value': 'shenzhen'},
    <String, String>{'name': '杭州', 'value': 'hangzhou'},
  ],
];

class CityLocatePage extends StatefulWidget {
  const CityLocatePage({super.key});

  @override
  State<CityLocatePage> createState() => _CityLocatePageState();
}

class _CityLocatePageState extends State<CityLocatePage> {
  String _currentCity = '';
  String _selectedCity = '未选择';

  Future<Map?> _resolveLocation(String locationType) async {
    return <String, dynamic>{
      'locationType': locationType,
      'locationCity': '南京',
    };
  }
}
```

In `build`, use `ExamplePageScaffold(title: '城市定位')` and a root
`Container` with the required route key. Render one `ExampleDemoBlock`
named `基础用法`; its child is a `SizedBox(height: 420)` containing:

```dart
UPCityLocate(
  key: const ValueKey('city-locate-page-basic'),
  indexList: const <String>['🔥', '所有城市'],
  cityList: _cityGroups,
  currentCity: _currentCity,
  locationHandler: _resolveLocation,
  onLocationSuccess: (result) {
    final city = '${result['locationCity'] ?? '南京'}';
    if (mounted) setState(() => _currentCity = city);
  },
  onSelectCity: (result) {
    final city = '${result['locationCity'] ?? ''}';
    if (mounted) setState(() => _selectedCity = city);
  },
)
```

Below the demo, add a `Column` keyed
`city-locate-page-selection` with the exact labels
`当前定位：$_currentCity` and `已选择：$_selectedCity`.
Do not call device location APIs; the public host callback is the source-aware
Flutter replacement.

- [ ] **Step 4: Format and run the focused test**

```text
dart format example/lib/pages/components_d/city_locate_page.dart example/test/components_d_pages_test.dart
flutter test example/test/components_d_pages_test.dart --plain-name "city locate page resolves local location and selects a city" --reporter expanded
```

Expected: PASS. The callback reports `南京` after the post-frame location
request, and tapping a rendered `上海` entry updates the visible result.

- [ ] **Step 5: Commit the CityLocate page**

```text
git add -- example/lib/pages/components_d/city_locate_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add city locate page"
```

### Task 2: Add Title Page and Focused Test

**Files:**

- Create: `example/lib/pages/components_d/title_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const TitlePage()`.
- Root key: `example-page-componentsD/title/title`.
- Demo keys: `title-page-default` and `title-page-prefix`.
- Uses two real `UPTitle` widgets and a public `UPIcon` prefix.

- [ ] **Step 1: Add the failing Title test and import**

Add:

```dart
import '../lib/pages/components_d/title_page.dart';
```

Append:

```dart
testWidgets('title page renders source default and custom prefix variants',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const TitlePage(),
    ),
  );

  expect(
    find.byKey(const ValueKey('example-page-componentsD/title/title')),
    findsOneWidget,
  );
  expect(find.text('默认'), findsOneWidget);
  expect(find.text('自定义前缀'), findsOneWidget);
  expect(find.byKey(const ValueKey('title-page-default')), findsOneWidget);
  expect(find.byKey(const ValueKey('title-page-prefix')), findsOneWidget);
  expect(find.text('默认标题'), findsOneWidget);
  expect(find.text('等级3'), findsOneWidget);
  expect(find.byType(UPTitle), findsNWidgets(2));
  expect(find.byType(UPIcon), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test example/test/components_d_pages_test.dart --plain-name "title page renders source default and custom prefix variants" --reporter expanded
```

Expected: FAIL at compilation because `TitlePage` is absent.

- [ ] **Step 3: Implement the two source title variants**

Create `title_page.dart` as a `StatelessWidget` using the standard page
helpers. Use a root `Container` with the required route key and exactly two
`ExampleDemoBlock`s:

```dart
ExampleDemoBlock(
  title: '默认',
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: UPTitle(
      key: ValueKey('title-page-default'),
      text: '默认标题',
    ),
  ),
),
ExampleDemoBlock(
  title: '自定义前缀',
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: UPTitle(
      key: ValueKey('title-page-prefix'),
      prefix: UPIcon(name: 'level', color: 'red', size: 16),
      text: '等级3',
    ),
  ),
),
```

Set the `ExamplePageScaffold` title to `标题`. Do not add local state or
tap behavior because neither source example has one.

- [ ] **Step 4: Format and run the focused test**

```text
dart format example/lib/pages/components_d/title_page.dart example/test/components_d_pages_test.dart
flutter test example/test/components_d_pages_test.dart --plain-name "title page renders source default and custom prefix variants" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the Title page**

```text
git add -- example/lib/pages/components_d/title_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add title page"
```

### Task 3: Add PullRefresh Page and Focused Gesture Test

**Files:**

- Create: `example/lib/pages/components_d/pull_refresh_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const PullRefreshPage()`.
- Root key: `example-page-componentsD/pullRefresh/pullRefresh`.
- Demo keys: `pull-refresh-page-basic`, `pull-refresh-page-custom`,
  `pull-refresh-page-virtual`, and `pull-refresh-page-loadmore`.
- Uses real `UPPullRefresh` callbacks and a nested `UPVirtualList`.

- [ ] **Step 1: Add the failing PullRefresh test and import**

Add:

```dart
import '../lib/pages/components_d/pull_refresh_page.dart';
```

Append:

```dart
testWidgets('pull refresh page responds to a real downward drag',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const PullRefreshPage(),
    ),
  );

  expect(
    find.byKey(const ValueKey('example-page-componentsD/pullRefresh/pullRefresh')),
    findsOneWidget,
  );
  expect(find.byKey(const ValueKey('pull-refresh-page-basic')), findsOneWidget);
  expect(find.byKey(const ValueKey('pull-refresh-page-custom')), findsOneWidget);
  expect(find.byKey(const ValueKey('pull-refresh-page-virtual')), findsOneWidget);
  expect(find.byKey(const ValueKey('pull-refresh-page-loadmore')), findsOneWidget);

  final basic = find.byKey(const ValueKey('pull-refresh-page-basic'));
  final gesture = await tester.startGesture(tester.getCenter(basic));
  await gesture.moveBy(const Offset(0, 160));
  await tester.pump();
  await gesture.up();
  await tester.pump();

  expect(find.text('基础刷新次数：1'), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 300));
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test example/test/components_d_pages_test.dart --plain-name "pull refresh page responds to a real downward drag" --reporter expanded
```

Expected: FAIL at compilation because `PullRefreshPage` is absent.

- [ ] **Step 3: Implement bounded, offline refresh demos**

Create `pull_refresh_page.dart` with a `StatefulWidget`. Define an
eight-item local list with integer `id` and `Item <id>` names. The state
owns `_basicRefreshing`, `_customRefreshing`, `_virtualRefreshing`, and
`_loadmoreRefreshing`, an integer `_basicRefreshCount`, an integer
`_loadmoreCount`, a mutable load-more item list, and
`_loadmoreStatus = 'loadmore'`.

Use these concrete state transitions:

```dart
void _refreshBasic() {
  setState(() {
    _basicRefreshing = true;
    _basicRefreshCount += 1;
  });
  Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
    if (mounted) setState(() => _basicRefreshing = false);
  });
}

void _refreshCustom() {
  setState(() => _customRefreshing = true);
  Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
    if (mounted) setState(() => _customRefreshing = false);
  });
}

void _refreshVirtual() {
  setState(() => _virtualRefreshing = true);
  Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
    if (mounted) setState(() => _virtualRefreshing = false);
  });
}

void _refreshLoadmore() {
  setState(() => _loadmoreRefreshing = true);
  Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
    if (mounted) setState(() => _loadmoreRefreshing = false);
  });
}

void _loadMore() {
  if (_loadmoreStatus != 'loadmore') return;
  setState(() => _loadmoreStatus = 'loading');
  Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
    if (!mounted) return;
    setState(() {
      final id = _loadmoreItems.length;
      _loadmoreItems.add(<String, dynamic>{'id': id, 'name': 'Item ' + id.toString()});
      _loadmoreCount += 1;
      _loadmoreStatus = 'loadmore';
    });
  });
}
```

Define the page-local row renderer once and use it as each non-virtual
refresh child's content:

```dart
Widget _buildRows(List<Map<String, dynamic>> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final item in items)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(item['name'].toString()),
        ),
    ],
  );
}
```

Render each `UPPullRefresh` inside an explicit `SizedBox(height: 180)`.
The basic demo must have the required key, `threshold: 50`,
`refreshing: _basicRefreshing`, `onRefresh: _refreshBasic`, and a
`child: _buildRows(_items)`. Render
`基础刷新次数：$_basicRefreshCount` below it.

The custom demo must provide all three public slots with local widgets:

```dart
UPPullRefresh(
  key: const ValueKey('pull-refresh-page-custom'),
  refreshing: _customRefreshing,
  onRefresh: _refreshCustom,
  pullSlot: const _RefreshStatus(
    icon: 'arrow-downward',
    text: '下拉刷新',
  ),
  releaseSlot: const _RefreshStatus(
    icon: 'arrow-upward',
    text: '释放刷新',
  ),
  refreshingSlot: const _RefreshStatus(
    icon: 'loading',
    text: '正在刷新...',
    loading: true,
  ),
  child: _buildRows(_items),
),
```

Implement `_RefreshStatus` in the same file. Its `loading: true` branch
uses `UPLoadingIcon(mode: 'circle', size: 18)`; its non-loading branch uses
`UPIcon`. Do not fetch the source GIF.

For `结合虚拟列表`, use:

```dart
UPPullRefresh(
  key: const ValueKey('pull-refresh-page-virtual'),
  useScrollView: false,
  refreshing: _virtualRefreshing,
  onRefresh: _refreshVirtual,
  child: UPVirtualList(
    listData: _items,
    itemHeight: 32,
    height: 180,
    itemBuilder: (context, item, index) =>
        Text('Item ' + item['id'].toString() + ': ' + item['name'].toString()),
  ),
)
```

For `上拉加载`, use a `UPPullRefresh` keyed
`pull-refresh-page-loadmore`, `showLoadmore: true`,
`refreshing: _loadmoreRefreshing`, `onRefresh: _refreshLoadmore`,
`onLoadmore: _loadMore`, `child: _buildRows(_loadmoreItems)`, and:

```dart
loadmoreProps: <String, dynamic>{
  'status': _loadmoreStatus,
  'loadmoreText': '上拉加载更多',
  'loadingText': '努力加载中...',
  'nomoreText': '我们是有底线的',
  'iconSize': 18,
},
```

Render `加载次数：$_loadmoreCount` below this viewport so the state field
is consumed and the callback result is visible.

Use `ExamplePageScaffold(title: '下拉刷新')`, a route-keyed root
`Container`, and `ExampleDemoBlock` titles exactly matching the four
source examples.

- [ ] **Step 4: Format and run the focused gesture test**

```text
dart format example/lib/pages/components_d/pull_refresh_page.dart example/test/components_d_pages_test.dart
flutter test example/test/components_d_pages_test.dart --plain-name "pull refresh page responds to a real downward drag" --reporter expanded
```

Expected: PASS. The test reaches the component's actual drag handler and
observes a refresh callback without calling `UPPullRefreshState.startRefresh`.

- [ ] **Step 5: Commit the PullRefresh page**

```text
git add -- example/lib/pages/components_d/pull_refresh_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add pull refresh page"
```

### Task 4: Add VirtualList Page and Focused Scroll Test

**Files:**

- Create: `example/lib/pages/components_d/virtual_list_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const VirtualListPage()`.
- Root key: `example-page-componentsD/virtualList/virtualList`.
- Demo and result keys: `virtual-list-page-basic` and
  `virtual-list-page-result`.
- Uses `UPVirtualList.listData`, `itemHeight`, `keyField`,
  `onUpdateScrollTop`, and `itemBuilder`.

- [ ] **Step 1: Add the failing VirtualList test and import**

Add:

```dart
import '../lib/pages/components_d/virtual_list_page.dart';
```

Append:

```dart
testWidgets('virtual list page scrolls real visible rows', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const VirtualListPage(),
    ),
  );
  await tester.pump();

  expect(
    find.byKey(const ValueKey('example-page-componentsD/virtualList/virtualList')),
    findsOneWidget,
  );
  final list = find.byKey(const ValueKey('virtual-list-page-basic'));
  expect(list, findsOneWidget);
  expect(find.text('Item 0'), findsOneWidget);

  await tester.drag(list, const Offset(0, -420));
  await tester.pump();

  expect(find.text('Item 8'), findsWidgets);
  expect(
    find.byKey(const ValueKey('virtual-list-page-result')),
    findsOneWidget,
  );
  expect(find.textContaining('滚动位置：'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test example/test/components_d_pages_test.dart --plain-name "virtual list page scrolls real visible rows" --reporter expanded
```

Expected: FAIL at compilation because `VirtualListPage` is absent.

- [ ] **Step 3: Implement the source-sized virtual list**

Create `virtual_list_page.dart` as a `StatefulWidget`. Generate exactly
10,000 page-local records during `initState`:

```dart
late final List<Map<String, dynamic>> _items;
double _scrollTop = 0;

@override
void initState() {
  super.initState();
  _items = List<Map<String, dynamic>>.generate(
    10000,
    (index) => <String, dynamic>{
      'id': index,
      'name': 'Item ' + index.toString(),
    },
  );
}
```

Use an `ExampleDemoBlock(title: '基本使用')` containing:

```dart
UPVirtualList(
  key: const ValueKey('virtual-list-page-basic'),
  listData: _items,
  itemHeight: 49,
  height: '800px',
  keyField: 'id',
  scrollTop: _scrollTop,
  onUpdateScrollTop: (value) => setState(() => _scrollTop = value),
  itemBuilder: (context, item, index) => UPCell(
    title: 'Item ' + item['id'].toString(),
  ),
)
```

Use `ExamplePageScaffold(title: '虚拟列表')` and a route-keyed root
`Container`. Render a keyed result line with
`滚动位置：${_scrollTop.toStringAsFixed(0)}` below the demo. Do not replace
`UPVirtualList` with a regular page-local `ListView`.

- [ ] **Step 4: Format and run the focused scroll test**

```text
dart format example/lib/pages/components_d/virtual_list_page.dart example/test/components_d_pages_test.dart
flutter test example/test/components_d_pages_test.dart --plain-name "virtual list page scrolls real visible rows" --reporter expanded
```

Expected: PASS. The drag changes the widget's scroll position and visible
virtual window without materializing all 10,000 child rows.

- [ ] **Step 5: Commit the VirtualList page**

```text
git add -- example/lib/pages/components_d/virtual_list_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add virtual list page"
```

### Task 5: Add Barcode Page and Focused Test

**Files:**

- Create: `example/lib/pages/components_d/barcode_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const BarcodePage()`.
- Root key: `example-page-componentsD/barcode/barcode`.
- Variant keys: `barcode-page-code128`, `barcode-page-ean13`,
  `barcode-page-ean8`, `barcode-page-upca`, `barcode-page-code39`,
  `barcode-page-ean5`, `barcode-page-ean2`, and
  `barcode-page-custom`.
- Uses eight real `UPBarcode` widgets; EAN5/EAN2 retain current visual
  fallback behavior.

- [ ] **Step 1: Add the failing Barcode test and import**

Add:

```dart
import '../lib/pages/components_d/barcode_page.dart';
```

Append:

```dart
testWidgets('barcode page renders every source barcode variant',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const BarcodePage(),
    ),
  );

  expect(
    find.byKey(const ValueKey('example-page-componentsD/barcode/barcode')),
    findsOneWidget,
  );
  expect(find.byType(UPBarcode), findsNWidgets(8));
  expect(find.byKey(const ValueKey('barcode-page-code128')), findsOneWidget);
  expect(find.byKey(const ValueKey('barcode-page-ean5')), findsOneWidget);
  expect(find.byKey(const ValueKey('barcode-page-ean2')), findsOneWidget);
  expect(find.byKey(const ValueKey('barcode-page-custom')), findsOneWidget);
  expect(find.text('自定义样式条形码'), findsOneWidget);
  expect(find.text('CUSTOM123'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test example/test/components_d_pages_test.dart --plain-name "barcode page renders every source barcode variant" --reporter expanded
```

Expected: FAIL at compilation because `BarcodePage` is absent.

- [ ] **Step 3: Implement all eight source barcode demos**

Create `barcode_page.dart` as a `StatelessWidget`. Use
`ExamplePageScaffold(title: '条码')`, a route-keyed root `Container`, and
one `ExampleDemoBlock` per source-visible title. Each block centers a real
`UPBarcode` with the following exact constructor data:

```dart
const UPBarcode(
  key: ValueKey('barcode-page-code128'),
  value: '1234567890',
  format: 'CODE128',
  height: 70,
  fontSize: 16,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-ean13'),
  value: '5901234123457',
  format: 'EAN13',
  height: 70,
  fontSize: 16,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-ean8'),
  value: '96385074',
  format: 'EAN8',
  height: 70,
  fontSize: 11,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-upca'),
  value: '123456789012',
  format: 'UPCA',
  height: 70,
  fontSize: 16,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-code39'),
  value: 'CODE39',
  format: 'CODE39',
  height: 70,
  fontSize: 16,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-ean5'),
  value: '12345',
  format: 'EAN5',
  width: 100,
  height: 60,
  fontSize: 14,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-ean2'),
  value: '12',
  format: 'EAN2',
  width: 100,
  height: 60,
  fontSize: 14,
)
```

```dart
const UPBarcode(
  key: ValueKey('barcode-page-custom'),
  value: 'CUSTOM123',
  format: 'CODE128',
  width: 200,
  height: 70,
  fontSize: 14,
  lineColor: '#FF0000',
  background: '#F0F0F0',
  textPosition: 'top',
)
```

Use exact titles `CODE128 条形码`, `EAN-13 条形码`,
`EAN-8 条形码`, `UPC-A 条形码`, `CODE39 条形码`,
`EAN-5 补充码`, `EAN-2 补充码`, and `自定义样式条形码`.

- [ ] **Step 4: Format and run the focused test**

```text
dart format example/lib/pages/components_d/barcode_page.dart example/test/components_d_pages_test.dart
flutter test example/test/components_d_pages_test.dart --plain-name "barcode page renders every source barcode variant" --reporter expanded
```

Expected: PASS. No package encoder change is made for EAN5/EAN2.

- [ ] **Step 5: Commit the Barcode page**

```text
git add -- example/lib/pages/components_d/barcode_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add barcode page"
```

### Task 6: Register Routes, Enable Previews, and Extend Route Tests

**Files:**

- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**

- Consumes the five `const <Page>Page()` classes created in Tasks 1-5.
- Produces five `ExampleRoute` records and five real builders.
- Keeps literal Components D source order from ten to fifteen route IDs.
- Raises `exampleRoutes` length from `93` to `98`.

- [ ] **Step 1: Update route expectations first**

In `route_catalog_test.dart`, append these values after
`componentsD/dragsort/dragsort` in `componentDRouteIds`:

```dart
'componentsD/cityLocate/cityLocate',
'componentsD/title/title',
'componentsD/pullRefresh/pullRefresh',
'componentsD/virtualList/virtualList',
'componentsD/barcode/barcode',
```

Change the total assertion to:

```dart
expect(exampleRoutes, hasLength(98));
```

Add these exact source paths to the completed-path `containsAll` set and to
the explicit available-preview path set:

```dart
'pages/componentsD/cityLocate/cityLocate',
'pages/componentsD/title/title',
'pages/componentsD/pullRefresh/pullRefresh',
'pages/componentsD/virtualList/virtualList',
'pages/componentsD/barcode/barcode',
```

The existing Components D smoke loop already derives from
`componentDRouteIds`; keep its 100 ms pump so CityLocate's post-frame
callback can settle.

- [ ] **Step 2: Run the route catalog test and verify it fails**

```text
flutter test example/test/route_catalog_test.dart --reporter expanded
```

Expected: FAIL because the five source IDs are not yet registered and the
catalog still has 93 routes.

- [ ] **Step 3: Register all five pages in source order**

Add imports for these page files to `example_catalog.dart` alongside the
existing Components D imports:

```dart
import '../pages/components_d/barcode_page.dart';
import '../pages/components_d/city_locate_page.dart';
import '../pages/components_d/pull_refresh_page.dart';
import '../pages/components_d/title_page.dart';
import '../pages/components_d/virtual_list_page.dart';
```

Immediately after the existing Dragsort route, add these records:

```dart
const ExampleRoute(
  id: 'componentsD/cityLocate/cityLocate',
  sourcePath: 'pages/componentsD/cityLocate/cityLocate',
  title: '城市定位',
  group: ExampleRouteGroup.componentsD,
  builder: _buildCityLocate,
),
const ExampleRoute(
  id: 'componentsD/title/title',
  sourcePath: 'pages/componentsD/title/title',
  title: '标题',
  group: ExampleRouteGroup.componentsD,
  builder: _buildTitle,
),
const ExampleRoute(
  id: 'componentsD/pullRefresh/pullRefresh',
  sourcePath: 'pages/componentsD/pullRefresh/pullRefresh',
  title: '下拉刷新',
  group: ExampleRouteGroup.componentsD,
  builder: _buildPullRefresh,
),
const ExampleRoute(
  id: 'componentsD/virtualList/virtualList',
  sourcePath: 'pages/componentsD/virtualList/virtualList',
  title: '虚拟列表',
  group: ExampleRouteGroup.componentsD,
  builder: _buildVirtualList,
),
const ExampleRoute(
  id: 'componentsD/barcode/barcode',
  sourcePath: 'pages/componentsD/barcode/barcode',
  title: '条码',
  group: ExampleRouteGroup.componentsD,
  builder: _buildBarcode,
),
```

Add these builders after `_buildDragsort`:

```dart
Widget _buildCityLocate(BuildContext context) => const CityLocatePage();
Widget _buildTitle(BuildContext context) => const TitlePage();
Widget _buildPullRefresh(BuildContext context) => const PullRefreshPage();
Widget _buildVirtualList(BuildContext context) => const VirtualListPage();
Widget _buildBarcode(BuildContext context) => const BarcodePage();
```

In `example_preview_catalog.dart`, change only the matching existing records
for VirtualList, PullRefresh, Title, Barcode, and CityLocate from
`available: false` to `available: true`; do not reorder records or alter
`componentGroupLengths`.

- [ ] **Step 4: Format and verify route registration**

```text
dart format example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/route_catalog_test.dart
flutter test example/test/route_catalog_test.dart --reporter expanded
```

Expected: PASS. The literal list contains 15 Components D IDs in source order,
all five preview records are available, and each route renders its real page.

- [ ] **Step 5: Commit route and preview registration**

```text
git add -- example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/route_catalog_test.dart
git commit -m "test(example): register components d batch 3 routes"
```

### Task 7: Run Batch Regression, Static Analysis, and Android Build

**Files:**

- Verify only the files created or modified in Tasks 1-6.
- Do not stage build output or unrelated worktree changes.

**Interfaces:**

- Verifies direct page tests, route catalog behavior, the example application,
  the unchanged package, and Android debug compilation.

- [ ] **Step 1: Format all changed Dart files**

```text
dart format example/lib/pages/components_d/city_locate_page.dart example/lib/pages/components_d/title_page.dart example/lib/pages/components_d/pull_refresh_page.dart example/lib/pages/components_d/virtual_list_page.dart example/lib/pages/components_d/barcode_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_d_pages_test.dart example/test/route_catalog_test.dart
```

Expected: formatter reports no remaining changes after the task-level format
steps.

- [ ] **Step 2: Run focused example regressions**

```text
flutter test example/test/components_d_pages_test.dart --reporter expanded
flutter test example/test/route_catalog_test.dart --reporter expanded
```

Expected: all existing ten Components D tests plus the five new page tests
pass, and the catalog test reports 98 completed routes.

- [ ] **Step 3: Run full Flutter regression and analysis**

```text
flutter test example
flutter analyze example
flutter test packages/ultra_ui
flutter analyze packages/ultra_ui
```

Expected: example tests and analysis pass. Package tests pass. If the package
analyzer reports pre-existing warnings and exits nonzero, record them without
changing package files; this batch must introduce no package diagnostics.

- [ ] **Step 4: Check the final diff and build Android debug APK**

```text
git diff --check
flutter build apk --debug --target-platform android-arm64
git status --short
```

Expected: no whitespace errors, a successful debug APK under
`example/build/app/outputs/flutter-apk/`, and only known user worktree
changes with no uncommitted batch source, test, or route files.
