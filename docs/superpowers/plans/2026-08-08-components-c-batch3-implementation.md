# Components C Batch 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the Flutter example pages and route coverage for the next five source-order Components C pages: Avatar, ReadMore, Layout, IndexList, and IndexList2.

**Architecture:** Keep the existing example-page pattern of `ExamplePageScaffold` plus `ExampleDemoBlock`. Reuse the package's existing `UP*` widgets, adding only focused package fixes if a page test proves a behavior gap. Keep deterministic index-list data in an example-only fixture shared by the two index pages; register `indexList2` as an internal route without adding a separate home preview row.

**Tech Stack:** Flutter SDK and Dart from the repository, Material 3 page shell, local `ultra_ui` package, `flutter_test`, `UP*` widgets, and the existing example route catalogs.

## Global Constraints

- Source of truth: `D:\Repos\xyito\open\uview-plus\src\pages.json` plus the corresponding files beneath `D:\Repos\xyito\open\uview-plus\src\pages`.
- Preserve source Chinese titles, source route order, representative default states, and interactive behavior with real `UP*` widgets.
- The batch scope is exactly `componentsC/avatar/avatar`, `componentsC/readMore/readMore`, `componentsC/layout/layout`, `componentsC/indexList/indexList`, and `componentsC/indexList/indexList2`.
- Every completed route has one dedicated non-placeholder page class and one catalog entry.
- `indexList2` is an internal available route and is not added as a separate home preview entry.
- Network image success is not part of the test contract; tests must remain deterministic when remote images fail.
- Do not add a generic demo-page framework, unrelated refactors, new network dependencies, or cleanup of historical scripts and generated files.
- Preserve the current modified `README.md`, historical untracked files, and unrelated working-tree changes.
- Use `dart format`, `flutter analyze`, and focused widget tests during implementation.

---

## File Structure

Create:

- `example/lib/pages/components_c/avatar_page.dart`: Avatar source demo sections and click result.
- `example/lib/pages/components_c/read_more_page.dart`: Long parsed content wrapped by `UPReadMore`.
- `example/lib/pages/components_c/layout_page.dart`: Five `UPRow`/`UPCol` layout sections.
- `example/lib/pages/components_c/index_list_page.dart`: Full-screen index list and navigation to IndexList2.
- `example/lib/pages/components_c/index_list2_page.dart`: Popup trigger and popup-hosted index list.
- `example/lib/pages/components_c/index_list_data.dart`: Immutable letters, contacts, and builders shared by both index pages.

Modify:

- `example/lib/routes/example_catalog.dart`: imports, five route records, five builder functions.
- `example/lib/routes/example_preview_catalog.dart`: availability flags for the four existing preview rows.
- `example/test/components_c_pages_test.dart`: five page-level widget tests.
- `example/test/route_catalog_test.dart`: Components C route order and preview availability expectations.

Modify only if focused tests identify a package behavior gap:

- The specific affected file under `packages/ultra_ui/lib/src/widgets/`.
- The corresponding focused test area in `packages/ultra_ui/test/widgets_test.dart`.

---

### Task 1: Add the Avatar Page

**Files:**
- Create: `example/lib/pages/components_c/avatar_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const AvatarPage()`.
- Adds route id `componentsC/avatar/avatar`, source path `pages/componentsC/avatar/avatar`, title `头像`, group `ExampleRouteGroup.componentsC`, and builder `_buildAvatar`.
- Uses `UPAvatar` and `UPAvatarGroup` without changing their public constructors.

- [ ] **Step 1: Write the failing page test**

Append a test named `avatar page renders source variants and reports clicks` to
`example/test/components_c_pages_test.dart`. Use the existing
`buildRouteUnderTest('componentsC/avatar/avatar')` helper and assert the source
section labels:

```dart
testWidgets('avatar page renders source variants and reports clicks',
    (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsC/avatar/avatar'),
  );

  expect(find.text('基础演示'), findsOneWidget);
  expect(find.text('头像形状'), findsOneWidget);
  expect(find.text('头像尺寸'), findsOneWidget);
  expect(find.text('图标头像'), findsOneWidget);
  expect(find.text('文字头像(自动背景色)'), findsOneWidget);
  expect(find.text('图片加载失败(显示默认头像)'), findsOneWidget);
  expect(find.text('头像组'), findsOneWidget);

  final group = tester.widget<UPAvatarGroup>(
    find.byKey(const ValueKey('avatar-page-group-wide')),
  );
  expect(group.urls, hasLength(7));
  expect(group.gap, 0.4);

  await tester.tap(find.byKey(const ValueKey('avatar-page-clickable')));
  await tester.pump();
  expect(find.text('点击次数：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify the route/page is missing**

Run from `example`:

```text
flutter test test/components_c_pages_test.dart --plain-name "avatar page renders source variants and reports clicks"
```

Expected: fail during compilation or route lookup because `AvatarPage` and
the new route entry do not exist.

- [ ] **Step 3: Implement the page**

Build `AvatarPage` with `ExamplePageScaffold(title: '头像')` and one
`ExampleDemoBlock` per source section. Use stable keys:

- `avatar-page-basic`
- `avatar-page-clickable`
- `avatar-page-group-wide`
- `avatar-page-group-tight`

Use the source album URLs for the image examples. For the failed image, use
the source `noExist.jpg` URL and keep the assertion independent of decoding.
Use `randomBgColor: true` and `colorIndex: 0` for the first text avatar, and
leave `colorIndex` unset for the remaining deterministic name-based colors.
Render click feedback as `点击次数：N` below the demos.

- [ ] **Step 4: Wire the route**

Add the page import beside the other Components C imports, add the route after
the existing Album route, and add:

```dart
Widget _buildAvatar(BuildContext context) => const AvatarPage();
```

- [ ] **Step 5: Format and run the focused test**

Run:

```text
dart format lib/pages/components_c/avatar_page.dart lib/routes/example_catalog.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "avatar page renders source variants and reports clicks"
```

Expected: PASS.

- [ ] **Step 6: Commit the task**

```text
git add example/lib/pages/components_c/avatar_page.dart example/lib/routes/example_catalog.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add avatar page"
```

---

### Task 2: Add the ReadMore Page

**Files:**
- Create: `example/lib/pages/components_c/read_more_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const ReadMorePage()`.
- Adds route id `componentsC/readMore/readMore`, source path `pages/componentsC/readMore/readMore`, title `阅读更多`, group `ExampleRouteGroup.componentsC`, and builder `_buildReadMore`.
- Uses `UPReadMore(showHeight: 200, toggle: true)` with `UPParse` as its child.

- [ ] **Step 1: Write the failing page test**

Add a test named `read more page expands and closes parsed content`:

```dart
testWidgets('read more page expands and closes parsed content', (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsC/readMore/readMore'),
  );
  await tester.pump(const Duration(milliseconds: 50));

  expect(find.text('状态：close'), findsOneWidget);
  expect(find.text('展开阅读全文'), findsOneWidget);

  await tester.tap(find.text('展开阅读全文'));
  await tester.pump();
  expect(find.text('状态：open'), findsOneWidget);
  expect(find.text('展开次数：1'), findsOneWidget);
  expect(find.text('收起'), findsOneWidget);

  await tester.tap(find.text('收起'));
  await tester.pump();
  expect(find.text('状态：close'), findsOneWidget);
  expect(find.text('收起次数：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "read more page expands and closes parsed content"
```

Expected: fail because `ReadMorePage` and its route are absent.

- [ ] **Step 3: Implement the page**

Use a `StatefulWidget` so the page can display `UPReadMoreState.status`,
open/close callback counts, and a stable page key. Declare
`final readMoreKey = GlobalKey<UPReadMoreState>();` in the state, pass it to
`UPReadMore(key: readMoreKey, ...)`, and use it for the load callback. The
child is:

```dart
UPReadMore(
  key: readMoreKey,
  showHeight: 200,
  toggle: true,
  onOpen: (_) => setState(() => openCount += 1),
  onClose: (_) => setState(() => closeCount += 1),
  child: UPParse(
    content: _content,
    tagStyle: const <String, String>{
      'p': 'color: #606266; line-height: 24px;',
    },
    onLoad: () => readMoreKey.currentState?.init(),
  ),
)
```

Keep the poem content long enough to exceed 200 logical pixels. Add keys:

- `read-more-page-widget`
- `read-more-page-status`

Read the `UPReadMoreState` from the key in the page build and render
`状态：close|open`, `展开次数：N`, and `收起次数：N`.

- [ ] **Step 4: Wire the route**

Add the import, route record after Avatar, and:

```dart
Widget _buildReadMore(BuildContext context) => const ReadMorePage();
```

- [ ] **Step 5: Format and run the focused test**

Run:

```text
dart format lib/pages/components_c/read_more_page.dart lib/routes/example_catalog.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "read more page expands and closes parsed content"
```

Expected: PASS. If the toggle is not present after the initial pump, use the
existing `UPReadMore.init()` lifecycle and pump the documented delayed layout
period; do not replace the component with a custom clipping implementation.

- [ ] **Step 6: Commit the task**

```text
git add example/lib/pages/components_c/read_more_page.dart example/lib/routes/example_catalog.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add read more page"
```

---

### Task 3: Add the Layout Page

**Files:**
- Create: `example/lib/pages/components_c/layout_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const LayoutPage()`.
- Adds route id `componentsC/layout/layout`, source path `pages/componentsC/layout/layout`, title `布局`, group `ExampleRouteGroup.componentsC`, and builder `_buildLayout`.
- Consumes `UPRow`/`UPCol` with source-compatible numeric `span`, `offset`, and `gutter` values.

- [ ] **Step 1: Write the failing page test**

Add a test named `layout page renders source layout sections and parameters`:

```dart
testWidgets('layout page renders source layout sections and parameters',
    (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsC/layout/layout'),
  );

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('分栏间隔'), findsOneWidget);
  expect(find.text('混合布局'), findsOneWidget);
  expect(find.text('分栏偏移'), findsOneWidget);
  expect(find.text('对齐方式'), findsOneWidget);

  final gutterRow = tester.widget<UPRow>(
    find.byKey(const ValueKey('layout-page-gutter-row')),
  );
  expect(gutterRow.gutter, 10);

  final offsetCol = tester.widget<UPCol>(
    find.byKey(const ValueKey('layout-page-offset-col')),
  );
  expect(offsetCol.span, 3);
  expect(offsetCol.offset, 3);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "layout page renders source layout sections and parameters"
```

Expected: fail because `LayoutPage` and its route are absent.

- [ ] **Step 3: Implement the page**

Create a small private `_DemoLayoutBlock` helper in the page file for the
25-pixel rounded color bars. Render the source combinations with stable keys:

- `layout-page-basic-row`
- `layout-page-gutter-row`
- `layout-page-mixed-row`
- `layout-page-offset-col`
- `layout-page-alignment-row`

Keep all `UPRow` and `UPCol` instances in the page tree so tests can inspect
their source parameters. Use `ExamplePageScaffold(title: '布局')` and the
source section titles verbatim.

- [ ] **Step 4: Wire the route**

Add the import, route record after ReadMore, and:

```dart
Widget _buildLayout(BuildContext context) => const LayoutPage();
```

- [ ] **Step 5: Format and run the focused test**

Run:

```text
dart format lib/pages/components_c/layout_page.dart lib/routes/example_catalog.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "layout page renders source layout sections and parameters"
```

Expected: PASS.

- [ ] **Step 6: Commit the task**

```text
git add example/lib/pages/components_c/layout_page.dart example/lib/routes/example_catalog.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add layout page"
```

---

### Task 4: Add Shared Index Data and the Full-Screen IndexList Page

**Files:**
- Create: `example/lib/pages/components_c/index_list_data.dart`
- Create: `example/lib/pages/components_c/index_list_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces immutable `indexListLetters`, `indexListNames`, `indexListUrls`, and
  `buildIndexListGroups()` values/functions used by both index pages.
- Produces `const IndexListPage()`.
- Adds route id `componentsC/indexList/indexList`, source path
  `pages/componentsC/indexList/indexList`, title `索引列表`, group
  `ExampleRouteGroup.componentsC`, and builder `_buildIndexList`.
- The page pushes `const IndexList2Page()` through a `MaterialPageRoute` when
  the `新的朋友` header row is tapped.

- [ ] **Step 1: Write the failing page test**

Add a test named `index list page renders contacts and opens popup page`:

```dart
testWidgets('index list page renders contacts and opens popup page',
    (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsC/indexList/indexList'),
  );

  expect(find.text('新的朋友'), findsOneWidget);
  expect(find.text('标签'), findsOneWidget);
  expect(find.text('朋友圈'), findsOneWidget);
  expect(find.text('QQ'), findsOneWidget);
  expect(find.text('共305位好友'), findsOneWidget);
  expect(find.text('A'), findsWidgets);
  expect(find.text('#'), findsWidgets);

  final indexList = tester.state<UPIndexListState>(
    find.byKey(const ValueKey('index-list-page-widget')),
  );
  await indexList.jumpToLetter('C');
  await tester.pump();
  expect(indexList.activeLetter, 'C');

  final newFriend = find.byKey(
    const ValueKey('index-list-page-new-friend'),
  );
  await tester.ensureVisible(newFriend);
  await tester.tap(newFriend);
  await tester.pumpAndSettle();
  expect(find.text('索引列表(弹窗)'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "index list page renders contacts and opens popup page"
```

Expected: fail because the route, fixture, and page are absent.

- [ ] **Step 3: Implement deterministic index data**

In `index_list_data.dart`, define:

```dart
const List<String> indexListLetters = <String>[
  '↑', '☆', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
  'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', '#',
];

const List<String> indexListNames = <String>[
  '勇往无敌', '疯狂的迪飙', '磊爱可', '梦幻梦幻梦',
  '枫中飘瓢', '飞翔天使', '曾经第一', '追风幻影族长',
  '麦小姐', '胡格罗雅', 'Red磊磊', '乐乐立立',
  '青龙爆风', '跑跑卡叮车', '山里狼', 'supersonic超',
];
```

Add fixed source album URLs and these exact fixture types:

```dart
class IndexListContact {
  const IndexListContact({required this.name, required this.url});

  final String name;
  final String url;
}

List<List<IndexListContact>> buildIndexListGroups() {
  return List<List<IndexListContact>>.generate(
    indexListLetters.length,
    (groupIndex) => List<IndexListContact>.generate(
      10,
      (itemIndex) {
        final name = indexListNames[
            (groupIndex * 10 + itemIndex) % indexListNames.length];
        final url = indexListUrls[
            (groupIndex + itemIndex) % indexListUrls.length];
        return IndexListContact(name: name, url: url);
      },
    ),
  );
}
```

The helper returns new lists so the widgets cannot mutate the constants.

- [ ] **Step 4: Implement the page**

Build the header, grouped `UPIndexItem` list, and footer. Use:

- `UPIndexList(key: const ValueKey('index-list-page-widget'), indexList: indexListLetters, ...)`
- `UPIndexAnchor(text: letter)`
- `UPAvatar(shape: 'square', size: 35, ...)` for header icons
- `UPImage(width: 35, height: 35, shape: 'square', radius: 3, ...)` for contacts

Give the tappable header row the key
`index-list-page-new-friend`. Use a `ScrollController` only through
`UPIndexList`; do not add a second controller in the page.

- [ ] **Step 5: Wire the route**

Add the import, route record after Layout, and:

```dart
Widget _buildIndexList(BuildContext context) => const IndexListPage();
```

- [ ] **Step 6: Format and run the focused test**

Run:

```text
dart format lib/pages/components_c/index_list_data.dart lib/pages/components_c/index_list_page.dart lib/routes/example_catalog.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "index list page renders contacts and opens popup page"
```

Expected: PASS.

- [ ] **Step 7: Commit the task**

```text
git add example/lib/pages/components_c/index_list_data.dart example/lib/pages/components_c/index_list_page.dart example/lib/routes/example_catalog.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add index list page"
```

---

### Task 5: Add the Popup-Hosted IndexList2 Page

**Files:**
- Create: `example/lib/pages/components_c/index_list2_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Produces `const IndexList2Page()`.
- Adds route id `componentsC/indexList/indexList2`, source path
  `pages/componentsC/indexList/indexList2`, title `索引列表(弹窗)`, group
  `ExampleRouteGroup.componentsC`, and builder `_buildIndexList2`.
- Uses `UPPopup(show: bool, mode: 'bottom', safeAreaInsetBottom: false,
  onUpdateShow: ValueChanged<bool>, child: Widget)`.

- [ ] **Step 1: Write the failing popup test**

Add a test named `index list2 page opens and closes its popup`:

```dart
testWidgets('index list2 page opens and closes its popup', (tester) async {
  await tester.pumpWidget(
    buildRouteUnderTest('componentsC/indexList/indexList2'),
  );

  expect(find.text('打开弹窗'), findsOneWidget);
  expect(find.byKey(const ValueKey('index-list2-page-content')), findsNothing);

  await tester.tap(find.byKey(const ValueKey('index-list2-page-open')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('index-list2-page-content')), findsOneWidget);
  expect(find.text('共305位好友'), findsOneWidget);

  final popup = tester.state<UPPopupState>(
    find.byKey(const ValueKey('index-list2-page-popup')),
  );
  popup.close();
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('index-list2-page-content')), findsNothing);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "index list2 page opens and closes its popup"
```

Expected: fail because `IndexList2Page` and its route are absent.

- [ ] **Step 3: Implement the page**

Use a `StatefulWidget` with `_show` state. The open button must have key
`index-list2-page-open`; the `UPPopup` must have key
`index-list2-page-popup`; and the popup's fixed-height child must have key
`index-list2-page-content`.

Reuse the shared index-list fixture and reproduce the same header/contact/footer
structure in this page. Keep the page-local builders small and private; only
the data is shared between the two pages. Wrap the popup child in
`SizedBox(height: 600)` and keep `safeAreaInsetBottom: false`. Let the popup's
`onUpdateShow` synchronize the page's `_show` state.

- [ ] **Step 4: Wire the route**

Add the import, route record after the full-screen IndexList route, and:

```dart
Widget _buildIndexList2(BuildContext context) => const IndexList2Page();
```

- [ ] **Step 5: Format and run the focused test**

Run:

```text
dart format lib/pages/components_c/index_list2_page.dart lib/routes/example_catalog.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "index list2 page opens and closes its popup"
```

Expected: PASS.

- [ ] **Step 6: Commit the task**

```text
git add example/lib/pages/components_c/index_list2_page.dart example/lib/routes/example_catalog.dart example/test/components_c_pages_test.dart
git commit -m "feat(example): add index list popup page"
```

---

### Task 6: Update Preview Availability and Route Regression Tests

**Files:**
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Existing preview paths
  `pages/componentsC/layout/layout`,
  `pages/componentsC/indexList/indexList`,
  `pages/componentsC/readMore/readMore`, and
  `pages/componentsC/avatar/avatar` have `available: true`.
- `componentPreviewRoutes` retains its existing group order and does not gain a
  new `indexList2` row.
- The Components C route assertion contains, in order:
  `form`, `textarea`, `noNetwork`, `loadmore`, `text`, `steps`, `navbar`,
  `skeleton`, `input`, `album`, `avatar`, `readMore`, `layout`, `indexList`,
  `indexList2`.

- [ ] **Step 1: Update availability flags**

Change only the four existing preview entries from `available: false` to
`available: true`. Do not reorder the preview catalog or add
`pages/componentsC/indexList/indexList2`.

- [ ] **Step 2: Update route catalog expectations**

Change the expected Components C route list to the exact 15-item sequence
listed in the Interfaces section. Extend any completed-source-path assertions
with the four preview paths now backed by registered routes. Keep the existing
uniqueness and `available == completedSourcePaths.contains(...)` checks.

- [ ] **Step 3: Run route regression tests**

Run:

```text
flutter test test/route_catalog_test.dart
```

Expected: PASS, including the exact group order and preview availability
invariants.

- [ ] **Step 4: Commit the catalog changes**

```text
git add example/lib/routes/example_preview_catalog.dart example/test/route_catalog_test.dart
git commit -m "test(example): register components c batch 3 routes"
```

---

### Task 7: Handle Focused Package Gaps and Run Full Validation

**Files:**
- Modify only the affected file under `packages/ultra_ui/lib/src/widgets/`
  when a focused example test proves a package behavior gap.
- Modify: `packages/ultra_ui/test/widgets_test.dart` only when such a package
  fix is required.
- Modify: `example/test/components_c_pages_test.dart` only for assertions
  clarified by the implemented behavior.

**Interfaces:**
- Preserve all existing public constructors and callback names.
- Any package fix must have a focused widget test and must not alter unrelated
  widget behavior.

- [ ] **Step 1: Run all example tests**

Run from the repository root:

```text
flutter test example
```

Expected: all existing and new example tests pass. If a failure identifies a
package behavior gap, isolate that gap before editing the package.

- [ ] **Step 2: Add a focused package regression test only for a confirmed gap**

Place the test beside the existing related coverage in
`packages/ultra_ui/test/widgets_test.dart`. Assert the exact source behavior
that failed in the example, such as:

```dart
testWidgets('index list jump emits the selected letter', (tester) async {
  dynamic selected;
  final stateKey = GlobalKey<UPIndexListState>();
  await tester.pumpWidget(
    MaterialApp(
      home: SizedBox(
        height: 500,
        child: UPIndexList(
          key: stateKey,
          indexList: const <String>['A', 'B', 'C'],
          onSelect: (value) => selected = value,
          children: const <UPIndexItem>[],
        ),
      ),
    ),
  );

  await stateKey.currentState!.jumpToLetter('C');
  expect(selected, 'C');
});
```

Use the smallest equivalent test for the actual confirmed gap; do not add
speculative coverage.

- [ ] **Step 3: Implement the minimal package fix if required**

Change only the affected widget implementation, preserving its existing API
and source-compatible state/callback aliases. Run the new focused package test
before rerunning the example test that exposed the issue.

- [ ] **Step 4: Run package tests and analysis**

Run:

```text
flutter test packages/ultra_ui
flutter analyze packages/ultra_ui
```

Expected: package tests pass. Analyze may report existing baseline warnings or
infos, but no new batch-specific errors.

- [ ] **Step 5: Run example analysis and build**

Run:

```text
flutter analyze example
flutter build apk --debug --target-platform android-arm64
```

Expected: example analysis is clean and the debug APK is generated.

- [ ] **Step 6: Review the diff and working tree**

Run:

```text
git diff --check HEAD~1..HEAD
git status --short
git log -5 --oneline
```

Confirm that the batch commits contain only the specified implementation,
route, test, and necessary package files. Do not stage or revert the modified
`README.md` or unrelated historical untracked files.

- [ ] **Step 7: Commit only confirmed validation fixes**

If no package gap or test-only adjustment was found, make no extra commit. If
one was required, inspect the exact paths first:

```text
git diff --name-only -- packages/ultra_ui/lib/src/widgets packages/ultra_ui/test/widgets_test.dart example/test/components_c_pages_test.dart
```

Stage only the paths printed by that command that belong to the confirmed
fix, then commit them with:

```text
git commit -m "fix: preserve components c widget behavior"
```
