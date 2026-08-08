# Components C Batch 3 Design

## Scope

Implement the next five uView Plus example pages in source order:

1. `componentsC/avatar/avatar`
2. `componentsC/readMore/readMore`
3. `componentsC/layout/layout`
4. `componentsC/indexList/indexList`
5. `componentsC/indexList/indexList2`

The work continues the existing Flutter port in
`D:\Repos\xyito\open\ultra-ui-flutter`. The source behavior is taken from the
corresponding nvue pages under
`D:\Repos\xyito\open\uview-plus\src\pages\componentsC`.

## Goals

- Add usable Flutter example pages matching the source examples.
- Preserve the existing component APIs and reuse the already implemented
  `UPAvatar`, `UPAvatarGroup`, `UPReadMore`, `UPParse`, `UPRow`, `UPCol`,
  `UPIndexList`, `UPIndexItem`, `UPIndexAnchor`, `UPButton`, and `UPPopup`.
- Keep page behavior deterministic and testable without depending on network
  image loading.
- Register the pages in the example route catalog in source order.
- Keep the current working tree changes outside this batch untouched.

## Non-goals

- No new generic demo-page framework.
- No unrelated refactoring or cleanup of historical scripts and generated
  files.
- No broad public API redesign for the existing package widgets.
- No requirement that MuMu or another Android emulator be available for the
  test suite.

## Architecture and File Boundaries

Add these example files:

- `example/lib/pages/components_c/avatar_page.dart`
- `example/lib/pages/components_c/read_more_page.dart`
- `example/lib/pages/components_c/layout_page.dart`
- `example/lib/pages/components_c/index_list_page.dart`
- `example/lib/pages/components_c/index_list2_page.dart`
- `example/lib/pages/components_c/index_list_data.dart`

The five page files use `ExamplePageScaffold` and `ExampleDemoBlock`, following
the existing Components C pages. `index_list_data.dart` contains fixed URLs,
names, index letters, and deterministic grouped contact data shared by the two
index-list pages. It is an example-layer fixture, not a package API.

The package widgets remain the source of component behavior. If a page test
identifies a missing or incorrect behavior, make the smallest focused change
in the corresponding widget and add a package widget test for that behavior.
Do not modify unrelated widgets.

Update:

- `example/lib/routes/example_catalog.dart` with imports, builders, and five
  route entries.
- `example/lib/routes/example_preview_catalog.dart` to mark the existing
  `layout`, `indexList`, `readMore`, and `avatar` preview entries available.
- `example/test/components_c_pages_test.dart` with page behavior tests.
- `example/test/route_catalog_test.dart` with the new Components C route list
  and preview availability expectations.

`indexList2` is an internal page reached from `indexList`, like the existing
internal parse jump page. It is registered as an available route for direct
tests and navigation, but it is not added as a separate home preview entry.

## Page Designs

### Avatar

Render the source sections in this order:

- basic image avatar
- circle and square shapes
- 30, 40, and 50 pixel sizes
- icon avatars
- text avatars with deterministic random background colors
- failed image with default rendering
- avatar group with gaps `0.4` and `0.6`

Use the source image URLs for visual parity. The page must expose a visible
click result or count for the clickable circle avatar so the callback is
observable in widget tests.

### Read More

Wrap a long `UPParse` paragraph containing the source poem with:

- `showHeight: 200`
- `toggle: true`
- source close/open labels and colors
- paragraph line-height styling equivalent to the nvue page

The page observes `onOpen` and `onClose` and renders the current state and
callback counts. The content must naturally exceed the collapsed height so
the toggle is present after layout.

### Layout

Render the five source sections:

- basic usage
- column gutter
- mixed spans
- column offsets
- alignment examples

Use `UPRow` and `UPCol` directly with the source `span`, `offset`, `gutter`,
and `justify` values. Neutral gray-blue blocks provide visible geometry while
the page structure remains equivalent to the source demo.

### Index List

Use the index sequence `↑`, `☆`, `A` through `P`, and `#`. The header contains
the four source entries:

- 新的朋友
- 标签
- 朋友圈
- QQ

Each grouped section contains an `UPIndexAnchor`, ten fixed contact rows with
35 pixel square avatars, and separators. The footer displays
`共305位好友`. Tapping `新的朋友` pushes `indexList2`.

The page uses the existing index-list rail and state. Tests verify a letter
selection updates the active index and emits the selected letter without
requiring a pixel-coordinate diagnostic.

### Index List 2

Render a small primary `UPButton` labeled `打开弹窗`. Tapping it displays a
bottom `UPPopup` with:

- `safeAreaInsetBottom: false`
- a 600 pixel content height
- the same header, grouped contacts, index rail, and footer as the source

The popup state is controlled by the page and tested through visible open and
close transitions. The page remains usable even when the popup is opened
before the index list has completed its first layout pass.

## Data Flow and State

- Page-local state owns visible callback counts, navigation actions, and popup
  visibility.
- Existing component state owns read-more expansion and index-list selection.
- Shared index-list fixture data is immutable and generated deterministically
  from fixed names and URLs.
- No network response, random number generator, or emulator-only behavior is
  part of the test contract.

## Testing and Acceptance

Add five example widget tests:

- Avatar sections, component parameters, and click result.
- Read-more collapsed/expanded/closed states and callbacks.
- Layout section labels and representative span/offset/gutter widgets.
- Index-list content, letter selection, and navigation to `indexList2`.
- Index-list popup opening, closing, and inner index-list interaction.

Update route catalog tests to assert:

- Components C contains the current ten routes plus these five in source order.
- All five route IDs resolve to registered builders.
- The four existing preview entries are marked available.
- `indexList2` remains an internal available route without a new preview entry.

Required validation after implementation:

```text
flutter test example
flutter test packages/ultra_ui
flutter analyze example
flutter analyze packages/ultra_ui
flutter build apk --debug --target-platform android-arm64
```

Package analyze output may retain the repository's existing baseline warnings
and informational issues, but the batch must introduce no new errors.

## Risks and Mitigations

- **Network images fail in tests:** assert structure and use the existing image
  widget behavior; do not assert successful remote decoding.
- **Read-more content is not measured as long:** use a real long paragraph and
  pump after layout before asserting the toggle.
- **Index rail taps are fragile:** use widget/state-level selection helpers or
  semantic letter finders instead of hard-coded screen coordinates.
- **Popup layout changes after opening:** give the popup content a stable
  height and keep the index-list fixture deterministic.
- **Dirty working tree contamination:** stage and commit only the new spec or
  later, only the files explicitly changed for this batch.
