# Components B Third Source-Order Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the next three registered Components B source routes after Slider: Upload, Notify, and CountDown.

**Architecture:** Add one Flutter example page per source route under `example/lib/pages/components_b/`, register the pages in source order, and enable their preview rows. Keep source remote images local by packaging the Upload custom trigger image and Notify row icons as example assets. Use existing `UPUpload`, `UPNotify`, and `UPCountDown` package widgets; include those untracked package files in this batch so the committed example has the widget implementations it demonstrates.

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
example/lib/pages/components_b/upload_page.dart       # UPUpload source sections
example/lib/pages/components_b/notify_page.dart       # UPNotify source presets
example/lib/pages/components_b/count_down_page.dart   # UPCountDown source sections
example/lib/routes/example_catalog.dart               # Adds three completed route builders
example/lib/routes/example_preview_catalog.dart       # Enables Upload, Notify, CountDown preview rows
example/test/components_b_pages_test.dart             # Adds page behavior tests
example/test/route_catalog_test.dart                  # Completed route count becomes 37
example/pubspec.yaml                                  # Adds local batch asset directories
example/assets/uview/demo/upload/positive.png         # Source custom upload trigger
example/assets/uview/demo/notify/*.png                # Seven source row icons
packages/ultra_ui/lib/src/widgets/up_upload.dart      # UPUpload implementation used by UploadPage
packages/ultra_ui/lib/src/widgets/up_notify.dart      # UPNotify implementation used by NotifyPage
packages/ultra_ui/lib/src/widgets/up_count_down.dart  # UPCountDown implementation used by CountDownPage
```

### Task 1: Add Upload Source Page

**Files:**
- Create: `example/lib/pages/components_b/upload_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Modify: `example/pubspec.yaml`
- Add: `example/assets/uview/demo/upload/positive.png`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_upload.dart`

**Interfaces:**
- Produces `UploadPage` at route id `componentsB/upload/upload`.
- Shows source sections: `基础用法`, `上传视频`, `文件预览`, `隐藏上传按钮`, `限制上传数量`, `自定义上传样式`.
- Uses real `UPUpload` widgets for all six sections.
- Runtime image paths use local assets only.

- [x] **Step 1: Write the failing Upload page test**

Append to `example/test/components_b_pages_test.dart`:

```dart
testWidgets('upload page adds a source basic file', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/upload/upload'));

  expect(find.text('基础用法：0'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('upload-page-basic')),
      matching: find.byWidgetPredicate(
        (widget) => widget is UPIcon && widget.name == 'camera-fill',
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('基础用法：1'), findsOneWidget);
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/components_b_pages_test.dart --plain-name "upload page adds a source basic file" --reporter expanded`

Expected: FAIL with an unregistered route.

- [x] **Step 3: Implement UploadPage and register it**

Create `UploadPage` with six `ExampleDemoBlock` sections. Use controlled local file lists:

```dart
final List<Map<String, dynamic>> _fileList1 = <Map<String, dynamic>>[];
final List<Map<String, dynamic>> _fileList2 = <Map<String, dynamic>>[];
final List<Map<String, dynamic>> _fileList3 = <Map<String, dynamic>>[
  {'url': 'assets/uview/swiper/swiper1.png', 'status': 'success'},
];
final List<Map<String, dynamic>> _fileList4 = <Map<String, dynamic>>[
  {'url': 'assets/uview/swiper/swiper1.png', 'status': 'success'},
  {'url': 'assets/uview/swiper/swiper1.png', 'status': 'success'},
];
final List<Map<String, dynamic>> _fileList5 = <Map<String, dynamic>>[];
final List<Map<String, dynamic>> _fileList6 = <Map<String, dynamic>>[];
```

Each uploader gets a deterministic local `picker`:

```dart
Future<dynamic> _pickFile(String name, String accept) async {
  if (accept == 'video') {
    return {'url': 'local-demo-video.mp4', 'name': 'local-demo-video.mp4', 'type': 'video'};
  }
  return {
    'url': 'assets/uview/swiper/swiper1.png',
    'name': 'swiper1.png',
    'type': 'image',
  };
}
```

Use `onUpdateFileList` to keep each list controlled and show `基础用法：${_fileList1.length}` under the first uploader.

For `自定义上传样式`, pass:

```dart
trigger: Image.asset(
  'assets/uview/demo/upload/positive.png',
  width: 250,
  height: 150,
  fit: BoxFit.cover,
),
width: 250,
height: 150,
```

Register after `componentsB/slider/slider`:

```dart
const ExampleRoute(
  id: 'componentsB/upload/upload',
  sourcePath: 'pages/componentsB/upload/upload',
  title: '上传',
  group: ExampleRouteGroup.componentsB,
  builder: _buildUpload,
),
```

Set the matching preview route to `available: true`.

- [x] **Step 4: Run Upload tests green**

Run: `flutter test test/components_b_pages_test.dart --plain-name "upload page adds a source basic file" --reporter expanded`

Expected: PASS.

### Task 2: Add Notify Source Page

**Files:**
- Create: `example/lib/pages/components_b/notify_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/pubspec.yaml`
- Add: `example/assets/uview/demo/notify/main.png`
- Add: `example/assets/uview/demo/notify/success.png`
- Add: `example/assets/uview/demo/notify/error.png`
- Add: `example/assets/uview/demo/notify/warning.png`
- Add: `example/assets/uview/demo/notify/customStyle.png`
- Add: `example/assets/uview/demo/notify/customTime.png`
- Add: `example/assets/uview/demo/notify/height.png`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_notify.dart`

**Interfaces:**
- Produces `NotifyPage` at route id `componentsB/notify/notify`.
- Shows the seven source rows: `主要通知`, `成功通知`, `危险通知`, `警告通知`, `自定义样式`, `自定义时间`, `插入状态栏高度`.
- Tapping each row calls a real `UPNotifyState.show(options: ...)`.

- [x] **Step 1: Write the failing Notify page test**

Append:

```dart
testWidgets('notify page opens the source success preset', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/notify/notify'));

  await tester.tap(find.text('成功通知'));
  await tester.pump();
  expect(find.text('notify顶部提示'), findsOneWidget);
  expect(find.byType(UPNotify), findsOneWidget);
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/components_b_pages_test.dart --plain-name "notify page opens the source success preset" --reporter expanded`

Expected: FAIL with an unregistered route.

- [x] **Step 3: Implement NotifyPage and register it**

Use a `GlobalKey<UPNotifyState>`:

```dart
final GlobalKey<UPNotifyState> _notifyKey = GlobalKey<UPNotifyState>();
```

Mount one real notify:

```dart
UPNotify(key: _notifyKey)
```

Use `_NotifyPreset` row data mirroring the source `notifyData`, with local icon assets under `assets/uview/demo/notify/`. Register after Upload:

```dart
const ExampleRoute(
  id: 'componentsB/notify/notify',
  sourcePath: 'pages/componentsB/notify/notify',
  title: '消息提示',
  group: ExampleRouteGroup.componentsB,
  builder: _buildNotify,
),
```

Set the matching preview route to `available: true`.

- [x] **Step 4: Run Notify tests green**

Run: `flutter test test/components_b_pages_test.dart --plain-name "notify page opens the source success preset" --reporter expanded`

Expected: PASS.

### Task 3: Add CountDown Source Page

**Files:**
- Create: `example/lib/pages/components_b/count_down_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`
- Add if untracked: `packages/ultra_ui/lib/src/widgets/up_count_down.dart`

**Interfaces:**
- Produces `CountDownPage` at route id `componentsB/countDown/countDown`.
- Includes source sections: `基础用法`, `自定义格式`, `毫秒级渲染`, `自定义样式`, `手动控制`.
- Uses real `UPCountDown` widgets in each section.
- The manual control section exposes `重置`, `开始`, `暂停` through `UPGrid` and `UPGridItem`, calling `UPCountDownState.reset/start/pause`.

- [x] **Step 1: Write the failing CountDown page test**

Append:

```dart
testWidgets('countDown page starts and pauses the manual source timer',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/countDown/countDown'));

  expect(find.text('手动状态：未开始'), findsOneWidget);
  await tester.tap(find.text('开始'));
  await tester.pump();
  expect(find.text('手动状态：运行中'), findsOneWidget);

  await tester.tap(find.text('暂停'));
  await tester.pump();
  expect(find.text('手动状态：已暂停'), findsOneWidget);
});
```

- [x] **Step 2: Run it red**

Run: `flutter test test/components_b_pages_test.dart --plain-name "countDown page starts and pauses the manual source timer" --reporter expanded`

Expected: FAIL with an unregistered route.

- [x] **Step 3: Implement CountDownPage and register it**

Use a `GlobalKey<UPCountDownState>` for the manual timer. Show source-like custom time rows with `UPCountDown.onChange` updating local `UPCountDownTimeData`.

Register after Notify:

```dart
const ExampleRoute(
  id: 'componentsB/countDown/countDown',
  sourcePath: 'pages/componentsB/countDown/countDown',
  title: '倒计时',
  group: ExampleRouteGroup.componentsB,
  builder: _buildCountDown,
),
```

Set the matching preview route to `available: true`.

- [x] **Step 4: Run CountDown tests green**

Run: `flutter test test/components_b_pages_test.dart --plain-name "countDown page starts and pauses the manual source timer" --reporter expanded`

Expected: PASS.

### Task 4: Batch Verification and Commit

**Files:**
- All files from Tasks 1-3.

**Interfaces:**
- Completed example route catalog has 37 routes: 4 main, 23 Components A, and 10 Components B.
- Upload, Notify, and CountDown preview rows are `available: true`; later preview rows remain unavailable.

- [x] **Step 1: Run formatting**

Run:

```powershell
cd example
dart format lib/pages/components_b/upload_page.dart lib/pages/components_b/notify_page.dart lib/pages/components_b/count_down_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
cd ..\packages\ultra_ui
dart format lib/src/widgets/up_upload.dart lib/src/widgets/up_notify.dart lib/src/widgets/up_count_down.dart
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
git add -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-3.md example/lib/pages/components_b/upload_page.dart example/lib/pages/components_b/notify_page.dart example/lib/pages/components_b/count_down_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart example/pubspec.yaml example/assets/uview/demo/upload/positive.png example/assets/uview/demo/notify/main.png example/assets/uview/demo/notify/success.png example/assets/uview/demo/notify/error.png example/assets/uview/demo/notify/warning.png example/assets/uview/demo/notify/customStyle.png example/assets/uview/demo/notify/customTime.png example/assets/uview/demo/notify/height.png packages/ultra_ui/lib/src/widgets/up_upload.dart packages/ultra_ui/lib/src/widgets/up_notify.dart packages/ultra_ui/lib/src/widgets/up_count_down.dart
git commit -m "feat(example): add upload notify countdown source pages"
```

## Plan Self-Review

- Spec coverage: The plan continues Components B in exact registered `pages.json` order after `slider/slider`, covers three consecutive routes, keeps runtime images local, and includes Android/MuMu verification.
- Placeholder scan: No `TBD`, `TODO`, or vague "add tests" steps remain; every route has a named failing test and implementation step.
- Type consistency: Page classes, route ids, source paths, widget APIs, and asset paths match the existing catalog conventions and available `UP*` APIs.
