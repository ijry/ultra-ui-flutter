#!/usr/bin/env python3
"""Compare the source theme CSS variables against the Dart theme tokens.

The source's real style contract lives in libs/css/theme-vars-core.scss as CSS
custom properties, for both the light and dark palettes. This extracts those and
diffs them against UPThemeTokens.light()/dark(), so a wrong or stale color is a
reported mismatch rather than something to be eyeballed.

Emits JSON on stdout:
  {"light": {token: {"source": "#rrggbb", "dart": "#rrggbb"|null, "ok": bool}},
   "dark":  {...}}
"""
from __future__ import annotations

import json
import os
import re
import sys

SCSS = (
    r"D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\libs\css"
    r"\theme-vars-core.scss"
)
THEME = (
    r"D:\Repos\xyito\open\ultra-ui-flutter\packages\ultra_ui\lib\src\theme"
    r"\up_theme.dart"
)
COMPONENTS = (
    r"D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components"
)

# CSS custom property -> Dart field on UPThemeTokens. Only tokens the Dart
# theme actually models are compared; the rest are reported as unmapped.
VAR_TO_FIELD = {
    "--up-main-color": "mainColor",
    "--up-content-color": "contentColor",
    "--up-tips-color": "tipsColor",
    "--up-light-color": "lightColor",
    "--up-border-color": "borderColor",
    "--up-bg-color": "bgColor",
    "--up-page-bg-color": "pageBgColor",
    "--up-card-bg-color": "cardBgColor",
    "--up-disabled-color": "disabledColor",
    "--up-primary": "primary",
    "--up-primary-dark": "primaryDark",
    "--up-primary-disabled": "primaryDisabled",
    "--up-primary-light": "primaryLight",
    "--up-warning": "warning",
    "--up-warning-dark": "warningDark",
    "--up-warning-disabled": "warningDisabled",
    "--up-warning-light": "warningLight",
    "--up-success": "success",
    "--up-success-dark": "successDark",
    "--up-success-disabled": "successDisabled",
    "--up-success-light": "successLight",
    "--up-error": "error",
    "--up-error-dark": "errorDark",
    "--up-error-disabled": "errorDisabled",
    "--up-error-light": "errorLight",
    "--up-info": "info",
    "--up-info-dark": "infoDark",
    "--up-info-disabled": "infoDisabled",
    "--up-info-light": "infoLight",
    "--up-hover-bg-color": "hoverBgColor",
    "--up-navbar-bg-color": "navbarBgColor",
    "--up-gap-bg-color": "gapBgColor",
    "--up-skeleton-bg-color": "skeletonBgColor",
    "--up-skeleton-shimmer-color": "skeletonShimmerColor",
    "--up-swipe-action-button-bg-color": "swipeActionButtonBgColor",
    "--up-index-list-indicator-bg-color": "indexListIndicatorBgColor",
    "--up-table2-header-bg-color": "table2HeaderBgColor",
    "--up-table2-zebra-bg-color": "table2ZebraBgColor",
    "--up-table2-highlight-bg-color": "table2HighlightBgColor",
}

DECL = re.compile(r"(--up-[a-z0-9-]+)\s*:\s*([^;]+);")
# `var(--fallback-name, #rrggbb)` -> take the literal fallback.
VAR_FALLBACK = re.compile(r"var\([^,]+,\s*([^)]+)\)")


def normalize(value: str) -> str | None:
    """Reduce a CSS color to lowercase #rrggbb, or None if not a plain color."""
    value = value.strip()
    m = VAR_FALLBACK.search(value)
    if m:
        value = m.group(1).strip()
    if value.startswith("#"):
        hexpart = value[1:]
        if len(hexpart) == 3:
            hexpart = "".join(c * 2 for c in hexpart)
        if len(hexpart) == 6:
            return "#" + hexpart.lower()
    # rgba()/other functional forms are compared separately, not here.
    return None


def parse_scss() -> tuple[dict[str, str], dict[str, str]]:
    """Return (light, dark) maps of CSS var -> #rrggbb."""
    text = open(SCSS, encoding="utf-8").read()

    # The dark palette lives inside a prefers-color-scheme block; the first
    # :root block is the light default.
    dark_start = text.find("prefers-color-scheme: dark")
    if dark_start < 0:
        raise SystemExit("dark palette block not found")
    # The dark block ends at the following top-level selector.
    dark_end = text.find("[data-up-theme='light']", dark_start)
    if dark_end < 0:
        dark_end = len(text)

    light_text = text[:dark_start]
    dark_text = text[dark_start:dark_end]

    def collect(chunk: str) -> dict[str, str]:
        out: dict[str, str] = {}
        for var, raw in DECL.findall(chunk):
            color = normalize(raw)
            if color:
                # First declaration wins, matching cascade order here.
                out.setdefault(var, color)
        return out

    return collect(light_text), collect(dark_text)


def parse_dart() -> tuple[dict[str, str], dict[str, str]]:
    """Return (light, dark) maps of Dart field -> #rrggbb."""
    text = open(THEME, encoding="utf-8").read()

    def factory_body(name: str) -> str:
        start = text.index(f"factory UPThemeTokens.{name}()")
        # Body ends at the next factory or the class close.
        rest = text[start:]
        nxt = rest.find("factory UPThemeTokens.", 10)
        return rest[:nxt] if nxt > 0 else rest

    field = re.compile(r"(\w+)\s*:\s*Color\(0x([0-9A-Fa-f]{8})\)")

    def collect(body: str) -> dict[str, str]:
        out: dict[str, str] = {}
        for name, argb in field.findall(body):
            # Drop the alpha byte; the source vars are opaque hex.
            out.setdefault(name, "#" + argb[2:].lower())
        return out

    return collect(factory_body("light")), collect(factory_body("dark"))


def parse_component_vars() -> dict[str, dict]:
    """Per-component theme-vars.scss -> {var: {light, dark, differs}}.

    Several components declare their own variables instead of reusing the core
    palette, and those carry distinct dark values. A port that hardcodes the
    light color is therefore wrong in dark mode, so the ones that actually
    differ between palettes are reported for review.
    """
    out: dict[str, dict] = {}
    if not os.path.isdir(COMPONENTS):
        return out
    for entry in sorted(os.listdir(COMPONENTS)):
        path = os.path.join(COMPONENTS, entry, "theme-vars.scss")
        if not os.path.exists(path):
            continue
        text = open(path, encoding="utf-8").read()
        dark_start = text.find("prefers-color-scheme: dark")
        light_text = text[:dark_start] if dark_start > 0 else text
        dark_text = text[dark_start:] if dark_start > 0 else ""

        def collect(chunk: str) -> dict[str, str]:
            found: dict[str, str] = {}
            for var, raw in DECL.findall(chunk):
                color = normalize(raw)
                if color:
                    found.setdefault(var, color)
            return found

        light = collect(light_text)
        dark = collect(dark_text)
        for var, light_value in light.items():
            dark_value = dark.get(var)
            out[var] = {
                "component": entry,
                "light": light_value,
                "dark": dark_value,
                # Identical values are safe to hardcode; differing ones are not.
                "differs": dark_value is not None and dark_value != light_value,
            }
    return out


def main() -> int:
    scss_light, scss_dark = parse_scss()
    dart_light, dart_dark = parse_dart()

    report: dict[str, dict] = {}
    mismatches = 0
    for label, scss, dart in (
        ("light", scss_light, dart_light),
        ("dark", scss_dark, dart_dark),
    ):
        entries: dict[str, dict] = {}
        for var, field in VAR_TO_FIELD.items():
            source = scss.get(var)
            if source is None:
                continue
            actual = dart.get(field)
            ok = actual == source
            if not ok:
                mismatches += 1
            entries[var] = {
                "field": field,
                "source": source,
                "dart": actual,
                "ok": ok,
            }
        report[label] = entries

    component_vars = parse_component_vars()
    report["component_vars"] = component_vars

    report["_summary"] = {
        "component_vars_with_dark_variant": sorted(
            k for k, v in component_vars.items() if v["differs"]
        ),
        "mismatches": mismatches,
        "compared": sum(len(v) for k, v in report.items() if k != "_summary"),
        "unmapped_source_vars": sorted(
            set(scss_light) - set(VAR_TO_FIELD)
        ),
    }
    # `compared` counted the report dicts; exclude the component_vars map.
    report["_summary"]["compared"] = sum(
        len(report[label]) for label in ("light", "dark")
    )
    json.dump(report, sys.stdout, ensure_ascii=False, indent=1)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
