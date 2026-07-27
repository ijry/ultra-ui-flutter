# Components B Second Source-Order Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the next three registered Components B source routes: Toast, Keyboard, and Slider.

**Architecture:** Add one focused Flutter page per source route under `example/lib/pages/components_b/` and register each page in the existing catalog. Keep remote source images out of runtime by packaging only the row/custom icon assets needed by this batch. Fix the `UPKeyboard` empty-mode branch in the package because the source Keyboard page uses `mode=""` for the car keyboard.

**Tech Stack:** Flutter `>=3.19.0`, Dart `>=3.3.0`, `flutter_test`, existing local `ultra_ui` package, Android/iOS only.

## Global Constraints

- Source of truth is `D:\Repos\xyito\open\uview-plus\src\pages.json` and the matching source files under `src/pages`.
- Preserve registered route order, exact source route title, visible Chinese labels, representative default state, and principal interaction.
- Use `UP*` widgets for each component demonstration. Do not substitute a Material control for the component being demonstrated.
- Do not use remote image resources at runtime; package any required source illustration as Flutter assets.
- `ExampleRoute` entries are added only when a real source page exists. Set a preview route `available: true` only when its matching catalog builder is added.
- Preserve Flutter package names with `UP` prefixes and do not alter unrelated dirty worktree files.
- Every new behavior uses test-first implementation.
- Run `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, then install and launch the APK on MuMu `127.0.0.1:16384` at the batch boundary.

---

## File Structure

```text
example/lib/pages/components_b/toast_page.dart       # UPToast source presets
example/lib/pages/components_b/keyboard_page.dart    # UPKeyboard source presets
example/lib/pages/components_b/slider_page.dart      # UPSlider source sections
example/lib/routes/example_catalog.dart              # Adds three completed route builders
example/lib/routes/example_preview_catalog.dart      # Enables Toast, Keyboard, Slider preview rows
example/test/components_b_pages_test.dart            # Adds page behavior tests
example/test/route_catalog_test.dart                 # Completed route count becomes 34
example/pubspec.yaml                                 # Adds local batch asset directories
example/assets/uview/demo/keyboard/*.png             # Five source row icons
example/assets/uview/demo/toast/jump.png             # Local custom toast image icon
packages/ultra_ui/lib/src/widgets/up_keyboard.dart   # Empty mode renders car keyboard
packages/ultra_ui/lib/src/widgets/up_slider.dart     # Decimal showValue formatting parity
packages/ultra_ui/lib/src/widgets/up_toast.dart      # Loading toast type and duration parity
packages/ultra_ui/test/widgets_test.dart             # Keyboard, Toast, and Slider regressions
```

### Task 1: Fix UPKeyboard Empty-Mode Source Branch

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_keyboard.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- `UPKeyboard(mode: '')` renders the car keyboard and tooltip `车牌号键盘`.
- `UPKeyboard(mode: 'number')` and `UPKeyboard(mode: 'card')` keep their existing number-keyboard branches.

- [x] **Step 1: Write the failing package regression**

Add this test near the existing `UPKeyboard shows tips` test:

```dart
testWidgets('UPKeyboard treats empty source mode as car keyboard',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPKeyboard(show: true, mode: ''),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('车牌号键盘'), findsOneWidget);
  expect(find.text('京'), findsOneWidget);
  expect(find.text('数字键盘'), findsNothing);
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/widgets_test.dart --plain-name "UPKeyboard treats empty source mode as car keyboard" --reporter expanded`

Expected: FAIL because the tooltip is `数字键盘` and the car keys are absent.

- [x] **Step 3: Implement the source branch**

Use source logic:

```dart
bool get _usesNumberKeyboard => widget.mode == 'number' || widget.mode == 'card';
String get _tips {
  if (widget.tips.isNotEmpty) return widget.tips;
  if (widget.mode == 'number') return '数字键盘';
  if (widget.mode == 'card') return '身份证键盘';
  return '车牌号键盘';
}
```

Render `UPNumberKeyboard` only when `_usesNumberKeyboard`; otherwise render `UPCarKeyboard`.

- [x] **Step 4: Run it green**

Run: `flutter test test/widgets_test.dart --plain-name "UPKeyboard treats empty source mode as car keyboard" --reporter expanded`

Expected: PASS.

### Task 2: Add Toast Source Page

**Files:**
- Create: `example/lib/pages/components_b/toast_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Modify: `example/pubspec.yaml`
- Add: `example/assets/uview/demo/toast/jump.png`

**Interfaces:**
- Produces `ToastPage` at route id `componentsB/toast/toast`.
- Shows the eight source rows: `默认主题`, `失败主题(不带图标)`, `成功主题(带图标)`, `位置偏移上方`, `正在加载`, `结束后跳转标签页`, `其它icon图标`, `自定义图片图标`.
- Tapping each row calls real `UPToast.show`; the loading row passes `loading: true`, and the custom image row uses local `assets/uview/demo/toast/jump.png`.
- `type: 'loading'` renders the loading icon and still auto-closes after the source duration unless `duration: -1`.

- [x] **Step 1: Write the failing Toast page test**

Append:

```dart
testWidgets('toast page opens the source success preset', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/toast/toast'));

  await tester.tap(find.text('成功主题(带图标)'));
  await tester.pump();
  expect(find.text('庄生晓梦迷蝴蝶'), findsOneWidget);
  UPToast.hide();
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/components_b_pages_test.dart --plain-name "toast page opens the source success preset" --reporter expanded`

Expected: FAIL with an unregistered route.

- [x] **Step 3: Implement ToastPage and register it**

Create a source-shaped `UPCellGroup` with bold titles and `isLink: true`. Use this row data:

```dart
const List<_ToastPreset> _toastPresets = <_ToastPreset>[
  _ToastPreset(type: 'default', title: '默认主题', message: '锦瑟无端五十弦'),
  _ToastPreset(type: 'error', title: '失败主题(不带图标)', message: '一弦一柱思华年', hideIcon: true),
  _ToastPreset(type: 'success', title: '成功主题(带图标)', message: '庄生晓梦迷蝴蝶'),
  _ToastPreset(type: 'warning', title: '位置偏移上方', message: '望帝春心托杜鹃', position: 'top'),
  _ToastPreset(type: 'loading', title: '正在加载', message: '正在加载', loading: true),
  _ToastPreset(type: 'default', title: '结束后跳转标签页', message: '此情可待成追忆', unresolvedUrl: '/pages/componentsB/tag/tag'),
  _ToastPreset(type: 'default', title: '其它icon图标', message: '只是当时已惘然', icon: 'photo'),
  _ToastPreset(type: 'default', title: '自定义图片图标', message: '只是当时已惘然', icon: 'assets/uview/demo/toast/jump.png'),
];
```

For `unresolvedUrl`, show the toast and then surface `Tag 页面尚未迁移` after the toast completes rather than navigating to an absent route.

- [x] **Step 4: Run Toast tests green**

Run: `flutter test test/components_b_pages_test.dart --plain-name "toast page opens the source success preset" --reporter expanded`

Expected: PASS.

- [x] **Step 5: Add and run the loading duration regression**

Add page and package regressions for the source loading preset:

```dart
testWidgets('toast page loading preset closes after the source duration',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/toast/toast'));

  await tester.tap(find.text('正在加载'));
  await tester.pump();
  expect(find.byType(UPLoadingIcon), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 2100));
  expect(find.byType(UPLoadingIcon), findsNothing);
});
```

Run:

```powershell
flutter test test/components_b_pages_test.dart --plain-name "toast page loading preset closes after the source duration" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPToast loading type uses the source icon and duration" --reporter expanded
```

Expected before the fix: FAIL because Flutter keeps `loading: true` visible forever and does not treat `type: 'loading'` as the loading icon branch.

- [x] **Step 6: Implement and verify loading toast parity**

Treat `type == 'loading'` as loading presentation, and auto-close every toast when `duration != -1`, matching `u-toast.vue`.

Expected: both loading duration regressions pass.

### Task 3: Add Keyboard Source Page

**Files:**
- Create: `example/lib/pages/components_b/keyboard_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/pubspec.yaml`
- Add: `example/assets/uview/demo/keyboard/car.png`
- Add: `example/assets/uview/demo/keyboard/number.png`
- Add: `example/assets/uview/demo/keyboard/IdCard.png`
- Add: `example/assets/uview/demo/keyboard/dot.png`
- Add: `example/assets/uview/demo/keyboard/order.png`

**Interfaces:**
- Produces `KeyboardPage` at route id `componentsB/keyboard/keyboard`.
- Shows the five source rows: `车牌号键盘`, `数字键盘`, `身份证键盘`, `隐藏键盘"."符号`, `打乱键盘按键的顺序`.
- Tapping a row opens a single real `UPKeyboard` configured from source `keyData`, and input changes update a visible source-compatible buffer.

- [x] **Step 1: Write the failing Keyboard page test**

Append:

```dart
testWidgets('keyboard page opens the source car keyboard preset',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/keyboard/keyboard'));

  await tester.tap(find.text('车牌号键盘'));
  await tester.pumpAndSettle();
  expect(find.text('车牌号键盘'), findsWidgets);
  expect(find.text('京'), findsOneWidget);
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/components_b_pages_test.dart --plain-name "keyboard page opens the source car keyboard preset" --reporter expanded`

Expected: FAIL with an unregistered route.

- [x] **Step 3: Implement KeyboardPage and register it**

Use `_KeyboardPreset(mode: '', dotDisabled: false, random: false)` for the car row, `mode: 'number'` for number rows, and `mode: 'card'` for ID card. Mount exactly one `UPKeyboard` in a `Stack`; keep it controlled by `_showKeyboard`. Use local asset icons in `UPCell.iconSlot`.

- [x] **Step 4: Run Keyboard tests green**

Run: `flutter test test/components_b_pages_test.dart --plain-name "keyboard page opens the source car keyboard preset" --reporter expanded`

Expected: PASS.

### Task 4: Add Slider Source Page

**Files:**
- Create: `example/lib/pages/components_b/slider_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Modify: `packages/ultra_ui/lib/src/widgets/up_slider.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- Produces `SliderPage` at route id `componentsB/slider/slider`.
- Includes source sections: `基本案例`, `自定义范围(10—50)`, `指定步长(每次步进5)`, `小数步长(每次步进0.1)`, `自定义样式`, `自定义样式(图片)`, `区间选择(双滑块)`, `垂直方向`, `垂直方向区间选择`, `在Modal弹窗中使用`, `在popup弹窗中使用`.
- The `前进` button increments the first slider value through real `UPSlider` state.
- `showValue` preserves source decimal values, so `value: 0.3` with `step: 0.1` displays `0.3`.

- [x] **Step 1: Write the failing Slider page test**

Append:

```dart
testWidgets('slider page advances the basic source slider', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/slider/slider'));

  expect(find.text('当前值：30'), findsOneWidget);
  await tester.tap(find.text('前进'));
  await tester.pump();
  expect(find.text('当前值：31'), findsOneWidget);
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/components_b_pages_test.dart --plain-name "slider page advances the basic source slider" --reporter expanded`

Expected: FAIL with an unregistered route.

- [x] **Step 3: Implement SliderPage and register it**

Use `ExampleDemoBlock` sections and real `UPSlider` instances. Use `UPButton(text: '前进')`, `UPText(text: '打开弹窗')`, `UPModal(show: _modalShow)`, and `UPPopup(show: _popupShow)` for the two popup sections. For the source SVG thumb section, use a red `UPIcon(name: 'photo')` as the Flutter slot-equivalent visual marker because `UPSlider` does not expose a thumb slot yet.

- [x] **Step 4: Run Slider tests green**

Run: `flutter test test/components_b_pages_test.dart --plain-name "slider page advances the basic source slider" --reporter expanded`

Expected: PASS.

- [x] **Step 5: Add and run the decimal showValue regression red**

Add `UPSlider showValue preserves decimal step values` to the package widget tests and run it in isolation.

Expected before the fix: FAIL because the rendered label is `0`.

- [x] **Step 6: Implement and verify decimal label formatting**

Format displayed single and range values using the source step/min/max precision, strip floating-point noise and trailing zeroes, and use the formatter for both labels.

Run: `flutter test test/widgets_test.dart --plain-name "UPSlider showValue preserves decimal step values" --reporter expanded`

Expected: PASS with the label `0.3`.

### Task 5: Batch Verification and Commit

**Files:**
- All files from Tasks 1-4.

**Interfaces:**
- Completed example route catalog has 34 routes: 4 main, 23 Components A, and 7 Components B.
- Toast, Keyboard, and Slider preview rows are `available: true`; later preview rows remain unavailable.

- [x] **Step 1: Run formatting**

Run:

```powershell
cd example
dart format lib test
cd ..\packages\ultra_ui
dart format lib/src/widgets/up_keyboard.dart test/widgets_test.dart
```

- [x] **Step 2: Run full verification**

Run:

```powershell
cd example
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

Run:

```powershell
cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --reporter expanded
```

- [x] **Step 3: Install and launch on MuMu**

Run:

```powershell
cd ..\example
$adb = (Get-Command adb).Source
$serial = '127.0.0.1:16384'
& $adb -s $serial install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s $serial shell am force-stop com.example.ultra_ui_example
& $adb -s $serial shell monkey -p com.example.ultra_ui_example -c android.intent.category.LAUNCHER 1
& $adb -s $serial shell dumpsys window | Select-String 'com.example.ultra_ui_example/.MainActivity'
```

- [x] **Step 4: Commit only this batch**

```powershell
git add -- docs/superpowers/plans/2026-07-27-uview-components-b-batch-2.md example/lib/pages/components_b/toast_page.dart example/lib/pages/components_b/keyboard_page.dart example/lib/pages/components_b/slider_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart example/pubspec.yaml example/assets/uview/demo/toast/jump.png example/assets/uview/demo/keyboard/car.png example/assets/uview/demo/keyboard/number.png example/assets/uview/demo/keyboard/IdCard.png example/assets/uview/demo/keyboard/dot.png example/assets/uview/demo/keyboard/order.png packages/ultra_ui/lib/src/widgets/up_keyboard.dart packages/ultra_ui/lib/src/widgets/up_slider.dart packages/ultra_ui/lib/src/widgets/up_toast.dart packages/ultra_ui/test/widgets_test.dart
git commit -m "feat(example): add toast keyboard slider source pages"
```

## Plan Self-Review

- Spec coverage: The plan continues Components B in exact registered `pages.json` order after `parse/jump`, covers three consecutive routes, keeps all runtime images local, and includes Android/MuMu verification.
- Placeholder scan: No `TBD`, `TODO`, or vague "add tests" steps remain; each test and page behavior is named.
- Type consistency: Page classes, route ids, source paths, and widget properties match the existing catalog and `UP*` APIs.
