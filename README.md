
---

# libNyx UI — demo edition ✨

Modern, animated UI components for **Garry’s Mod** written in Lua.
Built by **Nyx Team**, authored by **MaryBlackfild**. This repository is a **demo version** showcasing the library’s look, feel, and API.

[![Discord](https://img.shields.io/badge/Discord-Join%20us-5865F2?logo=discord\&logoColor=white)](https://discord.gg/rUEEz4mfXw)
[![Status](https://img.shields.io/badge/state-demo-blueviolet)](#-status--roadmap)
[![Platform](https://img.shields.io/badge/platform-Garry's%20Mod-13a5ec)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)](#license)
[![Dependency](https://img.shields.io/badge/uses-RNDX-0aa3d9)](#dependencies)

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
* [Dependencies](#dependencies)
* [Status & roadmap](#-status--roadmap)
* [Contributing](#contributing)
* [Author & credits](#author--credits)
* [Requirements](#requirements)
* [License](#license)

---

## Highlights

* 🎛️ **Rich component set**: buttons, switches/radios, sliders, dropdowns, lists, tabs, category cards, inventory cells, search box.
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

2. Ensure the **autorun** loader is present:

   ```
   lua/autorun/libnyx.lua
   ```

   It loads the library, prints the loaded version, and performs the update check.

3. Start your game/server and watch the console:

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

**File:** `lua/autorun/libnyx.lua`

* Reads local `VERSION` (fallback `0.0.0`).
* Prints: `Loaded vX.Y.Z (server|client)`.
* Fetches GitHub raw file `VERSION` and compares.
* If the primary check fails, it can fall back to parsing a remote loader.

---

## Components

Namespace: `libNyx.UI.Components`

* **CreateButton(parent, text, opts)** – variants: `primary`, `soft`, `ghost`, `gradient`, `primary_center`, `center_duo`, with icons & ripple effects.
* **CreateCheckbox(parent, opts)** – variants: `switch`, `knob`, `radio` (with grouping).
* **CreateSlider(parent, opts)** – smooth value animation, counter bubble, hover/drag emphasis.
* **CreateDropdown(parent, opts)** – glass menu with animated reveal, icons, and `onSelect(value)`.
* **CreateList(parent, opts)** – rows with icons, right text, label “chips”, selection & ripples.
* **CreateTabs(parent, opts)** – items with icon/label, animated indicator, `onChange(id)`.
* **CreateCategoryCard(parent, opts)** – `vibrant` / `glass` variants with dual gradients.
* **CreateVBox(parent, opts)** – `center_gradient`, `vertical_gradient`, `sunburst`, `model` (with subtle camera animation).
* **CreateCell / CreateInteractiveCell** – inventory cells with info box & drag-drop support.
* **CreateSearchBox(parent, opts)** – placeholder, debounce, clear button, RU/EN indicator.

---

## Styling & scale

Namespace: `libNyx.UI.Style`

* Colors: `bgColor`, `panelColor`, `cardColor`, `accentColor`, `textColor`, `glassFill`, `glassStroke`.
* Metrics: `radius`, `padding`, `iconSize`, `btnHeight`, `rowHeight`, `strokeWidth`.
* Adaptive scale from screen height (1080p baseline); manual override via ConVar:

```bash
cl_libnyx_ui_scale 0   # 0 = auto, range 0.50 … 2.00
```

Fonts are auto-generated and cached (Manrope → Tahoma fallback).

---

## Utilities & effects

* **libNyx.UI.Draw.Glass** – core glass/blur renderer with radius, fill, stroke, and blur intensity.
* **libNyx.UI.Draw.Panel** – rounded box helper with optional stroke/shadow/gradient.
* **CreateFrame** – animated open/close (easing), content alpha gating, glass background/title.
* **Ripples** – global `libNyx.UI.SetRippleStyle("fill"|"ring"|1|2)`.
* **Drag & drop overlay** – animated pickup/drop with target highlight (`PostRenderVGUI` overlay).
* **Smooth scrolling** – `libNyx.UI.SmoothScroll.ApplyToScrollPanel` / `InstallUnder`.
* **FlyIcon** – tiny icon travel animation for delightful micro-interactions.

---

## Commands, ConVars & paths

* **Command**: `libnyx_ui_showcase` — open the demo window.
* **ConVar**: `cl_libnyx_ui_scale` — UI scale.
* **Paths**

  * Autorun loader: `lua/autorun/libnyx.lua`
  * Core UI: `lua/libnyx/lib/libnyx_components.lua`
  * Demo: `lua/libnyx/lib/libnyx_maindemo.lua`
  * RNDX core: `lua/libnyx/lib/rndx.lua`
  * Version file: `VERSION` (repo root)

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

## Dependencies

This project uses the auxiliary rendering/drawing library **RNDX** by Srlion:
➡️ [https://github.com/Srlion/RNDX](https://github.com/Srlion/RNDX)

The demo includes an integrated `rndx.lua` and new exclusive Liquid Glass shader by MaryBlackfild

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
* Client for UI components; Server required to ship files via `AddCSLuaFile`.

---

## License

This project is licensed under the **MIT License**.
See [`LICENSE`](LICENSE) for details.

---
