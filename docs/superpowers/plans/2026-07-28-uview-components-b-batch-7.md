# Components B Batch 7 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Flutter example pages for the uView Plus `Code`, `NoticeBar`, and `Progress` Components B source demos.

**Architecture:** Create one focused example page per uView source route, register each route after Collapse, and update preview availability in place. The pages use existing `UPCode`, `UPNoticeBar`, and `UPLineProgress` package widgets and expose source interactions through visible state for deterministic tests.

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

- Create `example/lib/pages/components_b/code_page.dart`: Code source demo with three `UPCode` controllers and source controls.
- Create `example/lib/pages/components_b/notice_bar_page.dart`: NoticeBar source demo with all eight source blocks and link navigation to Tag.
- Create `example/lib/pages/components_b/progress_page.dart`: Progress source demo with all eight source blocks and manual percentage controls.
- Modify `example/lib/routes/example_catalog.dart`: import the three pages, register routes after Collapse, add builders.
- Modify `example/lib/routes/example_preview_catalog.dart`: mark `code`, `noticeBar`, and `progress` preview rows available.
- Modify `example/test/components_b_pages_test.dart`: add focused page tests for Code, NoticeBar, and Progress.
- Modify `example/test/route_catalog_test.dart`: update completed route count and Components B source-order assertion.
- Include `packages/ultra_ui/lib/src/widgets/up_code.dart`, `packages/ultra_ui/lib/src/widgets/up_notice_bar.dart`, and `packages/ultra_ui/lib/src/widgets/up_line_progress.dart` in the implementation commit because these demonstrated package widgets are currently untracked.

## Task 1: Route And Test Expectations

**Files:**
- Modify: `example/test/route_catalog_test.dart`
- Modify: `example/test/components_b_pages_test.dart`

**Interfaces:**
- Consumes: existing `buildRouteUnderTest(String id)`, `findExampleRoute(String id)`, `pushExampleRoute(BuildContext, ExampleRoute)`.
- Produces: failing expectations for the three new routes and page interactions.

- [ ] **Step 1: Add route-order failing expectations**

In `route_catalog_test.dart`, change `expect(exampleRoutes, hasLength(46));` to:

```dart
expect(exampleRoutes, hasLength(49));
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
]
```

Change the expectation from `componentBRoutes.take(19)` to `componentBRoutes.take(22)`.

- [ ] **Step 2: Add Code page failing test**

Append this test in `components_b_pages_test.dart`:

```dart
testWidgets('code page starts the source countdown and disables the button',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/code/code'));

  expect(find.text('基础功能'), findsOneWidget);
  await tester.tap(find.text('获取验证码').first);
  await tester.pump();
  expect(find.text('验证码已发送'), findsOneWidget);
  expect(find.textContaining('XS获取'), findsOneWidget);

  final button = tester.widget<UPButton>(
    find.widgetWithText(UPButton, '20S获取'),
  );
  expect(button.disabled, isTrue);
  UPToast.hide();
});
```

- [ ] **Step 3: Add NoticeBar failing tests**

Append these tests in `components_b_pages_test.dart`; use fixed `pump` calls because marquee notices run repeating animations:

```dart
testWidgets('noticeBar page closes the source closable notice',
    (tester) async {
  await tester
      .pumpWidget(buildRouteUnderTest('componentsB/noticeBar/noticeBar'));

  expect(find.text('关闭事件：0'), findsOneWidget);
  await tester.ensureVisible(find.byKey(const ValueKey('notice-page-closable')));
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('notice-page-closable')),
      matching: find.byWidgetPredicate(
        (widget) => widget is UPIcon && widget.name == 'close',
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  expect(find.text('关闭事件：1'), findsOneWidget);
});

testWidgets('noticeBar page link opens the completed tag route',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => pushExampleRoute(
            context,
            findExampleRoute('componentsB/noticeBar/noticeBar'),
          ),
          child: const Text('打开通知栏'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('打开通知栏'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const ValueKey('notice-page-link')));
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('notice-page-link')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('example-page-componentsB/tag/tag')),
      findsOneWidget);
});
```

- [ ] **Step 4: Add Progress page failing test**

Append this test in `components_b_pages_test.dart`:

```dart
testWidgets('progress page increments the source manual percentage',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/progress/progress'));

  expect(find.text('自定义样式(不支持安卓环境的nvue)'), findsOneWidget);
  expect(find.text('70%'), findsOneWidget);
  await tester.ensureVisible(find.byKey(const ValueKey('progress-page-manual')));
  await tester.pump();
  expect(find.text('手动值：50'), findsOneWidget);
  await tester.tap(find.text('增加'));
  await tester.pump(const Duration(milliseconds: 100));
  expect(find.text('手动值：60'), findsOneWidget);
});
```

- [ ] **Step 5: Run tests to verify the new expectations fail**

Run:

```powershell
cd example
flutter test test/route_catalog_test.dart test/components_b_pages_test.dart --reporter expanded
```

Expected: FAIL because the new page classes and route entries do not exist yet.

## Task 2: Implement Code Page

**Files:**
- Create: `example/lib/pages/components_b/code_page.dart`

**Interfaces:**
- Consumes: `UPCode`, `UPCodeController`, `UPButton`, `UPToast`, `UPThemeTokens`, `ExampleDemoBlock`, `ExamplePageScaffold`.
- Produces: `class CodePage extends StatefulWidget`.

- [ ] **Step 1: Create the page**

Create `CodePage` with:

```dart
class CodePage extends StatefulWidget {
  const CodePage({super.key});
}
```

State owns:

```dart
final UPCodeController _basicController = UPCodeController();
final UPCodeController _keepController = UPCodeController();
final UPCodeController _textController = UPCodeController();
String _tips = '';
String _tips1 = '';
String _tips2 = '';
bool _disabled1 = false;
bool _disabled2 = false;
```

- [ ] **Step 2: Add request helper**

Implement:

```dart
void _requestCode(UPCodeController controller) {
  if (controller.canGetCode) {
    UPToast.show(context, message: '验证码已发送');
    controller.start();
  } else {
    UPToast.show(context, message: '倒计时结束后再发送');
  }
}
```

- [ ] **Step 3: Render source blocks**

Use `ExamplePageScaffold(title: '验证码')` and a root container key
`example-page-componentsB/code/code`. Render three `_CodeBlock`s in source
order. Each block includes its logic-only `UPCode` and the visible source
control:

```dart
UPCode(
  controller: _basicController,
  seconds: 20,
  changeText: 'XS获取',
  onChange: (text) => setState(() => _tips = text),
  onStart: () => setState(() => _disabled1 = true),
  onEnd: () => setState(() => _disabled1 = false),
)
```

The button text uses `_tips.isEmpty ? '获取验证码' : _tips`; the text-style block
uses primary colored `GestureDetector` text.

- [ ] **Step 4: Run the Code page test**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --name "code page starts" --reporter expanded
```

Expected: still FAIL until routes are registered in Task 5, or PASS if route
registration has already been done locally.

## Task 3: Implement NoticeBar Page

**Files:**
- Create: `example/lib/pages/components_b/notice_bar_page.dart`

**Interfaces:**
- Consumes: `UPNoticeBar.openPageHandler`, `findExampleRoute`, `pushExampleRoute`, `UPNoticeBar`.
- Produces: `class NoticeBarPage extends StatefulWidget`.

- [ ] **Step 1: Create text constants**

Use the source constants:

```dart
static const String _text1 =
    'uview-plus众多组件覆盖开发过程的各个需求，组件功能丰富，多端兼容。让您快速集成，开箱即用';
static const String _text2 =
    'uview-plus众多的贴心小工具，是您开发过程中召之即来的利器，让您飞镖在手，百步穿杨';
static const String _text3 =
    'uview-plus收集众多的常用页面和布局，减少开发者的重复工作，让您专注逻辑，事半功倍';
static const String _text5 =
    '涵盖uniapp各个方面，给开发者方向指导和设计理念，让您茅塞顿开，一马平川';
static const List<String> _text4 = <String>[
  '寒雨连江夜入吴',
  '平明送客楚山孤',
  '洛阳亲友如相问',
  '一片冰心在玉壶',
];
```

- [ ] **Step 2: Wire link navigation**

In `initState`, save the previous handler and set:

```dart
UPNoticeBar.openPageHandler = (url, {String linkType = 'navigateTo'}) async {
  if (!mounted) return;
  if (url == '/pages/componentsB/tag/tag') {
    await pushExampleRoute(context, findExampleRoute('componentsB/tag/tag'));
  }
};
```

Restore the previous handler in `dispose`.

- [ ] **Step 3: Render source blocks**

Use `ExamplePageScaffold(title: '滚动通知')` and root key
`example-page-componentsB/noticeBar/noticeBar`. Render all eight source blocks
with `_NoticeBlock`. Add keys `notice-page-closable` and `notice-page-link` to
the closable and link blocks.

The closable block sets:

```dart
UPNoticeBar(
  text: _text5,
  mode: 'closable',
  onClose: () => setState(() => _closeCount++),
)
```

The link block wraps `UPNoticeBar(text: _text3, mode: 'link', url:
'/pages/componentsB/tag/tag')` in a keyed container or passes the key directly.

- [ ] **Step 4: Run NoticeBar tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --name "noticeBar page" --reporter expanded
```

Expected: PASS after route registration is complete.

## Task 4: Implement Progress Page

**Files:**
- Create: `example/lib/pages/components_b/progress_page.dart`

**Interfaces:**
- Consumes: `UPLineProgress`, `UPThemeTokens`, `ExampleDemoBlock`, `ExamplePageScaffold`.
- Produces: `class ProgressPage extends StatefulWidget`.

- [ ] **Step 1: Create state**

State owns:

```dart
double _percentage1 = 30;
double _percentage6 = 50;
```

In `initState`, schedule:

```dart
Future<void>.delayed(const Duration(milliseconds: 2500), () {
  if (mounted) setState(() => _percentage1 = 120);
});
```

- [ ] **Step 2: Render source blocks**

Use `ExamplePageScaffold(title: '进度条')` and root key
`example-page-componentsB/progress/progress`. Render all eight source blocks in
order, using the source percentages and props:

```dart
const UPLineProgress()
UPLineProgress(percentage: _percentage1)
const UPLineProgress(showText: false, percentage: 40)
const UPLineProgress(showText: false, percentage: 40, fromRight: true)
const UPLineProgress(height: 8, showText: false, percentage: 50)
const UPLineProgress(height: 8, showText: false, percentage: 60,
    activeColor: '#3c9cff', inactiveColor: '#f3f4f6')
```

Custom slot:

```dart
const UPLineProgress(
  height: 8,
  showText: false,
  percentage: 70,
  activeColor: '#3c9cff',
  inactiveColor: '#f3f4f6',
  child: _PercentageSlot(value: 70),
)
```

- [ ] **Step 3: Add manual controls**

Implement:

```dart
void _changeManual(int delta) {
  setState(() => _percentage6 = (_percentage6 + delta).clamp(0, 100));
}
```

Render `手动值：${_percentage6.round()}` and circular controls labeled `减少` and
`增加`; assign the block key `progress-page-manual`.

- [ ] **Step 4: Run Progress test**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --name "progress page increments" --reporter expanded
```

Expected: PASS after route registration is complete.

## Task 5: Register Routes And Preview Availability

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `CodePage`, `NoticeBarPage`, `ProgressPage`.
- Produces: completed catalog entries for `componentsB/code/code`, `componentsB/noticeBar/noticeBar`, `componentsB/progress/progress`.

- [ ] **Step 1: Add imports**

Add:

```dart
import '../pages/components_b/code_page.dart';
import '../pages/components_b/notice_bar_page.dart';
import '../pages/components_b/progress_page.dart';
```

- [ ] **Step 2: Register routes after Collapse**

Append these entries after `componentsB/collapse/collapse`:

```dart
const ExampleRoute(
  id: 'componentsB/code/code',
  sourcePath: 'pages/componentsB/code/code',
  title: '验证码',
  group: ExampleRouteGroup.componentsB,
  builder: _buildCode,
),
const ExampleRoute(
  id: 'componentsB/noticeBar/noticeBar',
  sourcePath: 'pages/componentsB/noticeBar/noticeBar',
  title: '滚动通知',
  group: ExampleRouteGroup.componentsB,
  builder: _buildNoticeBar,
),
const ExampleRoute(
  id: 'componentsB/progress/progress',
  sourcePath: 'pages/componentsB/progress/progress',
  title: '进度条',
  group: ExampleRouteGroup.componentsB,
  builder: _buildProgress,
),
```

Add builders:

```dart
Widget _buildCode(BuildContext context) => const CodePage();
Widget _buildNoticeBar(BuildContext context) => const NoticeBarPage();
Widget _buildProgress(BuildContext context) => const ProgressPage();
```

- [ ] **Step 3: Enable preview rows**

In `example_preview_catalog.dart`, set `available: true` for:

```dart
sourcePath: 'pages/componentsB/code/code'
sourcePath: 'pages/componentsB/progress/progress'
sourcePath: 'pages/componentsB/noticeBar/noticeBar'
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
dart format lib/pages/components_b/code_page.dart lib/pages/components_b/notice_bar_page.dart lib/pages/components_b/progress_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_code.dart lib/src/widgets/up_notice_bar.dart lib/src/widgets/up_line_progress.dart test/widgets_test.dart
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
git add -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-7.md `
  example/lib/pages/components_b/code_page.dart `
  example/lib/pages/components_b/notice_bar_page.dart `
  example/lib/pages/components_b/progress_page.dart `
  example/lib/routes/example_catalog.dart `
  example/lib/routes/example_preview_catalog.dart `
  example/test/components_b_pages_test.dart `
  example/test/route_catalog_test.dart `
  packages/ultra_ui/lib/src/widgets/up_code.dart `
  packages/ultra_ui/lib/src/widgets/up_notice_bar.dart `
  packages/ultra_ui/lib/src/widgets/up_line_progress.dart
```

Check `git status --short` and verify `README.md` is not staged.

- [ ] **Step 6: Commit implementation**

Run:

```powershell
git commit -m "feat(example): add code notice progress source pages"
```

Expected: implementation commit includes only the plan, three example pages,
route/test updates, and the three demonstrated package widget files.
