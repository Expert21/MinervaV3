# 🎯 Minerva V3

A dual-mode Hyprland rice for Arch Linux with aesthetic theming and modular configuration.

![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-blue?style=flat-square)
![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?style=flat-square&logo=arch-linux)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## 🌙 Two Modes, One Rice

| Mode | Description | Aesthetic |
|------|-------------|-----------|
| **Arcana** | Aesthetic daily driver | Blur, rounded corners, purple/gold accents |
| **Ghost** | Focus/pentesting mode | Minimal gaps, neon cyan/pink, VPN integration |

Toggle between modes with **`Super + Shift + G`**

## ✨ Features

- **Single source color system** — Edit one file, regenerate all configs
- **WezTerm** with mode-aware colors
- **swaync** notification center
- **Rofi** scripts (emoji, clipboard, power menu with mode switch)
- **Quick Notes** — Floating markdown scratchpad
- **VPN integration** — Auto-connects in Ghost mode

## 📦 Tech Stack

| Component | Tool |
|-----------|------|
| WM | Hyprland |
| Terminal | WezTerm |
| Shell | zsh + Starship |
| Bar | Waybar |
| Notifications | swaync |
| Launcher | Rofi |
| File Manager | Yazi |
| Lock | Hyprlock |
| Wallpaper | swww |
| Font | JetBrains Mono |

## 🚀 Installation

```bash
git clone https://github.com/YourUsername/Minerva-v3
cd Minerva-v3
./install.sh
```

Add wallpapers to `~/Pictures/Wallpapers/`:
- `arcana-wallpaper.jpg`
- `ghost-wallpaper.jpg`

## ⌨️ Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (WezTerm) |
| `Super + Tab` | App launcher (Rofi) |
| `Super + Q` | Close window |
| `Super + E` | File manager (Yazi) |
| `Super + X` | Power menu |
| `Super + N` | Quick notes |
| `Super + .` | Emoji picker |
| `Super + Shift + V` | Clipboard history |
| `Super + Shift + G` | **Switch mode** |
| `Super + Escape` | Lock screen |

## 🎨 Customizing Colors

```bash
# Edit the master color file
nano ~/.config/minerva-v3/colors/colors.sh

# Regenerate all configs
~/.config/minerva-v3/generate-themes.sh

# Reload Hyprland
hyprctl reload
```

## 📁 Structure

```
~/.config/
├── minerva-v3/
│   ├── colors/          # Color presets
│   ├── templates/       # Theme templates
│   └── notes/           # Quick notes storage
├── hypr/
│   ├── hyprland.conf    # → symlink to active theme
│   ├── shared/          # Common configs
│   ├── themes/
│   │   ├── arcana/
│   │   └── ghost/
│   └── scripts/
├── waybar/
├── rofi/
├── swaync/
└── wezterm/
```

## 🔮 Future: Matugen Integration

The color system is designed for future matugen support:

```bash
# Generate colors from wallpaper
matugen image ~/Pictures/wallpaper.jpg \
  --template templates/colors.sh.tpl \
  --output colors/colors.sh

./generate-themes.sh
```

---

*Arcana for aesthetics • Ghost for focus*
