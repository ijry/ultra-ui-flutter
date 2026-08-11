# Components C Batch 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the source-order Components C `swiper`, `scrollList`, `codeInput`, `modal`, and `picker` example pages with local deterministic data, route registration, focused tests, and the minimum confirmed `UPSwiper` vertical-mode parity fix.

**Architecture:** Keep one dedicated example page per route under `example/lib/pages/components_c/`. Use the existing `ExamplePageScaffold`, `ExampleDemoBlock`, and public `ultra_ui` widgets. Add the vertical swiper capability at the package boundary only after a focused regression test proves the current API gap; keep all other package behavior unchanged.

**Tech Stack:** Flutter SDK, Dart, Material 3 page shell, local `ultra_ui` package, `flutter_test`, local raster assets, existing example route catalogs, and Android Gradle debug build.

## Global Constraints

- Batch scope is exactly `componentsC/swiper/swiper`, `componentsC/scrollList/scrollList`, `componentsC/codeInput/codeInput`, `componentsC/modal/modal`, and `componentsC/picker/picker`.
- Preserve source Chinese titles, source section labels, source-order route registration, representative defaults, and principal interactions.
- Keep all image and data fixtures local and deterministic; do not add network image, video, API, persistence, or dependency requirements.
- Use `ExamplePageScaffold` and `ExampleDemoBlock`; do not introduce a generic demo-page abstraction.
- Preserve existing public constructor names and callback names.
- Modify `UPScrollList`, `UPCodeInput`, `UPModal`, or `UPPicker` only after a focused test demonstrates a behavior gap; do not make speculative package changes.
- Leave the modified `README.md`, generated artifacts, helper scripts, and historical untracked files untouched.
- Work in the current approved `main` workspace; do not create another worktree.
- Use local assets `example/assets/uview/swiper/swiper1.png`, `swiper2.png`, `swiper3.png`, and `example/assets/uview/common/logo.png`.
- The example analyzer must report no issues; package analyzer may retain the existing warning/info baseline but must report zero errors attributable to this batch.
- Complete focused tests, route tests, full package/example tests, analyzer checks, `git diff --check`, and the Android debug build before completion.

---

### Task 1: Add Vertical UPSwiper Support With TDD

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_swiper.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- Consumes: Existing `UPSwiper` constructor, `UPSwiperState.currentIndex`, `UPSwiper.onChange`, and `UPSwiper.itemBuilder`.
- Produces: A backward-compatible `UPSwiper.vertical` boolean with default `false`. Horizontal behavior remains the default.

- [ ] **Step 1: Write the failing package regression test**

Append this test near the existing `UPSwiper` widget tests in
`packages/ultra_ui/test/widgets_test.dart`:

```dart
testWidgets('UPSwiper vertical changes page on vertical drag', (tester) async {
  final key = GlobalKey<UPSwiperState>();
  var current = -1;

  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: SizedBox(
          height: 200,
          child: UPSwiper(
            key: key,
            vertical: true,
            autoplay: false,
            height: 200,
            list: const ['A', 'B'],
            itemBuilder: (context, item, index) {
              return ColoredBox(
                color: index == 0 ? Colors.blue : Colors.green,
                child: Center(child: Text('$item')),
              );
            },
            onChange: (index) => current = index,
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  expect(find.text('A'), findsOneWidget);

  await tester.drag(find.byType(UPSwiper), const Offset(0, -240));
  await tester.pumpAndSettle();

  expect(key.currentState!.currentIndex, 1);
  expect(current, 1);
  expect(find.text('B'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify the API gap**

Run from `packages/ultra_ui`:

```text
flutter test test/widgets_test.dart --plain-name "UPSwiper vertical changes page on vertical drag" --reporter expanded
```

Expected result before the implementation is a compile failure stating that
`UPSwiper` has no named parameter `vertical`.

- [ ] **Step 3: Add the minimal vertical API and layout switch**

Add the constructor field directly after `indicator`:

```dart
this.vertical = false,
```

Add the public field beside `indicator`:

```dart
final bool vertical;
```

In the existing `PageView.builder` inside `UPSwiper.build`, add:

```dart
scrollDirection: widget.vertical ? Axis.vertical : Axis.horizontal,
```

Do not change `_pageForLogicalIndex`, circular-page handling, callback
emission, autoplay, item builders, indicator layout, or horizontal defaults.

- [ ] **Step 4: Run the regression and existing swiper tests**

Run:

```text
flutter test test/widgets_test.dart --plain-name "UPSwiper vertical changes page on vertical drag" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPSwiper indicator and click" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPSwiper swipeTo next prev public API" --reporter expanded
```

Expected: all three focused tests pass.

- [ ] **Step 5: Format and commit the package change**

Run:

```text
dart format lib/src/widgets/up_swiper.dart test/widgets_test.dart
flutter test test/widgets_test.dart --plain-name "UPSwiper vertical changes page on vertical drag" --reporter expanded
git add -- lib/src/widgets/up_swiper.dart test/widgets_test.dart
git commit -m "feat: add vertical swiper support"
```

The commit must contain only the two package files.

---

### Task 2: Implement the Swiper Example Page

**Files:**
- Create: `example/lib/pages/components_c/swiper_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPSwiper`, `UPSwiperIndicator`, `ExamplePageScaffold`, `ExampleDemoBlock`, and local swiper assets.
- Produces: `const SwiperPage()` with root key `example-page-componentsC/swiper/swiper`, section keys `swiper-page-basic`, `swiper-page-vertical`, `swiper-page-title`, `swiper-page-indicator`, `swiper-page-loading`, `swiper-page-video`, `swiper-page-custom`, `swiper-page-custom-indicator`, and stable labels for current index and click count.

- [ ] **Step 1: Add the failing direct-page test**

Add the page import at the top of
`example/test/components_c_pages_test.dart`:

```dart
import '../lib/pages/components_c/swiper_page.dart';
```

Append:

```dart
testWidgets('swiper page changes index and renders source variants',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const SwiperPage(),
    ),
  );
  await tester.pump();

  expect(find.text('基础功能'), findsOneWidget);
  expect(find.text('纵向滑动'), findsOneWidget);
  expect(find.text('带标题'), findsOneWidget);
  expect(find.text('带指示器'), findsOneWidget);
  expect(find.text('加载中'), findsOneWidget);
  expect(find.text('嵌入视频'), findsOneWidget);
  expect(find.text('自定义内容'), findsOneWidget);
  expect(find.text('自定义指示器'), findsOneWidget);
  expect(find.text('卡片式'), findsOneWidget);

  final basic = tester.state<UPSwiperState>(
    find.byKey(const ValueKey('swiper-page-basic')),
  );
  basic.swipeTo(1, animated: false);
  await tester.pump();
  expect(find.text('当前索引：1'), findsOneWidget);

  basic.clickHandler(1);
  await tester.pump();
  expect(find.text('点击次数：1'), findsOneWidget);

  expect(
    tester.widget<UPSwiper>(
      find.byKey(const ValueKey('swiper-page-vertical')),
    ).vertical,
    isTrue,
  );
  expect(find.byType(UPLoadingIcon), findsOneWidget);
  expect(find.byKey(const ValueKey('swiper-page-custom-indicator')),
      findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run from `example`:

```text
flutter test test/components_c_pages_test.dart --plain-name "swiper page changes index and renders source variants" --reporter expanded
```

Expected: FAIL because `SwiperPage` does not exist.

- [ ] **Step 3: Implement the page with source-aligned local data**

Create a `StatefulWidget` with:

```dart
class SwiperPage extends StatefulWidget {
  const SwiperPage({super.key});

  @override
  State<SwiperPage> createState() => _SwiperPageState();
}
```

In `_SwiperPageState`, keep:

```dart
int _current = 0;
int _clicks = 0;

void _onChange(int index) {
  if (!mounted) return;
  setState(() => _current = index);
}

void _onClick(int index) {
  if (!mounted) return;
  setState(() => _clicks += 1);
}
```

Use these local fixtures:

```dart
const List<String> _swiperImages = <String>[
  'assets/uview/swiper/swiper1.png',
  'assets/uview/swiper/swiper2.png',
  'assets/uview/swiper/swiper3.png',
];

const List<Map<String, dynamic>> _swiperTitles = <Map<String, dynamic>>[
  <String, dynamic>{
    'image': 'assets/uview/swiper/swiper2.png',
    'title': '昨夜星辰昨夜风，画楼西畔桂堂东',
    'type': 'image',
  },
  <String, dynamic>{
    'image': 'assets/uview/swiper/swiper1.png',
    'title': '身无彩凤双飞翼，心有灵犀一点通',
  },
  <String, dynamic>{
    'image': 'assets/uview/swiper/swiper3.png',
    'title': '谁念西风独自凉，萧萧黄叶闭疏窗，沉思往事立残阳',
  },
];

const List<Map<String, dynamic>> _swiperVideos = <Map<String, dynamic>>[
  <String, dynamic>{
    'url': 'assets/uview/swiper/swiper1.png',
    'poster': 'assets/uview/swiper/swiper1.png',
    'type': 'video',
    'title': '昨夜星辰昨夜风，画楼西畔桂堂东',
  },
  <String, dynamic>{
    'url': 'assets/uview/swiper/swiper2.png',
    'type': 'image',
    'title': '身无彩凤双飞翼，心有灵犀一点通',
  },
];
```

Render `ExamplePageScaffold` with title `轮播` and the nine exact source
section titles. Configure the widgets as follows:

- Basic: `list: _swiperImages`, `autoplay: false`, `onChange: _onChange`,
  `onClick: _onClick`.
- Vertical: `list: _swiperImages`, `vertical: true`, `indicator: true`,
  `indicatorMode: 'dot'`, `autoplay: false`, `height: 200`.
- Title: `list: _swiperTitles`, `keyName: 'image'`, `showTitle: true`,
  `circular: true`, `autoplay: false`.
- Indicator: `list: _swiperImages`, `indicator: true`, `circular: true`,
  `autoplay: false`.
- Loading: `list: _swiperImages`, `loading: true`, `autoplay: false`.
- Video: `list: _swiperVideos`, `keyName: 'url'`, `autoplay: false`.
- Custom content: use `itemBuilder` to render the local `image` field.
- Custom indicator: use `indicatorSlot` containing `UPSwiperIndicator` or a
  local `Row` keyed `swiper-page-custom-indicator`.
- Card: `list: _swiperImages`, `previousMargin: 30`, `nextMargin: 30`,
  `circular: true`, `autoplay: false`, `radius: 5`.

Add text labels `当前索引：$_current` and `点击次数：$_clicks` below the basic
swiper. Do not load source URLs.

- [ ] **Step 4: Run the focused page test**

Run:

```text
dart format lib/pages/components_c/swiper_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "swiper page changes index and renders source variants" --reporter expanded
```

Expected: PASS, including the `vertical` constructor assertion from Task 1.

- [ ] **Step 5: Commit the page**

```text
git add -- lib/pages/components_c/swiper_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add swiper page"
```

---

### Task 3: Implement the ScrollList Example Page

**Files:**
- Create: `example/lib/pages/components_c/scroll_list_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPScrollList`, `UPImage` or `Image.asset`, `UPIcon`, `UPButton`, `ExamplePageScaffold`, and `ExampleDemoBlock`.
- Produces: `const ScrollListPage()` with root key `example-page-componentsC/scrollList/scrollList`, scroll list key `scroll-list-page-basic`, more-action key `scroll-list-page-more`, and deterministic edge/action labels.

- [ ] **Step 1: Add the failing direct-page test**

Add:

```dart
import '../lib/pages/components_c/scroll_list_page.dart';
```

Append:

```dart
testWidgets('scroll list page reports edge actions and more action',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const ScrollListPage(),
    ),
  );
  await tester.pump();

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('多菜单扩展'), findsOneWidget);
  expect(find.text('查看更多'), findsOneWidget);
  expect(find.text('查看更多次数：0'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('scroll-list-page-more')));
  await tester.pump();
  expect(find.text('查看更多次数：1'), findsOneWidget);

  final list = tester.state<UPScrollListState>(
    find.byKey(const ValueKey('scroll-list-page-basic')),
  );
  list.scrollToRight();
  await tester.pump();
  list.scrollToLeft();
  await tester.pump();
  expect(find.text('右侧触发次数：1'), findsOneWidget);
  expect(find.text('左侧触发次数：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```text
flutter test test/components_c_pages_test.dart --plain-name "scroll list page reports edge actions and more action" --reporter expanded
```

Expected: FAIL because `ScrollListPage` does not exist.

- [ ] **Step 3: Implement fixed local goods and menu sections**

Create a `StatefulWidget` with counters:

```dart
int _moreCount = 0;
int _leftCount = 0;
int _rightCount = 0;
```

Use eight fixed goods with prices `230.5`, `74.1`, `8457`, `1442`, `541`,
`234`, `562`, and `251.5`; reuse the three local swiper images in a repeating
pattern. Use two menu rows with the source names:

```text
天猫新品, 今日爆款, 天猫国际, 饿了么, 天猫超市, 分类, 天猫美食, 阿里健康, 口碑生活
充值中心, 机票酒店, 金币庄园, 阿里拍卖, 淘宝吃货, 闲鱼, 会员中心, 造点新货, 土货鲜食
```

Render `ExamplePageScaffold(title: '横向滚动列表')` with two
`ExampleDemoBlock`s titled `基础使用` and `多菜单扩展`. The first
`UPScrollList` uses:

```dart
UPScrollList(
  key: const ValueKey('scroll-list-page-basic'),
  indicatorColor: '#fff0f0',
  indicatorActiveColor: '#f56c6c',
  onLeft: _onLeft,
  onRight: _onRight,
  children: goodsAndMoreChildren,
)
```

The `查看更多` child is a `GestureDetector` or `InkWell` keyed
`scroll-list-page-more`, and increments `_moreCount`. Add labels for all three
counters. Use a second `UPScrollList` for the two-row menu grid and do not
request source network URLs.

- [ ] **Step 4: Run and format**

```text
dart format lib/pages/components_c/scroll_list_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "scroll list page reports edge actions and more action" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the page**

```text
git add -- lib/pages/components_c/scroll_list_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add scroll list page"
```

---

### Task 4: Implement the CodeInput Example Page

**Files:**
- Create: `example/lib/pages/components_c/code_input_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPCodeInput`, `UPCodeInputState`, `ExamplePageScaffold`, and `ExampleDemoBlock`.
- Produces: `const CodeInputPage()` with root key `example-page-componentsC/codeInput/codeInput`, basic input key `code-input-page-basic`, and labels for the current basic value and finish count.

- [ ] **Step 1: Add the failing direct-page test**

Add:

```dart
import '../lib/pages/components_c/code_input_page.dart';
```

Append:

```dart
testWidgets('code input page edits value and reports finish', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const CodeInputPage(),
    ),
  );
  await tester.pump();

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('横线模式'), findsOneWidget);
  expect(find.text('设置长度'), findsOneWidget);
  expect(find.text('设置间距'), findsOneWidget);
  expect(find.text('细边框'), findsOneWidget);
  expect(find.text('调整颜色'), findsOneWidget);
  expect(find.text('点模式'), findsOneWidget);
  expect(find.text('预置内容'), findsOneWidget);
  expect(find.text('预置值：123'), findsOneWidget);
  expect(find.text('预置值：34'), findsOneWidget);

  final basic = tester.state<UPCodeInputState>(
    find.byKey(const ValueKey('code-input-page-basic')),
  );
  basic.setValue('1234');
  await tester.pump();
  expect(find.text('基础值：1234'), findsOneWidget);
  expect(find.text('完成次数：1'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test test/components_c_pages_test.dart --plain-name "code input page edits value and reports finish" --reporter expanded
```

Expected: FAIL because `CodeInputPage` does not exist.

- [ ] **Step 3: Implement the eight source sections**

Create a `StatefulWidget` with:

```dart
String _basicValue = '';
int _finishCount = 0;

void _onBasicChange(String value) {
  if (!mounted) return;
  setState(() => _basicValue = value);
}

void _onFinish(String value) {
  if (!mounted) return;
  setState(() {
    _basicValue = value;
    _finishCount += 1;
  });
}
```

Render `ExamplePageScaffold(title: '验证码输入')` and the exact eight
`ExampleDemoBlock` titles. Configure:

- Basic: `maxlength: 4`, `onChange: _onBasicChange`, `onFinish: _onFinish`,
  key `code-input-page-basic`.
- Line: `mode: 'line'`, `maxlength: 4`, `bold: true`.
- Length: `maxlength: 6`.
- Spacing: `mode: 'box'`, `space: 0`, `maxlength: 4`.
- Hairline: one box and one line variant with `hairline: true`.
- Color: source red box and blue line variants.
- Dot: `dot: true`, `space: 0`, `maxlength: 4`, `hairline: true`.
- Preset: box variant with `value: '123'` and a second line/box variant with
  `value: '34'`.

Render `基础值：$_basicValue`, `完成次数：$_finishCount`,
`预置值：123`, and `预置值：34` labels. The code input's hidden
`EditableText` remains owned by `UPCodeInput`; do not add a second input.

- [ ] **Step 4: Run the focused test and verify public state behavior**

```text
dart format lib/pages/components_c/code_input_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "code input page edits value and reports finish" --reporter expanded
```

Expected: PASS.

- [ ] **Step 5: Commit the page**

```text
git add -- lib/pages/components_c/code_input_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add code input page"
```

---

### Task 5: Implement the Modal Example Page

**Files:**
- Create: `example/lib/pages/components_c/modal_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPModal`, `UPModalState`, `UPCell`, `UPButton`, `UPIcon`, `ExamplePageScaffold`, and local logo asset.
- Produces: `const ModalPage()` with root key `example-page-componentsC/modal/modal`, ten modal-row keys `modal-page-open-0` through `modal-page-open-9`, and modal keys `modal-page-basic`, `modal-page-cancel`, `modal-page-async`, `modal-page-slot`, `modal-page-custom-button`, and `modal-page-overlay`.

- [ ] **Step 1: Add the failing direct-page test**

Add:

```dart
import '../lib/pages/components_c/modal_page.dart';
```

Append:

```dart
testWidgets('modal page opens variants and handles async confirmation',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const ModalPage(),
    ),
  );
  await tester.pump();

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('无标题'), findsOneWidget);
  expect(find.text('带取消按钮'), findsOneWidget);
  expect(find.text('异步关闭'), findsOneWidget);
  expect(find.text('对调取消和确认按钮'), findsOneWidget);
  expect(find.text('允许点击遮罩关闭'), findsOneWidget);
  expect(find.text('传入slot'), findsOneWidget);
  expect(find.text('自定义按钮'), findsOneWidget);
  expect(find.text('淡入淡出动画'), findsOneWidget);
  expect(find.text('带底部关闭按钮'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('modal-page-open-0')));
  await tester.pump();
  expect(find.text('标题'), findsOneWidget);
  expect(find.text('模态框，常用于消息提示、消息确认、在当前页面内完成特定的交互操作'),
      findsOneWidget);
  await tester.tap(find.text('确认').last);
  await tester.pump();
  expect(find.text('确认次数：1'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('modal-page-open-3')));
  await tester.pump();
  await tester.tap(find.text('确认').last);
  await tester.pump();
  expect(find.text('操作中...'), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 180));
  expect(find.text('异步状态：已关闭'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test test/components_c_pages_test.dart --plain-name "modal page opens variants and handles async confirmation" --reporter expanded
```

Expected: FAIL because `ModalPage` does not exist.

- [ ] **Step 3: Implement the modal list and controlled overlay stack**

Create a `StatefulWidget` with one boolean per source variant or one
`_activeModal` integer plus per-variant configuration. Use a `Stack` with a
scrollable `ListView` below the modal widgets so each visible modal can occupy
the page overlay bounds. Keep these counters:

```dart
int _confirmCount = 0;
int _cancelCount = 0;
int _closeCount = 0;
bool _asyncClosed = false;
```

Use the exact source content:

```dart
const modalContent =
    '模态框，常用于消息提示、消息确认、在当前页面内完成特定的交互操作';
```

Render the ten source row titles in order. Configure the ten `UPModal`
instances:

1. title `标题`, left-aligned content, confirm callback increments
   `_confirmCount`.
2. no title, default content alignment.
3. cancel button and overlay close; confirm/cancel/close update counters.
4. cancel button and `asyncClose: true`; confirm starts a
   `Future.delayed(const Duration(milliseconds: 120))`, then closes the
   modal and sets `_asyncClosed = true`.
5. cancel and confirm buttons with `buttonReverse: true`.
6. title, overlay close enabled.
7. title `利剑出鞘,一统江湖` and a local `Image.asset` logo child.
8. custom `confirmButton` using `UPButton(type: 'success', shape: 'circle')`.
9. `zoom: false`.
10. `zoom: false` plus a `popupBottom` close control using `UPIcon`.

Use `ValueKey`s listed in the task interfaces. Add labels for confirm,
cancel, close, and async state. All modal `show` values must be controlled by
the page state; no global modal service is introduced.

- [ ] **Step 4: Run the focused modal test**

```text
dart format lib/pages/components_c/modal_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "modal page opens variants and handles async confirmation" --reporter expanded
```

Expected: PASS. If the visible confirm tap exposes an existing package
behavior gap, first add a package regression test for that exact callback
path; do not change unrelated modal behavior.

- [ ] **Step 5: Commit the page**

```text
git add -- lib/pages/components_c/modal_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add modal page"
```

---

### Task 6: Implement the Picker Example Page

**Files:**
- Create: `example/lib/pages/components_c/picker_page.dart`
- Modify: `example/test/components_c_pages_test.dart`

**Interfaces:**
- Consumes: `UPPicker`, `UPPickerState`, `UPToolbar` slots, `UPCell`, `ExamplePageScaffold`, and local deterministic column data.
- Produces: `const PickerPage()` with root key `example-page-componentsC/picker/picker`, six row keys `picker-page-open-0` through `picker-page-open-5`, picker keys `picker-page-basic`, `picker-page-default`, `picker-page-linked`, `picker-page-loading`, `picker-page-title`, and `picker-page-overlay`, plus labels for confirmed values and linked state.

- [ ] **Step 1: Add the failing direct-page test**

Add:

```dart
import '../lib/pages/components_c/picker_page.dart';
```

Append:

```dart
testWidgets('picker page confirms defaults and linked columns',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const PickerPage(),
    ),
  );
  await tester.pump();

  expect(find.text('基础使用'), findsOneWidget);
  expect(find.text('设置默认项'), findsOneWidget);
  expect(find.text('多列联动'), findsOneWidget);
  expect(find.text('加载中状态(切换第一列)'), findsOneWidget);
  expect(find.text('设置标题'), findsOneWidget);
  expect(find.text('允许点击遮罩关闭'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('picker-page-open-1')));
  await tester.pump();
  final defaultPicker = tester.state<UPPickerState>(
    find.byKey(const ValueKey('picker-page-default')),
  );
  expect(defaultPicker.getIndexs(), <int>[1]);
  defaultPicker.confirm();
  await tester.pump();
  expect(find.text('默认确认值：美国'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('picker-page-open-2')));
  await tester.pump();
  final linkedPicker = tester.state<UPPickerState>(
    find.byKey(const ValueKey('picker-page-linked')),
  );
  linkedPicker.changeHandler(0, 1);
  await tester.pump();
  expect(find.text('联动列：深圳'), findsOneWidget);
  linkedPicker.changeHandler(1, 2);
  linkedPicker.confirm();
  await tester.pump();
  expect(find.text('联动确认值：美国/上海'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

```text
flutter test test/components_c_pages_test.dart --plain-name "picker page confirms defaults and linked columns" --reporter expanded
```

Expected: FAIL because `PickerPage` does not exist.

- [ ] **Step 3: Implement the six picker variants**

Create fixed local columns:

```dart
const List<String> _countries = <String>['中国', '美国', '日本'];
const List<String> _cities = <String>['深圳', '厦门', '上海', '拉萨'];
const List<Map<String, dynamic>> _fruitOptions = <Map<String, dynamic>>[
  <String, dynamic>{'label': '苹果', 'value': 1},
  <String, dynamic>{'label': '橘子', 'value': 2},
  <String, dynamic>{'label': '香蕉', 'value': 3},
];
```

Keep `_activePicker`, `_confirmedValue`, `_defaultConfirmedValue`,
`_linkedValue`, `_linkedColumnLabel`, and `_loading` in page state. Open a
row by setting `_activePicker` to its index. Each picker receives
`show: _activePicker == index`, `onConfirm`, `onCancel`, and `onClose`.

Configure the variants:

1. Basic one-column picker with a toolbar-right slot containing `右侧`.
2. Default picker with `defaultIndex: const <int>[1]`.
3. Linked two-column picker with `GlobalKey<UPPickerState>` and an
   `onChange` callback that calls `setColumnValues(1, _cities)` when the first
   column changes.
4. Loading linked picker with `loading: _loading`; on first-column change,
   set `_loading = true`, use `Future.delayed(const Duration(milliseconds: 120))`,
   call `setColumnValues(1, _cities)`, then set `_loading = false`.
5. Titled picker with title `标题太长就会显示省略号`, `value: const <dynamic>['日本']`,
   and `keyName`/`valueName` object-value support demonstrated with
   `_fruitOptions` where appropriate.
6. Overlay-close picker with `closeOnClickOverlay: true`.

Render the six exact source row titles and labels:

```text
默认确认值：...
联动列：...
联动确认值：...
加载状态：...
```

Use `UPPickerState.confirm`, `cancel`, `closeHandler`, `changeHandler`, and
`setColumnValues` as the public interaction surface. Do not reach into
private picker fields.

- [ ] **Step 4: Run the focused picker test**

```text
dart format lib/pages/components_c/picker_page.dart test/components_c_pages_test.dart
flutter test test/components_c_pages_test.dart --plain-name "picker page confirms defaults and linked columns" --reporter expanded
```

Expected: PASS. If an existing picker callback or overlay behavior fails,
stop and add a focused package regression before changing package code.

- [ ] **Step 5: Commit the page**

```text
git add -- lib/pages/components_c/picker_page.dart test/components_c_pages_test.dart
git commit -m "feat(example): add picker page"
```

---

### Task 7: Register Batch 5 Routes and Preview Entries

**Files:**
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Consumes: `SwiperPage`, `ScrollListPage`, `CodeInputPage`, `ModalPage`, and `PickerPage`.
- Produces: five registered `ExampleRoute` records, five enabled preview records, an 80-route completed catalog, and a 25-route Components C completed list.

- [ ] **Step 1: Extend route assertions first**

In `example/test/route_catalog_test.dart`:

1. Change the completed route count from `75` to `80`.
2. Append these five IDs after `componentsC/list/list`:

```dart
'componentsC/swiper/swiper',
'componentsC/scrollList/scrollList',
'componentsC/codeInput/codeInput',
'componentsC/modal/modal',
'componentsC/picker/picker',
```

3. Add these five source paths to `completedSourcePaths`:

```dart
'pages/componentsC/swiper/swiper',
'pages/componentsC/scrollList/scrollList',
'pages/componentsC/codeInput/codeInput',
'pages/componentsC/modal/modal',
'pages/componentsC/picker/picker',
```

4. Extend the preview-availability set with the same five source paths.

Run:

```text
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
```

Expected: FAIL because the five routes are not yet present in
`exampleRoutes`.

- [ ] **Step 2: Add page imports and route records**

Add these imports to `example/lib/routes/example_catalog.dart`:

```dart
import '../pages/components_c/swiper_page.dart';
import '../pages/components_c/scroll_list_page.dart';
import '../pages/components_c/code_input_page.dart';
import '../pages/components_c/modal_page.dart';
import '../pages/components_c/picker_page.dart';
```

Insert these records immediately after the existing `list` record:

```dart
const ExampleRoute(
  id: 'componentsC/swiper/swiper',
  sourcePath: 'pages/componentsC/swiper/swiper',
  title: '轮播',
  group: ExampleRouteGroup.componentsC,
  builder: _buildSwiper,
),
const ExampleRoute(
  id: 'componentsC/scrollList/scrollList',
  sourcePath: 'pages/componentsC/scrollList/scrollList',
  title: '横向滚动列表',
  group: ExampleRouteGroup.componentsC,
  builder: _buildScrollList,
),
const ExampleRoute(
  id: 'componentsC/codeInput/codeInput',
  sourcePath: 'pages/componentsC/codeInput/codeInput',
  title: '验证码输入',
  group: ExampleRouteGroup.componentsC,
  builder: _buildCodeInput,
),
const ExampleRoute(
  id: 'componentsC/modal/modal',
  sourcePath: 'pages/componentsC/modal/modal',
  title: '模态框',
  group: ExampleRouteGroup.componentsC,
  builder: _buildModal,
),
const ExampleRoute(
  id: 'componentsC/picker/picker',
  sourcePath: 'pages/componentsC/picker/picker',
  title: '选择器',
  group: ExampleRouteGroup.componentsC,
  builder: _buildPicker,
),
```

Add these builders beside the existing Components C builders:

```dart
Widget _buildSwiper(BuildContext context) => const SwiperPage();
Widget _buildScrollList(BuildContext context) => const ScrollListPage();
Widget _buildCodeInput(BuildContext context) => const CodeInputPage();
Widget _buildModal(BuildContext context) => const ModalPage();
Widget _buildPicker(BuildContext context) => const PickerPage();
```

- [ ] **Step 3: Enable only the five existing preview records**

Change `available: false` to `available: true` for the existing records:

```text
pages/componentsC/swiper/swiper
pages/componentsC/scrollList/scrollList
pages/componentsC/codeInput/codeInput
pages/componentsC/modal/modal
pages/componentsC/picker/picker
```

Do not add duplicate preview records, move catalog rows, or change unrelated
preview availability.

- [ ] **Step 4: Format and run route regression tests**

```text
dart format lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
flutter test test/route_catalog_test.dart --plain-name "component catalogs preserve literal source order and total" --reporter expanded
flutter test test/route_catalog_test.dart --plain-name "route ids resolve to their registered catalog entries" --reporter expanded
```

Expected: PASS with 80 completed routes and 25 Components C routes.

- [ ] **Step 5: Run all Components C page tests**

```text
flutter test test/components_c_pages_test.dart --reporter expanded
```

Expected: all existing Components C tests plus the five Batch 5 tests pass.

- [ ] **Step 6: Commit route registration**

```text
git add -- lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/route_catalog_test.dart
git commit -m "test(example): register components c batch 5 routes"
```

---

### Task 8: Run Full Validation and Handle Only Confirmed Gaps

**Files:**
- No additional files are expected if Tasks 1-7 pass.
- If a focused page test proves an existing package gap, modify only the
  affected widget and its focused package test before continuing.

**Interfaces:**
- The five pages use the public package APIs defined in Tasks 1-6.
- Any confirmed package fix preserves existing constructor names, callback
  names, and unrelated behavior.

- [ ] **Step 1: Format all changed Dart files**

Run from `example`:

```text
dart format lib/pages/components_c/swiper_page.dart lib/pages/components_c/scroll_list_page.dart lib/pages/components_c/code_input_page.dart lib/pages/components_c/modal_page.dart lib/pages/components_c/picker_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
```

Run from `packages/ultra_ui`:

```text
dart format lib/src/widgets/up_swiper.dart test/widgets_test.dart
```

- [ ] **Step 2: Run focused regression suites**

From `example`:

```text
flutter test test/components_c_pages_test.dart --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

From `packages/ultra_ui`:

```text
flutter test test/widgets_test.dart --plain-name "UPSwiper vertical changes page on vertical drag" --reporter expanded
```

Expected: all focused tests pass.

- [ ] **Step 3: Run full package and example tests**

From `packages/ultra_ui`:

```text
flutter test
```

From `example`:

```text
flutter test
```

Expected: zero test failures in both suites.

- [ ] **Step 4: Run analyzers**

From `example`:

```text
flutter analyze
```

Expected: `No issues found!`.

From `packages/ultra_ui`:

```text
flutter analyze
```

Expected: no errors attributable to Batch 5. Existing repository warning/info
baseline may remain.

- [ ] **Step 5: Build the Android debug artifact**

From `example`:

```text
flutter build apk --debug --target-platform android-arm64
```

Expected output:

```text
example/build/app/outputs/flutter-apk/app-debug.apk
```

Do not stage the build output.

- [ ] **Step 6: Review the final diff and worktree**

Run from the repository root:

```text
git diff --check
git status --short
git log -8 --oneline
git diff --name-only -- packages/ultra_ui/lib/src/widgets/up_swiper.dart packages/ultra_ui/test/widgets_test.dart example/lib/pages/components_c example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_c_pages_test.dart example/test/route_catalog_test.dart
```

Confirm that only planned Batch 5 commits and files are present. Leave
`README.md` and historical untracked files untouched. Do not stage generated
artifacts.

- [ ] **Step 7: Commit only a confirmed validation fix**

If no new package gap was found, make no extra validation commit. If a package
gap is confirmed by a failing focused test, first add and run the regression
test for that exact behavior. Then stage the exact implementation path named
by the failing test and `test/widgets_test.dart`; do not use a wildcard or
stage unrelated package files. Use this focused commit message:

```text
git commit -m "fix: preserve components c batch 5 widget behavior"
```

The implementation path must be written literally in the `git add --` command
before execution, based on the confirmed failing widget.
