---

# libNyx UI — demo edition ✨

Modern, animated UI components for **Garry’s Mod** written in Lua.
Built by **Nyx Team**, authored by **MaryBlackfild**. This repository is a **demo version** showcasing the library’s look, feel, and API.

[![Discord](https://img.shields.io/badge/Discord-Join%20us-5865F2?logo=discord\&logoColor=white)](https://discord.gg/rUEEz4mfXw)
[![State](https://img.shields.io/badge/state-demo-blueviolet)](#-status--roadmap)
[![Platform](https://img.shields.io/badge/platform-Garry's%20Mod-13a5ec)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

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
* [RNDX dependency](#rndx-dependency)
* [Commands, ConVars & paths](#commands-convars--paths)
* [Project layout](#project-layout)
* [Status & roadmap](#-status--roadmap)
* [Contributing](#contributing)
* [Author & credits](#author--credits)
* [Requirements](#requirements)
* [License](#license)

---

## Highlights

* 🎛️ **Rich component set**: buttons, checkboxes/switches/radios, sliders, dropdowns, lists, tabs, category cards, inventory cells, search box.
* 🧊 **“Glass” aesthetic** with dynamic blur, soft strokes, and gradients.
* 🔄 **Animated** open/close transitions, ripples, hover states, drag & drop, and focus accents.
* 🧭 **Tabs** with animated selection indicator.
* 🧷 **Smooth scrolling** overlay for any scroll panel.
* 🔔 **Auto-loader** prints **Loaded vX** and checks **GitHub VERSION** to tell you if you’re **up-to-date**.

> This repository is a **showcase** build. APIs may evolve.

---

## Screens & demo

Open the interactive showcase in-game:

```bash
libnyx_ui_showcase
```

---

## Installation

1. Copy the `lua/` folder into your addon (or `garrysmod/lua/` during development).
2. Ensure the autorun entry exists at `lua/autorun/libnyx.lua` (it loads the library and performs the update check).
3. Start your game/server and watch the console:

```
[libNyx] Loaded vX.Y.Z (server|client)
[libNyx] Checking for updates…
[libNyx] Up-to-date ✓ (latest: X.Y.Z)
```

If outdated, you’ll see:

```
[libNyx] Update available ✱ installed X.Y.Z → latest A.B.C
[libNyx] Get it: https://github.com/maryblackfild/libnyx
```

---

## Quick start

```lua
-- Create a frameless “glass” window
local frame = libNyx.UI.CreateFrame({ w = 960, h = 640, title = "libNyx UI" })

-- Add a button
local btn = libNyx.UI.Components.CreateButton(frame, "Click me", {
  variant = "primary",
  onClick = function() chat.AddText(Color(0,255,0), "[libNyx] Hello!") end
})
btn:Dock(TOP); btn:DockMargin(16,16,16,0)

-- Or just open the demo window:
libNyx.UI.OpenShowcase()
```

---

## Auto-loader & version check

File: `lua/autorun/libnyx.lua`

* Reads local `VERSION` (fallback `0.0.0`).
* Prints: `Loaded vX.Y.Z (server|client)`.
* Compares against GitHub raw file:

  * Raw version: `https://raw.githubusercontent.com/maryblackfild/libnyx/main/VERSION`
  * Project home: `https://github.com/maryblackfild/libnyx`

---

## Components

Namespace: `libNyx.UI.Components`

* **CreateButton(parent, text, opts)** — variants: `primary`, `soft`, `ghost`, `gradient`, `primary_center`, `center_duo` (ripples, icons, gradients).
* **CreateCheckbox(parent, opts)** — `switch`, `knob`, `radio` (+ radio grouping).
* **CreateSlider(parent, opts)** — smooth value animation, counter bubble, hover/drag emphasis.
* **CreateDropdown(parent, opts)** — glass menu with reveal animation, icons, `onSelect`.
* **CreateList(parent, opts)** — rows with icons, label “chips”, right-side text, selection + ripples.
* **CreateTabs(parent, opts)** — items with icon/label, animated indicator, `onChange`.
* **CreateCategoryCard(parent, opts)** — `vibrant`/`glass` variants with dual gradients.
* **CreateVBox(parent, opts)** — `center_gradient`, `vertical_gradient`, `sunburst`, `model` (with subtle camera animation).
* **CreateCell / CreateInteractiveCell** — item cells with **hover info box** and **drag & drop**.

---

## Styling & scale

* Adaptive scale (1080p baseline) with override:

  ```
  cl_libnyx_ui_scale 0   # 0 = auto, 0.50..2.00 allowed
  ```
* Centralized colors/metrics in `libNyx.UI.Style`.
* Auto-generated font cache (Manrope → Tahoma fallback).

---

## Utilities & effects

* `libNyx.UI.Draw.Glass(...)` / `Draw.Panel(...)` helpers (blur, strokes, gradients).
* Drag/drop overlay (`PostRenderVGUI`) with pickup/drop animation & target highlight.
* Ripples (`libNyx.UI.SetRippleStyle("fill"|"ring"|1|2)`).
* Smooth scrolling (`libNyx.UI.SmoothScroll.*`).
* Animated window frame (`libNyx.UI.CreateFrame`) with open/close easing and content alpha gating.
* SFX: hover/click with subtle redirection of default UI sounds.

---

## RNDX dependency

This UI toolkit uses the **RNDX** auxiliary rendering library for fast rounded geometry, gradients, and blur composition.

* RNDX project: **[https://github.com/Srlion/RNDX](https://github.com/Srlion/RNDX)**
* libNyx integrates RNDX through `lua/libnyx/lib/rndx.lua` and builds the glass & effects stack on top of it.

> Huge thanks to RNDX for the performant drawing primitives that make the “glass” look possible. 🧊

---

## Commands, ConVars & paths

* **Command**: `libnyx_ui_showcase` — open the demo window.
* **ConVar**: `cl_libnyx_ui_scale` — UI scale.
* **Paths**

  * Autorun loader: `lua/autorun/libnyx.lua`
  * Core UI: `lua/libnyx/lib/libnyx_components.lua`
  * Demo: `lua/libnyx/lib/libnyx_maindemo.lua`
  * RNDX core: `lua/libnyx/lib/rndx.lua`
  * Version file: `VERSION`

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
* Theme packs / light mode.
* Extended docs with GIFs & examples.
* Public hooks & events.

Ideas or bugs? → **[Join the Discord](https://discord.gg/rUEEz4mfXw)**.

---

## Contributing

1. Fork and create a feature branch.
2. Keep code style consistent (Lua 5.1 for GMod).
3. Submit a PR with a clear description and screenshots where helpful.

---

## Author & credits

* **Author:** MaryBlackfild
* **Team:** Nyx Team
* **Discord:** [https://discord.gg/rUEEz4mfXw](https://discord.gg/rUEEz4mfXw)

Thanks to everyone testing the demo and giving feedback ❤️

---

## Requirements

* Garry’s Mod (x86/x64)
* Client for UI; Server used to ship files via `AddCSLuaFile`.

---

## License

This project is licensed under the **MIT License**.
See the [LICENSE](LICENSE) file for details.
