# Components B Batch 9 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Flutter example pages for the uView Plus Components B `Card`, `Table`, and `Table2` source demos.

**Architecture:** Add one focused page per source route under `example/lib/pages/components_b/`, register the routes immediately after Waterfall, and flip the three existing preview rows to available. Card uses `UPCard` plus source section controls. Table uses `UPTable`, `UPTr`, `UPTh`, and `UPTd` with simple state switches. Table2 uses `UPTable2` with deterministic local data, local interaction state, and popup/table actions that remain testable on Android and iOS.

**Tech Stack:** Flutter, Dart, `ultra_ui`, existing example route catalog, Flutter widget tests, adb.

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

- Create `example/lib/pages/components_b/card_page.dart`: Card source demo with the base and advanced cards plus the four parameter controls.
- Create `example/lib/pages/components_b/table_page.dart`: Table source demo with border-color and alignment subsections.
- Create `example/lib/pages/components_b/table2_page.dart`: Table2 source demo with the nine ordered table blocks, selection, sort, tree, span, and popup behavior.
- Modify `example/lib/routes/example_catalog.dart`: import the three pages, register routes after Waterfall, add builders.
- Modify `example/lib/routes/example_preview_catalog.dart`: mark Card, Table, and Table2 preview rows available.
- Modify `example/test/components_b_pages_test.dart`: add focused page tests for Card, Table, and Table2.
- Modify `example/test/route_catalog_test.dart`: update completed route count from 52 to 55 and extend the Components B source-order assertion through `card`, `table`, and `table2`.
- Include the existing untracked package widget files in the implementation commit: `packages/ultra_ui/lib/src/widgets/up_card.dart`, `packages/ultra_ui/lib/src/widgets/up_table.dart`, and `packages/ultra_ui/lib/src/widgets/up_table2.dart`. Only edit them if verification finds a real bug.

## Task 1: Add Failing Route And Page Tests

**Files:**
- Modify: `example/test/route_catalog_test.dart`
- Modify: `example/test/components_b_pages_test.dart`

**Interfaces:**
- Consumes: `buildRouteUnderTest(String id)`, `findExampleRoute(String id)`, `pushExampleRoute(BuildContext, ExampleRoute)`, `UPToast.hide()`.
- Produces: failing expectations for the three new route pages and the final Components B route-order assertion.

- [x] **Step 1: Extend the route-order assertions**

Change the completed route count:

```dart
expect(exampleRoutes, hasLength(55));
```

Extend the Components B ordered list so it ends with:

```dart
<String>[
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
]
```

Change the Components B route-order slice from `take(25)` to `take(28)`.

- [x] **Step 2: Add Card, Table, and Table2 widget tests**

Append the new page tests to `components_b_pages_test.dart`:

```dart
testWidgets('card page toggles the source card configuration', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/card/card'));

  expect(find.text('基础卡片'), findsOneWidget);
  expect(find.text('高级卡片'), findsOneWidget);
  expect(find.text('尊敬的客户您好'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('card-page-thumb')),
      matching: find.text('隐藏'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('左上角图标：隐藏'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('card-page-padding')),
      matching: find.text('20'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('内边距：20'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('card-page-foot')),
      matching: find.text('隐藏'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('底部：隐藏'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('card-page-border')),
      matching: find.text('隐藏'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('外边框：隐藏'), findsOneWidget);
});

testWidgets('table page switches border color and alignment', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/table/table'));

  expect(find.text('演示效果'), findsOneWidget);
  expect(find.text('吕布'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table-page-border')),
      matching: find.text('primary'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('边框颜色：primary'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table-page-align')),
      matching: find.text('右'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('对齐方式：right'), findsOneWidget);
});

testWidgets('table2 page updates row selection and row click state',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/table2/table2'));

  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table2-page-basic')),
      matching: find.text('张三'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('行点击：张三'), findsOneWidget);
});
```

Add two more Table2 tests:

```dart
testWidgets('table2 page selects rows and sorts columns', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/table2/table2'));

  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table2-page-selection')),
      matching: find.text('☐'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('选择数量：1'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table2-page-sort')),
      matching: find.text('年龄'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('排序：age'), findsOneWidget);
});

testWidgets('table2 page opens the popup table and closes on row tap', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/table2/table2'));

  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table2-page-popup')),
      matching: find.text('打开弹窗表格'),
    ),
  );
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('table2-page-popup-table')),
      matching: find.text('李四'),
    ),
  );
  await tester.pump();
  expect(find.textContaining('弹窗选择：李四'), findsOneWidget);
});
```

- [x] **Step 3: Run the new tests to confirm they fail for missing pages**

Run:

```powershell
cd example
flutter test test/route_catalog_test.dart test/components_b_pages_test.dart --reporter expanded
```

Expected: fail because Card, Table, and Table2 routes/pages are not wired yet.

## Task 2: Implement Card Page

**Files:**
- Create: `example/lib/pages/components_b/card_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `UPCard`, `UPTitle`, `UPSubsection`, `UPIcon`, `UPImage`.
- Produces: `CardPage` with visible state text for thumb, padding, footer, and border toggles.

- [x] **Step 1: Build the page shell and the base card**

Use a small stateful page with visible section headings and a base card that matches the source copy:

```dart
UPTitle('基础卡片');
UPCard(
  showHead: false,
  body: Text('尊敬的客户您好，您有来自的开票。如果有疑问请联系您的客户经理。'),
);
```

- [x] **Step 2: Add the advanced card and parameter controls**

Use the source title, subtitle, thumb URL, body rows, and footer text, then drive the controls with local state:

```dart
UPCard(
  title: title,
  subTitle: subTitle,
  thumb: thumbEnabled ? thumbUrl : '',
  padding: paddingValue,
  border: borderEnabled,
  showFoot: bottomEnabled,
  onClick: (_) => setState(() => clickCount++),
  onHeadClick: (_) => setState(() => headClicks++),
  onBodyClick: (_) => setState(() => bodyClicks++),
  onFootClick: (_) => setState(() => footClicks++),
);
```

Expose the subsection state text so the test can assert, and wrap the controls
with stable keys:

```dart
ValueKey('card-page-thumb')
ValueKey('card-page-padding')
ValueKey('card-page-foot')
ValueKey('card-page-border')

左上角图标：显示
内边距：15
底部：显示
外边框：显示
```

- [x] **Step 3: Wire the route and preview entries**

Import `card_page.dart`, register `componentsB/card/card` after Waterfall, and set `pages/componentsB/card/card` to available in the preview catalog.

- [x] **Step 4: Run the Card test**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart -n "card page toggles the source card configuration" --reporter expanded
```

Expected: PASS for the Card page test once the route is wired.

## Task 3: Implement Table Page

**Files:**
- Create: `example/lib/pages/components_b/table_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `UPTable`, `UPTr`, `UPTh`, `UPTd`, `UPSubsection`.
- Produces: `TablePage` with visible state text for border color and alignment.

- [x] **Step 1: Build the source table**

Use the source row/column content and preserve the visible header labels:

```dart
UPTable(
  borderColor: borderColor,
  align: align,
  children: [
    UPTr(children: [
      UPTh(child: Text('姓名')),
      UPTh(child: Text('年龄')),
      UPTh(child: Text('籍贯')),
      UPTh(child: Text('性别')),
    ]),
    UPTr(children: [
      UPTd(child: Text('吕布')),
      UPTd(child: Text('22')),
      UPTd(child: Text('楚河')),
      UPTd(child: Text('男')),
    ]),
  ],
);
```

- [x] **Step 2: Add the border and alignment subsections**

Map the source labels directly to local state:

```dart
灰色 -> #e4e7ed
primary -> #2979ff
warning -> #ff9900

左 -> left
中 -> center
右 -> right
```

Show visible status text such as `边框颜色：primary` and `对齐方式：right`.
Wrap the subsection rows with `ValueKey('table-page-border')` and
`ValueKey('table-page-align')` so tests can tap the intended source option.

- [x] **Step 3: Wire the route and preview entries**

Import `table_page.dart`, register `componentsB/table/table` after Card, and set `pages/componentsB/table/table` to available in the preview catalog.

- [x] **Step 4: Run the Table test**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart -n "table page switches border color and alignment" --reporter expanded
```

Expected: PASS for the Table page test once the route is wired.

## Task 4: Implement Table2 Page

**Files:**
- Create: `example/lib/pages/components_b/table2_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `UPTable2`, `UPButton`, `UPPopup`, `UPTag`, `UPToast`.
- Produces: `Table2Page` with row-click, selection, sort, tree, span, and popup state text.

- [x] **Step 1: Build the nine source blocks**

Preserve the source order with local deterministic data:

```dart
基础表格（斑马纹 + 边框）
表格样式自定义
支持单选的表格
支持复选框的表格
支持排序与筛选
列固定
树形结构
单元格合并
弹窗中使用表格
```

Use the source row and column data, a `GlobalKey<UPTable2State>` when needed, and fixed local assets or inline data so the page remains runnable offline.

- [x] **Step 2: Implement the interactive state**

Track these visible states:

```dart
行点击：张三
选择数量：1
排序：age ascending
展开：1
弹窗选择：李四
```

Use the source selection, tree expand, span, and popup interactions to update
those texts. Wrap the visible demo sections with stable keys so tests target the
right table: `table2-page-basic`, `table2-page-selection`, `table2-page-sort`,
`table2-page-tree`, `table2-page-span`, and `table2-page-popup`. Put the popup
table itself under `table2-page-popup-table`.

- [x] **Step 3: Wire the route and preview entries**

Import `table2_page.dart`, register `componentsB/table2/table2` after Table, and set `pages/componentsB/table2/table2` to available in the preview catalog.

- [x] **Step 4: Run the Table2 tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart -n "table2 page" --reporter expanded
```

Expected: PASS for the Table2 page tests once the route is wired.

## Task 5: Final Verification And Commit

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Include: `packages/ultra_ui/lib/src/widgets/up_card.dart`
- Include: `packages/ultra_ui/lib/src/widgets/up_table.dart`
- Include: `packages/ultra_ui/lib/src/widgets/up_table2.dart`

**Interfaces:**
- Consumes: the new pages and the existing `ultra_ui` widgets.
- Produces: a clean batch commit for the final three Components B source demos.

- [x] **Step 1: Format the changed files**

Run:

```powershell
cd example
dart format lib/pages/components_b/card_page.dart lib/pages/components_b/table_page.dart lib/pages/components_b/table2_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
cd ..\packages\ultra_ui
dart format lib/src/widgets/up_card.dart lib/src/widgets/up_table.dart lib/src/widgets/up_table2.dart test/widgets_test.dart
```

- [x] **Step 2: Run full verification**

Run:

```powershell
cd example
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --reporter expanded
```

- [x] **Step 3: Install to MuMu**

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

Expected: the app installs, launches, and the main activity is focused.

- [x] **Step 4: Commit only the batch 9 files**

Stage only the three new pages, the route catalog, preview catalog, tests, this plan file, and the three package widget files. Leave `README.md` and unrelated untracked files untouched.
