# Components C Batch 4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the next five source-order Components C example pages: Tooltip, Guide, Popover, Tabs, and List.

**Architecture:** Keep one dedicated page file per route under `example/lib/pages/components_c/`, using `ExamplePageScaffold` and `ExampleDemoBlock`. Reuse the existing `UPTooltip`, `UPGuide`, `UPPopover`, `UPTabs`, `UPList`, `UPListItem`, `UPCell`, `UPAvatar`, `UPButton`, `UPSticky`, and `UPBadge` widgets. Use fixed local data and the existing `assets/uview/common/logo.png`; do not introduce a generic demo abstraction or network dependency.

**Tech Stack:** Flutter SDK, Dart, Material 3 page shell, local `ultra_ui` package, `flutter_test`, and the existing example route catalogs.

## Global Constraints

- Source of truth: `D:\Repos\xyito\open\uview-plus\src\pages\pages.json` and the five corresponding source pages under `src/pages/componentsC`.
- Batch scope is exactly `componentsC/tooltip/tooltip`, `componentsC/guide/guide`, `componentsC/popover/popover`, `componentsC/tabs/tabs`, and `componentsC/list/list`.
- Preserve source Chinese titles, section labels, source-order route registration, representative defaults, and principal interactions.
- Keep all image data local and deterministic; do not make network image success a test condition.
- Preserve all existing public package constructors and callback names. Modify package code only after a focused example test proves a package behavior gap.
- Do not add a generic demo-page framework, new network or persistence dependency, or unrelated refactor.
- Do not clean, revert, stage, or commit the existing modified `README.md`, generated artifacts, helper scripts, or other historical untracked files.
- Work in the current approved `main` workspace; do not create another worktree.
- Use `dart format`, focused widget tests, `flutter analyze`, full tests, and Android debug build verification before completion.

## Source and Test Matrix

| Source route | Flutter page | Required behavior | Stable page key |
| --- | --- | --- | --- |
| `pages/componentsC/tooltip/tooltip` | `TooltipPage` | Open source tooltip variants, invoke an extension action, and keep singleton/custom-content behavior. | `example-page-componentsC/tooltip/tooltip` |
| `pages/componentsC/guide/guide` | `GuidePage` | First entry opens a three-page guide; next, finish, reset, and reopen work. | `example-page-componentsC/guide/guide` |
| `pages/componentsC/popover/popover` | `PopoverPage` | Right and left/forced-position popovers open from real triggers and close. | `example-page-componentsC/popover/popover` |
| `pages/componentsC/tabs/tabs` | `TabsPage` | Current selection changes, disabled tabs remain inert, badges and shape variants render. | `example-page-componentsC/tabs/tabs` |
| `pages/componentsC/list/list` | `ListPage` | Fixed list rows render and a lower-edge event appends the next deterministic batch. | `example-page-componentsC/list/list` |

---

### Task 1: Implement the Tooltip Page

**Files:**
- Create: `example/lib/pages/components_c/tooltip_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const TooltipPage()`.
- Uses existing `UPTooltip` callbacks and trigger modes without package API changes.
- Exposes keys `tooltip-page-extension`, `tooltip-page-custom-trigger`, and `tooltip-page-custom` for focused tests.

- [ ] **Step 1: Add the failing behavior test**

Append this test to `example/test/components_c_pages_test.dart`:

```dart
testWidgets(
  'tooltip page opens custom trigger and records extension action',
  (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsC/tooltip/tooltip'),
    );

    expect(find.text('基础使用'), findsOneWidget);
    expect(find.text('单例打开'), findsOneWidget);
    expect(find.text('自定义触发器'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('tooltip-page-custom-trigger')),
    );
    await tester.pump();
    expect(find.text('自定义内容'), findsOneWidget);

    final extension = tester.state<UPTooltipState>(
      find.byKey(const ValueKey('tooltip-page-extension')),
    );
    extension.open();
    await tester.pump();
    await tester.tap(find.text('扩展').last);
    await tester.pump();
    expect(find.text('扩展点击：1'), findsOneWidget);
  },
);
```

Add the `UPTooltipState` package import only if it is not already available
through the existing `ultra_ui` import.

- [ ] **Step 2: Run the focused test and verify it fails**

Run from `example`:

```text
flutter test test/components_c_pages_test.dart --plain-name "tooltip page opens custom trigger and records extension action" --reporter expanded
```

Expected: FAIL because `componentsC/tooltip/tooltip` is not yet registered and
`TooltipPage` does not exist.

- [ ] **Step 3: Implement `TooltipPage`**

Create a `StatefulWidget` with root key
`example-page-componentsC/tooltip/tooltip`. Use `ExamplePageScaffold(title: '长按提示',
child: ...)` and eight `ExampleDemoBlock`s with these exact titles:

```text
基础使用
下方显示
扩展按钮
自动调整位置
高亮选中文本背景色
单例打开
自定义触发器
左侧弹出
```

Use the following source-aligned widget configuration:

- Basic: `UPTooltip(text: '长按文本，上方提示', overlay: true)`.
- Bottom: `UPTooltip(text: '长按文本，下方提示', direction: 'bottom')`.
- Extension: key the widget `tooltip-page-extension`, set
  `text: '显示多个扩展按钮'`, `buttons: const ['扩展']`, `showCopy: false`,
  and update `_extensionClicks` from `onClick`.
- Automatic position: use `buttons: const ['扩展', '搜索', '翻译']`.
- Highlight: use click trigger, `bgColor: '#e3e4e6'`, and the three buttons.
- Singleton: render two click-triggered `UPTooltip`s with `singleton: true`.
- Custom trigger: key the `UPTooltip` `tooltip-page-custom`, pass a keyed
  `UPButton` trigger through `child` with key
  `tooltip-page-custom-trigger`, set `triggerMode: 'click'`, `direction: 'right'`,
  `bgColor: '#e3e4e6'`, `popupBgColor: '#f7f7f7'`, and `content: const Padding(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12), child:
  Text('自定义内容'))`.
- Left: use a click-triggered keyed button, `direction: 'left'`, dark popup
  colors, and `forcePosition: const {'right': '108px', 'top': '0px'}`.

Show `扩展点击：$_extensionClicks` beneath the extension block. Keep callback
state local and use `setState` only when mounted.

- [ ] **Step 4: Format and rerun the focused test**

Run:

```text
dart format lib/pages/components_c/tooltip_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "tooltip page opens custom trigger and records extension action" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the Tooltip page**

```text
git add -- example/lib/pages/components_c/tooltip_page.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add tooltip page"
```

---

### Task 2: Implement the Guide Page

**Files:**
- Create: `example/lib/pages/components_c/guide_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const GuidePage()`.
- Uses `UPGuide` with `storageKey: 'components-c-batch4-guide'`, `once: true`,
  and the existing local logo asset.
- Exposes key `guide-page-widget`, `guide-page-open`, and `guide-page-reset`.

- [ ] **Step 1: Add the failing guide behavior test**

Append:

```dart
testWidgets('guide page runs the first-entry flow and can reset it',
    (tester) async {
  const storageKey = 'components-c-batch4-guide';
  UPGuide.clearRemembered(storageKey);
  addTearDown(() => UPGuide.clearRemembered(storageKey));

  await tester.pumpWidget(buildRouteUnderTest('componentsC/guide/guide'));
  await tester.pump();

  final guide = tester.state<UPGuideState>(
    find.byKey(const ValueKey('guide-page-widget')),
  );
  expect(guide.isOpen, isTrue);
  expect(find.text('欢迎使用 uview-plus'), findsOneWidget);

  await tester.tap(find.text('下一步'));
  await tester.pump(const Duration(milliseconds: 320));
  expect(find.text('引导页支持多页滑动'), findsOneWidget);

  await tester.tap(find.text('下一步'));
  await tester.pump(const Duration(milliseconds: 320));
  expect(find.text('只显示一次'), findsOneWidget);

  await tester.tap(find.text('立即体验'));
  await tester.pump();
  expect(guide.isOpen, isFalse);
  expect(find.text('完成次数：1'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('guide-page-reset')));
  await tester.pump();
  expect(find.text('重置次数：1'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('guide-page-open')));
  await tester.pump();
  expect(guide.isOpen, isTrue);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "guide page runs the first-entry flow and can reset it" --reporter expanded
```

Expected: FAIL because the route and page are absent.

- [ ] **Step 3: Implement `GuidePage`**

Create a `StatefulWidget` with root key
`example-page-componentsC/guide/guide`. Use `ExamplePageScaffold(title: '首屏引导',
child: ...)`. Keep the action controls visible behind the guide overlay and
place the keyed `UPGuide` in the same page stack so it can cover the full
viewport.

Configure the guide as follows:

```dart
UPGuide(
  key: _guideKey,
  show: true,
  once: true,
  storageKey: 'components-c-batch4-guide',
  list: const [
    {
      'image': 'assets/uview/common/logo.png',
      'title': '欢迎使用 uview-plus',
      'desc': '一套跨端可复用的高质量组件库。',
    },
    {
      'image': 'assets/uview/common/logo.png',
      'title': '引导页支持多页滑动',
      'desc': '可配置跳过、下一步和立即体验。',
    },
    {
      'image': 'assets/uview/common/logo.png',
      'title': '只显示一次',
      'desc': '默认内置本地存储记忆能力。',
    },
  ],
  onChange: (index) => setState(() => _changeCount += 1),
  onSkip: () => setState(() => _skipCount += 1),
  onFinish: () => setState(() => _finishCount += 1),
)
```

The page's `重新打开引导` button calls `_guideKey.currentState?.open()` and
the `重置首次标记` button awaits
`_guideKey.currentState?.reset()` before incrementing the reset count. Render
the four counters as `变化次数：N`, `跳过次数：N`, `完成次数：N`, and
`重置次数：N`.

- [ ] **Step 4: Format and rerun the focused test**

Run:

```text
dart format lib/pages/components_c/guide_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "guide page runs the first-entry flow and can reset it" --reporter expanded
```

Expected: PASS. If the guide animation leaves a pending frame, add only the
fixed `pump(const Duration(milliseconds: 320))` already specified; do not use
unbounded settling for the guide flow.

- [ ] **Step 5: Commit the Guide page**

```text
git add -- example/lib/pages/components_c/guide_page.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add guide page"
```

---

### Task 3: Implement the Popover Page

**Files:**
- Create: `example/lib/pages/components_c/popover_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const PopoverPage()`.
- Uses `UPPopover` trigger/content slots and existing open/close callbacks.
- Exposes keys `popover-page-right`, `popover-page-right-trigger`, and
  `popover-page-left`.

- [ ] **Step 1: Add the failing popover behavior test**

Append:

```dart
testWidgets('popover page opens custom content and closes', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/popover/popover'));

  expect(find.text('右侧弹出'), findsOneWidget);
  expect(find.text('左侧弹出及强制定位'), findsOneWidget);
  expect(find.text('自定义内容'), findsNothing);

  await tester.tap(
    find.byKey(const ValueKey('popover-page-right-trigger')),
  );
  await tester.pump();
  expect(find.text('自定义内容'), findsOneWidget);
  expect(find.text('打开次数：1'), findsOneWidget);

  final popover = tester.state<UPPopoverState>(
    find.byKey(const ValueKey('popover-page-right')),
  );
  popover.close();
  await tester.pump();
  expect(find.text('自定义内容'), findsNothing);
  expect(find.text('关闭次数：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "popover page opens custom content and closes" --reporter expanded
```

Expected: FAIL because the route and page are absent.

- [ ] **Step 3: Implement `PopoverPage`**

Create a `StatefulWidget` with root key
`example-page-componentsC/popover/popover` and two `ExampleDemoBlock`s. Use
`ExamplePageScaffold(title: 'Popover弹窗', child: ...)`.

Configure the right popover with key `popover-page-right`, direction `right`,
the existing theme colors, a keyed `UPButton` child with key
`popover-page-right-trigger`, and `const Text('自定义内容')` content wrapped in
the source padding. Increment `打开次数` and `关闭次数` from `onOpen` and
`onClose`.

Configure the left popover with key `popover-page-left`, direction `left`,
dark text and popup colors, `forcePosition: const {'right': '108px', 'top': '0px'}`,
a keyed primary button, and the same custom content. Render status text below
the two blocks so it remains visible after the popup closes.

- [ ] **Step 4: Format and rerun the focused test**

Run:

```text
dart format lib/pages/components_c/popover_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "popover page opens custom content and closes" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the Popover page**

```text
git add -- example/lib/pages/components_c/popover_page.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add popover page"
```

---

### Task 4: Implement the Tabs Page

**Files:**
- Create: `example/lib/pages/components_c/tabs_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const TabsPage()`.
- Uses fixed `List<Map<String, dynamic>>` tab fixtures with `UPTabs`, `UPSticky`,
  `UPButton`, `UPIcon`, and `UPBadge` behavior supplied by the package.
- Exposes keys `tabs-page-basic`, `tabs-page-next`, and `tabs-page-disabled`.

- [ ] **Step 1: Add the failing tabs behavior test**

Append:

```dart
testWidgets('tabs page changes selection and renders source variants',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/tabs/tabs'));

  expect(find.text('基础演示'), findsOneWidget);
  expect(find.text('粘性布局'), findsOneWidget);
  expect(find.text('显示徽标'), findsOneWidget);
  expect(find.text('胶囊模式'), findsOneWidget);
  expect(find.text('卡片模式'), findsOneWidget);
  expect(find.text('圆角矩形箭头模式'), findsOneWidget);
  expect(find.text('Tag模式'), findsOneWidget);

  final basic = tester.state<UPTabsState>(
    find.byKey(const ValueKey('tabs-page-basic')),
  );
  basic.setCurrent(2);
  await tester.pump();
  expect(find.text('当前索引：2'), findsOneWidget);
  expect(find.text('点击次数：1'), findsOneWidget);

  final disabled = find.byKey(const ValueKey('tabs-page-disabled'));
  await tester.tap(find.descendant(of: disabled, matching: find.text('电影')));
  await tester.pump();
  expect(find.text('当前索引：2'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('tabs-page-next')));
  await tester.pump();
  expect(find.text('当前索引：3'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "tabs page changes selection and renders source variants" --reporter expanded
```

Expected: FAIL because the route and page are absent.

- [ ] **Step 3: Implement `TabsPage`**

Create a `StatefulWidget` with root key
`example-page-componentsC/tabs/tabs`. Define these fixed fixtures:

```dart
const baseTabs = <Map<String, dynamic>>[
  {'name': '关注'},
  {'name': '推荐'},
  {'name': '电影'},
  {'name': '科技'},
  {'name': '音乐'},
  {'name': '美食'},
  {'name': '文化'},
  {'name': '财经'},
  {'name': '手工'},
];

const badgeTabs = <Map<String, dynamic>>[
  {'name': '关注'},
  {'name': '推荐', 'badge': {'isDot': true}},
  {'name': '电影', 'badge': {'value': 5}},
  {'name': '科技'},
];

const disabledTabs = <Map<String, dynamic>>[
  {'name': '关注'},
  {'name': '推荐'},
  {'name': '电影', 'disabled': true},
  {'name': '科技'},
];
```

Render source sections using `UPTabs`:

- Basic key `tabs-page-basic`, `list: baseTabs`, `current: 3`, and
  `onChange` that updates `_current` and `_clickCount`.
- Sticky key `tabs-page-sticky` inside `UPSticky` with `baseTabs`.
- Badge key `tabs-page-badge` with `badgeTabs`.
- Non-scrollable key `tabs-page-non-scrollable` with four base items and
  `scrollable: false`.
- Disabled key `tabs-page-disabled` with `disabledTabs`.
- Custom style key `tabs-page-custom-style`, line width 30, line color
  `#f56c6c`, and explicit active/inactive style maps.
- Right-slot example with `right: const UPIcon(name: 'list', size: 21)` and a
  keyed small `UPButton` `tabs-page-next` whose text is `切换下一个`.
- Shape sections with `shapeMode: 'capsule'`, `'card'`, `'pill-arrow'`, and
  `'tag'`, using the source lists and `scrollable: false` where the source does.

Render `当前索引：$_current` and `点击次数：$_clickCount` below the basic
example. The next button wraps to index zero after the last enabled base item;
do not call `setCurrent` on a disabled item.

- [ ] **Step 4: Format and rerun the focused test**

Run:

```text
dart format lib/pages/components_c/tabs_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "tabs page changes selection and renders source variants" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the Tabs page**

```text
git add -- example/lib/pages/components_c/tabs_page.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add tabs page"
```

---

### Task 5: Implement the List Page

**Files:**
- Create: `example/lib/pages/components_c/list_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const ListPage()`.
- Uses `UPList(height: 520)` with `UPListItem`, `UPCell`, `UPAvatar`, and the
  existing local logo asset.
- Exposes key `list-page-widget` and status text `列表数量：N`.

- [ ] **Step 1: Add the failing list behavior test**

Append:

```dart
testWidgets('list page appends deterministic rows at the lower edge',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/list/list'));
  await tester.pump();

  expect(find.text('列表长度-1'), findsOneWidget);
  expect(find.text('列表长度-10'), findsOneWidget);
  expect(find.text('列表数量：10'), findsOneWidget);

  final list = tester.state<UPListState>(
    find.byKey(const ValueKey('list-page-widget')),
  );
  list.scrollToBottom();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 40));
  expect(find.text('列表长度-20'), findsOneWidget);
  expect(find.text('列表数量：20'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "list page appends deterministic rows at the lower edge" --reporter expanded
```

Expected: FAIL because the route and page are absent.

- [ ] **Step 3: Implement `ListPage`**

Create a `StatefulWidget` with root key
`example-page-componentsC/list/list` and use
`ExamplePageScaffold(title: '列表', scrollable: false, child: ...)`.

Maintain `_rows` as an integer count initialized to 10 and `_loadCount` as
zero. Build a fixed list of `UPListItem`s for indices `0` through `_rows - 1`.
Each item contains an `UPCell` with title `列表长度-${index + 1}` and a
`UPAvatar(shape: 'square', size: 35, src: 'assets/uview/common/logo.png')`
inside the cell's leading slot. Key the `UPList` as `list-page-widget` and set
`height: 520`, `lowerThreshold: 50`, and `onScrolltolower: _loadMore`.

`_loadMore` increments `_rows` and `_loadCount` by 10 until 30 rows, then
updates the status without adding more rows. Render `列表数量：$_rows` and
`加载次数：$_loadCount` below the list. Use `setState` only while mounted.

- [ ] **Step 4: Format and rerun the focused test**

Run:

```text
dart format lib/pages/components_c/list_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "list page appends deterministic rows at the lower edge" --reporter expanded
```

Expected: PASS. If the lower-edge callback's package delay is involved, keep
the explicit 40 ms pump from the test; do not replace the test with a random
wait or network load.

- [ ] **Step 5: Commit the List page**

```text
git add -- example/lib/pages/components_c/list_page.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add list page"
```

---

### Task 6: Register Routes, Enable Previews, and Update Catalog Tests

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Adds `TooltipPage`, `GuidePage`, `PopoverPage`, `TabsPage`, and `ListPage`
  imports and builders.
- Adds five `ExampleRoute` records after
  `componentsC/indexList/indexList2` in this exact order:
  `tooltip`, `guide`, `popover`, `tabs`, `list`.
- Enables the existing five preview rows without reordering the preview
  catalog or changing group lengths.

- [ ] **Step 1: Add the failing route catalog expectations**

Update the Components C expected list in `route_catalog_test.dart` to append:

```dart
'componentsC/tooltip/tooltip',
'componentsC/guide/guide',
'componentsC/popover/popover',
'componentsC/tabs/tabs',
'componentsC/list/list',
```

Change the completed route count from `70` to `75`, and add these paths to the
`completedSourcePaths` `containsAll` set:

```dart
'pages/componentsC/tooltip/tooltip',
'pages/componentsC/guide/guide',
'pages/componentsC/popover/popover',
'pages/componentsC/tabs/tabs',
'pages/componentsC/list/list',
```

Add a focused preview assertion:

```dart
expect(
  componentPreviewRoutes
      .where((route) => <String>{
        'pages/componentsC/tooltip/tooltip',
        'pages/componentsC/guide/guide',
        'pages/componentsC/popover/popover',
        'pages/componentsC/tabs/tabs',
        'pages/componentsC/list/list',
      }.contains(route.sourcePath))
      .every((route) => route.available),
  isTrue,
);
```

- [ ] **Step 2: Run route tests and verify they fail**

Run from `example`:

```text
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
```

Expected: FAIL because the new routes are not registered and their previews
are still unavailable.

- [ ] **Step 3: Wire the five route records**

Add imports for the five page files. Insert these route records immediately
after the existing `indexList2` record:

```dart
const ExampleRoute(
  id: 'componentsC/tooltip/tooltip',
  sourcePath: 'pages/componentsC/tooltip/tooltip',
  title: '长按提示',
  group: ExampleRouteGroup.componentsC,
  builder: _buildTooltip,
),
const ExampleRoute(
  id: 'componentsC/guide/guide',
  sourcePath: 'pages/componentsC/guide/guide',
  title: '首屏引导',
  group: ExampleRouteGroup.componentsC,
  builder: _buildGuide,
),
const ExampleRoute(
  id: 'componentsC/popover/popover',
  sourcePath: 'pages/componentsC/popover/popover',
  title: 'Popover弹窗',
  group: ExampleRouteGroup.componentsC,
  builder: _buildPopover,
),
const ExampleRoute(
  id: 'componentsC/tabs/tabs',
  sourcePath: 'pages/componentsC/tabs/tabs',
  title: '标签',
  group: ExampleRouteGroup.componentsC,
  builder: _buildTabs,
),
const ExampleRoute(
  id: 'componentsC/list/list',
  sourcePath: 'pages/componentsC/list/list',
  title: '列表',
  group: ExampleRouteGroup.componentsC,
  builder: _buildList,
),
```

Add builders with the existing `Widget _buildX(BuildContext context) =>
const XPage();` pattern. Use the exact source titles already used by each
page's `ExamplePageScaffold`.

- [ ] **Step 4: Enable only the five preview records**

Change `available: false` to `available: true` for these existing records in
`example_preview_catalog.dart`:

```text
pages/componentsC/tooltip/tooltip
pages/componentsC/guide/guide
pages/componentsC/popover/popover
pages/componentsC/tabs/tabs
pages/componentsC/list/list
```

Do not add an `indexList2` preview row, move any existing record, or change
`componentGroupLengths`.

- [ ] **Step 5: Format and run route regression tests**

Run:

```text
dart format lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
flutter test test/route_catalog_test.dart --plain-name "route ids resolve to their registered catalog entries" --reporter expanded
```

Expected: PASS.

- [ ] **Step 6: Commit route registration**

```text
git add -- example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/route_catalog_test.dart
git commit -m "test(example): register components c batch 4 routes"
```

---

### Task 7: Run Full Validation and Handle Confirmed Package Gaps

**Files:**
- No package files expected.
- Modify a specific file under `packages/ultra_ui/lib/src/widgets/` only if a
  focused page test demonstrates a behavior gap.
- Modify the corresponding focused test area in
  `packages/ultra_ui/test/widgets_test.dart` only for that confirmed gap.

**Interfaces:**
- All five pages use existing public package APIs.
- Any package change preserves constructor names, callback aliases, and
  unrelated widget behavior.

- [ ] **Step 1: Run all Components C tests**

From `example` run:

```text
flutter test test/components_c_pages_test.dart --reporter expanded
```

Expected: all existing Components C tests and the five new tests pass.

- [ ] **Step 2: Run formatting, analyzer, and full example tests**

From `example` run:

```text
dart format lib/pages/components_c/tooltip_page.dart lib/pages/components_c/guide_page.dart lib/pages/components_c/popover_page.dart lib/pages/components_c/tabs_page.dart lib/pages/components_c/list_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test
```

Expected: analyzer reports no issues and all example tests pass.

- [ ] **Step 3: Run package verification when package behavior is involved**

If no package source or package test file changed, retain the existing package
verification baseline and do not create a speculative package test. If a page
test did identify a package gap, first run its focused package regression, then
run:

```text
cd ..\packages\ultra_ui
flutter test
flutter analyze
```

The package analyzer may retain the repository's existing warnings or infos,
but it must report zero errors attributable to this batch.

- [ ] **Step 4: Build the Android debug artifact**

From `example` run:

```text
flutter build apk --debug --target-platform android-arm64
```

Expected: `example/build/app/outputs/flutter-apk/app-debug.apk` exists. Skip
the iOS build on the Windows host and report that it was not applicable.

- [ ] **Step 5: Review the final diff and worktree**

Run from the repository root:

```text
git diff --check
git status --short
git log -8 --oneline
git diff --name-only -- packages/ultra_ui/lib/src/widgets packages/ultra_ui/test/widgets_test.dart example/test/components_c_pages_test.dart
```

Confirm that only planned files from this batch are committed. Leave the
modified `README.md` and historical untracked files untouched. Do not stage
build outputs or generated artifacts.

- [ ] **Step 6: Commit only a confirmed validation fix**

If no package gap was found, make no extra validation commit. If a package gap
was confirmed, stage only the exact affected package implementation, its
focused package test, and any clarified example assertion, then commit:

```text
git commit -m "fix: preserve components c widget behavior"
```

Do not use this step for formatting-only or unrelated cleanup changes.
