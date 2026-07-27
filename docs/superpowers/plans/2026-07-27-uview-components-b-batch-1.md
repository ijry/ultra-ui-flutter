# Components B First Source-Order Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the complete 124-route source manifest and migrate the first four registered `componentsB` pages: Dropdown, ActionSheet, Parse, and Parse Jump.

**Architecture:** Keep the complete source route inventory separate from the completed `ExampleRoute` catalog so the application can accurately show remaining migration work while making final catalog completeness mechanically verifiable. Add one dedicated page class per source route in `example/lib/pages/components_b/`; each page composes existing `UP*` widgets and owns only its source-specific state. The parse source fixture stays Dart-local and uses `UPParse`, with Flutter navigation handling the source internal link.

**Tech Stack:** Flutter `>=3.19.0`, Dart `>=3.3.0`, `flutter_test`, existing local `ultra_ui` package, and Android/iOS only.

## Global Constraints

- Source of truth is `D:\Repos\xyito\open\uview-plus\src\pages.json` and the matching source files under `src/pages`.
- Preserve registered route order, exact source route title, visible Chinese labels, representative default state, and principal interaction.
- Use `UP*` widgets for each component demonstration. Do not substitute a Material control for the component being demonstrated.
- Do not use remote image resources at runtime. The first batch has no required source illustration asset; Parse's remote source preview image must remain a controlled `UPImage` source and never block route rendering.
- `ExampleRoute` entries are added only when a real source page exists. Set a preview route `available: true` only when its matching catalog builder is added.
- Preserve Flutter package names with `UP` prefixes and do not alter unrelated dirty worktree files.
- Every new behavior uses test-first implementation: run its widget test red before adding the page or catalog entry, then rerun it green.
- Run `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, then install and launch the APK on MuMu `127.0.0.1:16384` at the batch boundary.

---

## File Structure

```text
example/lib/
  routes/example_source_manifest.dart       # All 124 registered source routes
  routes/example_catalog.dart               # Adds four completed Components B builders
  routes/example_preview_catalog.dart       # Enables Dropdown, ActionSheet, Parse
  pages/components_b/dropdown_page.dart     # UPDropdown source demo
  pages/components_b/action_sheet_page.dart # UPActionSheet source presets
  pages/components_b/parse_page.dart        # UPParse source content and links
  pages/components_b/parse_jump_page.dart   # Registered internal-link target
  pages/components_b/parse_source_content.dart # Static source HTML fixture
example/test/
  route_catalog_test.dart                   # Manifest and completed-route contract
  components_b_pages_test.dart              # First-batch real interactions
```

### Task 1: Add Complete Source Route Manifest

**Files:**
- Create: `example/lib/routes/example_source_manifest.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Produces `ExampleSourceRoute` with `id`, `sourcePath`, `title`, and `group`.
- Produces `sourceExampleRoutes`, the literal `pages.json` order: 4 main, 23 Components A, 28 Components B, 28 Components C, 27 Components D, and 14 Templates.
- Produces `findSourceExampleRoute(String id)` for audit and later batch smoke coverage.

- [ ] **Step 1: Write failing manifest contract tests**

```dart
import 'package:ultra_ui_example/routes/example_source_manifest.dart';

test('source route manifest preserves all registered pages.json routes', () {
  expect(sourceExampleRoutes, hasLength(124));
  expect(
    sourceExampleRoutes.take(5).map((route) => route.id),
    <String>[
      'example/components',
      'example/template',
      'example/mine',
      'example/ad',
      'componentsA/transition/transition',
    ],
  );
  expect(
    sourceExampleRoutes.skip(27).take(4).map((route) => route.id),
    <String>[
      'componentsB/dropdown/dropdown',
      'componentsB/actionSheet/actionSheet',
      'componentsB/parse/parse',
      'componentsB/parse/jump',
    ],
  );
  expect(
    sourceExampleRoutes.skip(120).map((route) => route.id),
    <String>[
      'template/order/index',
      'template/login/code',
      'template/address/index',
      'template/address/addSite',
    ],
  );
  expect(
    sourceExampleRoutes.map((route) => route.sourcePath).toSet().length,
    sourceExampleRoutes.length,
  );
});
```

- [ ] **Step 2: Run the manifest test and verify it fails because the manifest is absent**

Run: `flutter test test/route_catalog_test.dart --plain-name "source route manifest preserves all registered pages.json routes" --reporter expanded`

Expected: FAIL with an unresolved import for `example_source_manifest.dart`.

- [ ] **Step 3: Implement the literal source manifest**

Define the value type and use every registered source path and title from
`pages.json` exactly once. Use source-package group values:

```dart
class ExampleSourceRoute {
  const ExampleSourceRoute({
    required this.id,
    required this.sourcePath,
    required this.title,
    required this.group,
  });

  final String id;
  final String sourcePath;
  final String title;
  final ExampleRouteGroup group;
}
```

The 28 Components B IDs must begin with the four IDs from the failing test and
continue in this exact order:

```dart
const List<String> componentBSourceRouteIds = <String>[
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
  'componentsB/card/card',
  'componentsB/table/table',
  'componentsB/table2/table2',
];
```

- [ ] **Step 4: Run manifest and existing catalog tests**

Run: `flutter test test/route_catalog_test.dart --reporter expanded`

Expected: PASS with current catalog still containing 27 completed routes.

- [ ] **Step 5: Commit the manifest contract**

```bash
git add example/lib/routes/example_source_manifest.dart example/test/route_catalog_test.dart
git commit -m "test(example): track all source example routes"
```

### Task 2: Migrate Dropdown Page

**Files:**
- Create: `example/lib/pages/components_b/dropdown_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Create: `example/test/components_b_pages_test.dart`

**Interfaces:**
- Produces `DropdownPage` at `componentsB/dropdown/dropdown` with title `下拉菜单`.
- Uses `UPDropdown` and three `UPDropdownItem` entries: `距离`, `温度`, and `属性`.
- Exposes source default `value1 == ''`, `value2 == 2`, mask close enabled, no bottom border, and primary `#2979ff` active color.

- [ ] **Step 1: Write the failing Dropdown interaction test**

```dart
testWidgets('dropdown page selects the source distance option', (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsB/dropdown/dropdown'),
  );

  await tester.tap(find.text('距离'));
  await tester.pumpAndSettle();
  expect(find.text('距离优先'), findsOneWidget);

  await tester.tap(find.text('距离优先'));
  await tester.pump();
  expect(find.text('当前选择：2'), findsOneWidget);
});
```

- [ ] **Step 2: Run the Dropdown test and verify it fails because the route is absent**

Run: `flutter test test/components_b_pages_test.dart --plain-name "dropdown page selects the source distance option" --reporter expanded`

Expected: FAIL with `No completed example route registered for componentsB/dropdown/dropdown`.

- [ ] **Step 3: Implement the source dropdown page and register it**

Build `DropdownPage` with an `ExamplePageScaffold`, route marker key
`example-page-componentsB/dropdown/dropdown`, and a `UPDropdown` whose option
sets exactly match the source:

```dart
const distanceOptions = <Map<String, dynamic>>[
  <String, dynamic>{'label': '默认排序', 'value': 1},
  <String, dynamic>{'label': '距离优先', 'value': 2},
  <String, dynamic>{'label': '价格优先', 'value': 3},
];
const temperatureOptions = <Map<String, dynamic>>[
  <String, dynamic>{'label': '去冰', 'value': 1},
  <String, dynamic>{'label': '加冰', 'value': 2},
  <String, dynamic>{'label': '正常温', 'value': 3},
  <String, dynamic>{'label': '加热', 'value': 4},
  <String, dynamic>{'label': '极寒风暴', 'value': 5},
];
```

The third item contains seven selectable source labels, an `确定` `UPButton`,
and calls the `UPDropdownState.close()` through a `GlobalKey`. Add the three
source configuration selectors with `UPSubsection`: `下边框` (`有`/`无`),
`激活颜色` (`#2979ff`/`#ff9900`/`#19be6b`), and `遮罩是否可点击`
(`是`/`否`). Every selection change must update visible page state.

Register the exact source route and set only the existing Dropdown preview
route to `available: true`.

- [ ] **Step 4: Run Dropdown and catalog tests**

Run: `flutter test test/components_b_pages_test.dart test/route_catalog_test.dart --reporter expanded`

Expected: PASS; the completed catalog contains 28 routes and Dropdown is an enabled preview.

- [ ] **Step 5: Commit the Dropdown migration**

```bash
git add example/lib/pages/components_b/dropdown_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart
git commit -m "feat(example): add dropdown source page"
```

### Task 3: Migrate ActionSheet Page

**Files:**
- Create: `example/lib/pages/components_b/action_sheet_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`

**Interfaces:**
- Produces `ActionSheetPage` at `componentsB/actionSheet/actionSheet` with title `上拉菜单`.
- Uses a real `UPActionSheet` for source presets 0 through 4 and `UPToast` for the Android/iOS source substitute for WeChat-only preset 5.

- [ ] **Step 1: Write the failing ActionSheet interaction tests**

```dart
testWidgets('action sheet page opens the source cancel preset', (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsB/actionSheet/actionSheet'),
  );

  await tester.tap(find.text('显示取消按钮'));
  await tester.pumpAndSettle();
  expect(find.text('选项3'), findsOneWidget);
  expect(find.text('取消'), findsOneWidget);
});

testWidgets('action sheet page explains the WeChat-only source preset',
    (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsB/actionSheet/actionSheet'),
  );

  await tester.tap(find.text('微信开放能力'));
  await tester.pump();
  expect(find.text('请在微信内预览'), findsOneWidget);
  UPToast.hide();
});
```

- [ ] **Step 2: Run ActionSheet tests and verify they fail because the route is absent**

Run: `flutter test test/components_b_pages_test.dart --name "action sheet page" --reporter expanded`

Expected: FAIL with the unregistered ActionSheet route.

- [ ] **Step 3: Implement the six source presets and register the page**

Render source cell labels in order: `普通使用`, `设置状态`, `显示取消按钮`,
`描述内容`, `显示标题(显示圆角)`, and `微信开放能力`. Maintain one selected
preset state and render its `UPActionSheet`:

- normal: 13 actions with `选项1`, repeated `选项2`, and `选项3`/`描述文本`; use `closeOnClickOverlay: false`.
- status: `选项1`, loading action, and disabled `选项被禁用`.
- cancel: `选项1` through `选项3` plus `cancelText: '取消'`.
- description: actions plus exact source description `这是一段描述文本,字号偏小,颜色偏淡`.
- title: `title: '标题位置'`, `round: 10`, and the exact source slot text.
- WeChat: call `UPToast.show(context, message: '请在微信内预览')` rather than opening a fake user-info control.

Register the route and enable only the existing ActionSheet preview.

- [ ] **Step 4: Run ActionSheet, catalog, and current example tests**

Run: `flutter test test/components_b_pages_test.dart test/route_catalog_test.dart test/components_a_pages_test.dart --reporter expanded`

Expected: PASS; completed catalog contains 29 routes.

- [ ] **Step 5: Commit the ActionSheet migration**

```bash
git add example/lib/pages/components_b/action_sheet_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart
git commit -m "feat(example): add action sheet source page"
```

### Task 4: Migrate Parse and Registered Internal-Link Pages

**Files:**
- Create: `example/lib/pages/components_b/parse_source_content.dart`
- Create: `example/lib/pages/components_b/parse_page.dart`
- Create: `example/lib/pages/components_b/parse_jump_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Produces `ParsePage` at `componentsB/parse/parse` with title `富文本解析器`.
- Produces `ParseJumpPage` at `componentsB/parse/jump` with title `内部链接`.
- Uses `UPParse` for source tables, list/text/link sections and Flutter route navigation for its source internal link.

- [ ] **Step 1: Write failing Parse route and link behavior tests**

```dart
testWidgets('parse page renders source content and opens its internal route',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => pushExampleRoute(
            context,
            findExampleRoute('componentsB/parse/parse'),
          ),
          child: const Text('打开解析器'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开解析器'));
  await tester.pumpAndSettle();
  expect(find.text('富文本示例'), findsWidgets);
  expect(find.text('内部链接'), findsWidgets);

  await tester.tap(find.text('内部链接').last);
  await tester.pumpAndSettle();
  expect(find.text('内部链接'), findsOneWidget);
  expect(find.byKey(const ValueKey('example-page-componentsB/parse/jump')),
      findsOneWidget);
});
```

- [ ] **Step 2: Run Parse test and verify it fails because the routes are absent**

Run: `flutter test test/components_b_pages_test.dart --plain-name "parse page renders source content and opens its internal route" --reporter expanded`

Expected: FAIL with the unregistered Parse route.

- [ ] **Step 3: Implement source content, Parse page, and Jump page**

Copy the complete HTML string exported by
`src/pages/componentsB/parse/content.js` into
`parse_source_content.dart` as `const String parseSourceContent`. Do not
replace the source's table/list/text/link sections with a shortened summary.

`ParsePage` wraps:

```dart
UPParse(
  content: parseSourceContent,
  domain: 'https://6874-html-foe72-1259071903.tcb.qcloud.la/demo',
  lazyLoad: true,
  scrollTable: true,
  selectable: true,
  useAnchor: true,
  onLinkTap: _handleSourceLink,
)
```

`_handleSourceLink` must push the registered `componentsB/parse/jump` route
when the URL ends with `/pages/componentsB/parse/jump`; it shows in-app
feedback for the source external and anchor links. `ParseJumpPage` renders the
exact source text `跳转测试页面` under its source title and route marker.

Register both exact source routes. Enable only the existing Parse preview;
`parse/jump` intentionally has no source index preview row.

- [ ] **Step 4: Run new batch tests and full example static validation**

Run: `dart format lib test`

Run: `flutter analyze`

Run: `flutter test --reporter expanded`

Expected: all example tests PASS and the completed catalog contains 31 routes.

- [ ] **Step 5: Build, install, and launch on MuMu**

Run: `flutter build apk --debug`

Run:

```powershell
$adb = (Get-Command adb).Source
$serial = '127.0.0.1:16384'
& $adb -s $serial install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s $serial shell am force-stop com.example.ultra_ui_example
& $adb -s $serial shell monkey -p com.example.ultra_ui_example -c android.intent.category.LAUNCHER 1
```

Expected: ADB reports `Success`, one launcher event is injected, and
`dumpsys window` contains `com.example.ultra_ui_example/.MainActivity`.

- [ ] **Step 6: Commit the Parse routes and source-order batch**

```bash
git add example/lib/pages/components_b/parse_source_content.dart example/lib/pages/components_b/parse_page.dart example/lib/pages/components_b/parse_jump_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart
git commit -m "feat(example): add parse source pages"
```

## Plan Self-Review

- Spec coverage: Task 1 makes all 124 registered routes auditable. Tasks 2-4 implement the first four registered Components B routes in exact source order, enable only their actual preview rows, and preserve the one unindexed internal detail route.
- Placeholder scan: all page IDs, titles, source labels, interaction checks, and terminal commands are concrete.
- Type consistency: `ExampleSourceRoute`, `sourceExampleRoutes`, and `findSourceExampleRoute` are used only as defined in Task 1. All detail pages are added through the existing `ExampleRoute`/`pushExampleRoute` interfaces.
