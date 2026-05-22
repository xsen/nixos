<h1 align="center">NixOS & Hyprland</h1>

<div align="center">

![nixos](https://img.shields.io/badge/NixOS-unstable-informational.svg?style=flat&logo=nixos&logoColor=5f92c8&colorA=24273A&colorB=5f92c8)
![hyprland](https://img.shields.io/badge/Hyprland-303446.svg?style=flat&logo=hyprland)
![nvidia](https://img.shields.io/badge/Nvidia-303446.svg?style=flat&logo=nvidia)

</div>

## Table of Contents

- [Description](#-description)
- [Components](#-components)
- [Installation](#-installation)
- [Usage](#-usage)

## 📄 Description

A stable NixOS, Hyprland, and Nvidia configuration (Nvidia typically causes many issues) using home-manager.

All applications work natively without XWayland, including Obsidian and Discord. A vertically-oriented Waybar optimizes space for ultrawide monitors.

Applications are styled with the Catppuccin Mocha theme.

![Showcase1](home/images/showcase1.png)
![Showcase2](home/images/showcase2.png)
![Showcase3](home/images/showcase3.png)

## 🛠️ Components

| Component        | Description                    |
| ---------------- | ------------------------------ |
| Video driver     | Nvidia "595.71.05"             |
| Shell            | Fish                           |
| Shell Prompt     | Starship                       |
| WM (Compositor)  | Hyprland                       |
| Bar              | Waybar                         |
| Notification     | Mako                           |
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

## ▶️ Usage

- To change wallpapers: `change-wallpaper path` (supports SDDM, hyprpaper, and hyprlock).
- A script for launching frequently used apps is added to Rofi: **Launch Apps**.
- **Hyprland Lua Autocompletion**: We use a `update-hypr-stubs` alias in Fish to automatically fetch the latest `hl.meta.lua` stubs from the Nix Store to `~/.nix-config/home/hypr/stubs/`. This enables full Lua autocompletion in Zed and other editors configured via `.luarc.json`.
- Aliases for nh commands:
  - `nh-os`: Build system configuration
  - `nh-home`: Build home-manager configuration
  - `nh-all`: Run both `nh-os` and `nh-home`
  - `nh-clean`: Cleanup generations
