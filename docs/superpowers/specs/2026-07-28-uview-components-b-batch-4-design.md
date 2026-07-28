# Components B Fourth Source-Order Batch Design

**Date:** 2026-07-28

**Status:** Approved for implementation

## Goal

Migrate the next three registered uView Plus Components B source pages after
CountDown into the Flutter example:

1. `pages/componentsB/color/color`
2. `pages/componentsB/numberBox/numberBox`
3. `pages/componentsB/countTo/countTo`

The pages must preserve the source route order, visible labels, default values,
principal interactions, and source-like spacing and colors. Flutter component
classes continue to use the `UP` prefix. The supported example platforms remain
Android and iOS.

## Source Of Truth

The route order and navigation titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

The page content comes from:

- `src/pages/componentsB/color/color.nvue`
- `src/pages/componentsB/numberBox/numberBox.nvue`
- `src/pages/componentsB/countTo/countTo.nvue`

No route may be enabled in the Flutter preview catalog before its real example
page and route builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_b/`. Register the three pages immediately after
CountDown in `example_catalog.dart`, and mark the corresponding preview entries
available without reordering the preview catalog.

Color is a source design-token showcase rather than an interactive color-picker
demo. It will therefore use Flutter layout primitives and text to reproduce the
source swatches instead of substituting `UPColorPicker`, which would change the
page's purpose and behavior.

NumberBox and CountTo will use real `UPNumberBox` and `UPCountTo` instances for
every source demonstration. `UPNumberBox` will gain optional slot-builder APIs
needed by the source custom example; the component retains ownership of tap,
disabled, range, and value-update behavior around those slots.

## Color Page

Create `ColorPage` with route title `色彩` and page key
`example-page-componentsB/color/color`.

Render the source sections in this exact order:

1. `主色调`
2. `Error`
3. `Warning`
4. `Info`
5. `Success`
6. `文字颜色`
7. `边框颜色`
8. `背景颜色`

Each section uses a horizontal row of equal-width swatches. The first seven
sections contain four swatches; the background section contains one swatch with
the same width as one item in a four-column row.

Each swatch displays both the source label and hexadecimal value. Light
swatches use dark tip text; all other swatches use white text. Source colors,
3-pixel corner radius, 5-pixel vertical padding, 15-pixel page padding, and
section spacing are preserved.

The Color page has no mutable state or runtime assets.

## NumberBox Component API

Extend `UPNumberBox` with three optional builders:

```dart
typedef UPNumberBoxSlotBuilder = Widget Function(
  BuildContext context,
  num value,
  bool disabled,
);

final UPNumberBoxSlotBuilder? minusBuilder;
final UPNumberBoxSlotBuilder? inputBuilder;
final UPNumberBoxSlotBuilder? plusBuilder;
```

The builders receive the current formatted value and the relevant disabled
state. The existing built-in controls remain the default when a builder is
absent.

The component wraps `minusBuilder` and `plusBuilder` with the same tap,
long-press, min/max, `onOverlimit`, `onMinus`, `onPlus`, and change-emission
behavior used by the default buttons. `inputBuilder` replaces only the editable
input surface; it does not add an implicit text field.

The source `showMinus` and `showPlus` flags continue to control whether custom
button slots are mounted. Existing callers and behavior remain source
compatible.

## NumberBox Page

Create `NumberBoxPage` with route title `步进器` and page key
`example-page-componentsB/numberBox/numberBox`.

Use a bordered `UPCellGroup` containing these exact source rows:

1. `基础用法`
2. `步长设置`
3. `限制输入范围`
4. `限制输入整数`
5. `禁用状态`
6. `禁用输入框`
7. `禁用长按`
8. `固定小数位数`
9. `异步变更`
10. `自定义大小颜色样式`
11. `自定义(为0时减少按钮会消失)`

Each row places a controlled `UPNumberBox` in the right slot. Initial values and
configuration match the source:

- Standard values start at `3`.
- Step configuration uses `2`.
- Range configuration starts at `5` with `min: 5` and `max: 8`; the source
  declaration initializes it to `3`, but `UPNumberBox` formats controlled input
  to the valid minimum, so the visible initial value is `5`.
- Integer mode uses `integer: true`.
- Disabled and disabled-input rows preserve their respective behavior.
- Long-press-disabled mode uses `longPress: false`.
- Decimal mode starts at `3.1`, uses `step: 0.2`, and one decimal place.
- Custom colors use white content, a 36-pixel button size, and `#2979ff`
  background.

The asynchronous row uses `asyncChange: true`. On change it shows the existing
loading toast, waits three seconds like the source, then writes the proposed
value back to the controlled state and dismisses loading. Repeated input while
loading is ignored.

The final row uses the new builders to render the source circular outlined
minus button, centered value text, and red circular plus button. Its minimum is
zero. `showMinus` follows `value > 0`, so decrementing to zero removes the minus
control.

## CountTo Page

Create `CountToPage` with route title `数字滚动` and page key
`example-page-componentsB/countTo/countTo`.

Render these source blocks in order:

1. `基础功能`
2. `倒计数`
3. `显示小数位`
4. `千分位分隔符`
5. `自定义控制`
6. `自定义`

All six blocks use real `UPCountTo` widgets with the source values:

- Basic: `0` to `3000`.
- Countdown: `300` to the component default end value `0`.
- Decimals: `100.00` to `10.55`, two decimal places.
- Separator: `2000` to `1542`, comma grouping, two decimal places.
- Manual: `0` to `3000`, `autoplay: false`.
- Custom: `0` to `3000`, color `#909399`, font size `40`, bold.

The manual example owns a `GlobalKey<UPCountToState>` and exposes three
source-style `UPGridItem` controls: `开始`, `暂停`, and `继续`. They call
`start()`, `stop()`, and `resume()` respectively. A small visible status label
mirrors the current control state so behavior is deterministic and testable
without inspecting animation internals.

## Data Flow And State

Each page owns only the state required by its demonstrations:

- Color has no state.
- NumberBox stores eleven controlled numeric values plus an asynchronous-loading
  guard.
- CountTo stores only the manual-control status and component key.

Callbacks update only their matching demonstration. No page shares mutable
state with another route. Timers and delayed asynchronous writes check
`mounted` before updating page state.

## Error And Lifecycle Handling

- NumberBox range, integer, and decimal normalization remain inside
  `UPNumberBox`.
- Async NumberBox loading always closes after the delayed update while the page
  remains mounted.
- CountTo timers remain owned and disposed by `UPCountToState`.
- The pages introduce no network calls, permissions, remote images, or new
  dependencies.

## Testing

Add focused widget tests before implementation:

- Color renders the source primary swatch and exact `#3c9cff` value.
- NumberBox increments the basic value and removes the custom minus control when
  its value reaches zero.
- CountTo manual controls transition through started, paused, and resumed
  states.
- Package tests verify custom NumberBox builders render and retain component
  step behavior.
- Route catalog tests update the completed total from 37 to 40 and preserve
  exact source order.

At the batch boundary run:

```powershell
cd example
dart format .
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_number_box.dart
flutter test test/widgets_test.dart --reporter expanded
```

Install the resulting APK to MuMu at `127.0.0.1:16384`, launch
`com.example.ultra_ui_example/.MainActivity`, and verify it is the focused app.

## Commit Boundary

The implementation commit contains only:

- The three new example pages.
- Their route, preview, and test updates.
- The `UPNumberBox` slot-builder extension and package tests.
- The implementation plan for this batch.

Existing unrelated modifications and untracked files remain untouched.
