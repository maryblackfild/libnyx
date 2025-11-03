Here’s my plan and the finished README.

# Plan (for myself)

* Goal: refresh README.md to highlight the new **Liquid Glass** module and demo, place the two GIFs and two PNGs near the top, and document usage.
* Structure:

  1. Title + short tagline
  2. Hero GIF (libnyx_liquid.gif), then a compact image row (libnyx.png + liquid.png). A second demo GIF (libnyx_demo.gif) appears in a “Demos” section.
  3. Features list (Liquid Glass, UI Components, Global Skins, Smooth Scroll, Drag-n-Drop Cells, Sounds, Version check)
  4. Installation (addons placement), file layout, auto-loader behavior, CVars/console command
  5. Quick start (open the Liquid Glass builder, minimal code usage)
  6. Liquid Glass API quick reference (the chainable methods you exposed)
  7. UI kit highlights (Buttons, Tabs, Slider, Dropdown, List, Search, CategoryCard)
  8. Global skins (menu + notifications)
  9. Demos (link to command and function)
  10. Troubleshooting & FAQ
  11. Changelog v0.7.0
  12. Credits/Links
* Constraints: keep names as in your library (libNyx, RNDX), no renames, include the four media assets close to the top, English prose, ready-to-use.

---

# README.md

# libNyx — Modern UI kit for Garry’s Mod with Liquid Glass

<p align="center">
  <img src="libnyx_liquid.gif" alt="libNyx Liquid Glass demo" />
</p>

<p align="center">
  <img src="libnyx.png" alt="libNyx logo" height="120" />
  &nbsp;&nbsp;&nbsp;
  <img src="liquid.png" alt="Liquid Glass mark" height="120" />
</p>

A lightweight, modern UI framework for Garry’s Mod focusing on glassmorphism, smooth motion, gradient accents, and consistent design tokens. Powered by **RNDX** rendering utilities and ready for production UIs.

---

## Highlights

* **Liquid Glass (new in v0.7.0)**
  iOS-style translucent glass with real refraction & tinting, shimmer, grain, edge smoothing, shadows, adjustable blur radius, and runtime tuning UI. Includes a builder that exports ready-to-paste code.

* **UI Components**
  Buttons (primary/ghost/duo/gradient), Tabs with animated indicator, Slider with counter, Dropdown, Checkbox/Switch/Radio, Lists, SearchBox, Category Cards, smooth drag-n-drop item cells, and more.

* **Global Skins**
  Glassy **DMenu** theme and **notifications** skin that seamlessly replace vanilla `notification.AddLegacy` (and gamemode `AddNotify`), with gentle motion and Liquid-style feel.

* **Smooth Scroll**
  Drop-in inertia and styled scrollbars for any `DScrollPanel`.

* **Design Tokens**
  Unified scale, fonts, radii, paddings, stroke/gradient alphas, and accent color.

* **Version Check**
  Auto-checks GitHub raw for new `VERSION` and notifies in console.

---

## Installation

1. Place the repo as an addon:
   `garrysmod/addons/libnyx/`
2. Ensure the following client files are present (shipped by the addon):

   * `lua/autorun/libnyx.lua` (loader)
   * `lua/libnyx/VERSION`
   * `lua/libnyx/lib/rndx.lua`
   * `lua/libnyx/lib/libnyx_components.lua`
   * `lua/libnyx/lib/libnyx_liquidglass.lua`
   * `lua/libnyx/lib/libnyx_maindemo.lua`
3. Start the game; the loader initializes and reports version in console.

### File layout (core)

```
lua/
  autorun/
    libnyx.lua
  libnyx/
    VERSION
    lib/
      rndx.lua
      libnyx_components.lua
      libnyx_liquidglass.lua
      libnyx_maindemo.lua
```

The loader:

* Pre-creates font aliases (`libNyx.UI.*`)
* Includes RNDX and all libNyx modules once
* Installs global menu & notification skins
* Performs a non-blocking update check

---

## Quick Start

### Open the Liquid Glass builder (demo UI)

Console:

```
libnyx_liquid
```

Adjust sliders, switch shapes, toggle shadow, then press **Copy** — you’ll get a formatted call chain you can paste into your HUD/VGUI paint.

### Minimal usage in your panel/HUD

```lua
local R = RNDX()
-- backdrop blur (optional)
R:Rect(x, y, w, h):Rad(32):Flags(RNDX.SHAPE_IOS):Blur(1):Draw()

-- liquid glass box
R:Liquid(x, y, w, h)
  :Rad(32)
  :Color(255,255,255,255)
  :Tint(255,255,255)
  :TintStrength(0.08)
  :Saturation(1.06)
  :GlassBlur(0.02, 0.40)
  :EdgeSmooth(2.0)
  :Strength(0.014)
  :Speed(0.35)
  :Shimmer(22.0)
  :Grain(0.005)
  :Alpha(0.95)
  :Flags(RNDX.SHAPE_IOS)
  :Shadow(40, 56)   -- optional
  :Draw()
```

**Shapes:** `RNDX.SHAPE_IOS`, `RNDX.SHAPE_FIGMA`, `RNDX.SHAPE_CIRCLE`
**Tip:** Circle sets radius = min(w,h)/2 in the builder export.

---

## Liquid Glass — Builder & API

### Builder UI (what it controls)

* Layout: `size`, `rad`, shape (`iOS`, `Figma`, `Circle`)
* Visuals: `strength`, `speed`, `sat`, `Tint RGB`, `tints`
* Blur & Edge: `GlassBlur(all, radius)`, `EdgeSmooth(px)`
* FX: `Shimmer`, `Grain`, `Alpha`
* Shadow: `Enable`, `Spread`, `Intensity`
* Drag: click-and-hold to move, clamped in-screen (outside the left nav)

### Console & CVars

* **Open builder:** `libnyx_liquid`
* **Scale all libNyx UI:** `cl_libnyx_ui_scale` (0 = auto)
* **Builder box default size:** `libnyx_liquid_size`

### Method cheat sheet

```
RNDX():Liquid(x,y,w,h)
  :Rad(r)                      -- or :Radii(...) via Rect if needed
  :Color(r,g,b,a)              -- base “glass” color for composition
  :Tint(r,g,b) :TintStrength(s)
  :Saturation(s)
  :GlassBlur(amount, radius)   -- two-stage blur controller
  :EdgeSmooth(px)              -- AA-like smoothing on edges
  :Strength(k)                 -- refraction strength
  :Speed(v)                    -- shimmer motion speed
  :Shimmer(v)                  -- light streak sparkles
  :Grain(v)                    -- fine film grain
  :Alpha(a)                    -- final composited alpha
  :Flags(RNDX.SHAPE_*)
  :Shadow(spread, intensity)   -- optional soft drop
  :Draw()
```

---

## UI Components (selected)

* **Buttons**: `primary`, `primary_center`, `ghost`, `gradient`, `center_duo`
* **Tabs**: animated rail indicator, ripple, icons
* **Slider**: inertial knob, live counter, wheel & drag
* **Dropdown**: glass popup with smooth open, icons per option
* **Checkbox / Switch / Radio**: grouped radios, tinted tracks, glass knobs
* **List**: gradient accent chips, selection/hover states
* **SearchBox**: inline clear, language hint, gradient accent
* **CategoryCard**: vibrant / glass variants, large icon, subtle motion
* **Interactive Cell**: drag-n-drop with overlay, auto-highlight target

### Smooth Scroll

Apply to any `DScrollPanel`:

```lua
libNyx.UI.SmoothScroll.ApplyToScrollPanel(scrollPanel, {
  step    = libNyx.UI.Scale(90),
  speed   = 18,
  fadeHold= 0.9,
  width   = libNyx.UI.Scale(12),
})
```

Or install under a root panel:

```lua
libNyx.UI.SmoothScroll.InstallUnder(rootPanel)
```

### Global Skins

* **Menu Skin** (DMenu / DMenuOption / Divider):
  `libNyx.UI.InstallGlobalMenuSkin()`
* **Notifications**: Intercepts `notification.AddLegacy`, `AddProgress`, and gamemode `AddNotify` to render glass toasts.
  `libNyx.UI.InstallGlobalNotificationSkin()`

---

## Demos

<p align="center">
  <img src="libnyx_demo.gif" alt="libNyx UI demo" />
</p>

* **Liquid Glass builder:** `libnyx_liquid`
* **Showcase panel:** call `libNyx.UI.OpenShowcase()` from console:

  ```
  lua_run_cl if libNyx and libNyx.UI and libNyx.UI.OpenShowcase then libNyx.UI.OpenShowcase() end
  ```

---

## Troubleshooting

* **“font doesn’t exist (libNyx.UI.*)”**
  Loader pre-creates aliases. If you hot-reloaded mid-frame, run `reloadlua` or re-open the UI; fallback is Tahoma when Manrope is missing.

* **Nothing happens on `libnyx_liquid`**
  Ensure the addon path is correct and client has `lua/libnyx/lib/libnyx_liquidglass.lua`. Check console for “Loaded vX (client)” line.

* **Artifacts or seams**
  Prefer drawing a backdrop blur `Rect(...):Blur(1)` behind your `Liquid(...)` call to unify scene samples, then tune `EdgeSmooth` and `GlassBlur`.

* **Performance**
  Start with lower `GlassBlur`, lower `Shimmer`, and smaller box size. Avoid stacking many overlapping liquid surfaces in the same frame.

---

## Changelog

### v0.8.0

* Added **Liquid Glass** module and **builder UI** (`libnyx_liquid`)
* New **notification skin** with Liquid styling
* Smoother scroll with styled bar, inertia, and fading
* UI polish: ripples, gradients, layout clamps, scale tokens
* Loader: robust include sequencing, version check improvements

---

## Links

* Discord: `https://discord.gg/rUEEz4mfXw`
* Home/Updates: `https://github.com/maryblackfild/libnyx`

---

Made with ❤️ by **MaryBlackfild**.
