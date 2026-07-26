# Component A Route Audit

## Scope and Catalog

The completed catalog contains exactly 27 real routes: the four source main
routes and the 23 `pages/componentsA` routes below. The exported
`componentARouteIds` list is the literal source order and is exercised by the
route smoke test.

`pages.json` places `test/test` under the `pages/componentsA` subpackage root.
Its Flutter route is therefore `componentsA/test/test`, with source path
`pages/componentsA/test/test`; it is the second Component A route after
transition. The catalog title for transition is `过渡动画`.

The component index contains 22 existing Component A preview rows. Every one
is available. `TestListPage` is registered in the catalog but deliberately has
no synthetic preview row because the source `components.config.js` has none.
All Components B-D and template preview rows remain unavailable.

## Route Matrix

| Source path | Flutter class | Local assets | Representative automated coverage | Actual mobile substitution |
| --- | --- | --- | --- | --- |
| `pages/componentsA/transition/transition` | `TransitionPage` | None | `transition page shows the selected transition block` | - |
| `pages/componentsA/test/test` | `TestListPage` | `assets/uview/test/list-item.jpg` | `Component A scroll routes render their source titles` | - |
| `pages/componentsA/icon/icon` | `IconPage` | None | `Component A display routes render their source titles` | - |
| `pages/componentsA/cell/cell` | `CellPage` | `assets/uview/demo/cell/tag.png` | `Component A display routes render their source titles` | - |
| `pages/componentsA/line/line` | `LinePage` | None | `Component A display routes render their source titles` | - |
| `pages/componentsA/image/image` | `ImagePage` | `assets/uview/album/1.jpg` | `Component A display routes render their source titles` | Remote source illustration replaced by a local bundled source asset. |
| `pages/componentsA/link/link` | `LinkPage` | None | `Component A display routes render their source titles` | Source link opening replaced by in-app feedback. |
| `pages/componentsA/button/button` | `ButtonPage` | None | `button page opens its source action sheet` | - |
| `pages/componentsA/loading-icon/loading-icon` | `LoadingIconPage` | None | `Component A display routes render their source titles` | - |
| `pages/componentsA/overlay/overlay` | `OverlayPage` | `assets/uview/demo/overlay/baseCases.png`, `embeddedContent.png`, `setTransparency.png` | `overlay page opens and dismisses embedded content` | - |
| `pages/componentsA/loading-page/loading-page` | `LoadingPagePage` | `assets/uview/demo/loading-page/promptContent.png`, `customPicture.png`, `customMode.png`, `customBgColor.png`, `assets/uview/common/logo.png` | `loading page uses the custom text preset` | - |
| `pages/componentsA/popup/popup` | `PopupPage` | `assets/uview/demo/popup/modeTop.png`, `modeRight.png`, `modeBottom.png`, `modeLeft.png`, `modeCenter.png`, `showRadis.png`, `noClose.png`, `showCloseBtn.png` | `popup page opens a top popup preset` | - |
| `pages/componentsA/swipeAction/swipeAction` | `SwipeActionPage` | None | `swipe action delete confirmation removes the base row` | - |
| `pages/componentsA/sticky/sticky` | `StickyPage` | None | `Component A scroll routes render their source titles` | - |
| `pages/componentsA/radio/radio` | `RadioPage` | None | `radio page changes the source group value` | - |
| `pages/componentsA/checkbox/checkbox` | `CheckboxPage` | None | `checkbox page programmatic toggle changes standalone state` | - |
| `pages/componentsA/empty/empty` | `EmptyPage` | Bundled empty-state asset group | `empty page changes its selected source mode` | - |
| `pages/componentsA/backtop/backtop` | `BackTopPage` | None | `back top page returns its controller to scroll origin` | - |
| `pages/componentsA/divider/divider` | `DividerPage` | None | `Component A display routes render their source titles` | - |
| `pages/componentsA/rate/rate` | `RatePage` | None | `rate page emits an editable half rating` | - |
| `pages/componentsA/gap/gap` | `GapPage` | None | `Component A display routes render their source titles` | - |
| `pages/componentsA/grid/grid` | `GridPage` | None | `grid item tap reports source-style feedback` | - |
| `pages/componentsA/lazyLoad/lazyLoad` | `LazyLoadPage` | `assets/uview/swiper/swiper1.png`, `swiper2.png`, `swiper3.png` | `lazy load page appends a source image batch` | - |

Every row is also covered by `every completed Component A source route renders a real page`, which verifies its literal route marker and catalog registration.

## Main Route Substitution

`pages/example/ad` maps to `AdPage`. The source WeChat rewarded ad is replaced
by an explanatory Android/iOS page because Flutter does not provide a fake
rewarded-ad experience in this example.

## Host and Validation Evidence

| Check | Result |
| --- | --- |
| Host generation | `flutter create --platforms=android,ios .` completed. |
| Platform directories | `example/android/` and `example/ios/` present; no web, Windows, macOS, or Linux host directories created. |
| Manifest preservation | `ultra_ui: path: ../packages/ultra_ui` and all 11 `assets/uview/` declarations remain in `pubspec.yaml`. |
| Full static analysis | `flutter analyze` passed after the generated app boot test was adapted to `UltraUiExampleApp`. |
| Full automated tests | `flutter test --reporter expanded` passed: 26 tests, including the generated-project boot smoke and all 23 Component A route titles. |
| Android build | `flutter build apk --debug` passed; output is `example/build/app/outputs/flutter-apk/app-debug.apk`. |
| iOS build | Skipped: this execution host is Windows, so Xcode/iOS Simulator builds cannot run. |
| Device discovery | `flutter devices` found Windows, Chrome, and Edge only; `flutter emulators` found no emulators. |

## Manual Acceptance

Manual Android acceptance is pending because no Android device or emulator was
available. Manual iOS acceptance is unavailable on this Windows host and
pending an actual macOS/iOS environment. No manual result is fabricated.

The pending acceptance matrix covers launch, safe areas, three bottom tabs,
system back, every enabled Component A route, long-list scrolling,
popup/overlay dismissal, keyboard-free interaction, and the interaction
matrices exercised by Tasks 3-7.
