# Components B Sixth Source-Order Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the next three registered Components B source routes after Tag: Alert, Switch, and Collapse.

**Architecture:** Add one Flutter example page per source route under `example/lib/pages/components_b/`, register the pages in source order, and enable their preview rows. Use real `UPAlert`, `UPSwitch`, `UPCollapse`, and `UPCollapseItem` widgets. Add source slot bridge props to `UPCollapseItem` for the custom Collapse source example.

**Tech Stack:** Flutter `>=3.19.0`, Dart `>=3.3.0`, `flutter_test`, existing local `ultra_ui` package, Android/iOS only.

## Global Constraints

- Source of truth is `D:\Repos\xyito\open\uview-plus\src\pages.json` and the matching source files under `src/pages`.
- Preserve registered route order, exact source route title, visible Chinese labels, representative default state, and principal interaction.
- Use `UP*` widgets for each component demonstration. Do not substitute a Material control for the component being demonstrated.
- Do not use remote image resources at runtime.
- `ExampleRoute` entries are added only when a real source page exists. Set a preview route `available: true` only when its matching catalog builder is added.
- Preserve Flutter package names with `UP` prefixes and do not alter unrelated dirty worktree files.
- Every new behavior uses test-first implementation.
- Run `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, then install and launch the APK on MuMu `127.0.0.1:16384` at the batch boundary.

---

## File Structure

```text
example/lib/pages/components_b/alert_page.dart        # Source Alert sections
example/lib/pages/components_b/switch_page.dart       # Source Switch sections
example/lib/pages/components_b/collapse_page.dart     # Source Collapse sections
example/lib/routes/example_catalog.dart               # Adds three completed route builders
example/lib/routes/example_preview_catalog.dart       # Enables Alert, Switch, Collapse preview rows
example/test/components_b_pages_test.dart             # Adds page behavior tests
example/test/route_catalog_test.dart                  # Completed route count becomes 46
packages/ultra_ui/lib/src/widgets/up_alert.dart       # Included widget demonstrated by AlertPage
packages/ultra_ui/lib/src/widgets/up_switch.dart      # Included widget demonstrated by SwitchPage
packages/ultra_ui/lib/src/widgets/up_collapse.dart    # Adds item slot bridge props and included widget
packages/ultra_ui/test/widgets_test.dart              # Adds Collapse slot bridge component test
```

### Task 1: Add UPCollapseItem Slot Bridges

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_collapse.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- `UPCollapseItem` constructor accepts:

```dart
this.titleWidget,
this.iconWidget,
this.rightIconWidget,
```

- New fields:

```dart
final Widget? titleWidget;
final Widget? iconWidget;
final Widget? rightIconWidget;
```

- `titleWidget` replaces only the title text region.
- `iconWidget` replaces only the left icon region.
- `rightIconWidget` replaces the right arrow/value region.

- [x] **Step 1: Write the failing component test**

Append near the existing `UPCollapse` tests:

```dart
testWidgets('UPCollapseItem renders source slot bridge widgets',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCollapse(
          value: ['slot'],
          children: [
            UPCollapseItem(
              name: 'slot',
              title: 'fallback-title',
              icon: 'map',
              value: 'fallback-right',
              titleWidget: Text('slot-title'),
              iconWidget: UPIcon(name: 'tags-fill', size: 20),
              rightIconWidget: Text('slot-right'),
              child: Text('slot-body'),
            ),
          ],
        ),
      ),
    ),
  );

  expect(find.text('slot-title'), findsOneWidget);
  expect(find.text('slot-right'), findsOneWidget);
  expect(find.text('slot-body'), findsOneWidget);
  expect(find.text('fallback-title'), findsNothing);
  expect(find.text('fallback-right'), findsNothing);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is UPIcon && widget.name == 'tags-fill',
    ),
    findsOneWidget,
  );
});
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPCollapseItem renders source slot bridge widgets" --reporter expanded
```

Expected: FAIL because the three named parameters are not defined.

- [x] **Step 3: Implement the slot bridges**

In `UPCollapseItem`, add the constructor parameters and fields. In `build`,
replace the left icon branch with:

```dart
if (iconWidget != null) ...[
  iconWidget!,
  const SizedBox(width: 4),
] else if (icon.isNotEmpty) ...[
  UPIcon(name: icon, size: 22, color: tokens.contentColor),
  const SizedBox(width: 4),
],
```

Replace the title `Text(title, ...)` with:

```dart
titleWidget ??
    Text(
      title,
      style: TextStyle(
        color: disabled ? tokens.disabledColor : tokens.mainColor,
        fontSize: 15,
      ),
    ),
```

Replace the right region with:

```dart
if (rightIconWidget != null)
  rightIconWidget!
else ...[
  if (value.isNotEmpty)
    Text(
      value,
      style: TextStyle(
        color: tokens.contentColor,
        fontSize: 14,
        height: 24 / 14,
      ),
    ),
  if (showRight && isLink) ...[
    const SizedBox(width: 4),
    AnimatedRotation(...),
  ],
],
```

- [x] **Step 4: Run the component test green**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPCollapseItem renders source slot bridge widgets" --reporter expanded
```

Expected: PASS.

### Task 2: Add Alert Source Page

**Files:**
- Create: `example/lib/pages/components_b/alert_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_alert.dart`

**Interfaces:**
- Produces `AlertPage` at route id `componentsB/alert/alert`.
- Uses page key `example-page-componentsB/alert/alert`.
- Uses real `UPAlert` widgets for all source blocks.

- [x] **Step 1: Write the failing Alert page test**

Append to `example/test/components_b_pages_test.dart`:

```dart
testWidgets('alert page closes source alert and records close callback',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/alert/alert'));

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('关闭事件：0'), findsOneWidget);
  await tester.ensureVisible(
    find.byKey(const ValueKey('alert-page-close-callback')),
  );
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('alert-page-close-callback')),
      matching: find.byWidgetPredicate(
        (widget) => widget is UPIcon && widget.name == 'close',
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('关闭事件：1'), findsOneWidget);
});
```

Update `example/test/route_catalog_test.dart`:

```dart
expect(exampleRoutes, hasLength(44));
expect(componentBRoutes.take(17).last, 'componentsB/alert/alert');
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "alert page closes source alert and records close callback" --reporter expanded
```

Expected: FAIL with unregistered route.

- [x] **Step 3: Implement AlertPage and register it**

Create `AlertPage` as a `StatefulWidget`. Use `_AlertBlock` and `_alertItem`
helpers to render source rows with `margin-bottom: 10`.

Register after Tag:

```dart
const ExampleRoute(
  id: 'componentsB/alert/alert',
  sourcePath: 'pages/componentsB/alert/alert',
  title: '警告',
  group: ExampleRouteGroup.componentsB,
  builder: _buildAlert,
),
```

Add:

```dart
Widget _buildAlert(BuildContext context) => const AlertPage();
```

Set preview `pages/componentsB/alert/alert` to `available: true`.

- [x] **Step 4: Run Alert tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "alert page closes source alert and records close callback" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 3: Add Switch Source Page

**Files:**
- Create: `example/lib/pages/components_b/switch_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_switch.dart`

**Interfaces:**
- Produces `SwitchPage` at route id `componentsB/switch/switch`.
- Uses page key `example-page-componentsB/switch/switch`.
- Uses real `UPSwitch` widgets for all source blocks.

- [x] **Step 1: Write the failing Switch page test**

Append:

```dart
testWidgets('switch page toggles basic and confirms async source switch',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/switch/switch'));

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('异步值：true'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('switch-page-basic-1')),
      matching: find.byType(UPSwitch),
    ),
  );
  await tester.pump(const Duration(milliseconds: 450));
  expect(
    find.descendant(
      of: find.byKey(const ValueKey('switch-page-basic-1')),
      matching: find.text('true'),
    ),
    findsOneWidget,
  );

  await tester.ensureVisible(find.byKey(const ValueKey('switch-page-async')));
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('switch-page-async')),
      matching: find.byType(UPSwitch),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.text('确定要关闭吗'), findsOneWidget);
  await tester.tap(find.text('确定'));
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.text('异步值：false'), findsOneWidget);
});
```

Update route count and order through Switch:

```dart
expect(exampleRoutes, hasLength(45));
expect(componentBRoutes.take(18).last, 'componentsB/switch/switch');
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "switch page toggles basic and confirms async source switch" --reporter expanded
```

Expected: FAIL with unregistered route.

- [x] **Step 3: Implement SwitchPage and register it**

Create `SwitchPage` state:

```dart
final List<bool> _values = <bool>[
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  true,
  true,
  false,
  true,
  true,
];
```

Use row keys `switch-page-basic-1` and `switch-page-async`. The async handler:

```dart
Future<void> _asyncChange(bool next) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(next ? '确定要打开吗' : '确定要关闭吗'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  if (!mounted || confirmed != true) return;
  setState(() => _values[12] = next);
}
```

Register after Alert and set preview `pages/componentsB/switch/switch`
available.

- [x] **Step 4: Run Switch tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "switch page toggles basic and confirms async source switch" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 4: Add Collapse Source Page

**Files:**
- Create: `example/lib/pages/components_b/collapse_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_collapse.dart`

**Interfaces:**
- Produces `CollapsePage` at route id `componentsB/collapse/collapse`.
- Uses page key `example-page-componentsB/collapse/collapse`.
- Uses real `UPCollapse` and `UPCollapseItem` widgets for all source blocks.

- [x] **Step 1: Write the failing Collapse page test**

Append:

```dart
testWidgets('collapse page opens source panels and renders custom slots',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/collapse/collapse'));

  expect(find.text('基础功能'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('collapse-page-basic')),
      matching: find.text('文档指南'),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.textContaining('方向指导和设计理念'), findsWidgets);
  expect(find.textContaining('变更：'), findsOneWidget);

  await tester.ensureVisible(
    find.byKey(const ValueKey('collapse-page-expanded-disabled')),
  );
  await tester.pumpAndSettle();
  expect(
    find.descendant(
      of: find.byKey(const ValueKey('collapse-page-expanded-disabled')),
      matching: find.textContaining('贴心小工具'),
    ),
    findsOneWidget,
  );

  await tester.ensureVisible(
    find.byKey(const ValueKey('collapse-page-custom-slots')),
  );
  await tester.pumpAndSettle();
  expect(find.text('10'), findsOneWidget);
});
```

Update route count and order through Collapse:

```dart
expect(exampleRoutes, hasLength(46));
expect(
  componentBRoutes.take(19),
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
  ],
);
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "collapse page opens source panels and renders custom slots" --reporter expanded
```

Expected: FAIL with unregistered route.

- [x] **Step 3: Implement CollapsePage and register it**

Create `CollapsePage` as a `StatefulWidget` with:

```dart
List<dynamic> _basicValue = <dynamic>[];
String _changeText = '变更：[]';
```

Use helper methods for repeated source items. The basic block passes
`onUpdateValue` to keep the controlled value and `onChange` to update
`_changeText`. The expanded block passes `value: const ['2']`. The custom slots
block uses `titleWidget`, `iconWidget`, and `rightIconWidget`.

Register after Switch and set preview `pages/componentsB/collapse/collapse`
available.

- [x] **Step 4: Run Collapse tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "collapse page opens source panels and renders custom slots" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 5: Batch Verification and Commit

**Files:**
- All files from Tasks 1-4.
- Modify this plan file to mark completed steps before staging.

**Interfaces:**
- Completed example route catalog has 46 routes: 4 main, 23 Components A, and 19 Components B.
- Alert, Switch, and Collapse preview rows are `available: true`; other unfinished preview rows remain unavailable.

- [x] **Step 1: Run formatting**

Run:

```powershell
cd example
dart format lib/pages/components_b/alert_page.dart lib/pages/components_b/switch_page.dart lib/pages/components_b/collapse_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
cd ..\packages\ultra_ui
dart format lib/src/widgets/up_alert.dart lib/src/widgets/up_switch.dart lib/src/widgets/up_collapse.dart test/widgets_test.dart
cd ..\..
git diff --check -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-6.md
```

- [x] **Step 2: Run targeted tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "alert page closes source alert and records close callback" --reporter expanded
flutter test test/components_b_pages_test.dart --plain-name "switch page toggles basic and confirms async source switch" --reporter expanded
flutter test test/components_b_pages_test.dart --plain-name "collapse page opens source panels and renders custom slots" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPCollapseItem renders source slot bridge widgets" --reporter expanded
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
$files = @(
  'docs/superpowers/plans/2026-07-28-uview-components-b-batch-6.md',
  'example/lib/pages/components_b/alert_page.dart',
  'example/lib/pages/components_b/switch_page.dart',
  'example/lib/pages/components_b/collapse_page.dart',
  'example/lib/routes/example_catalog.dart',
  'example/lib/routes/example_preview_catalog.dart',
  'example/test/components_b_pages_test.dart',
  'example/test/route_catalog_test.dart',
  'packages/ultra_ui/lib/src/widgets/up_alert.dart',
  'packages/ultra_ui/lib/src/widgets/up_switch.dart',
  'packages/ultra_ui/lib/src/widgets/up_collapse.dart',
  'packages/ultra_ui/test/widgets_test.dart'
)
git diff --check -- $files
git add -- $files
git diff --cached --check
git diff --cached --name-only
git commit -m "feat(example): add alert switch collapse source pages"
```

## Plan Self-Review

- Spec coverage: Tasks cover the three approved source routes, the `UPCollapseItem` slot bridges, route and preview enablement, tests, APK build, and MuMu launch.
- Placeholder scan: No deferred-detail markers or vague unimplemented steps remain.
- Type consistency: Route ids, source paths, page class names, builder names, slot prop names, and test names are consistent across tasks.
