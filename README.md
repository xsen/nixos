<h1 align="center">NixOS & Hyprland</h1>

<div align="center">

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?style=flat&logo=nixos&colorA=303446&colorB=5f92c8)](https://nixos.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green?style=flat&logo=hyprland&colorA=303446&colorB=38bdf8)](https://hyprland.org)
[![Nvidia](https://img.shields.io/badge/Nvidia-Proprietary-green?style=flat&logo=nvidia&colorA=303446&colorB=76b900)](https://nvidia.com)
[![Catppuccin Mocha](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-pink?style=flat&logo=catppuccin&colorA=303446&colorB=f5c2e7)](https://github.com/catppuccin/catppuccin)
[![Vim-way](https://img.shields.io/badge/Navigation-Vim--way-yellow?style=flat&logo=vim&colorA=303446&colorB=019833)](https://www.vim.org)
[![AI-Optimized](https://img.shields.io/badge/AI--Optimized-Antigravity%20%2F%20Gemini-blue?style=flat&logo=google-gemini&colorA=303446&colorB=8ab4f8)](#-ai-agent-friendly-antigravity--gemini-optimization)


</div>


## Table of Contents

- [Description](#-description)
- [Components](#-components)
- [Installation](#-installation)
- [Usage & Key Workflows](#-usage--key-workflows)
- [Custom Tooling & Scripts](#-custom-tooling--scripts)
- [AI-Agent Friendly](#-ai-agent-friendly-antigravity--gemini-optimization)



## 📄 Description



A stable NixOS, Hyprland, and Nvidia configuration (Nvidia typically causes many issues) using home-manager.

All applications work natively without XWayland, including Obsidian and Discord. A vertically-oriented Waybar optimizes space for ultrawide monitors.

Applications, IDEs (PhpStorm, Zed), and web browsers (using Catppuccin Dark Reader configs) are meticulously styled with the Catppuccin Mocha theme for a highly unified, distraction-free dark environment.

<p align="center">
  <img src="home/images/showcase1.png" width="100%" alt="Showcase 1">
</p>
<p align="center">
  <img src="home/images/showcase2.png" width="49.5%" alt="Showcase 2">
  <img src="home/images/showcase3.png" width="49.5%" alt="Showcase 3">
</p>




## 🛠️ Components



| Component        | Description                    |
| ---------------- | ------------------------------ |
| Video driver     | Nvidia "595.80"                |
| Shell            | Fish                           |
| Shell Prompt     | Starship                       |
| WM (Compositor)  | Hyprland                       |
| Bar              | Waybar                         |
| Notification     | Swaync                         |
| Launcher         | Rofi-Wayland                   |
| Editor           | Zed                            |
| Terminal         | Ghostty                        |
| Theme            | Catppuccin Mocha               |
| Font             | JetBrains Mono Nerd Font       |
| Player           | Spotify                        |
| File Browser     | pcmanfm + Yazi                 |
| Internet Browser | Yandex Browser + Google Chrome |
| Screenshot       | Hyprshot + Satty               |
| Idle             | Hypridle                       |
| Lock             | Hyprlock                       |
| Wallpaper        | Hyprpaper                      |
| Display Manager  | SDDM                           |
| Polkit           | lxqt-policykit                 |
| Network          | Throne Tun mode                |

## 🖥️ Installation



- Install NixOS
- Clone the repository
- Run the script: `./install.sh`
  - **Note:** This script creates a symlink `~/.nix-config` pointing to this repository. This symlink is essential because it is used by the `NH_FLAKE` environment variable (for `nh` commands) and by the `update-hypr-stubs` alias to maintain a stable, non-hardcoded path to the dotfiles.
- Generate a new hardware configuration:  
  `nixos-generate-config --show-hardware-config > ./hosts/nix-desktop/hardware-configuration.nix`

## ▶️ Usage & Key Workflows



### 1. NixOS Deployment (Nix Helper)
We use Fish functions acting as aliases for `nh` (Nix Helper) with built-in desktop notifications and privilege checks:
*   `nh-os` — Rebuild and switch the NixOS system configuration.
*   `nh-home` — Rebuild and switch the Home Manager configuration.
*   `nh-all` — Sequential rebuild of both system and home environments.
*   `nh-clean` — Clean up old Nix generations (`nh clean all`).

### 2. Wallpaper & Theme Management
*   To change the wallpaper system-wide (updates SDDM, hyprpaper, and hyprlock background):  
    `change-wallpaper /path/to/image.png`
### 3. Essential Keybindings (`mainMod` is `Super`)

The setup is built around a keyboard-centric, **Vim-way** navigation flow for maximum efficiency, featuring consistent Vim-keybindings and modal inputs across Hyprland, the Zed editor, and the Fish shell:


| Keybinding | Action |
| :--- | :--- |
| **System & Apps** | |
| `Super + Return` | Open Terminal (Ghostty) |
| `Super + Space` | Open Application Launcher (Rofi) |
| `Super + C` | Close Active Window |
| `Super + F` | Toggle Floating Window Mode |
| `Super + O` | Lock Screen (Hyprlock) |
| `Super + Shift + B` | Switch Browser Dispatcher Profile (`Auto` / `Work` / `Chill`) |
| `Print` | Take Screenshot of a Region (Satty) |
| `Shift + Print` | Take Screenshot of the Active Window |
| `Ctrl + Print` | Take Screenshot of the Entire Screen |
| **Vim-Way Tiling & Navigation** | |
| `Super + h / j / k / l` | Move Focus (Left / Down / Up / Right) |
| `Super + Shift + h / j / k / l` | Move Window in Layout (Left / Down / Up / Right) |
| `Super + [1-9]` | Switch Workspace |
| `Super + Shift + [1-9]` | Move Window to Workspace |
| **Tabbed Window Groups** | |
| `Super + G` | Toggle Tabbed Window Group |
| `Super + Ctrl + h / j / k / l` | Move Window into Group (Left / Down / Up / Right) |
| `Super + Ctrl + G` | Move Window out of Group |
| `Super + N` / `Super + P` | Cycle Tabs in Group (Next / Previous) |

---



## ⚙️ Custom Tooling & Scripts



This setup features unique workflows for workspace navigation and integration:

### 1. Smart Browser Dispatcher (`browser-dispatcher`)
We use a custom routing helper for web links, associated via `mime.nix` and set as the default `$BROWSER`:
*   **Auto Workspace Routing:** By default, if you open a link while on Workspaces 1 or 2 (Work Area), it automatically opens in Yandex Browser's **Work Profile (`Profile 1`)**. If you are on Workspace 3+ (Chill Area), it routes to **Personal Profile (`Profile 2`)**.
*   **Manual Override:** Press **`Super + Shift + B`** to cycle between routing modes. A notification will show the active mode:
    *   `Auto` (routes by workspace)
    *   `Work` (force routes all links to Work Profile)
    *   `Chill` (force routes all links to Personal Profile)
*   **Integration:** Current status is displayed dynamically in Waybar via `home/waybar/scripts/browser-profile.sh`.

### 2. Hyprland Configuration on Lua
Unlike typical static `.conf` set-ups, Hyprland is configured dynamically via Lua:
*   **Lua Core:** Main configuration is written in [home/hypr/hyprland.lua](./home/hypr/hyprland.lua).
*   **Nix-to-Lua Bridge:** Nix variables (like path definitions) are injected into `nix_vars.lua` on rebuilding, making configurations fully modular.
*   **Autocompletion:** We use a helper command **`update-hypr-stubs`** (configured in Fish) to grab the latest `hl.meta.lua` stubs from the Nix Store and link them to `~/.nix-config/home/hypr/stubs/`. This enables full Lua IDE autocomplete in Zed/VSCode (configured via `.luarc.json`).

### 3. Nvidia Driver Auto-Update Tool
Nvidia updates are historically painful on NixOS due to manual hash calculation. We solved this with a dedicated automation script:
*   **The Script:** Located at `.agents/skills/update-nvidia/scripts/update-nvidia.py`.
*   **Workflow:** It queries the official Nvidia Unix drivers website, detects the latest Production version, prefetches and calculates SRI hashes for all 5 required components (x86_64, aarch64, open modules, settings, persistenced), and updates the `mkDriver` block inside `hosts/nix-desktop/configuration.nix` automatically.
*   Runs safe dry-run compilation check after updating to prevent broken boot setups.

---


## 🤖 AI-Agent Friendly (Antigravity & Gemini Optimization)



This repository is optimized for development using agentic AI coders (like Google Antigravity, Aider, or Cursor) with workspace rules defined in `.agents/`. 

*   **Isolated Code Review:** Changes are automatically critiqued by an independent subagent (`Senior Code Reviewer`) in a clean context window to find edge-case bugs before they hit your system.
*   **Token-Efficient Diffs:** Large context reads are minimized. Diffs are filtered to exclude heavy lockfiles (`flake.lock`, `package-lock.json`), compiled files, and dependencies, feeding the agent only precise `-U5` code chunks.
*   **Plan-First Guardrails:** For complex tasks, the agent drafts a high-level architecture change-plan and halts for human approval (`Proceed`) before executing code.
*   **Self-Correction Halt:** The agent automatically aborts and prompts the user for help after 2 failed rebuild/re-plan attempts, preventing looping or credit-draining.


