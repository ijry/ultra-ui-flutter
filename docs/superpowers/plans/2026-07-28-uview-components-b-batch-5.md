# Components B Fifth Source-Order Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the next three registered Components B source routes after CountTo: Search, Badge, and Tag.

**Architecture:** Add one Flutter example page per source route under `example/lib/pages/components_b/`, register the pages in source order, and enable their preview rows. Use real `UPSearch`, `UPBadge`, and `UPTag` widgets. Add the source-compatible `UPSearch.clearable` alias while keeping existing `clearabled` callers working.

**Tech Stack:** Flutter `>=3.19.0`, Dart `>=3.3.0`, `flutter_test`, existing local `ultra_ui` package, Android/iOS only.

## Global Constraints

- Source of truth is `D:\Repos\xyito\open\uview-plus\src\pages.json` and the matching source files under `src/pages`.
- Preserve registered route order, exact source route title, visible Chinese labels, representative default state, and principal interaction.
- Use `UP*` widgets for each component demonstration. Do not substitute a Material control for the component being demonstrated.
- Do not use remote image resources at runtime; use existing local assets for source image icons.
- `ExampleRoute` entries are added only when a real source page exists. Set a preview route `available: true` only when its matching catalog builder is added.
- Preserve Flutter package names with `UP` prefixes and do not alter unrelated dirty worktree files.
- Every new behavior uses test-first implementation.
- Run `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, then install and launch the APK on MuMu `127.0.0.1:16384` at the batch boundary.

---

## File Structure

```text
example/lib/pages/components_b/search_page.dart       # Source Search sections
example/lib/pages/components_b/badge_page.dart        # Source Badge sections
example/lib/pages/components_b/tag_page.dart          # Source Tag sections
example/lib/routes/example_catalog.dart               # Adds three completed route builders
example/lib/routes/example_preview_catalog.dart       # Enables Search, Badge, Tag preview rows
example/test/components_b_pages_test.dart             # Adds page behavior tests
example/test/route_catalog_test.dart                  # Completed route count becomes 43
packages/ultra_ui/lib/src/widgets/up_search.dart      # Adds clearable alias and included widget
packages/ultra_ui/lib/src/widgets/up_badge.dart       # Included widget demonstrated by BadgePage
packages/ultra_ui/lib/src/widgets/up_tag.dart         # Included widget demonstrated by TagPage
packages/ultra_ui/test/widgets_test.dart              # Adds UPSearch alias component test
```

### Task 1: Add UPSearch clearable Alias

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_search.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- Adds nullable source alias:

```dart
final bool? clearable;
```

- `UPSearch` constructor accepts `this.clearable`.
- Clear icon visibility uses `clearable ?? clearabled`.

- [x] **Step 1: Write the failing component test**

Append near the existing `UPSearch action triggers onSearch` tests:

```dart
testWidgets('UPSearch clearable alias controls source clear icon',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPSearch(
          value: '天山雪莲',
          clearable: false,
          onlyClearableOnFocused: false,
        ),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (widget) => widget is UPIcon && widget.name == 'close',
    ),
    findsNothing,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPSearch(
          value: '天山雪莲',
          onlyClearableOnFocused: false,
        ),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (widget) => widget is UPIcon && widget.name == 'close',
    ),
    findsOneWidget,
  );
});
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPSearch clearable alias controls source clear icon" --reporter expanded
```

Expected: FAIL because `clearable` is not defined.

- [x] **Step 3: Implement the alias**

In `up_search.dart`, add `this.clearable,` after `this.clearabled = true,`.

Add field:

```dart
final bool? clearable;
```

Update `_showClear`:

```dart
if (!(widget.clearable ?? widget.clearabled) || _controller.text.isEmpty) {
  return false;
}
```

- [x] **Step 4: Run the component test green**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPSearch clearable alias controls source clear icon" --reporter expanded
```

Expected: PASS.

### Task 2: Add Search Source Page

**Files:**
- Create: `example/lib/pages/components_b/search_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_search.dart`

**Interfaces:**
- Produces `SearchPage` at route id `componentsB/search/search`.
- Uses page key `example-page-componentsB/search/search`.
- Uses real `UPSearch` widgets for all source blocks.

- [x] **Step 1: Write the failing Search page test**

Append to `example/test/components_b_pages_test.dart`:

```dart
testWidgets('search page edits basic source input and opens icon toast',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/search/search'));

  expect(find.text('基础功能'), findsOneWidget);
  final basicInput = find.descendant(
    of: find.byKey(const ValueKey('search-page-basic')),
    matching: find.byType(TextField),
  );
  await tester.enterText(basicInput, '关键词');
  await tester.pump();
  expect(find.text('关键词'), findsOneWidget);

  await tester.ensureVisible(find.byKey(const ValueKey('search-page-click-icon')));
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('search-page-click-icon')),
      matching: find.byWidgetPredicate(
        (widget) => widget is UPIcon && widget.name == 'search',
      ),
    ),
  );
  await tester.pump();
  expect(find.text('点击了左侧图标'), findsOneWidget);
  UPToast.hide();
});
```

Update `example/test/route_catalog_test.dart`:

```dart
expect(exampleRoutes, hasLength(41));
```

Extend the Components B source-order expectation through Search:

```dart
expect(
  componentBRoutes.take(14),
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
  ],
);
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "search page edits basic source input and opens icon toast" --reporter expanded
```

Expected: FAIL with unregistered route.

- [x] **Step 3: Implement SearchPage and register it**

Create `SearchPage` with 15 controlled string fields matching source values:

```dart
String _value1 = '';
String _value2 = '天山雪莲';
String _value3 = '';
String _value4 = '';
String _value5 = '';
String _value6 = '';
String _value7 = '';
String _value8 = '';
String _value9 = '';
String _value10 = '';
String _value11 = '';
String _value12 = '';
String _value13 = '';
String _value14 = '';
String _value15 = '';
```

Use `ExampleDemoBlock` for the ten source sections. Wrap each `UPSearch` in
`Padding(padding: EdgeInsets.only(top: ...))` when the source uses `m-t-10`.

Register after CountTo:

```dart
const ExampleRoute(
  id: 'componentsB/search/search',
  sourcePath: 'pages/componentsB/search/search',
  title: '搜索',
  group: ExampleRouteGroup.componentsB,
  builder: _buildSearch,
),
```

Add:

```dart
Widget _buildSearch(BuildContext context) => const SearchPage();
```

Set the matching preview route `pages/componentsB/search/search` to `available: true`.

- [x] **Step 4: Run Search tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "search page edits basic source input and opens icon toast" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 3: Add Badge Source Page

**Files:**
- Create: `example/lib/pages/components_b/badge_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_badge.dart`

**Interfaces:**
- Produces `BadgePage` at route id `componentsB/badge/badge`.
- Uses page key `example-page-componentsB/badge/badge`.
- Uses real `UPBadge` widgets for all source blocks.

- [x] **Step 1: Write the failing Badge page test**

Append:

```dart
testWidgets('badge page renders source limit number formats', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/badge/badge'));

  expect(find.text('徽标数显示方式'), findsOneWidget);
  expect(find.text('1.5k'), findsOneWidget);
  expect(find.text('4.51w'), findsOneWidget);
  expect(
    find.byKey(const ValueKey('example-page-componentsB/badge/badge')),
    findsOneWidget,
  );
});
```

Update route count and order through Badge:

```dart
expect(exampleRoutes, hasLength(42));
```

```dart
expect(componentBRoutes.take(15).last, 'componentsB/badge/badge');
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "badge page renders source limit number formats" --reporter expanded
```

Expected: FAIL with unregistered route.

- [x] **Step 3: Implement BadgePage and register it**

Create five `ExampleDemoBlock` sections with row/wrap layout:

```dart
Wrap(
  spacing: 40,
  runSpacing: 10,
  children: <Widget>[...],
)
```

Use source widgets:

```dart
const UPBadge(value: 1500, shape: 'horn')
const UPBadge(value: 5132, numberType: 'ellipsis')
const UPBadge(value: 1011, numberType: 'overflow')
const UPBadge(value: 1500, numberType: 'limit')
const UPBadge(value: 45187, numberType: 'limit')
const UPBadge(value: 1011, numberType: 'overflow', isDot: true)
const UPBadge(value: 9, type: 'error')
const UPBadge(value: 9, type: 'warning')
const UPBadge(value: 9, type: 'success')
const UPBadge(value: 9, type: 'primary')
const UPBadge(value: 9, type: 'error', inverted: true)
const UPBadge(value: 1532, type: 'warning', inverted: true)
const UPBadge(value: 12, type: 'success', inverted: true)
const UPBadge(value: 999, type: 'primary', inverted: true)
```

Register after Search and set preview `pages/componentsB/badge/badge` available.

- [x] **Step 4: Run Badge tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "badge page renders source limit number formats" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 4: Add Tag Source Page

**Files:**
- Create: `example/lib/pages/components_b/tag_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_tag.dart`

**Interfaces:**
- Produces `TagPage` at route id `componentsB/tag/tag`.
- Uses page key `example-page-componentsB/tag/tag`.
- Uses real `UPTag` widgets for all source blocks.
- Uses local `assets/uview/demo/cell/tag.png` for the source image icon.

- [x] **Step 1: Write the failing Tag page test**

Append:

```dart
testWidgets('tag page closes and toggles source selectable tags',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/tag/tag'));

  expect(find.text('可关闭标签'), findsOneWidget);
  expect(find.text('关闭状态：true,true,true'), findsOneWidget);
  await tester.tap(
    find
        .descendant(
          of: find.byKey(const ValueKey('tag-page-closeable')),
          matching: find.byWidgetPredicate(
            (widget) => widget is UPIcon && widget.name == 'close',
          ),
        )
        .first,
  );
  await tester.pumpAndSettle();
  expect(find.text('关闭状态：false,true,true'), findsOneWidget);

  await tester.ensureVisible(find.text('单选标签'));
  await tester.pump();
  await tester.tap(find.text('选项2').first);
  await tester.pumpAndSettle();
  expect(find.text('单选：2'), findsOneWidget);

  await tester.ensureVisible(find.text('多选标签'));
  await tester.pump();
  await tester.tap(find.text('选项3').last);
  await tester.pumpAndSettle();
  expect(find.text('多选：1,3'), findsOneWidget);
});
```

Update route count and order through Tag:

```dart
expect(exampleRoutes, hasLength(43));
```

```dart
expect(
  componentBRoutes.take(16),
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
  ],
);
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "tag page closes and toggles source selectable tags" --reporter expanded
```

Expected: FAIL with unregistered route.

- [x] **Step 3: Implement TagPage and register it**

Create `TagPage` state:

```dart
final List<bool> _close = <bool>[true, true, true];
int _radio = 0;
final List<bool> _checks = <bool>[true, false, false];
```

Render ten `ExampleDemoBlock` sections using wrap layout. The closeable section
uses `key: const ValueKey('tag-page-closeable')` and shows:

```dart
Text('关闭状态：${_close.join(',')}')
```

The radio section shows:

```dart
Text('单选：${_radio + 1}')
```

The checkbox section shows:

```dart
Text('多选：${_checks.asMap().entries.where((e) => e.value).map((e) => e.key + 1).join(',')}')
```

For the image tag, use:

```dart
UPTag(
  text: '标签',
  type: 'success',
  plain: true,
  size: 'large',
  iconWidget: Image.asset(
    'assets/uview/demo/cell/tag.png',
    width: 17,
    height: 17,
  ),
)
```

Register after Badge and set preview `pages/componentsB/tag/tag` available.

- [x] **Step 4: Run Tag tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "tag page closes and toggles source selectable tags" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 5: Batch Verification and Commit

**Files:**
- All files from Tasks 1-4.
- Modify this plan file to mark completed steps before staging.

**Interfaces:**
- Completed example route catalog has 43 routes: 4 main, 23 Components A, and 16 Components B.
- Search, Badge, and Tag preview rows are `available: true`; other unfinished preview rows remain unavailable.

- [x] **Step 1: Run formatting**

Run:

```powershell
cd example
dart format lib/pages/components_b/search_page.dart lib/pages/components_b/badge_page.dart lib/pages/components_b/tag_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
cd ..\packages\ultra_ui
dart format lib/src/widgets/up_search.dart lib/src/widgets/up_badge.dart lib/src/widgets/up_tag.dart test/widgets_test.dart
cd ..\..
git diff --check -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-5.md
```

- [x] **Step 2: Run targeted tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "search page edits basic source input and opens icon toast" --reporter expanded
flutter test test/components_b_pages_test.dart --plain-name "badge page renders source limit number formats" --reporter expanded
flutter test test/components_b_pages_test.dart --plain-name "tag page closes and toggles source selectable tags" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPSearch clearable alias controls source clear icon" --reporter expanded
```

- [x] **Step 3: Run full verification**

Run from `example`:

```powershell
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

Run from `packages\ultra_ui`:

```powershell
flutter test test/widgets_test.dart --reporter expanded
```

- [x] **Step 4: Install and launch on MuMu**

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

- [x] **Step 5: Commit only this batch**

Run:

```powershell
git diff --check -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-5.md example/lib/pages/components_b/search_page.dart example/lib/pages/components_b/badge_page.dart example/lib/pages/components_b/tag_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets/up_search.dart packages/ultra_ui/lib/src/widgets/up_badge.dart packages/ultra_ui/lib/src/widgets/up_tag.dart packages/ultra_ui/test/widgets_test.dart
git add -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-5.md example/lib/pages/components_b/search_page.dart example/lib/pages/components_b/badge_page.dart example/lib/pages/components_b/tag_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets/up_search.dart packages/ultra_ui/lib/src/widgets/up_badge.dart packages/ultra_ui/lib/src/widgets/up_tag.dart packages/ultra_ui/test/widgets_test.dart
git diff --cached --check
git commit -m "feat(example): add search badge tag source pages"
```

## Plan Self-Review

- Spec coverage: Tasks cover the three approved source routes, the `UPSearch.clearable` alias, route and preview enablement, tests, APK build, and MuMu launch.
- Placeholder scan: No deferred-detail markers or vague unimplemented steps remain.
- Type consistency: Route ids, source paths, page class names, builder names, and test names are consistent across tasks.
