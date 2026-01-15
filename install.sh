#!/bin/bash
# =============================================================================
# Minerva V3 — Install Script
# =============================================================================
# Deploys the rice configuration to ~/.config
# Creates backups of existing configs before overwriting.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║           Minerva V3 — Installation Script                       ║"
echo "║                  Dual-Mode Hyprland Rice                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# === BACKUP EXISTING CONFIGS ===
echo "📦 Backing up existing configs to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

for dir in hypr waybar rofi swaync wezterm yazi micro; do
    if [[ -d "$CONFIG_DIR/$dir" ]]; then
        cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/" 2>/dev/null || true
        echo "  ✓ Backed up $dir"
    fi
done

# === CREATE CONFIG DIRECTORIES ===
echo ""
echo "📁 Creating config directories..."
mkdir -p "$CONFIG_DIR/hypr/themes/arcana"
mkdir -p "$CONFIG_DIR/hypr/themes/ghost"
mkdir -p "$CONFIG_DIR/hypr/shared"
mkdir -p "$CONFIG_DIR/hypr/scripts"
mkdir -p "$CONFIG_DIR/waybar"
mkdir -p "$CONFIG_DIR/rofi/scripts"
mkdir -p "$CONFIG_DIR/swaync"
mkdir -p "$CONFIG_DIR/wezterm"
mkdir -p "$CONFIG_DIR/minerva-v3/colors"
mkdir -p "$CONFIG_DIR/minerva-v3/notes"
mkdir -p "$HOME/Pictures/Wallpapers"

# === COPY MINERVA V3 FILES ===
echo ""
echo "🎨 Installing Minerva V3..."

# Colors and generator
cp -r "$SCRIPT_DIR/colors" "$CONFIG_DIR/minerva-v3/"
cp "$SCRIPT_DIR/generate-themes.sh" "$CONFIG_DIR/minerva-v3/"
chmod +x "$CONFIG_DIR/minerva-v3/generate-themes.sh"

# Templates
cp -r "$SCRIPT_DIR/templates" "$CONFIG_DIR/minerva-v3/"

# Shared Hyprland configs
cp -r "$SCRIPT_DIR/shared/hyprland/"* "$CONFIG_DIR/hypr/shared/"

# Mode-specific configs
cp -r "$SCRIPT_DIR/themes/arcana/"* "$CONFIG_DIR/hypr/themes/arcana/"
cp -r "$SCRIPT_DIR/themes/ghost/"* "$CONFIG_DIR/hypr/themes/ghost/"

# Scripts
cp "$SCRIPT_DIR/scripts/"*.sh "$CONFIG_DIR/hypr/scripts/"
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh

# Rofi
cp "$SCRIPT_DIR/shared/rofi/config.rasi" "$CONFIG_DIR/rofi/"
cp -r "$SCRIPT_DIR/shared/rofi/scripts/"* "$CONFIG_DIR/rofi/scripts/"
chmod +x "$CONFIG_DIR/rofi/scripts/"*/emoji 2>/dev/null || true
chmod +x "$CONFIG_DIR/rofi/scripts/"*/clipboard 2>/dev/null || true
chmod +x "$CONFIG_DIR/rofi/scripts/"*/powermenu 2>/dev/null || true

# WezTerm
cp "$SCRIPT_DIR/shared/wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/"

# swaync
cp "$SCRIPT_DIR/themes/arcana/swaync/config.json" "$CONFIG_DIR/swaync/"

# === SET DEFAULT MODE ===
echo ""
echo "🔮 Setting default mode to Arcana..."
echo "arcana" > "$HOME/.current-mode"
cp "$CONFIG_DIR/minerva-v3/colors/arcana.sh" "$CONFIG_DIR/minerva-v3/colors/colors.sh"

# === GENERATE THEMES ===
echo ""
echo "🎨 Generating theme files..."
cd "$CONFIG_DIR/minerva-v3"
./generate-themes.sh

# === CREATE SYMLINKS ===
echo ""
echo "🔗 Creating symlinks..."
ln -sf "$CONFIG_DIR/hypr/themes/arcana/hyprland.conf" "$CONFIG_DIR/hypr/hyprland.conf"
ln -sf "$CONFIG_DIR/hypr/themes/arcana/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc"
ln -sf "$CONFIG_DIR/hypr/themes/arcana/waybar/style.css" "$CONFIG_DIR/waybar/style.css"
ln -sf "$CONFIG_DIR/hypr/themes/arcana/rofi/colors.rasi" "$CONFIG_DIR/rofi/colors.rasi"
ln -sf "$CONFIG_DIR/hypr/themes/arcana/swaync/style.css" "$CONFIG_DIR/swaync/style.css"

# === WALLPAPER PLACEHOLDER ===
if [[ ! -f "$HOME/Pictures/Wallpapers/arcana-wallpaper.jpg" ]]; then
    echo ""
    echo "⚠️  No arcana-wallpaper.jpg found. Add one to ~/Pictures/Wallpapers/"
fi
if [[ ! -f "$HOME/Pictures/Wallpapers/ghost-wallpaper.jpg" ]]; then
    echo "⚠️  No ghost-wallpaper.jpg found. Add one to ~/Pictures/Wallpapers/"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next steps:"
echo "   1. Add wallpapers to ~/Pictures/Wallpapers/"
echo "   2. Log out and select Hyprland from your display manager"
echo "   3. Use Super+Shift+G to switch between Arcana and Ghost modes"
echo ""
echo "📁 Config locations:"
echo "   • Colors:  ~/.config/minerva-v3/colors/"
echo "   • Hyprland: ~/.config/hypr/"
echo "   • Notes:    ~/.config/minerva-v3/notes/"
echo ""
echo "🎮 Keybinds:"
echo "   • Super+Return   → Terminal (WezTerm)"
echo "   • Super+Tab      → App Launcher (Rofi)"
echo "   • Super+X        → Power Menu"
echo "   • Super+N        → Quick Notes"
echo "   • Super+Shift+G  → Switch Mode"
echo ""
