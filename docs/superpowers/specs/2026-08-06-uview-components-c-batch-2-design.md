# Components C Batch 2 Design

**Date:** 2026-08-06

**Status:** Approved for implementation

## Goal

Migrate the next five registered uView Plus Components C source pages into the
Flutter example while preserving source order, visible Chinese copy, default
state, principal interactions, and the existing `UP` component API style.

The batch contains:

1. `pages/componentsC/steps/steps`
2. `pages/componentsC/navbar/navbar`
3. `pages/componentsC/skeleton/skeleton`
4. `pages/componentsC/input/input`
5. `pages/componentsC/album/album`

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsC/steps/steps.vue`
- `src/pages/componentsC/navbar/navbar.nvue`
- `src/pages/componentsC/skeleton/skeleton.nvue`
- `src/pages/componentsC/input/input.nvue`
- `src/pages/componentsC/album/album.nvue`

The five routes are registered immediately after the existing Components C
`text` route. Preview rows are enabled without changing preview catalog order.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_c/`. Follow the existing
`ExamplePageScaffold` and `ExampleDemoBlock` patterns. Pages own only the
state needed to make their source interactions visible and testable; no new
shared showcase abstraction is introduced.

Use the existing package widgets:

- `StepsPage`: `UPSteps` and `UPStepsItem`.
- `NavbarPage`: `UPNavbar`, `UPIcon`, and `UPLine` for the custom left slot.
- `SkeletonPage`: `UPSkeleton`, `UPSwitch`, `UPGap`, and `UPText`.
- `InputPage`: `UPInput`, `UPButton`, `UPCode`, and `UPText`.
- `AlbumPage`: `UPAlbum` and `UPText`.

The implementation commit includes the five direct package widget files when
they are needed by the pages or must be changed to close a verified source
compatibility gap:

- `up_steps.dart`
- `up_navbar.dart`
- `up_skeleton.dart`
- `up_input.dart`
- `up_album.dart`

Unrelated package widgets, shared utilities, and historical untracked files
remain outside this batch boundary.

## Steps Page

Create `StepsPage` with route title `步骤条` and page key
`example-page-componentsC/steps/steps`.

Render the seven source blocks in order:

1. `基础演示`: six items, current index `1`, with the first item style matching
   the source background.
2. `显示点类型`: horizontal and vertical dot variants, both current index `1`.
3. `错误状态`: the middle item uses `error: true`.
4. `自定义图标`: source `checkmark` and `arrow-right` icons.
5. `自定义插槽`: the third item uses a warning-colored circular `运` widget.
6. `自定义颜色`: active color `#3c9cff`.
7. `竖向展示`: a three-item vertical variant.

The page's current value is local and initialized to `1`. Steps are display
examples, so no synthetic navigation interaction is added beyond the existing
widget API.

## Navbar Page

Create `NavbarPage` with route title `导航栏` and page key
`example-page-componentsC/navbar/navbar`.

Render the source fixed, safe-area, placeholder navbar first, followed by the
three inline examples:

- `基础功能`: title `个人中心`, with left and right callbacks updating visible
  feedback text.
- `自定义文本`: title `个人中心`, left text `返回`, right icon `map`.
- `自定义插槽`: a rounded left slot containing `arrow-left`, a vertical
  `UPLine`, and `home`, matching the source spacing and opacity.

The page remains inside the example scaffold's normal navigation stack. The
source `autoBack` behavior is preserved by `UPNavbar`; tests invoke callbacks
on the inline example rather than relying on an external route pop.

## Skeleton Page

Create `SkeletonPage` with route title `骨架屏` and page key
`example-page-componentsC/skeleton/skeleton`.

Render the seven source blocks and retain two local switch values:

- `switch1` starts `true` and controls animation for the animation and avatar
  examples.
- `switch2` starts `false` and controls the loading/content transition.

The first four blocks cover default rows, custom row count, custom widths, and
custom heights. The next two cover animation and avatar display. The final
block renders the source content slot with the logo placeholder, two texts, and
the source gap after the block. Toggling `switch2` must visibly replace the
skeleton with the content slot.

## Input Page

Create `InputPage` with route title `输入框` and page key
`example-page-componentsC/input/input`.

Render all source blocks in order:

1. `基础使用`
2. `颜色`
3. `可清空内容(仅focus时显示清除图标)`
4. `可清空内容(始终显示清除图标)`
5. `数字键盘`
6. `密码类型`
7. `显示下划线`
8. `禁用状态`
9. `圆形`
10. `前后图标`
11. `前后插槽`

The page owns `value`, `inputNumber`, `inputPassword`, and the verification
code display text. The basic input's change and confirm callbacks update
visible feedback; the source random-change button uses a deterministic sample
value so tests remain repeatable. Numeric input keeps digits only. Password
visibility, clear buttons, icon styles, bottom border, disabled state, and
circle shape use the corresponding `UPInput` props.

The source prefix and suffix slots are composed at page level around
`UPInput`: the prefix shows `http://`; the suffix contains `UPCode` and a mini
success `UPButton`. This preserves the visible source layout without adding a
new generic slot abstraction to `UPInput`.

## Album Page

Create `AlbumPage` with route title `相册` and page key
`example-page-componentsC/album/album`.

Use the exact source image URL families:

`https://uview-plus.jiangruyi.com/uview/album/1.jpg` through `10.jpg`.

Render the eight source blocks in order:

1. `基础使用`: a single object URL using `keyName: src2`.
2. `多图模式`: ten URLs with the default nine-image limit and more overlay.
3. `图文对齐`: four URLs with album width feedback shown beside the source
   text.
4. `更改裁剪模式`: four URLs using the source alternate image mode.
5. `更改图片大小`: four URLs with the source single and multiple sizes.
6. `自定义圆角`: four URLs with radius `10`.
7. `自定义形状`: four URLs with `shape: circle`.
8. `自适应自动换行`: four URLs with `maxCount: 9` and `autoWrap: true`.

The first album exposes a preview callback that updates visible feedback. The
existing `UPImage` loading and error fallback remains responsible for image
failure behavior; widget tests assert layout, source props, and preview
callbacks without requiring successful remote image downloads.

## Package Compatibility Fixes

Only verified gaps that affect this page batch are included:

1. `UPInput.onlyClearableOnFocused` defaults to the source value `true`.
2. `UPInput` forwards string or Map `prefixIconStyle` and
   `suffixIconStyle` values to the corresponding `UPIcon` instances.
3. Existing public callbacks, state helpers, password toggling, numeric input,
   and clear behavior remain compatible with current package tests.

No generic slot API, network abstraction, image cache, or unrelated widget
refactor is added.

## Error And Lifecycle Handling

- No device navigation, network mutation, or platform permission is added.
- Album previews use the existing host callback path and tolerate image load
  failure through `UPImage`.
- Input verification countdown and toast state are owned by the page and
  cleaned up through existing controller/widget lifecycle behavior.
- Tests hide toast overlays after assertions and use deterministic values for
  generated source feedback.
- Pages use local state only and do not share mutable state across routes.

## Testing

Add focused coverage to `example/test/components_c_pages_test.dart`:

- Steps renders all seven source block labels, custom slot text, and error
  state.
- Navbar taps the inline left and right actions and verifies feedback.
- Skeleton toggles the loading switch and verifies the source content slot.
- Input edits the basic value, confirms it, exercises numeric filtering,
  password visibility, and clear behavior.
- Album renders all source section labels, verifies the nine-image limit, and
  taps the preview callback.

Update `example/test/route_catalog_test.dart` from `60` to `65` total routes
and assert the ten Components C route IDs in source order, including the five
new IDs.

Add package regression tests for the `UPInput` default clear visibility and
string/Map icon style forwarding. At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_c/steps_page.dart lib/pages/components_c/navbar_page.dart lib/pages/components_c/skeleton_page.dart lib/pages/components_c/input_page.dart lib/pages/components_c/album_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_steps.dart lib/src/widgets/up_navbar.dart lib/src/widgets/up_skeleton.dart lib/src/widgets/up_input.dart lib/src/widgets/up_album.dart test/widgets_test.dart
flutter test test/widgets_test.dart --reporter expanded
```

Install the resulting APK to MuMu at `127.0.0.1:16384`, launch
`com.example.ultra_ui_example/.MainActivity`, and verify it is focused.

## Commit Boundary

The design commit contains only this spec file.

The implementation commit contains only:

- The five new example pages.
- Route, preview, and test updates.
- The five direct package widget files when required by the pages or changed
  for the compatibility fixes above.
- The implementation plan for this batch.

Existing `README.md` changes and unrelated historical untracked files remain
untouched.
