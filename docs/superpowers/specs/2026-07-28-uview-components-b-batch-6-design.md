# Components B Sixth Source-Order Batch Design

**Date:** 2026-07-28

**Status:** Approved for implementation

## Goal

Migrate the next three registered uView Plus Components B source pages after
Tag into the Flutter example:

1. `pages/componentsB/alert/alert`
2. `pages/componentsB/switch/switch`
3. `pages/componentsB/collapse/collapse`

The pages must preserve source order, navigation titles, visible Chinese labels,
representative default state, principal interaction, and Android/iOS-only
runtime behavior. Flutter component class names continue to use the `UP` prefix.

## Source Of Truth

Route order and titles come from:

`D:\Repos\xyito\open\uview-plus\src\pages.json`

Page content comes from:

- `src/pages/componentsB/alert/alert.nvue`
- `src/pages/componentsB/switch/switch.nvue`
- `src/pages/componentsB/collapse/collapse.nvue`

No preview route is marked available before its real catalog route and page
builder exist.

## Architecture

Add one focused Flutter page per source route under
`example/lib/pages/components_b/`. Register the routes immediately after Tag in
`example_catalog.dart`; enable their existing preview rows without reordering
the preview catalog.

Alert, Switch, and Collapse examples use real `UPAlert`, `UPSwitch`, and
`UPCollapse` / `UPCollapseItem` widgets. The corresponding package widget files
are currently untracked and must be included in the implementation commit,
matching the previous batch pattern for newly demonstrated package components.

`UPCollapseItem` will gain three source slot bridges:

- `titleWidget` for the source `#title` slot.
- `iconWidget` for the source `#icon` slot.
- `rightIconWidget` for the source `#right-icon` slot.

Existing `title`, `icon`, `value`, `showRight`, and arrow behavior remain
compatible. Slot widgets override only the visible region they represent.

## Alert Page

Create `AlertPage` with route title `警告` and page key
`example-page-componentsB/alert/alert`.

Render source blocks in order:

1. `基础功能`
2. `深浅色`
3. `显示图标`
4. `可关闭`
5. `带标题`

All examples use real `UPAlert`. The alert rows use the exact source
descriptions, `type`, `effect`, `showIcon`, `closable`, `title`, and spacing.
The closable block owns two booleans so closing either alert hides only that
row. The second closable row records `关闭事件：1` when its `onClose` callback
runs, matching the source `@close` callback as a visible testable signal.

## Switch Page

Create `SwitchPage` with route title `开关` and page key
`example-page-componentsB/switch/switch`.

Render source blocks in order:

1. `基础功能`
2. `加载中`
3. `禁用状态`
4. `自定义尺寸`
5. `自定义颜色`
6. `自定义样式`
7. `异步控制`

The page stores thirteen source values with the same initial state:

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

Each source row uses `UPSwitch` with the matching `loading`, `disabled`, `size`,
`activeColor`, `inactiveColor`, `space`, and `asyncChange` props. The basic rows
print their boolean value beside the switch, matching the source interpolation.

The async row uses `UPSwitch(asyncChange: true)`. Its `onChange` opens a Flutter
confirmation dialog with content `确定要打开吗` or `确定要关闭吗`. Confirming the
dialog updates `_values[12]`; cancelling leaves the value unchanged.

## Collapse Page

Create `CollapsePage` with route title `折叠面板` and page key
`example-page-componentsB/collapse/collapse`.

Render source blocks in order:

1. `基础功能`
2. `展开和禁用`
3. `手风琴模式`
4. `移除下划线`
5. `自定义标题和内容`

All examples use real `UPCollapse` and `UPCollapseItem`. The content text,
source item titles, `name`, `showRight`, `disabled`, `value`, `accordion`, and
`border` props match the source. The basic block stores the latest change event
as `变更：...` for testability.

The custom title and content block uses the new slot bridge props:

- First item passes `titleWidget: Text('文档指南')` styled with the source primary
  color and has no string `title`.
- Second item passes `iconWidget: UPIcon(name: 'tags-fill', size: 20)`.
- Third item passes `rightIconWidget: Text('10')`.

The bottom source `up-gap height="50"` is represented with `SizedBox(height: 50)`.

## Data Flow And State

- Alert stores only closeable-row visibility and close-event count.
- Switch stores one boolean per source `v-model` value.
- Collapse stores only the basic block change payload text.
- Dialog state is owned by Flutter `showDialog` and does not cross route
  boundaries.

Callbacks update only their own demo row. No page shares mutable state with
another route.

## Error And Lifecycle Handling

- No new dependencies, permissions, remote image loads, or network calls are
  introduced.
- The Switch async dialog checks `context.mounted` before updating state after
  the dialog result.
- Alert closing uses component callbacks and does not schedule delayed work.
- Collapse slot widgets are optional and default to existing behavior, so older
  callers are not affected.

## Testing

Add focused widget tests before implementation:

- `UPCollapseItem` component test proves `titleWidget`, `iconWidget`, and
  `rightIconWidget` render and replace only their intended regions.
- Alert page test closes a source closable alert and verifies its callback
  count becomes visible.
- Switch page test toggles a basic switch, opens the async confirmation dialog,
  confirms, and verifies the controlled value changes.
- Collapse page test opens the source basic panel, sees content, verifies the
  default-expanded `众多利器` panel, and verifies the custom slot content `10`.
- Route catalog test updates completed total from 43 to 46 and verifies
  Components B order through `alert`, `switch`, and `collapse`.

At the batch boundary run:

```powershell
cd example
dart format lib/pages/components_b/alert_page.dart lib/pages/components_b/switch_page.dart lib/pages/components_b/collapse_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
dart format lib/src/widgets/up_alert.dart lib/src/widgets/up_switch.dart lib/src/widgets/up_collapse.dart test/widgets_test.dart
flutter test test/widgets_test.dart --reporter expanded
```

Install the resulting APK to MuMu at `127.0.0.1:16384`, launch
`com.example.ultra_ui_example/.MainActivity`, and verify it is focused.

## Commit Boundary

The design commit contains only this spec file.

The implementation commit contains only:

- The three new example pages.
- Route, preview, and test updates.
- `UPCollapseItem` slot bridge changes and package test.
- The package widget files demonstrated by this batch.
- The implementation plan for this batch.

Existing unrelated modifications and untracked files remain untouched.
