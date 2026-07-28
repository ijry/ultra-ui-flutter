# Components B Batch 8 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Flutter example pages for the uView Plus `Tabbar`, `Tabbar-vue`, and `Waterfall` Components B source demos.

**Architecture:** Create one focused page per source route, register the routes immediately after Progress, and enable existing Tabbar/Waterfall preview rows in place. The Tabbar pages use `UPTabbar`/`UPTabbarItem`; Waterfall uses `UPWaterfall`/`UPLoadmore` with local assets and deterministic item generation for tests.

**Tech Stack:** Flutter, Dart, `ultra_ui`, existing example route catalog, Flutter widget tests, Android debug APK install through adb.

## Global Constraints

- Source root: `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus`.
- Example routes must preserve `pages.json` source order.
- Component class names use the `UP` prefix, for example `UPButton`.
- Runtime target is Android/iOS Flutter only.
- Examples should follow uView Plus source demos 1:1 for labels, order, representative props, and principal interactions.
- Do not stage `README.md` or unrelated untracked files.
- Work directly on `main`; previous user direction approved this workflow.

---

## File Structure

- Create `example/lib/pages/components_b/tabbar_page.dart`: Tabbar source demo with twelve ordered source blocks and route navigation to Tabbar-vue.
- Create `example/lib/pages/components_b/tabbar2_page.dart`: Tabbar-vue source demo with fifteen ordered source blocks, including card, underline, dot, glow, and fixed-bottom variants.
- Create `example/lib/pages/components_b/waterfall_page.dart`: Waterfall source demo with deterministic product cards, close/remove behavior, and load-more behavior.
- Modify `example/lib/routes/example_catalog.dart`: import the three pages, register routes after Progress, add builders.
- Modify `example/lib/routes/example_preview_catalog.dart`: mark Tabbar and Waterfall preview rows available; there is no preview row for Tabbar-vue.
- Modify `example/test/components_b_pages_test.dart`: add focused page tests for Tabbar, Tabbar-vue, and Waterfall.
- Modify `example/test/route_catalog_test.dart`: update completed route count from 49 to 52 and Components B source-order assertion.
- Include `packages/ultra_ui/lib/src/widgets/up_tabbar.dart`, `packages/ultra_ui/lib/src/widgets/up_waterfall.dart`, and `packages/ultra_ui/lib/src/widgets/up_loadmore.dart` in the implementation commit because these demonstrated package widgets are currently untracked.

## Task 1: Route And Page Test Expectations

**Files:**
- Modify: `example/test/route_catalog_test.dart`
- Modify: `example/test/components_b_pages_test.dart`

**Interfaces:**
- Consumes: existing `buildRouteUnderTest(String id)`, `findExampleRoute(String id)`, `pushExampleRoute(BuildContext, ExampleRoute)`, `UPTabbar`, `UPWaterfall`, `UPLoadmore`.
- Produces: failing expectations for the three new route pages and source interactions.

- [ ] **Step 1: Add route-order failing expectations**

In `route_catalog_test.dart`, change:

```dart
expect(exampleRoutes, hasLength(49));
```

to:

```dart
expect(exampleRoutes, hasLength(52));
```

Extend the Components B ordered list to:

```dart
<String>[
  'componentsB/dropdown/dropdown',
  'componentsB/actionSheet/actionSheet',
  'componentsB/parse/parse',
  'componentsB/parse/jump',
  'componentsB/toast/toast',
  'componentsB/keyboard/keyboard',
  'componentsB/slider/slider',
  'componentsB/upload/upload',
  'componentsB/notify/notify',
  'componentsB/countDown/countDown',
  'componentsB/color/color',
  'componentsB/numberBox/numberBox',
  'componentsB/countTo/countTo',
  'componentsB/search/search',
  'componentsB/badge/badge',
  'componentsB/tag/tag',
  'componentsB/alert/alert',
  'componentsB/switch/switch',
  'componentsB/collapse/collapse',
  'componentsB/code/code',
  'componentsB/noticeBar/noticeBar',
  'componentsB/progress/progress',
  'componentsB/tabbar/tabbar',
  'componentsB/tabbar/tabbar2',
  'componentsB/waterfall/waterfall',
]
```

Change the expectation from `componentBRoutes.take(22)` to `componentBRoutes.take(25)`.

- [ ] **Step 2: Add Tabbar failing tests**

Append these tests in `components_b_pages_test.dart`:

```dart
testWidgets('tabbar page updates the source basic selection', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/tabbar/tabbar'));

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('基础值：0'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('tabbar-page-basic')),
      matching: find.text('放映厅'),
    ),
  );
  await tester.pump();
  expect(find.text('基础值：1'), findsOneWidget);
});

testWidgets('tabbar page intercepts the second source tab', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/tabbar/tabbar'));

  await tester.ensureVisible(
    find.byKey(const ValueKey('tabbar-page-intercept')),
  );
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('tabbar-page-intercept')),
      matching: find.text('放映厅'),
    ),
  );
  await tester.pump();
  expect(find.text('请您先登录'), findsOneWidget);
  expect(find.text('拦截值：0'), findsOneWidget);
  UPToast.hide();
});
```

- [ ] **Step 3: Add Tabbar-vue failing test**

Append:

```dart
testWidgets('tabbar-vue page updates the source dot style tab',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/tabbar/tabbar2'));

  await tester.ensureVisible(find.byKey(const ValueKey('tabbar2-page-dot')));
  await tester.pump();
  expect(find.text('圆点值：0'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('tabbar2-page-dot')),
      matching: find.text('图片'),
    ),
  );
  await tester.pump();
  expect(find.text('圆点值：1'), findsOneWidget);
});
```

- [ ] **Step 4: Add Waterfall failing tests**

Append:

```dart
testWidgets('waterfall page removes the source product card', (tester) async {
  await tester
      .pumpWidget(buildRouteUnderTest('componentsB/waterfall/waterfall'));

  expect(find.text('商品数量：10'), findsOneWidget);
  await tester.tap(
    find
        .byWidgetPredicate(
          (widget) => widget is UPIcon && widget.name == 'close-circle-fill',
        )
        .first,
  );
  await tester.pump();
  expect(find.text('商品数量：9'), findsOneWidget);
});

testWidgets('waterfall page loads another deterministic source batch',
    (tester) async {
  await tester
      .pumpWidget(buildRouteUnderTest('componentsB/waterfall/waterfall'));

  expect(find.text('商品数量：10'), findsOneWidget);
  await tester.ensureVisible(find.text('加载更多'));
  await tester.pump();
  await tester.tap(find.text('加载更多'));
  await tester.pump();
  expect(find.text('商品数量：20'), findsOneWidget);
});
```

- [ ] **Step 5: Run tests to verify the new expectations fail**

Run:

```powershell
cd example
flutter test test/route_catalog_test.dart test/components_b_pages_test.dart --reporter expanded
```

Expected: FAIL because the new page classes and route entries do not exist yet.

## Task 2: Implement Tabbar Page

**Files:**
- Create: `example/lib/pages/components_b/tabbar_page.dart`

**Interfaces:**
- Consumes: `UPTabbar`, `UPTabbarItem`, `UPToast`, `ExampleDemoBlock`, `ExamplePageScaffold`, `findExampleRoute`, `pushExampleRoute`.
- Produces: `class TabbarPage extends StatefulWidget`.

- [ ] **Step 1: Create the page state**

Create `TabbarPage` and state values matching source defaults:

```dart
int _value1 = 0;
int _value2 = 1;
String _value3 = 'play-right';
int _value4 = 0;
int _value5 = 0;
int _value6 = 0;
int _value7 = 3;
int _value8 = 0;
int _value9 = 1;
int _value10 = 1;
int _value11 = 0;
int _value12 = 2;
String _fixedStatus = '未跳转';
String _midStatus = '未点击';
```

Add:

```dart
void _changeIntercept(dynamic name) {
  if (name == 1) {
    UPToast.show(context, message: '请您先登录');
    return;
  }
  setState(() => _value5 = name as int);
}

Future<void> _goNext() async {
  setState(() => _fixedStatus = '准备跳转');
  await pushExampleRoute(context, findExampleRoute('componentsB/tabbar/tabbar2'));
}

void _clickMidButton() {
  setState(() => _midStatus = '点击了中间按钮');
  UPToast.show(context, message: '点击了中间按钮');
}
```

- [ ] **Step 2: Add reusable local widgets**

Inside the file add private helpers:

```dart
class _TabbarBlock extends StatelessWidget {
  const _TabbarBlock({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => ExampleDemoBlock(
        title: title,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      );
}
```

Add a helper method returning the four source items:

```dart
List<Widget> _sourceItems({bool badge = false, bool midButton = false}) {
  return <Widget>[
    const UPTabbarItem(name: 0, text: '首页', icon: 'home'),
    UPTabbarItem(name: 1, text: '放映厅', icon: 'photo', badge: badge ? 5 : null),
    UPTabbarItem(
      name: 2,
      text: '直播',
      icon: 'play-right',
      mode: midButton ? 'midButton' : '',
      onClick: midButton ? _clickMidButton : null,
    ),
    const UPTabbarItem(name: 3, text: '我的', icon: 'account'),
  ];
}
```

- [ ] **Step 3: Render all source blocks in order**

Use `ExamplePageScaffold(title: 'Tabbar')`, root key `example-page-componentsB/tabbar/tabbar`, and twelve `_TabbarBlock`s in source order. Every `UPTabbar` is inline:

```dart
UPTabbar(
  value: _value1,
  fixed: false,
  placeholder: false,
  safeAreaInsetBottom: false,
  onChange: (name) => setState(() => _value1 = name as int),
  children: _sourceItems(),
)
```

Add visible state text under interactive demos, for example `基础值：$_value1`, `拦截值：$_value5`, `固定状态：$_fixedStatus`, and `中间按钮：$_midStatus`. The string-name block uses item names `home`, `photo`, `play-right`, `account` and initial value `play-right`.

- [ ] **Step 4: Run Tabbar tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --name "tabbar page" --reporter expanded
```

Expected: PASS after route registration is complete.

## Task 3: Implement Tabbar-vue Page

**Files:**
- Create: `example/lib/pages/components_b/tabbar2_page.dart`

**Interfaces:**
- Consumes: `UPTabbar`, `UPTabbarItem`, `UPToast`, `ExampleDemoBlock`, `ExamplePageScaffold`.
- Produces: `class Tabbar2Page extends StatefulWidget`.

- [ ] **Step 1: Create the page state**

Create `Tabbar2Page` with source defaults:

```dart
int _value1 = 0;
int _value2 = 1;
String _value3 = 'play-right';
int _value4 = 0;
int _value5 = 0;
int _value6 = 0;
int _value7 = 3;
int _value8 = 0;
int _value9 = 1;
int _value10 = 0;
int _value11 = 2;
int _value12 = 0;
int _value13 = 1;
int _value14 = 2;
int _value15 = 2;
```

Add the same second-tab intercept method as Tabbar.

- [ ] **Step 2: Render all source blocks in order**

Use `ExamplePageScaffold(title: 'Tabbar-vue')`, root key `example-page-componentsB/tabbar/tabbar2`, and fifteen source blocks. Include style-specific props:

```dart
UPTabbar(styleType: 'card', animationType: 'pulse', ...)
UPTabbar(styleType: 'underline', ...)
UPTabbar(styleType: 'dot', textMode: 'active', ...)
UPTabbar(styleType: 'glow', activeBackgroundColor: '#ecf5ff', ...)
```

Assign key `tabbar2-page-dot` to the `圆点风格` block, show `圆点值：$_value12`, and use tab text `图片` for the second item in that block.

- [ ] **Step 3: Run Tabbar-vue test**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --name "tabbar-vue page" --reporter expanded
```

Expected: PASS after route registration is complete.

## Task 4: Implement Waterfall Page

**Files:**
- Create: `example/lib/pages/components_b/waterfall_page.dart`

**Interfaces:**
- Consumes: `UPWaterfall`, `UPWaterfallState`, `UPLoadmore`, `UPIcon`, local assets under `example/assets/uview/swiper/`.
- Produces: `class WaterfallPage extends StatefulWidget`.

- [ ] **Step 1: Create deterministic state and seed data**

Create:

```dart
final GlobalKey<UPWaterfallState> _waterfallKey = GlobalKey<UPWaterfallState>();
final List<Map<String, dynamic>> _flowList = <Map<String, dynamic>>[];
int _cursor = 0;
String _loadStatus = 'loadmore';
```

Seed data contains the source product title/price/shop copy and local images:

```dart
static const List<Map<String, dynamic>> _seeds = <Map<String, dynamic>>[
  {'price': 35, 'title': '北国风光，千里冰封，万里雪飘', 'shop': '李白杜甫白居易旗舰店', 'image': 'assets/uview/swiper/swiper1.png', 'height': 176},
  {'price': 75, 'title': '望长城内外，惟余莽莽', 'shop': '李白杜甫白居易旗舰店', 'image': 'assets/uview/swiper/swiper2.png', 'height': 196},
  {'price': 385, 'title': '大河上下，顿失滔滔', 'shop': '李白杜甫白居易旗舰店', 'image': 'assets/uview/swiper/swiper3.png', 'height': 216},
];
```

- [ ] **Step 2: Add add/remove methods**

Implement:

```dart
void _addRandomData() {
  setState(() {
    for (var i = 0; i < 10; i++) {
      final seed = _seeds[_cursor % _seeds.length];
      _flowList.add(<String, dynamic>{...seed, 'id': _cursor + 1});
      _cursor++;
    }
    _loadStatus = 'loadmore';
  });
}

void _remove(dynamic id) {
  _waterfallKey.currentState?.remove(id);
  setState(() => _flowList.removeWhere((item) => item['id'] == id));
}
```

Call `_addRandomData()` in `initState`.

- [ ] **Step 3: Render cards and loadmore**

Use `ExamplePageScaffold(title: '瀑布流')`, root key `example-page-componentsB/waterfall/waterfall`, visible `商品数量：${_flowList.length}`, and:

```dart
UPWaterfall(
  key: _waterfallKey,
  value: _flowList,
  columns: 'auto',
  itemBuilder: (context, item, itemIndex, colIndex) =>
      _WaterfallCard(item: item as Map, onRemove: () => _remove(item['id'])),
)
```

`_WaterfallCard` renders `Image.asset`, title, `￥price 元`, tags `自营` and `放心购`, shop, and `UPIcon(name: 'close-circle-fill')`. Render `UPLoadmore(status: _loadStatus, onLoadmore: _addRandomData)` below the waterfall.

- [ ] **Step 4: Run Waterfall tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --name "waterfall page" --reporter expanded
```

Expected: PASS after route registration is complete.

## Task 5: Register Routes And Preview Availability

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `TabbarPage`, `Tabbar2Page`, `WaterfallPage`.
- Produces: completed catalog entries for `componentsB/tabbar/tabbar`, `componentsB/tabbar/tabbar2`, and `componentsB/waterfall/waterfall`.

- [ ] **Step 1: Add imports**

Add:

```dart
import '../pages/components_b/tabbar_page.dart';
import '../pages/components_b/tabbar2_page.dart';
import '../pages/components_b/waterfall_page.dart';
```

- [ ] **Step 2: Register routes after Progress**

Append these entries after `componentsB/progress/progress`:

```dart
const ExampleRoute(
  id: 'componentsB/tabbar/tabbar',
  sourcePath: 'pages/componentsB/tabbar/tabbar',
  title: 'Tabbar',
  group: ExampleRouteGroup.componentsB,
  builder: _buildTabbar,
),
const ExampleRoute(
  id: 'componentsB/tabbar/tabbar2',
  sourcePath: 'pages/componentsB/tabbar/tabbar2',
  title: 'Tabbar-vue',
  group: ExampleRouteGroup.componentsB,
  builder: _buildTabbar2,
),
const ExampleRoute(
  id: 'componentsB/waterfall/waterfall',
  sourcePath: 'pages/componentsB/waterfall/waterfall',
  title: '瀑布流',
  group: ExampleRouteGroup.componentsB,
  builder: _buildWaterfall,
),
```

Add builders:

```dart
Widget _buildTabbar(BuildContext context) => const TabbarPage();
Widget _buildTabbar2(BuildContext context) => const Tabbar2Page();
Widget _buildWaterfall(BuildContext context) => const WaterfallPage();
```

- [ ] **Step 3: Enable preview rows**

In `example_preview_catalog.dart`, set `available: true` for:

```dart
sourcePath: 'pages/componentsB/tabbar/tabbar'
sourcePath: 'pages/componentsB/waterfall/waterfall'
```

- [ ] **Step 4: Run route tests**

Run:

```powershell
cd example
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

## Task 6: Format, Verify, Build, Install, Commit

**Files:**
- Format all batch files.
- Commit only explicit batch files.

**Interfaces:**
- Produces: verified debug APK installed and launched on MuMu.

- [ ] **Step 1: Format**

Run:

```powershell
cd example
dart format lib/pages/components_b/tabbar_page.dart lib/pages/components_b/tabbar2_page.dart lib/pages/components_b/waterfall_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_tabbar.dart lib/src/widgets/up_waterfall.dart lib/src/widgets/up_loadmore.dart test/widgets_test.dart
```

- [ ] **Step 2: Run targeted tests**

Run:

```powershell
cd ..\..\example
flutter test test/route_catalog_test.dart test/components_b_pages_test.dart --reporter expanded

cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --reporter expanded
```

Expected: PASS.

- [ ] **Step 3: Run full example verification**

Run:

```powershell
cd ..\..\example
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

Expected: PASS.

- [ ] **Step 4: Install and launch on MuMu**

Run:

```powershell
cd example
$adb = (Get-Command adb).Source
$serial = '127.0.0.1:16384'
& $adb connect $serial
& $adb -s $serial install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s $serial shell am force-stop com.example.ultra_ui_example
& $adb -s $serial shell monkey -p com.example.ultra_ui_example -c android.intent.category.LAUNCHER 1
& $adb -s $serial shell dumpsys window | Select-String 'com.example.ultra_ui_example/.MainActivity'
```

Expected: install succeeds and `MainActivity` is focused.

- [ ] **Step 5: Stage only batch files**

Run:

```powershell
git add -- docs/superpowers/plans/2026-07-29-uview-components-b-batch-8.md `
  example/lib/pages/components_b/tabbar_page.dart `
  example/lib/pages/components_b/tabbar2_page.dart `
  example/lib/pages/components_b/waterfall_page.dart `
  example/lib/routes/example_catalog.dart `
  example/lib/routes/example_preview_catalog.dart `
  example/test/components_b_pages_test.dart `
  example/test/route_catalog_test.dart `
  packages/ultra_ui/lib/src/widgets/up_tabbar.dart `
  packages/ultra_ui/lib/src/widgets/up_waterfall.dart `
  packages/ultra_ui/lib/src/widgets/up_loadmore.dart
```

Check `git status --short` and verify `README.md` is not staged.

- [ ] **Step 6: Commit implementation**

Run:

```powershell
git commit -m "feat(example): add tabbar waterfall source pages"
```

Expected: implementation commit includes only the plan, three example pages, route/test updates, and the three demonstrated package widget files.
