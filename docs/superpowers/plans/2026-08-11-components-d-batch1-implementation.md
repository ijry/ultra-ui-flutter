# Components D Batch 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the first five source-order Components D example pages: Qrcode,
Copy, NavbarMini, Box, and FloatButton.

**Architecture:** Add one focused page file per source route under
`example/lib/pages/components_d/`. Reuse the existing `ExamplePageScaffold`,
`ExampleDemoBlock`, local assets, and public `UP*` widgets. Register the five
routes after the completed Components C routes and enable only their existing
preview records. Modify the package only if a focused page test proves a
concrete compatibility gap.

**Tech Stack:** Flutter SDK, Dart, Material 3, local `ultra_ui` package,
`flutter_test`, and the existing example route catalogs.

## Global Constraints

- Work directly on the approved `main` workspace.
- Batch scope is exactly `componentsD/qrcode/qrcode`,
  `componentsD/copy/copy`, `componentsD/navbarMini/navbarMini`,
  `componentsD/box/box`, and `componentsD/floatButton/floatButton`.
- Preserve source Chinese titles, source order, representative defaults, and
  principal interactions.
- Keep the implementation offline; use the existing local logo asset and no
  network or new dependency.
- Reuse public `UPQrcode`, `UPCopy`, `UPNavbarMini`, `UPBox`, `UPFloatButton`,
  `UPIcon`, and supporting public widgets.
- Do not add a generic Components D page abstraction.
- Do not modify `README.md`, generated artifacts, helper scripts, or unrelated
  historical untracked files.
- Update only the existing preview records for these five source paths.
- The completed route count changes from `83` to `88`; Components D contains
  exactly five completed routes after this batch.
- Run focused tests before broad validation and do not hide package failures
  with page-only workarounds.

---

## File Map

Create:

- `example/lib/pages/components_d/qrcode_page.dart`: three offline QR demos.
- `example/lib/pages/components_d/copy_page.dart`: text and button copy demos.
- `example/lib/pages/components_d/navbar_mini_page.dart`: fixed and custom
  mini-navbar demos.
- `example/lib/pages/components_d/box_page.dart`: default and slot layouts.
- `example/lib/pages/components_d/float_button_page.dart`: base, menu, and
  custom list demos.
- `example/test/components_d_pages_test.dart`: focused page interaction tests.

Modify:

- `example/lib/routes/example_catalog.dart`: five imports, route records, and
  builders.
- `example/lib/routes/example_preview_catalog.dart`: five `available` flags.
- `example/test/route_catalog_test.dart`: route count, order, and availability
  assertions.

Modify only if a focused regression proves a package gap:

- One affected file under `packages/ultra_ui/lib/src/widgets/`.
- The corresponding focused area in `packages/ultra_ui/test/widgets_test.dart`.

No new asset file is required. The Qrcode logo uses the existing
`assets/uview/common/logo.png` declaration.

## Task 1: Add Qrcode Page and Test

**Files:**

- Create: `example/lib/pages/components_d/qrcode_page.dart`
- Create: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const QrcodePage()`.
- Produces root key `example-page-componentsD/qrcode/qrcode`.
- Produces QR keys `qrcode-page-basic`, `qrcode-page-logo`, and
  `qrcode-page-colors`.

- [ ] **Step 1: Write the failing Qrcode page test**

Add the Components D test file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/components_d/qrcode_page.dart';
import 'example_test_helpers.dart';

void main() {
  testWidgets('qrcode page renders source variants offline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const QrcodePage(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('example-page-componentsD/qrcode/qrcode')),
        findsOneWidget);
    expect(find.text('不带logo'), findsOneWidget);
    expect(find.text('带logo'), findsOneWidget);
    expect(find.text('二维码颜色'), findsOneWidget);
    expect(find.byType(UPQrcode), findsNWidgets(3));
    expect(find.byKey(const ValueKey('qrcode-page-logo')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run from `example`:

```text
flutter test test/components_d_pages_test.dart --plain-name "qrcode page renders source variants offline" --reporter expanded
```

Expected: FAIL because `QrcodePage` is not defined.

- [ ] **Step 3: Implement the Qrcode page**

Create a stateless page using `ExamplePageScaffold` and three
`ExampleDemoBlock`s. Use the fixed source value
`https://click.meituan.com/t?t=1&c=2&p=WhaD2b5zGU-h`.

The three QR widgets must be:

```dart
const UPQrcode(
  key: ValueKey('qrcode-page-basic'),
  cid: 'up1',
  size: 150,
  val: _sourceValue,
)
```

```dart
Stack(
  key: const ValueKey('qrcode-page-logo'),
  alignment: Alignment.center,
  children: const [
    UPQrcode(cid: 'up2', size: 150, val: _sourceValue),
    DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Image(
          image: AssetImage('assets/uview/common/logo.png'),
          width: 32,
          height: 32,
        ),
      ),
    ),
  ],
)
```

Use `UPQrcode(cid: 'up3', size: 150, val: _sourceValue,
background: 'red', foreground: 'blue')` for the color variant. Keep the
background in each demo block source-owned and center the content.

- [ ] **Step 4: Format and run the focused test**

Run:

```text
dart format lib/pages/components_d/qrcode_page.dart test/components_d_pages_test.dart
flutter test test/components_d_pages_test.dart --plain-name "qrcode page renders source variants offline" --reporter expanded
```

Expected: the test passes. If the asset test fails because the route is
constructed without the example asset bundle, use the existing example test
helper's runtime `MaterialApp` contract and keep the asset declaration
unchanged; do not add a network fallback.

- [ ] **Step 5: Commit the Qrcode page**

```text
git add -- example/lib/pages/components_d/qrcode_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add qrcode page"
```

## Task 2: Add Copy and NavbarMini Pages and Tests

**Files:**

- Create: `example/lib/pages/components_d/copy_page.dart`
- Create: `example/lib/pages/components_d/navbar_mini_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const CopyPage()` with root key
  `example-page-componentsD/copy/copy`.
- Produces `const NavbarMiniPage()` with root key
  `example-page-componentsD/navbarMini/navbarMini`.
- Uses existing `UPCopy` and `UPNavbarMini` callback contracts.

- [ ] **Step 1: Add failing Copy and NavbarMini tests**

Append:

```dart
import '../lib/pages/components_d/copy_page.dart';
import '../lib/pages/components_d/navbar_mini_page.dart';

testWidgets('copy page reports successful text and button copies',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const CopyPage(),
    ),
  );

  expect(find.text('点击文字复制'), findsOneWidget);
  expect(find.text('点击按钮复制'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('copy-page-text')));
  await tester.pump();
  expect(find.text('复制次数：1'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('copy-page-button')));
  await tester.pump();
  expect(find.text('复制次数：2'), findsOneWidget);
});

testWidgets('navbar mini page invokes its source left callback',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const NavbarMiniPage(),
    ),
  );

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('自定义插槽'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('navbar-mini-page-left')));
  await tester.pump();
  expect(find.text('左侧点击：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused tests and verify they fail**

Run:

```text
flutter test test/components_d_pages_test.dart --plain-name "copy page|navbar mini page" --reporter expanded
```

Expected: FAIL because both page classes are absent.

- [ ] **Step 3: Implement CopyPage**

Use a `StatefulWidget` with `_successCount`. Wrap a text `Text('点击复制')`
and an `UPButton(type: 'primary', text: '点击复制')` in two `UPCopy` widgets:

```dart
UPCopy(
  key: const ValueKey('copy-page-text'),
  content: 'uview-plus is great !',
  onSuccess: _recordSuccess,
  child: const Text('点击复制'),
)
```

Use `UPCopy` as the interactive owner. Render `复制次数：$_successCount`
after the two blocks, and do not invoke `Clipboard` directly in the page.

- [ ] **Step 4: Implement NavbarMiniPage**

Use a `StatefulWidget` with `_leftCount`. Render:

```dart
UPNavbarMini(
  key: const ValueKey('navbar-mini-page-basic'),
  safeAreaInsetTop: true,
  fixed: true,
  autoBack: true,
  leftSlot: const KeyedSubtree(
    key: ValueKey('navbar-mini-page-left'),
    child: UPIcon(name: 'arrow-leftward', size: 20),
  ),
  onLeftClick: _recordLeftClick,
)
```

and a second widget with `fixed: false`, `safeAreaInsetTop: false`, and
`leftSlot: const UPIcon(name: 'arrow-left', size: 19)`. The keyed
`KeyedSubtree` is the test target for the basic widget's left action. Keep the
displayed result `左侧点击：N`.

- [ ] **Step 5: Format and run the focused tests**

Run:

```text
dart format lib/pages/components_d/copy_page.dart lib/pages/components_d/navbar_mini_page.dart test/components_d_pages_test.dart
flutter test test/components_d_pages_test.dart --plain-name "copy page reports successful text and button copies" --reporter expanded
flutter test test/components_d_pages_test.dart --plain-name "navbar mini page invokes its source left callback" --reporter expanded
```

Expected: both tests pass. A Clipboard platform-channel failure is a package
or test-environment issue to reproduce in isolation; do not replace `UPCopy`
with a Material button.

- [ ] **Step 6: Commit Copy and NavbarMini**

```text
git add -- example/lib/pages/components_d/copy_page.dart example/lib/pages/components_d/navbar_mini_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add copy and navbar mini pages"
```

## Task 3: Add Box and FloatButton Pages and Tests

**Files:**

- Create: `example/lib/pages/components_d/box_page.dart`
- Create: `example/lib/pages/components_d/float_button_page.dart`
- Modify: `example/test/components_d_pages_test.dart`

**Interfaces:**

- Produces `const BoxPage()` with root key
  `example-page-componentsD/box/box`.
- Produces `const FloatButtonPage()` with root key
  `example-page-componentsD/floatButton/floatButton`.
- Uses `UPBox`, `UPIcon`, `UPFloatButton`, and public state methods only.

- [ ] **Step 1: Add failing Box and FloatButton tests**

Append:

```dart
import '../lib/pages/components_d/box_page.dart';
import '../lib/pages/components_d/float_button_page.dart';

testWidgets('box page renders default and custom slots', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const BoxPage(),
    ),
  );

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('自定义插槽'), findsOneWidget);
  expect(find.byKey(const ValueKey('box-page-basic')), findsOneWidget);
  expect(find.byKey(const ValueKey('box-page-custom')), findsOneWidget);
  expect(find.byType(UPIcon), findsNWidgets(3));
});

testWidgets('float button page opens menu and emits item click',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const FloatButtonPage(),
    ),
  );

  final state = tester.state<UPFloatButtonState>(
    find.byKey(const ValueKey('float-button-page-menu')),
  );
  expect(state.isOpen, isFalse);
  await tester.tap(find.byKey(const ValueKey('float-button-page-menu-trigger')));
  await tester.pump();
  expect(state.isOpen, isTrue);
  expect(find.byKey(const ValueKey('up-float-item-0')), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('up-float-item-0')));
  await tester.pump();
  expect(find.text('菜单点击：plus'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused tests and verify they fail**

Run:

```text
flutter test test/components_d_pages_test.dart --plain-name "box page|float button page" --reporter expanded
```

Expected: FAIL because both page classes are absent.

- [ ] **Step 3: Implement BoxPage**

Render two `ExampleDemoBlock`s. The basic block uses:

```dart
UPBox(
  key: const ValueKey('box-page-basic'),
  height: '160px',
  gap: '12px',
)
```

The custom block uses `height: '180px'`, `gap: '12px'`, and all three slot
properties with `UPIcon(name: 'arrow-left', size: 19)`. Keep the page
scrollable and leave the component's source click callbacks unset.

- [ ] **Step 4: Implement FloatButtonPage**

Use a `StatefulWidget` with `_menuMessage`. Put each float button in a
bounded `SizedBox(height: 180, child: Stack(...))`; the page itself must not
place a `Positioned` widget directly under a `Column`.

For the menu example:

```dart
UPFloatButton(
  key: const ValueKey('float-button-page-menu'),
  isMenu: true,
  list: const [
    {'key': 'plus', 'name': 'plus', 'color': '#fff', 'backgroundColor': 'red'},
    {'key': 'order', 'name': 'order', 'color': '#fff', 'backgroundColor': 'green'},
  ],
  onItemClick: (item, _) => setState(
    () => _menuMessage = '菜单点击：${item['key']}',
  ),
)
```

Place a keyed `GestureDetector`/transparent wrapper over the main button only
if the existing `UPFloatButton` hit target cannot be found reliably; prefer
the widget's own state and hit target. The custom example uses `listSlot` with
two 50px circular `UPIcon` containers in the source colors.

- [ ] **Step 5: Format and run the focused tests**

Run:

```text
dart format lib/pages/components_d/box_page.dart lib/pages/components_d/float_button_page.dart test/components_d_pages_test.dart
flutter test test/components_d_pages_test.dart --plain-name "box page renders default and custom slots" --reporter expanded
flutter test test/components_d_pages_test.dart --plain-name "float button page opens menu and emits item click" --reporter expanded
```

Expected: both tests pass. If the FloatButton state cannot be reached because
the page structure is wrong, fix the page's `Stack` bounds rather than adding
an alternative floating-button implementation.

- [ ] **Step 6: Commit Box and FloatButton**

```text
git add -- example/lib/pages/components_d/box_page.dart example/lib/pages/components_d/float_button_page.dart example/test/components_d_pages_test.dart
git commit -m "feat(example): add box and float button pages"
```

## Task 4: Register Routes, Enable Previews, and Extend Route Tests

**Files:**

- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**

- Consumes the five page classes from Tasks 1-3.
- Produces five route records and builders in source order.
- Keeps all existing Components A-C route order and counts unchanged.

- [ ] **Step 1: Add failing route assertions**

In `route_catalog_test.dart`:

- change `expect(exampleRoutes, hasLength(83));` to `hasLength(88)`;
- add this Components D extraction and order assertion after the Components C
  assertion:

```dart
final componentDRoutes = exampleRoutes
    .where((route) => route.group == ExampleRouteGroup.componentsD)
    .map((route) => route.id)
    .toList();

expect(componentDRoutes, <String>[
  'componentsD/qrcode/qrcode',
  'componentsD/copy/copy',
  'componentsD/navbarMini/navbarMini',
  'componentsD/box/box',
  'componentsD/floatButton/floatButton',
]);
```

- add the five source paths to the completed-path set;
- add the five source paths to the focused available-preview set;
- add this literal Components D list near the existing Components A list:

```dart
const componentDRouteIds = <String>[
  'componentsD/qrcode/qrcode',
  'componentsD/copy/copy',
  'componentsD/navbarMini/navbarMini',
  'componentsD/box/box',
  'componentsD/floatButton/floatButton',
];
```

- add this smoke test:

```dart
testWidgets('every completed Components D source route renders a real page',
    (tester) async {
  for (final id in componentDRouteIds) {
    await tester.pumpWidget(buildRouteUnderTest(id));
    final route = findExampleRoute(id);
    expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(route.title),
      ),
      findsOneWidget,
    );
  }
});
```

Run:

```text
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
```

Expected: FAIL because the five route records are not registered.

- [ ] **Step 2: Add imports, route records, and builders**

Import the five page files. Add route records immediately after
`componentsC/subsection/subsection`:

```dart
const ExampleRoute(
  id: 'componentsD/qrcode/qrcode',
  sourcePath: 'pages/componentsD/qrcode/qrcode',
  title: '二维码',
  group: ExampleRouteGroup.componentsD,
  builder: _buildQrcode,
),
const ExampleRoute(
  id: 'componentsD/copy/copy',
  sourcePath: 'pages/componentsD/copy/copy',
  title: '复制',
  group: ExampleRouteGroup.componentsD,
  builder: _buildCopy,
),
const ExampleRoute(
  id: 'componentsD/navbarMini/navbarMini',
  sourcePath: 'pages/componentsD/navbarMini/navbarMini',
  title: '迷你导航栏',
  group: ExampleRouteGroup.componentsD,
  builder: _buildNavbarMini,
),
const ExampleRoute(
  id: 'componentsD/box/box',
  sourcePath: 'pages/componentsD/box/box',
  title: '盒子',
  group: ExampleRouteGroup.componentsD,
  builder: _buildBox,
),
const ExampleRoute(
  id: 'componentsD/floatButton/floatButton',
  sourcePath: 'pages/componentsD/floatButton/floatButton',
  title: '悬浮按钮',
  group: ExampleRouteGroup.componentsD,
  builder: _buildFloatButton,
),
```

Add builders:

```dart
Widget _buildQrcode(BuildContext context) => const QrcodePage();
Widget _buildCopy(BuildContext context) => const CopyPage();
Widget _buildNavbarMini(BuildContext context) => const NavbarMiniPage();
Widget _buildBox(BuildContext context) => const BoxPage();
Widget _buildFloatButton(BuildContext context) => const FloatButtonPage();
```

- [ ] **Step 3: Enable only the five existing preview records**

Change `available: false` to `available: true` for:

```text
pages/componentsD/qrcode/qrcode
pages/componentsD/copy/copy
pages/componentsD/navbarMini/navbarMini
pages/componentsD/box/box
pages/componentsD/floatButton/floatButton
```

Do not reorder `componentPreviewRoutes`, alter group lengths, or add
duplicates.

- [ ] **Step 4: Format and run route regressions**

Run:

```text
dart format lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
flutter test test/route_catalog_test.dart --plain-name "route ids resolve to their registered catalog entries" --reporter expanded
```

Expected: both tests pass and the completed route count is `88`.

- [ ] **Step 5: Commit route registration**

```text
git add -- example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/route_catalog_test.dart
git commit -m "test(example): register components d batch 1 routes"
```

## Task 5: Run Full Validation and Handle Confirmed Package Gaps

**Files:**

- Modify only a package widget/test file if a focused test proves a gap.

- [ ] **Step 1: Run all Components D tests**

From `example`:

```text
flutter test test/components_d_pages_test.dart --reporter expanded
```

Expected: all five page tests pass. If a failure points into a package
component, reproduce the smallest behavior in `packages/ultra_ui/test` before
editing package code.

- [ ] **Step 2: Add a package regression only for a confirmed gap**

Use the affected widget's existing test area. The regression must assert the
exact state or render behavior that failed in the page test. Run it before the
implementation change and confirm that it fails.

- [ ] **Step 3: Implement the smallest confirmed package fix**

Preserve the public constructor and callback names. Run the focused regression:

```text
flutter test test/widgets_test.dart --reporter expanded
```

Do not add a package workaround when the page layout or test harness is the
actual cause.

- [ ] **Step 4: Run package validation**

From the repository root:

```text
flutter test packages/ultra_ui
flutter analyze packages/ultra_ui
```

Expected: all package tests pass, with no new analyzer errors.

- [ ] **Step 5: Run example validation**

```text
dart format example/lib/pages/components_d example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_d_pages_test.dart example/test/route_catalog_test.dart
flutter test example
flutter analyze example
```

Expected: all example tests pass and the example analyzer reports
`No issues found!`.

- [ ] **Step 6: Build the Android debug artifact**

From `example`:

```text
flutter build apk --debug --target-platform android-arm64
```

Expected: `example/build/app/outputs/flutter-apk/app-debug.apk` exists. Do
not stage the build output.

- [ ] **Step 7: Review the final diff and worktree**

From the repository root:

```text
git diff --check
git status --short
git log -8 --oneline
git diff --name-only -- example/lib/pages/components_d example/lib/routes example/test/components_d_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets packages/ultra_ui/test/widgets_test.dart
```

Confirm that only the planned Batch 1 files were added to the new commits.
Leave all unrelated existing modifications and untracked files untouched.

If a package gap was confirmed and fixed, create a separate commit containing
only that implementation file and its focused regression test, with commit
message `fix: preserve components d widget behavior`. If no gap was found,
make no package commit.

## Plan Self-Review

- The five source routes each have one page task and one focused test path.
- Route registration, preview availability, and route-count assertions are
  covered by Task 4.
- Offline QR logo behavior is explicit and does not require a new dependency.
- Package changes are constrained to reproduced failures and have a regression
  step before implementation.
- Every validation command names the repository or example working directory.
- No unrelated files are staged by any command.
