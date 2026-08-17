# Ultra UI Flutter Design

Date: 2026-07-23  
Source of truth: `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus` (uview-plus 3.8.82)  
Target repo: `D:\Repos\xyito\open\ultra-ui-flutter`

## Goal

Build a Flutter UI library that is API-compatible with uview-plus and visually 1:1 with its default styles. Component prefix is `UP` (for example `UPButton`, `UPIcon`). Final objective is full component-set parity with the source library, delivered in stages without shrinking the end state.

## Decisions

- Approach: source-driven 1:1 port (map props/defaults/styles/utils from uview-plus, not a free redesign)
- Package layout: `packages/ultra_ui` library + `example` showcase app
- Naming: Dart package `ultra_ui`, widgets prefixed with `UP`
- Compatibility priority: props names, defaults, visual metrics, then idiomatic Flutter internals
- Platform-only source APIs (WeChat `openType`, mini-program share cards, etc.): keep parameter surface, no-op at runtime, document as unsupported on Flutter
- Style acceptance: hard visual parity
  - layout metrics tolerance: ±1 logical px
  - font metrics must match declared size/weight/line height; platform rasterization differences are allowed
  - active/disabled/plain/loading states must match source behavior

## Repository Structure

```text
ultra-ui-flutter/
  packages/ultra_ui/
    lib/
      ultra_ui.dart
      src/
        config/
        theme/
        utils/
        icons/
        widgets/
    fonts/
    test/
  example/
  docs/superpowers/specs/
  docs/superpowers/plans/
```

## Core Architecture

### 1. Config layer

Mirror source modules:

- `config` (`version`, `unit`, `iconUrl`, `customIcon`, `interceptor`)
- `color`
- `zIndex`
- `props` defaults registry

Provide:

```dart
UP.setConfig(...)
UP.config
UP.color
UP.zIndex
UP.props
```

Default unit is `px`, same as source `config.unit`.

### 2. Unit and style utilities

Port first:

- `getPx`
- `rpx2px` (750-width design baseline: `px = rpx * screenWidth / 750`)
- `range`
- `sleep`
- `test.*`
- `debounce` / `throttle`
- color helpers (`hexToRgb`, `rgbToHex`, `colorToRgba`, `colorGradient`)

All widget size inputs accept `num | String` style values (`12`, `"12px"`, `"24rpx"`) through `getPx`.

### 3. Theme tokens

Seed tokens from source theme/color defaults:

| Token | Value |
|---|---|
| primary | `#3c9cff` |
| success | `#5ac725` |
| warning | `#f9ae3d` |
| error | `#f56c6c` |
| info | `#909399` |
| mainColor | `#303133` |
| contentColor | `#606266` |
| tipsColor | `#909399` |
| lightColor | `#c0c4cc` |
| borderColor | `#dadbde` |
| bgColor | `#f3f4f6` |
| disabledColor | `#c8c9cc` |

Implementation notes:

- `UPTheme` via `ThemeExtension` + inherited access helper
- light theme first; dark structure reserved
- component colors resolve through tokens, not hard-coded one-offs unless source itself hard-codes

### 4. Icon system

- Ship source `upicon.ttf`
- Port `icons.js` name → codepoint map
- `UPIcon` supports font icon, image icon path/url, label placement, and theme color names

### 5. Widget mapping rules

- Keep prop names aligned with source whenever legal in Dart
- Events: `@click` → `onClick`, keep semantic names for other callbacks
- slots → nullable `Widget` parameters (`child`, `iconSlot`, etc.)
- `customStyle` → `UPStyle` (padding/margin/color/decoration/textStyle subset)
- defaults copied from each source `*.js` props table
- styles copied from component scss + inline computed styles

## MVP Scope (P0-P1)

Infrastructure:

- package scaffold
- config/theme/utils/icons
- example app shell

Widgets:

1. `UPButton`
2. `UPIcon`
3. `UPText`
4. `UPTag`
5. `UPBadge`
6. `UPCell` / `UPCellGroup`
7. `UPLoadingIcon`
8. `UPGap`
9. `UPLine`
10. `UPDivider`
11. `UPImage`
12. `UPAvatar`

Each widget deliverable includes:

- default props table
- widget implementation
- example gallery states
- tests for defaults + at least one visual/behavior variant

## Full Roadmap (end state unchanged)

| Phase | Scope | Done means |
|---|---|---|
| P0 | scaffold + theme/utils/config + Icon/Button | runnable example, Icon/Button 1:1 |
| P1 | remaining MVP base widgets | all MVP widgets 1:1 |
| P2 | form set (Input/Switch/Checkbox/Radio/Search/Form...) | form flows usable |
| P3 | feedback/navigation (Popup/Modal/Toast/Notify/Navbar/Tabs...) | app chrome usable |
| P4 | data/complex widgets (Swiper/Picker/Calendar/Upload/...) | batch parity continues |
| P5 | full remaining set + docs + platform gap matrix | complete source component parity |

Final success condition: Flutter library covers the source component set with API compatibility and 1:1 default visual parity, plus core `$u` utility surface needed by those components.

## Compatibility Matrix Policy

For every source prop/event:

1. **Supported**: implemented with equivalent Flutter behavior
2. **Emulated**: closest Flutter behavior with documented difference
3. **No-op retained**: API accepted, ignored, documented
4. **Deferred**: scheduled in later phase, listed in gap matrix

No silent drops of public source props in completed phases.

## Verification

- Unit tests for utils and default props
- Widget tests for interaction and state classes
- Golden tests for default and key variants (light theme)
- Manual example comparison against uview-plus demo states
- Gap matrix maintained under `docs/` as components land

## Non-goals for first implementation slice

- Full i18n runtime parity in P0
- Full http/route stack in P0
- Dark theme pixel parity in P0
- Mini-program host API simulation

These remain part of the long-term end state where source requires them, but do not block P0/P1 visual component parity.
