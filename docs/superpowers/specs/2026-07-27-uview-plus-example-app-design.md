# uView Plus Flutter Example App Design

## Goal

Replace the current single long-form Flutter component showcase with an Android/iOS example application that mirrors every route registered by uView Plus `src/pages.json`. The application must preserve the source example's three top-level destinations, route grouping, page titles, representative layout, default component state, and interactive behavior while using the `UP*` Flutter components.

## Scope

The source of truth is:

- `D:\Repos\xyito\open\uview-plus\src\pages.json`
- `D:\Repos\xyito\open\uview-plus\src\pages\**\*.vue`

The registered source application contains 124 routes:

| Group | Source root | Route count | Flutter destination |
| --- | --- | ---: | --- |
| Main | `pages/example` | 4 | Component landing page, template landing page, mine page, and source ad route |
| Components A | `pages/componentsA` | 23 | Component example pages, batch A |
| Components B | `pages/componentsB` | 28 | Component example pages, batch B |
| Components C | `pages/componentsC` | 28 | Component example pages, batch C |
| Components D | `pages/componentsD` | 27 | Component example pages, batch D |
| Templates | `pages/template` | 14 | Composed application-template pages |

The work includes all 124 registered routes. Vue files that are imported by a registered page but are not themselves routes remain implementation detail of their parent Flutter page. The work does not target Flutter Web.

## Product Structure

The Flutter application uses a root `MaterialApp` with a source-shaped mobile shell.

- Bottom navigation has three persistent destinations: `组件`, `模板`, and `我的`.
- `组件` is a grouped index containing four source groups, `componentsA` through `componentsD`. Each group lists its source page titles in source order and opens a dedicated Flutter page.
- `模板` is a source-order list of all 14 template routes and opens a dedicated Flutter page for each.
- `我的` reproduces the source mine route using the source component composition and navigation affordances that are supported on Android/iOS.
- The source ad route is reachable from the component landing area and is not silently omitted.
- Every source detail page has a source title in the app bar, Android/iOS back navigation, safe-area-aware content, and a stable route identifier that maps to its source path.

## Route Catalog

A typed route catalog is the only navigation registry. Each entry contains:

```dart
class ExampleRoute {
  const ExampleRoute({
    required this.id,
    required this.sourcePath,
    required this.title,
    required this.group,
    required this.builder,
  });

  final String id;
  final String sourcePath;
  final String title;
  final ExampleRouteGroup group;
  final WidgetBuilder builder;
}
```

`id` is a slash-normalized Flutter key derived from the source route, such as `componentsA/button/button`. `sourcePath` retains the original registered route. The catalog is used by the component index, template index, direct route resolution, smoke tests, and the completion audit. Each registered source route must have exactly one catalog entry and one non-placeholder page builder.

## Page Architecture

The example app is split by responsibility instead of expanding `example/lib/main.dart` further.

```text
example/lib/
  main.dart                         # app bootstrap only
  app/example_app.dart              # MaterialApp, theme, named-route resolution
  app/example_shell.dart            # three-destination mobile shell
  routes/example_route.dart         # route value object and group enum
  routes/example_catalog.dart       # complete 124-route registry
  pages/home/components_home_page.dart
  pages/home/templates_home_page.dart
  pages/home/mine_page.dart
  pages/shared/example_page_scaffold.dart
  pages/shared/example_section.dart
  pages/shared/example_route_list.dart
  pages/components_a/...            # 23 dedicated source-shaped pages
  pages/components_b/...            # 28 dedicated source-shaped pages
  pages/components_c/...            # 28 dedicated source-shaped pages
  pages/components_d/...            # 27 dedicated source-shaped pages
  pages/templates/...               # 14 dedicated source-shaped pages
```

`ExamplePageScaffold` supplies the common Android/iOS page chrome only: safe area, source title, normal back action, page background, and scroll behavior. It does not impose a card layout or replace source page composition. Individual pages own their local state and use `UP*` widgets directly.

Pages may share a focused helper only when the source pages genuinely repeat the same interaction, such as a selectable option row. Helpers do not hide component APIs or convert all pages into generic configuration data.

## Fidelity Rules

Each source page migration must preserve the following user-observable behavior where Flutter platform capabilities permit it:

- Page title, grouping, source order, visual hierarchy, color, spacing, labels, and default selected values.
- The source component's documented and demonstrated props, callbacks, loading states, disabled states, overlays, popup directions, selection changes, and form state.
- A page-specific interaction must use the actual `UP*` component rather than a static likeness.
- Route-level page navigation and modal dismissal use Android/iOS back behavior in addition to visible controls.
- Source page assets are copied into the Flutter example asset bundle only when they are required to reproduce a visible page. Remote source URLs are not made a runtime dependency for basic navigation or component interaction.
- Uni-app-only capabilities without a native Flutter equivalent, such as mini-program cover views or browser-only host APIs, are represented by the closest Android/iOS interaction and documented in the route audit rather than replaced with a fake no-op control.

## Migration Batches

The work is deliberately incremental. Each completed batch leaves the application installable and all registered routes from earlier batches functional.

1. **Foundation and components A, 23 routes**
   - Replace the long single-page demo with the app shell, route catalog, component index, template index, mine page, source ad route, common mobile page scaffold, and full `componentsA` route set.
   - This is the first installable milestone for Android/iOS.
2. **Components B, 28 routes**
   - Add every source component B page and its assets/interactions.
3. **Components C, 28 routes**
   - Add every source component C page and its assets/interactions.
4. **Components D, 27 routes**
   - Add every source component D page and its assets/interactions.
5. **Templates, 14 routes and final fidelity sweep**
   - Add every registered source template page, complete source asset packaging, validate route catalog completeness, and perform Android/iOS manual visual and interaction review.

## Error Handling and Unsupported Behavior

- A route catalog lookup failure shows a visible development error page containing its source path; production navigation must not silently land on an unrelated page.
- Expected user-level component validation stays inside the corresponding `UP*` component behavior. Example pages do not add duplicate validation unless it exists in the source page.
- An unsupported platform behavior is noted in a route audit document with its source behavior, native substitute, and affected platform. It is not counted as 1:1 complete until reviewed.

## Testing and Acceptance

Automated verification grows with each migration batch.

- Widget tests verify app boot, three bottom-navigation destinations, route catalog uniqueness, and that all routes in the current batch can be pushed and render their source page title.
- Each migrated page has at least one behavior test for its principal interactive state, such as opening a popup, changing a selection, or submitting a form. Static-only assertions do not qualify as the page behavior test.
- The final route smoke test iterates all 124 catalog routes, pushes each through the actual navigation path, and asserts a rendered page marker and title.
- `flutter analyze`, `flutter test`, and `dart format` must pass at each batch boundary.
- Android and iOS manual acceptance verifies installation, launch, safe-area layout, bottom navigation, back navigation, long-list scrolling, popups/overlays, keyboard handling, and the representative interactions for every page.

## First Milestone Acceptance Criteria

The foundation and `componentsA` batch is complete only when:

- The app launches into the source-shaped `组件` destination on Android and iOS.
- `组件`, `模板`, and `我的` are reachable from the bottom navigation.
- The components index lists source groups A-D in source order, with group A pages enabled and later batches visibly marked unavailable only until their page builders exist.
- All 23 registered `pages/componentsA` routes resolve to a dedicated, non-placeholder Flutter page.
- Every group A page renders source title and representative layout, and its key interaction works through a real `UP*` component.
- The route smoke tests cover the shell, main routes, and every group A route.
- `flutter analyze` and all example/package tests pass.

## Out of Scope

- Flutter Web support and browser-specific screenshot parity.
- Rewriting the `ultra_ui` component API while building example pages, except for a separately demonstrated source-compatibility defect required by a page.
- Unregistered experimental source pages.
- Reproducing uni-app build tooling, mini-program manifests, or host-specific source configuration.
