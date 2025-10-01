---

# libNyx UI — demo edition ✨

Modern, animated UI components for **Garry’s Mod** written in Lua.
Built by **Nyx Team**, authored by **MaryBlackfild**. This repository is a **demo version** showcasing the library’s look, feel, and API.

[![Discord](https://img.shields.io/badge/Discord-Join%20us-5865F2?logo=discord\&logoColor=white)](https://discord.gg/rUEEz4mfXw)
[![Status](https://img.shields.io/badge/state-demo-blueviolet)](#-status--roadmap)
[![Platform](https://img.shields.io/badge/platform-Garry's%20Mod-13a5ec)](#requirements)
[![License](https://img.shields.io/badge/license-TBD-lightgrey)](#license)

---

## Table of contents

* [Highlights](#highlights)
* [Screens & demo](#screens--demo)
* [Installation](#installation)
* [Quick start](#quick-start)
* [Auto-loader & version check](#auto-loader--version-check)
* [Components](#components)
* [Styling & scale](#styling--scale)
* [Utilities & effects](#utilities--effects)
* [Commands, ConVars & paths](#commands-convars--paths)
* [Project layout](#project-layout)
* [Status & roadmap](#-status--roadmap)
* [Contributing](#contributing)
* [Author & credits](#author--credits)
* [License](#license)

---

## Highlights

* 🎛️ **Rich component set**: buttons (multiple variants), checkboxes/switches/radios, sliders, dropdowns, lists, tabs, category cards, inventory cells, search box.
* 🧊 **“Glass” aesthetic** with dynamic blur, soft strokes, and gradients.
* 🔄 **Animated** open/close transitions, ripples, hover states, drag & drop, and focus accents.
* 🖱️ **Inventory cells** with **hover info boxes** (title, description, tags) and **drag-to-swap**.
* 🧭 **Tabs** with animated selection indicator.
* 🧷 **Smooth scrolling** overlay for any scroll panel.
* 🔍 **Search** with RU/EN language hint and clear button.
* 🔊 Sound UX: hover/click sounds and gentle redirection of default UI sounds.
* 🔔 **Auto-loader** that prints **Loaded vX** and checks **GitHub VERSION** to tell you if you’re **up-to-date**.

> This repository is a **showcase** build. APIs may evolve.

---

## Screens & demo

Open the interactive showcase in-game:

```bash
libnyx_ui_showcase
```

The showcase features two tabs with examples of all components, layouts, and states.

---

## Installation

1. Copy the `lua/` folder into your addon (or `garrysmod/lua/` during development).

2. Make sure the **autorun** file exists:

   ```
   lua/autorun/libnyx.lua
   ```

   It loads the library, prints the loaded version, and performs the update check.

3. Start your game/server and watch the console for:

```
[libNyx] Loaded vX.Y.Z (server|client)
[libNyx] Checking for updates…
[libNyx] Up-to-date ✓ (latest: X.Y.Z)
```

If you are behind:

```
[libNyx] Update available ✱ installed X.Y.Z → latest A.B.C
[libNyx] Get it: https://github.com/maryblackfild/libnyx
```

---

## Quick start

```lua
-- Create a frameless “glass” window
local W, H = 960, 640
local frame = libNyx.UI.CreateFrame({ w = W, h = H, title = "libNyx UI" })

-- Add a button
local btn = libNyx.UI.Components.CreateButton(frame, "Click me", {
  variant = "primary",
  onClick = function() chat.AddText(Color(0,255,0), "[libNyx] Hello!") end
})
btn:Dock(TOP); btn:DockMargin(16,16,16,0)

-- Show the demo window (or just run the console command)
libNyx.UI.OpenShowcase()
```

---

## Auto-loader & version check

File: `lua/autorun/libnyx.lua`

* Reads local `VERSION` (fallback `0.0.0`).
* Prints: `Loaded vX.Y.Z (server|client)`.
* Fetches GitHub raw file `VERSION` and compares.
* If the primary check fails, it optionally falls back to parsing a remote loader.
* URLs used:

  * Raw version: `https://raw.githubusercontent.com/maryblackfild/libnyx/main/VERSION`
  * Project home: `https://github.com/maryblackfild/libnyx`

You only need to **commit a single `VERSION` file** at repo root (already present).

---

## Components

Namespace: `libNyx.UI.Components`

* **CreateButton(parent, text, opts)**
  Variants: `primary`, `soft`, `ghost`, `gradient`, `primary_center`, `center_duo`
  Supports icons, ripple effects (filled/ring), and center gradient styles.

* **CreateCheckbox(parent, opts)**
  Variants: `switch`, `knob`, `radio`
  Grouped radios supported via `SetGroup(name)`. `onChange(checked, self)` callback.

* **CreateSlider(parent, opts)**
  Smooth value animation, counter bubble, hover/drag emphasis. `min`, `max`, `decimals`, `value`, `tint`.

* **CreateDropdown(parent, opts)**
  Glass menu with animated reveal, optional icons for options, gradient hover, `onSelect(value)`.

* **CreateList(parent, opts)**
  Rows with icons, right-side text, label “chips”, selection handling, ripple on hover/click.

* **CreateTabs(parent, opts)**
  Items with icon/label, animated indicator that stretches on hover, `onChange(id)`.

* **CreateCategoryCard(parent, opts)**
  `vibrant` and `glass` variants with dual gradients, animated icon overlay and text.

* **CreateVBox(parent, opts)**
  Small display cards: `center_gradient`, `vertical_gradient`, `sunburst`, `model`.
  Optional `model` preview with subtle camera animation on hover.

* **CreateCell(parent, opts)** and **CreateInteractiveCell(parent, opts)**
  Base square cell + interactive behavior:

  * `SetItemIcon(material, size, info)` where `info = { title, desc, tags = { "tag" or {text=..., color=...} } }`
  * `SetItemModel(path)` or `ClearItem()`
  * Interactive cells support **drag & drop** with drop target highlight.

* **CreateSearchBox(parent, opts)**
  Placeholder, debounce, clear button, `onChange`, `onSubmit`, `onClear`.
  Shows RU/EN indicator while focused based on input.

---

## Styling & scale

Namespace: `libNyx.UI.Style`

Key colors & metrics:

* `bgColor`, `panelColor`, `cardColor`, `accentColor`, `textColor`, `glassFill`, `glassStroke`
* `radius`, `padding`, `iconSize`, `btnHeight`, `rowHeight`, `strokeWidth`
* Gradient alphas for rows, chips, buttons.

**Adaptive scale** is computed from screen height (1080p baseline) with manual override.

ConVar:

```bash
cl_libnyx_ui_scale 0   # 0 = auto, allowed range 0.50 … 2.00
```

Fonts are auto-generated and cached (Manrope → Tahoma fallback).

---

## Utilities & effects

* `libNyx.UI.Draw.Glass(x,y,w,h, {radius, fill, stroke, strokeColor, blurIntensity})`
  Core glass/blur renderer used across components.

* `libNyx.UI.Draw.Panel(...)`
  Rounded, optional stroke/shadow/gradient helper.

* **Drag & drop overlay**
  Animated pickup/drop with target highlight (`PostRenderVGUI` overlay).
  Helpers: `libNyx.UI.StartDragIcon(...)`, `libNyx.UI.StopDragIcon(target)`.

* **Ripples**
  Global style `libNyx.UI.SetRippleStyle("fill"|"ring"|1|2)`.

* **Smooth scrolling**
  `libNyx.UI.SmoothScroll.ApplyToScrollPanel(panel, opts)` and
  `libNyx.UI.SmoothScroll.InstallUnder(root, opts)` to auto-install under a tree.

* **FlyIcon**
  `libNyx.UI.FlyIcon(material, sx, sy, ex, ey, size, dur, cb)` little icon animation.

* **CreateFrame(opts)**
  Animated open/close (back/exp ease), content alpha gating, glass background and header title.

* **Sounds**
  `libNyx.UI.Sounds.hover` / `click` with subtle redirection from common default sounds.

> The low-level drawing/effects are backed by `rndx.lua` (includes an internal “LENS” shader package).

---

## Commands, ConVars & paths

* **Command**: `libnyx_ui_showcase` — open the demo window.
* **ConVar**: `cl_libnyx_ui_scale` — UI scale (see above).
* **Important paths**

  * Autorun loader: `lua/autorun/libnyx.lua`
  * Core UI: `lua/libnyx/lib/libnyx_components.lua`
  * Demo window: `lua/libnyx/lib/libnyx_maindemo.lua`
  * RNDX core & shaders: `lua/libnyx/lib/rndx.lua`
  * Version: `VERSION` (repo root)

---

## Project layout

```
libnyx/
├─ VERSION
└─ lua/
   ├─ autorun/
   │  └─ libnyx.lua
   └─ libnyx/lib/
      ├─ rndx.lua
      ├─ libnyx_components.lua
      └─ libnyx_maindemo.lua
```

---

## 📌 Status & roadmap

This is a **demo** and API **may change**. Planned:

* More components (tooltips, progress, toasts).
* Theme packs and light mode.
* Extended docs with GIFs & examples.
* Public hooks and event bus.

Have ideas or found a bug? → **[Join the Discord](https://discord.gg/rUEEz4mfXw)**.

---

## Contributing

1. Fork the repo and create a feature branch.
2. Keep code style consistent (Lua 5.1 for GMod).
3. Submit a PR describing your change & screenshots where useful.

Bug reports and feature requests are welcome in **Issues** or on **Discord**.

---

## Author & credits

* **Author:** MaryBlackfild
* **Team:** Nyx Team
* **Discord:** [https://discord.gg/rUEEz4mfXw](https://discord.gg/rUEEz4mfXw)

Thanks to everyone testing the demo and giving feedback ❤️

---

## Requirements

* Garry’s Mod (x86/x64)
* Client for UI components; Server required for shipping files via `AddCSLuaFile`.

---

## License

License is currently **TBD**. Until one is added, please contact the author (Discord) for usage in commercial projects or redistribution.

---

