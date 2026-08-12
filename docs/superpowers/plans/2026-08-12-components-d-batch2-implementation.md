# Components D Batch 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the next five source-order Components D example pages: CateTab,
Select, Pagination, Tree, and Dragsort.

**Architecture:** Add one focused page per source route under
`example/lib/pages/components_d/`, reusing `ExamplePageScaffold`,
`ExampleDemoBlock`, and the public `UP*` widgets. Extend the existing focused
page tests and route catalog tests. Modify package code only when a focused
test reproduces a concrete package behavior gap.

**Tech Stack:** Flutter SDK, Dart, Material 3, local `ultra_ui` package,
`flutter_test`, existing example route catalogs, and local deterministic data.

## Global Constraints

- Batch scope is exactly `componentsD/cateTab/cateTab`,
  `componentsD/select/select`, `componentsD/pagination/pagination`,
  `componentsD/tree/tree`, and `componentsD/dragsort/dragsort`.
- Preserve source titles, source route order, representative defaults, and
  principal interactions.
- Keep all demos offline and deterministic; add no dependency or network data.
- Reuse public `UPCateTab`, `UPSelect`, `UPPagination`, `UPTree`, `UPDragSort`,
  `UPIcon`, and existing example helpers.
- Do not add a generic Components D abstraction.
- Do not modify `README.md`, source manifest, generated artifacts, helper
  scripts, or unrelated historical untracked files.
- Keep the current main workspace and preserve unrelated user changes.
- The completed route count changes from `88` to `93`.
- Enable only the five existing preview records for this batch.
- Package modifications require a focused package regression test and a
  separate package commit.

---

## File Map

Create:

- `example/lib/pages/components_d/cate_tab_page.dart`: follow and tab demos.
- `example/lib/pages/components_d/select_page.dart`: anchored select demo.
- `example/lib/pages/components_d/pagination_page.dart`: page and size demos.
- `example/lib/pages/components_d/tree_page.dart`: nested selectable tree.
- `example/lib/pages/components_d/dragsort_page.dart`: real reorder demo.

Modify:

- `example/test/components_d_pages_test.dart`: five focused page tests.
- `example/lib/routes/example_catalog.dart`: five imports, route records, and
  builders.
- `example/lib/routes/example_preview_catalog.dart`: five availability flags.
- `example/test/route_catalog_test.dart`: route count, order, preview, and
  Components D smoke assertions.

Modify only if reproduced by a focused test:

- One affected file under `packages/ultra_ui/lib/src/widgets/`.
- The corresponding focused test area in `packages/ultra_ui/test/widgets_test.dart`.

No source manifest file should be edited because all five source records
already exist.

## Task 1: Add CateTab Page and Focused Test

**Files:**

- Create: `example/lib/pages/components_d/cate_tab_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const CateTabPage()`.
- Root key: `example-page-componentsD/cateTab/cateTab`.
- Demo keys: `cate-tab-page-follow`, `cate-tab-page-tab`.
- Uses `UPCateTab` with `tabList`, `mode`, `current`, and `onChange`.

- [ ] **Step 1: Add the failing CateTab test**

Append this test:

```dart
testWidgets('cate tab page switches local categories', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const CateTabPage(),
    ),
  );

  expect(
    find.byKey(const ValueKey('example-page-componentsD/cateTab/cateTab')),
    findsOneWidget,
  );
  expect(find.byKey(const ValueKey('cate-tab-page-follow')), findsOneWidget);
  expect(find.byKey(const ValueKey('cate-tab-page-tab')), findsOneWidget);
  expect(find.text('食品'), findsWidgets);
  expect(find.text('米饭'), findsOneWidget);

  final follow = find.byKey(const ValueKey('cate-tab-page-follow'));
  await tester.tap(
    find.descendant(
      of: follow,
      matching: find.byKey(const ValueKey('up-cate-tab-left-1')),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('当前分类：饮料'), findsOneWidget);
  expect(find.text('分类变化次数：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the test and verify it fails**

Run from `example`:

```text
flutter test test/components_d_pages_test.dart --plain-name "cate tab page switches local categories" --reporter expanded
```

Expected: FAIL because `CateTabPage` does not exist.

- [ ] **Step 3: Implement `CateTabPage`**

Use deterministic data:

```dart
const List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': '食品',
    'children': <Map<String, String>>[
      <String, String>{'name': '米饭'},
      <String, String>{'name': '面条'},
    ],
  },
  <String, dynamic>{
    'name': '饮料',
    'children': <Map<String, String>>[
      <String, String>{'name': '可乐'},
      <String, String>{'name': '果汁'},
    ],
  },
  <String, dynamic>{
    'name': '水果',
    'children': <Map<String, String>>[
      <String, String>{'name': '苹果'},
      <String, String>{'name': '香蕉'},
    ],
  },
];
```

Create a `StatefulWidget` with `_followIndex`, `_followChanges`,
`_tabIndex`, and `_tabChanges`. Render two `ExampleDemoBlock`s:

```dart
UPCateTab(
  key: const ValueKey('cate-tab-page-follow'),
  mode: 'follow',
  height: '320px',
  tabList: _categories,
  current: _followIndex,
  onChange: (index) => setState(() {
    _followIndex = index;
    _followChanges += 1;
  }),
)
```

Use a second `UPCateTab` with `key: ValueKey('cate-tab-page-tab')`,
`mode: 'tab'`, and its own state. Put
`当前分类：...` and `分类变化次数：...` below the follow widget.
Use `ExamplePageScaffold` with the required root key.

- [ ] **Step 4: Format and run the focused test**

Run:

```text
dart format lib/pages/components_d/cate_tab_page.dart test/components_d_pages_test.dart
flutter test test/components_d_pages_test.dart --plain-name "cate tab page switches local categories" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the CateTab page**

```text
git add -- example/lib/pages/components_d/cate_tab_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add cate tab page"
```

## Task 2: Add Select and Pagination Pages and Tests

**Files:**

- Create: `example/lib/pages/components_d/select_page.dart`
- Create: `example/lib/pages/components_d/pagination_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const SelectPage()` and `const PaginationPage()`.
- Root keys:
  `example-page-componentsD/select/select` and
  `example-page-componentsD/pagination/pagination`.
- Demo keys:
  `select-page-basic`, `select-page-trigger`,
  `pagination-page-basic`, and `pagination-page-sized`.

- [ ] **Step 1: Add failing Select and Pagination tests**

Append:

```dart
testWidgets('select page opens and selects an option', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const SelectPage(),
    ),
  );

  await tester.tap(find.byKey(const ValueKey('select-page-trigger')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('up-select-options-panel')), findsOneWidget);
  expect(find.text('选项二'), findsOneWidget);
  await tester.tap(find.text('选项二'));
  await tester.pumpAndSettle();
  expect(find.text('当前选择：选项二'), findsOneWidget);
  expect(find.byKey(const ValueKey('up-select-options-panel')), findsNothing);
});

testWidgets('pagination page changes page and page size', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const PaginationPage(),
    ),
  );

  expect(find.byKey(const ValueKey('pagination-page-basic')), findsOneWidget);
  await tester.tap(find.text('2').first);
  await tester.pump();
  expect(find.text('当前页：2'), findsOneWidget);

  await tester.tap(find.text('20条/页'));
  await tester.pump();
  expect(find.text('每页：20'), findsOneWidget);
});
```

- [ ] **Step 2: Run both tests and verify they fail**

Run:

```text
flutter test test/components_d_pages_test.dart --plain-name "select page|pagination page" --reporter expanded
```

Expected: FAIL because the page classes are absent.

- [ ] **Step 3: Implement `SelectPage`**

Use a `StatefulWidget` with `_current = '1'` and `_selectCount`.
Use options:

```dart
const List<Map<String, String>> _options = <Map<String, String>>[
  {'id': '1', 'name': '选项一'},
  {'id': '2', 'name': '选项二'},
  {'id': '3', 'name': '选项三'},
];
```

Render:

```dart
UPSelect(
  key: const ValueKey('select-page-basic'),
  label: '请选择',
  current: _current,
  options: _options,
  border: true,
  showOptionsLabel: true,
  onSelect: (item) => setState(() {
    _current = '${item['id']}';
    _selectCount += 1;
  }),
  onUpdateCurrent: (value) => setState(() => _current = '$value'),
)
```

Wrap it in a keyed `KeyedSubtree`:

```dart
const KeyedSubtree(
  key: ValueKey('select-page-trigger'),
  child: ...
)
```

Because the trigger is stateful and cannot be a const child, use a runtime
`KeyedSubtree(key: ..., child: select)` in the page rather than a `const`
subtree. Render
`当前选择：${_labelFor(_current)}` and `选择次数：$_selectCount`.

- [ ] **Step 4: Implement `PaginationPage`**

Use a `StatefulWidget` with `_basicPage`, `_sizedPage`, and `_pageSize`.
Render:

```dart
UPPagination(
  key: const ValueKey('pagination-page-basic'),
  currentPage: _basicPage,
  total: 45,
  layout: 'prev, pager, next',
  onCurrentChange: (page) => setState(() => _basicPage = page),
)
```

and:

```dart
UPPagination(
  key: const ValueKey('pagination-page-sized'),
  currentPage: _sizedPage,
  pageSize: _pageSize,
  total: 100,
  pageSizes: const [10, 20],
  layout: 'total, sizes, prev, pager, next',
  onCurrentChange: (page) => setState(() => _sizedPage = page),
  onSizeChange: (size) => setState(() => _pageSize = size),
)
```

Render `当前页：$_basicPage`, `每页：$_pageSize`, and
`分页变化次数：...` labels under the blocks.

- [ ] **Step 5: Format and run focused tests**

Run:

```text
dart format lib/pages/components_d/select_page.dart lib/pages/components_d/pagination_page.dart test/components_d_pages_test.dart
flutter test test/components_d_pages_test.dart --plain-name "select page|pagination page" --reporter expanded
```

Expected: both tests pass. If the select panel is not found, inspect the
actual trigger subtree and use the public `UPSelect` overlay behavior; do not
replace it with a page-local dropdown.

- [ ] **Step 6: Commit Select and Pagination**

```text
git add -- example/lib/pages/components_d/select_page.dart example/lib/pages/components_d/pagination_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add select and pagination pages"
```

## Task 3: Add Tree and Dragsort Pages and Tests

**Files:**

- Create: `example/lib/pages/components_d/tree_page.dart`
- Create: `example/lib/pages/components_d/dragsort_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const TreePage()` and `const DragsortPage()`.
- Root keys:
  `example-page-componentsD/tree/tree` and
  `example-page-componentsD/dragsort/dragsort`.
- Demo keys:
  `tree-page-basic`, `tree-page-checkbox`, and `dragsort-page-basic`.

- [ ] **Step 1: Add failing Tree and Dragsort tests**

Append:

```dart
testWidgets('tree page expands and cascades checked children',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const TreePage(),
    ),
  );

  expect(find.text('子节点一'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('up-tree-checkbox-root')));
  await tester.pump();
  expect(find.text('已选：root,child-1,grandchild-1'), findsOneWidget);
  expect(find.text('禁用节点'), findsOneWidget);
});

testWidgets('dragsort page reorders with a real drag gesture',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const DragsortPage(),
    ),
  );

  final first = find.byKey(const ValueKey('dragsort-page-item-0'));
  final second = find.byKey(const ValueKey('dragsort-page-item-1'));
  expect(first, findsOneWidget);
  expect(second, findsOneWidget);
  await tester.drag(first, const Offset(0, 100));
  await tester.pumpAndSettle();
  expect(find.text('排序：第二项,第一项,第三项'), findsOneWidget);
});
```

- [ ] **Step 2: Run both tests and verify they fail**

Run:

```text
flutter test test/components_d_pages_test.dart --plain-name "tree page|dragsort page" --reporter expanded
```

Expected: FAIL because the page classes are absent.

- [ ] **Step 3: Implement `TreePage`**

Use a `StatefulWidget` with a stable tree `GlobalKey<UPTreeState>`, but let
the component own interaction state. Use data:

```dart
const List<Map<String, dynamic>> _treeData = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'root',
    'label': '根节点',
    'children': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'child-1',
        'label': '子节点一',
        'children': <Map<String, String>>[
          <String, String>{'id': 'grandchild-1', 'label': '孙节点一'},
        ],
      },
      <String, dynamic>{'id': 'child-2', 'label': '子节点二'},
      <String, dynamic>{
        'id': 'disabled',
        'label': '禁用节点',
        'disabled': true,
      },
    ],
  },
];
```

Render two blocks:

- basic tree using `defaultExpandAll: true`;
- checkbox tree using `showCheckbox: true`, `defaultExpandAll: true`,
  `defaultCheckedKeys: const []`, and `onCheckChange`/`onCheck`.

The checkbox tree uses a custom `nodeBuilder` only when needed to expose
stable labels; otherwise use default labels. Render the checked-key result
from `UPTreeState.getCheckedKeys()` after each callback, sorting it in the
source tree order before display.

Use a keyed checkbox wrapper supplied by the widget's
`up-tree-checkbox-root` key convention. The page test must tap the actual
checkbox finder rather than call a public state method directly.

- [ ] **Step 4: Implement `DragsortPage`**

Use a `StatefulWidget` with:

```dart
List<String> _items = <String>['第一项', '第二项', '第三项'];
int _dragChanges = 0;
```

Render:

```dart
UPDragSort(
  key: const ValueKey('dragsort-page-basic'),
  initialList: _items,
  direction: 'vertical',
  itemBuilder: (context, item, index) => Container(
    key: ValueKey('dragsort-page-item-$index'),
    padding: const EdgeInsets.all(16),
    child: Text('$item'),
  ),
  onDragEnd: (items) => setState(() {
    _items = items.cast<String>();
    _dragChanges += 1;
  }),
)
```

Because `UPDragSort` uses `ReorderableListView` for vertical mode, keep the
page content bounded enough for the test viewport and use a visible result
line below it. The page must keep `initialList` stable with the current list
state so callback results re-render in source order.

- [ ] **Step 5: Format and run focused tests**

Run:

```text
dart format lib/pages/components_d/tree_page.dart lib/pages/components_d/dragsort_page.dart test/components_d_pages_test.dart
flutter test test/components_d_pages_test.dart --plain-name "tree page|dragsort page" --reporter expanded
```

Expected: both tests pass. If the drag finder key moves after reorder, keep
the visible item keys stable by keying the item content with the item identity
instead of using coordinate-only assertions.

- [ ] **Step 6: Commit Tree and Dragsort**

```text
git add -- example/lib/pages/components_d/tree_page.dart example/lib/pages/components_d/dragsort_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add tree and dragsort pages"
```

## Task 4: Register Routes, Enable Previews, and Extend Route Tests

**Files:**

- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**

- Consumes the five page classes from Tasks 1-3.
- Produces five route records after the Batch 1 Components D routes.
- Preserves all Components A-C and Batch 1 route order.

- [ ] **Step 1: Add route contract assertions**

In `route_catalog_test.dart`:

- change `expect(exampleRoutes, hasLength(88));` to
  `expect(exampleRoutes, hasLength(93));`;
- expand the Components D route ID list to:

```dart
const List<String> componentDRouteIds = <String>[
  'componentsD/qrcode/qrcode',
  'componentsD/copy/copy',
  'componentsD/navbarMini/navbarMini',
  'componentsD/box/box',
  'componentsD/floatButton/floatButton',
  'componentsD/cateTab/cateTab',
  'componentsD/select/select',
  'componentsD/pagination/pagination',
  'componentsD/tree/tree',
  'componentsD/dragsort/dragsort',
];
```

- add the five source paths to the completed-path set;
- add the five source paths to the focused available-preview set;
- retain the Components D route smoke test and let it iterate over the
  expanded ten-route list.

Run:

```text
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
```

Expected: FAIL because the five new route records are not registered.

- [ ] **Step 2: Add imports, route records, and builders**

Add imports:

```dart
import '../pages/components_d/cate_tab_page.dart';
import '../pages/components_d/dragsort_page.dart';
import '../pages/components_d/pagination_page.dart';
import '../pages/components_d/select_page.dart';
import '../pages/components_d/tree_page.dart';
```

Add the five route records after
`componentsD/floatButton/floatButton` in the exact order defined above.
Add builders:

```dart
Widget _buildCateTab(BuildContext context) => const CateTabPage();
Widget _buildSelect(BuildContext context) => const SelectPage();
Widget _buildPagination(BuildContext context) => const PaginationPage();
Widget _buildTree(BuildContext context) => const TreePage();
Widget _buildDragsort(BuildContext context) => const DragsortPage();
```

- [ ] **Step 3: Enable only the five preview records**

Change `available: false` to `available: true` for:

```text
pages/componentsD/cateTab/cateTab
pages/componentsD/select/select
pages/componentsD/pagination/pagination
pages/componentsD/tree/tree
pages/componentsD/dragsort/dragsort
```

Do not reorder preview records or change group lengths.

- [ ] **Step 4: Format and run route regressions**

Run:

```text
dart format lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
flutter test test/route_catalog_test.dart --plain-name "route ids resolve to their registered catalog entries" --reporter expanded
flutter test test/route_catalog_test.dart --plain-name "every completed Components D source route renders a real page" --reporter expanded
```

Expected: all pass and the completed route count is `93`.

- [ ] **Step 5: Commit route registration**

```text
git add -- example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/route_catalog_test.dart
git commit -m "test(example): register components d batch 2 routes"
```

## Task 5: Run Full Validation and Handle Confirmed Package Gaps

**Files:**

- Modify only package widget/test files when a focused test proves a gap.

- [ ] **Step 1: Run all Components D focused tests**

From `example`:

```text
flutter test test/components_d_pages_test.dart --reporter expanded
```

Expected: all ten Components D page tests pass.

- [ ] **Step 2: Reproduce any package failure in isolation**

If a page test fails in package code, add the smallest corresponding
regression under `packages/ultra_ui/test/widgets_test.dart`, run that single
test to confirm failure, and identify whether the cause is package behavior or
page layout/test harness.

- [ ] **Step 3: Implement only a confirmed package fix**

Preserve existing public constructor names and callback contracts. Run the
focused package regression and the full package test suite after the fix.

- [ ] **Step 4: Run package validation**

From `packages/ultra_ui`:

```text
flutter test
flutter analyze
```

The package analyzer may report existing warnings/info; do not broaden this
batch to unrelated cleanup.

- [ ] **Step 5: Run example validation**

From `example`:

```text
flutter test
flutter analyze
```

Expected: all example tests pass and example analysis reports no issues.

- [ ] **Step 6: Build the Android debug artifact**

From `example`:

```text
flutter build apk --debug --target-platform android-arm64
```

Expected artifact:
`example/build/app/outputs/flutter-apk/app-debug.apk`.
Do not stage the build output.

- [ ] **Step 7: Review final diff and worktree**

From repository root:

```text
git diff --check
git status --short
git log -8 --oneline
git diff --name-only -- example/lib/pages/components_d example/lib/routes example/test/components_d_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets packages/ultra_ui/test/widgets_test.dart
```

Confirm only planned Batch 2 files are included in the new commits. Leave
README and unrelated historical files untouched. If a package gap was fixed,
commit it separately with:

```text
git commit -m "fix: preserve components d batch 2 widget behavior"
```

## Plan Self-Review

- Every page has a concrete focused test and explicit root/demo keys.
- Select verifies the real overlay, Tree verifies checkbox cascade, and
  Dragsort verifies a real gesture rather than a direct state call.
- Route count, source order, preview availability, and smoke rendering are
  covered.
- Package modifications remain conditional on reproduced failures.
- No source manifest or unrelated worktree files are included.
- Validation commands use the correct project working directories.
