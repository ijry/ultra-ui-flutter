# Components C Batch 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the next five source-order Components C examples (`steps`, `navbar`, `skeleton`, `input`, and `album`) with source-compatible interactions, routes, previews, tests, and targeted `UPInput` parity fixes.

**Architecture:** Keep one focused page per source route under `example/lib/pages/components_c/`, using the existing `ExamplePageScaffold` and `ExampleDemoBlock`. Reuse the existing `UPSteps`, `UPNavbar`, `UPSkeleton`, `UPInput`, `UPAlbum`, and supporting widgets; compose the Input page's prefix/suffix slots locally instead of adding a new generic slot abstraction. Register all five routes after the current Components C `text` route and enable only those five preview rows.

**Tech Stack:** Flutter/Dart, `ultra_ui` package widgets, Flutter widget tests, existing Example route catalogs, MuMu ADB verification.

## Global Constraints

- Preserve the source order from `D:\Repos\xyito\open\uview-plus\src\pages.json`.
- Preserve source Chinese labels, source default values, and the primary interaction of each demo block.
- Do not add dependencies, permissions, device network mutation, or remote image requirements to tests.
- Use source album URLs at runtime; rely on `UPImage` loading/error fallback and assert album layout/callbacks without requiring successful downloads.
- Keep `README.md` and unrelated historical untracked files untouched.
- Work directly on the approved `main` checkout; do not create another worktree.
- The implementation boundary includes only the five pages, route/preview/test updates, required direct package widgets, and the implementation plan.

---

### Task 1: Close UPInput Source Compatibility Gaps

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_input.dart`
- Test: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- Consumes the existing `UPInput` constructor and `UPIcon` properties `size`, `color`, `bold`, and `top`.
- Produces source-compatible `onlyClearableOnFocused` defaults and style forwarding used by `InputPage`.

- [ ] **Step 1: Write the failing default and icon-style tests**

Append tests near the existing `UPInput clearable emits empty string` coverage:

```dart
test('UPInput uses the source clear-button focus default', () {
  expect(const UPInput(clearable: true).onlyClearableOnFocused, isTrue);
});

testWidgets('UPInput forwards prefix and suffix icon styles', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPInput(
          prefixIcon: 'search',
          suffixIcon: 'map-fill',
          prefixIconStyle:
              'font-size: 22px; color: #123456; font-weight: bold; top: 2px',
          suffixIconStyle: <String, dynamic>{
            'fontSize': '20px',
            'color': '#654321',
          },
        ),
      ),
    ),
  );

  final icons = tester.widgetList<UPIcon>(find.byType(UPIcon)).toList();
  expect(icons, hasLength(2));
  expect(icons[0].size, '22px');
  expect(icons[0].color, '#123456');
  expect(icons[0].bold, isTrue);
  expect(icons[0].top, '2px');
  expect(icons[1].size, '20px');
  expect(icons[1].color, '#654321');
});
```

- [ ] **Step 2: Run the focused tests and verify the current implementation fails**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --name "UPInput uses the source clear-button focus default" --reporter expanded
flutter test test/widgets_test.dart --name "UPInput forwards prefix and suffix icon styles" --reporter expanded
```

Expected failures are the current default `false` and hard-coded icon `size: 18`/theme color.

- [ ] **Step 3: Implement the minimal compatibility fix**

Change the constructor default to:

```dart
this.onlyClearableOnFocused = true,
```

Add a private helper that accepts either a Map or CSS-like string and returns normalized keys for `fontSize`, `color`, `fontWeight`, and `top`. For string input, split declarations on `;`, split each declaration at its first `:`, trim both sides, and normalize `font-size`/`font-weight` to camel case. In `build`, resolve each style independently and pass the values to the prefix/suffix `UPIcon`; treat `fontWeight: bold` or a numeric weight of at least `600` as `bold: true`. Keep the existing 18px/theme-color defaults when a style field is absent.

- [ ] **Step 4: Run both focused tests and the existing Input-adjacent tests**

Run:

```powershell
flutter test test/widgets_test.dart --name "UPInput uses the source clear-button focus default" --reporter expanded
flutter test test/widgets_test.dart --name "UPInput forwards prefix and suffix icon styles" --reporter expanded
flutter test test/widgets_test.dart --name "UPInput clearable emits empty string" --reporter expanded
```

Expected: all selected tests pass.

---

### Task 2: Implement StepsPage

**Files:**
- Create: `example/lib/pages/components_c/steps_page.dart`
- Test: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes `UPSteps(children: List<Widget>, direction, current, dot, activeIcon, inactiveIcon, activeColor)` and `UPStepsItem(title, desc, error, iconWidget, itemStyle)`.
- Produces route page key `example-page-componentsC/steps/steps` and visible source block labels for later route/catalog tests.

- [ ] **Step 1: Add a failing StepsPage route test**

Add this test to `components_c_pages_test.dart` before implementing the page:

```dart
testWidgets('steps page renders source variants', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/steps/steps'));

  expect(find.text('基础演示'), findsOneWidget);
  expect(find.text('显示点类型'), findsOneWidget);
  expect(find.text('错误状态'), findsOneWidget);
  expect(find.text('自定义图标'), findsOneWidget);
  expect(find.text('自定义插槽'), findsOneWidget);
  expect(find.text('自定义颜色'), findsOneWidget);
  expect(find.text('竖向展示'), findsOneWidget);
  expect(find.text('运'), findsOneWidget);
  expect(
    find.byWidgetPredicate((widget) => widget is UPStepsItem && widget.error),
    findsOneWidget,
  );
});
```

- [ ] **Step 2: Run the focused test and verify the route is missing**

Run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "steps page renders source variants" --reporter expanded
```

Expected: failure because `componentsC/steps/steps` has no registered builder yet.

- [ ] **Step 3: Implement the source blocks**

Create `StepsPage` as a `StatelessWidget` with the page key and seven
`ExampleDemoBlock`s. Use reusable local item lists only where they do not hide
source differences. Set the first current value to `1`; use the source titles
and times exactly. Render the custom slot as a 21px warning-colored circular
container containing `运`; render the first item style with the page background
color and the custom active color `#3c9cff`.

- [ ] **Step 4: Run the focused test and format the page**

Run:

```powershell
dart format lib/pages/components_c/steps_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --name "steps page renders source variants" --reporter expanded
```

Expected: the test passes and the seven source labels plus error item render.

---

### Task 3: Implement NavbarPage

**Files:**
- Create: `example/lib/pages/components_c/navbar_page.dart`
- Test: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes `UPNavbar` props `safeAreaInsetTop`, `fixed`, `placeholder`, `autoBack`, `leftText`, `rightIcon`, `leftSlot`, `onLeftClick`, and `onRightClick`.
- Produces page key `example-page-componentsC/navbar/navbar` and deterministic left/right feedback strings.

- [ ] **Step 1: Add the failing NavbarPage interaction test**

Add:

```dart
testWidgets('navbar page renders source variants and callbacks', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/navbar/navbar'));

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('自定义文本'), findsOneWidget);
  expect(find.text('自定义插槽'), findsOneWidget);
  expect(find.text('个人中心'), findsNWidgets(2));
  expect(find.text('返回'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('navbar-page-left')));
  await tester.pump();
  expect(find.text('左侧点击：1'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('navbar-page-right')));
  await tester.pump();
  expect(find.text('右侧点击：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run it and verify the route is missing**

Run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "navbar page renders source variants and callbacks" --reporter expanded
```

Expected: failure because the route is not registered.

- [ ] **Step 3: Implement the fixed and inline navbar examples**

Create a stateful `NavbarPage` with integer left/right counters. Put the source
fixed safe-area navbar with `title: 导航栏`, `fixed: true`, `placeholder: true`,
and `autoBack: true` at the top. Put the three inline sections below it. Give
the callback-driven navbar keys `navbar-page-left` and `navbar-page-right`.
Build the custom left slot from `UPIcon(name: arrow-left)`, `UPLine(direction:
column, hairline: false, length: 16, margin: 0 8px)`, and
`UPIcon(name: home)`, inside the source rounded bordered container.

- [ ] **Step 4: Run the focused test and format**

Run:

```powershell
dart format lib/pages/components_c/navbar_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --name "navbar page renders source variants and callbacks" --reporter expanded
```

Expected: source titles render and both callbacks update exactly once.

---

### Task 4: Implement SkeletonPage

**Files:**
- Create: `example/lib/pages/components_c/skeleton_page.dart`
- Test: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes `UPSkeleton(loading, animate, rows, rowsWidth, rowsHeight, title, avatar, child)` and `UPSwitch(value, onChange)`.
- Produces page key `example-page-componentsC/skeleton/skeleton`, switch keys, and visible source content after loading is disabled.

- [ ] **Step 1: Add the failing loading-state test**

Add:

```dart
testWidgets('skeleton page toggles source loading state', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/skeleton/skeleton'));

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('自定义段落行数'), findsOneWidget);
  expect(find.text('设置段落宽度'), findsOneWidget);
  expect(find.text('设置段落高度'), findsOneWidget);
  expect(find.text('是否开启动画'), findsOneWidget);
  expect(find.text('展示头像'), findsOneWidget);
  expect(find.text('切换状态'), findsOneWidget);
  expect(find.text('利剑出鞘,一统江湖'), findsNothing);

  await tester.tap(find.byKey(const ValueKey('skeleton-page-loading-switch')));
  await tester.pump();
  expect(find.text('利剑出鞘,一统江湖'), findsOneWidget);
});
```

- [ ] **Step 2: Run it and verify the route is missing**

Run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "skeleton page toggles source loading state" --reporter expanded
```

Expected: failure because the route is not registered.

- [ ] **Step 3: Implement all seven source blocks and two switches**

Create a stateful page with `_animate = true` and `_loading = false`. Give the
two `UPSwitch` instances keys `skeleton-page-animate-switch` and
`skeleton-page-loading-switch`. Use the exact source row widths/heights for the
first four examples. For the final block, pass the source content as
`UPSkeleton.child`: a 40px logo placeholder beside the two source `UPText`
values. Keep the source transparent bottom gap.

- [ ] **Step 4: Run focused test, settle animations, and format**

Run:

```powershell
dart format lib/pages/components_c/skeleton_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --name "skeleton page toggles source loading state" --reporter expanded
```

Expected: the test passes without pending animation exceptions.

---

### Task 5: Implement InputPage and UPInput Usage Coverage

**Files:**
- Create: `example/lib/pages/components_c/input_page.dart`
- Test: `example/test/components_c_pages_test.dart`
- Modify if required by Task 1: `packages/ultra_ui/lib/src/widgets/up_input.dart`

**Interfaces:**
- Consumes `UPInput` state methods `clear`, `setValue`, `onConfirm`, and `isPassword`, plus `UPCodeController` and `UPCode` callbacks.
- Produces page key `example-page-componentsC/input/input`, field keys `input-page-basic`, `input-page-number`, and `input-page-password`, and visible basic/confirm/code feedback.

- [ ] **Step 1: Add the failing InputPage interaction test**

Add:

```dart
testWidgets('input page edits, filters, clears, and confirms source values',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/input/input'));

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('前后插槽'), findsOneWidget);

  final basic = find.descendant(
    of: find.byKey(const ValueKey('input-page-basic')),
    matching: find.byType(TextField),
  );
  await tester.enterText(basic, 'hello');
  await tester.pump();
  expect(find.text('基础值：hello'), findsOneWidget);

  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pump();
  expect(find.text('确认：hello'), findsOneWidget);

  final number = find.descendant(
    of: find.byKey(const ValueKey('input-page-number')),
    matching: find.byType(TextField),
  );
  await tester.enterText(number, '12a3');
  await tester.pump();
  expect(find.text('数字值：123'), findsOneWidget);

  final passwordState = tester.state<UPInputState>(
    find.byKey(const ValueKey('input-page-password')),
  );
  expect(passwordState.isPassword(), isTrue);
  passwordState.setValue('secret');
  passwordState.onClear();
  await tester.pump();
  expect(passwordState.value, isEmpty);
});
```

- [ ] **Step 2: Run it and verify the route is missing**

Run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "input page edits, filters, clears, and confirms source values" --reporter expanded
```

Expected: failure because the route is not registered.

- [ ] **Step 3: Implement the eleven source blocks**

Create a stateful `InputPage` with local strings for `value`, `inputNumber`,
`inputPassword`, `tips`, `basicConfirm`, and `codeText`, plus a
`UPCodeController`. Use `UPInput` keys listed in the Interfaces section. The
basic button sets a deterministic string such as `0.123456`; its confirm
callback sets `basicConfirm` and shows the source toast. The number field uses
`type: number`; the password field uses `password`, `clearable`, and
`passwordVisibilityToggle`.

Use source props for colors, borders, clear behavior, underline, disabled,
circle shape, prefix/suffix icons, and the styles from Task 1. Compose the
prefix slot as `UPText(text: http://, type: tips)` and the suffix slot as a
`UPCode` plus mini success button. Start the code controller countdown only
after the button callback and update `tips` from `UPCode.onChange`.

- [ ] **Step 4: Run focused tests and verify cleanup**

Run:

```powershell
dart format lib/pages/components_c/input_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --name "input page edits, filters, clears, and confirms source values" --reporter expanded
```

Expected: all value feedback and password/clear assertions pass; hide any
toast shown by the test before it exits.

---

### Task 6: Implement AlbumPage

**Files:**
- Create: `example/lib/pages/components_c/album_page.dart`
- Test: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes `UPAlbum` props `urls`, `keyName`, `singleSize`, `multipleSize`, `space`, `singleMode`, `multipleMode`, `maxCount`, `rowCount`, `shape`, `radius`, `autoWrap`, and `onPreview`.
- Produces page key `example-page-componentsC/album/album` and visible preview feedback from the first source album.

- [ ] **Step 1: Add the failing AlbumPage test**

Add:

```dart
testWidgets('album page renders source variants and previews an image',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsC/album/album'));

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('多图模式'), findsOneWidget);
  expect(find.text('图文对齐'), findsOneWidget);
  expect(find.text('更改裁剪模式'), findsOneWidget);
  expect(find.text('更改图片大小'), findsOneWidget);
  expect(find.text('自定义圆角'), findsOneWidget);
  expect(find.text('自定义形状'), findsOneWidget);
  expect(find.text('自适应自动换行'), findsOneWidget);

  final multi = tester.widget<UPAlbum>(
    find.byKey(const ValueKey('album-page-multiple')),
  );
  expect(multi.urls, hasLength(10));
  expect(multi.maxCount, 9);

  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('album-page-basic')),
      matching: find.byType(UPImage),
    ),
  );
  await tester.pump();
  expect(find.textContaining('预览：'), findsOneWidget);
});
```

- [ ] **Step 2: Run it and verify the route is missing**

Run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "album page renders source variants and previews an image" --reporter expanded
```

Expected: failure because the route is not registered.

- [ ] **Step 3: Implement exact source URL families and eight blocks**

Define the source URL constants for images 1 through 10. Pass the single
object list with `keyName: src2`; pass the ten-image list to the multiple block;
use the exact source subsets for the alignment, crop, size, radius, circle,
and auto-wrap blocks. Add keys `album-page-basic` and `album-page-multiple`.
Update `_previewText` from `onPreview` with the selected URL and index. Use
source modes and dimensions without introducing an image download mock into
production code.

- [ ] **Step 4: Run focused test and format**

Run:

```powershell
dart format lib/pages/components_c/album_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --name "album page renders source variants and previews an image" --reporter expanded
```

Expected: section labels, source props, and preview feedback pass even when
remote images resolve through the existing error fallback.

---

### Task 7: Register Routes, Enable Previews, and Update Catalog Tests

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`
- Test: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes the five page classes and builders created in Tasks 2 through 6.
- Produces route IDs in this exact order after `componentsC/text/text`:

```text
componentsC/steps/steps
componentsC/navbar/navbar
componentsC/skeleton/skeleton
componentsC/input/input
componentsC/album/album
```

- [ ] **Step 1: Add the failing catalog assertions**

Update the catalog test before wiring all five routes:

```dart
expect(exampleRoutes, hasLength(65));
expect(
  componentCRoutes,
  <String>[
    'componentsC/form/form',
    'componentsC/textarea/textarea',
    'componentsC/noNetwork/noNetwork',
    'componentsC/loadmore/loadmore',
    'componentsC/text/text',
    'componentsC/steps/steps',
    'componentsC/navbar/navbar',
    'componentsC/skeleton/skeleton',
    'componentsC/input/input',
    'componentsC/album/album',
  ],
);
```

- [ ] **Step 2: Run route tests and verify the expected missing-route failure**

Run:

```powershell
cd example
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: route total/order assertions fail until the five builders are added.

- [ ] **Step 3: Wire imports, route records, builders, and preview availability**

Add imports and builders for the five page classes. Add route records after the
existing `_buildText` route, preserving source titles `步骤条`, `导航栏`,
`骨架屏`, `输入框`, and `相册`. Mark only the matching five preview rows
`available: true`; do not reorder `componentPreviewRoutes`.

- [ ] **Step 4: Run catalog and all Components C tests**

Run:

```powershell
dart format lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
flutter test test/route_catalog_test.dart --reporter expanded
flutter test test/components_c_pages_test.dart --reporter expanded
```

Expected: route count is 65, source order is exact, preview consistency passes,
and all ten Components C page tests pass.

---

### Task 8: Full Verification, Device Check, and Implementation Commit

**Files:**
- Modify only the files listed in Tasks 1 through 7.
- Include in commit: `docs/superpowers/plans/2026-08-06-uview-components-c-batch-2.md`.

- [ ] **Step 1: Format the complete batch**

Run:

```powershell
cd example
dart format lib/pages/components_c/steps_page.dart lib/pages/components_c/navbar_page.dart lib/pages/components_c/skeleton_page.dart lib/pages/components_c/input_page.dart lib/pages/components_c/album_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_steps.dart lib/src/widgets/up_navbar.dart lib/src/widgets/up_skeleton.dart lib/src/widgets/up_input.dart lib/src/widgets/up_album.dart test/widgets_test.dart
```

- [ ] **Step 2: Run static analysis and full tests**

Run:

```powershell
cd example
flutter analyze
flutter test --reporter expanded

cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --reporter expanded
```

Expected: zero analysis issues and zero test failures.

- [ ] **Step 3: Build and verify the Android app**

Run:

```powershell
cd ..\example
flutter build apk --debug
$adb = 'C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe'
& $adb -s 127.0.0.1:16384 install -r 'build\app\outputs\flutter-apk\app-debug.apk'
& $adb -s 127.0.0.1:16384 shell am force-stop com.example.ultra_ui_example
& $adb -s 127.0.0.1:16384 shell monkey -p com.example.ultra_ui_example 1
& $adb -s 127.0.0.1:16384 shell dumpsys activity activities | Select-String -Pattern 'topResumedActivity'
```

Expected: build/install succeed and the output contains
`com.example.ultra_ui_example/.MainActivity` as `topResumedActivity`.

- [ ] **Step 4: Check the commit boundary**

Run:

```powershell
git diff --check
git status --short
git diff --name-only
```

Confirm that `README.md` and unrelated untracked files are not staged. Stage
only the five pages, five direct package widgets, route/preview/test updates,
the package regression test changes, and this implementation plan.

- [ ] **Step 5: Commit the implementation batch**

Run:

```powershell
git add -- docs/superpowers/plans/2026-08-06-uview-components-c-batch-2.md example/lib/pages/components_c/steps_page.dart example/lib/pages/components_c/navbar_page.dart example/lib/pages/components_c/skeleton_page.dart example/lib/pages/components_c/input_page.dart example/lib/pages/components_c/album_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_c_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets/up_steps.dart packages/ultra_ui/lib/src/widgets/up_navbar.dart packages/ultra_ui/lib/src/widgets/up_skeleton.dart packages/ultra_ui/lib/src/widgets/up_input.dart packages/ultra_ui/lib/src/widgets/up_album.dart packages/ultra_ui/test/widgets_test.dart
git diff --cached --check
git commit -m "Add components C steps input and album examples"
```

After committing, verify `git show --stat --oneline HEAD` and confirm the
working tree contains only the pre-existing `README.md` and unrelated
untracked files.
