#!/usr/bin/env bash
# =============================================================================
# Minerva V3 — Theme Generator
# =============================================================================
# Reads colors/colors.sh and generates all theme configs from templates.
# Run this after changing colors or switching modes.
#
# Usage: ./generate-themes.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/colors/colors.sh"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Check if colors.sh exists
if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: colors/colors.sh not found!"
    echo "Copy a preset: cp colors/arcana.sh colors/colors.sh"
    exit 1
fi

# Source colors
source "$COLORS_FILE"

echo "🎨 Generating themes for mode: $MODE"

# Helper: strip # from hex colors for Hyprland rgba format
strip_hash() {
    echo "${1#\#}"
}

# Export stripped versions for templates that need them
export BG_BASE_RAW=$(strip_hash "$BG_BASE")
export BG_SURFACE_RAW=$(strip_hash "$BG_SURFACE")
export BG_ELEVATED_RAW=$(strip_hash "$BG_ELEVATED")
export BORDER_RAW=$(strip_hash "$BORDER")
export TEXT_PRIMARY_RAW=$(strip_hash "$TEXT_PRIMARY")
export PRIMARY_RAW=$(strip_hash "$PRIMARY")
export PRIMARY_HOVER_RAW=$(strip_hash "$PRIMARY_HOVER")
export SECONDARY_RAW=$(strip_hash "$SECONDARY")
export ACCENT_RAW=$(strip_hash "$ACCENT")
export SUCCESS_RAW=$(strip_hash "$SUCCESS")
export ERROR_RAW=$(strip_hash "$ERROR")

# Determine theme directory (themes are in ~/.config/hypr/themes/)
THEME_DIR="$HOME/.config/hypr/themes/$MODE"

# Ensure theme subdirectories exist
mkdir -p "$THEME_DIR/waybar"
mkdir -p "$THEME_DIR/swaync"
mkdir -p "$THEME_DIR/rofi"

# Generate Hyprland colors
if [[ -f "$TEMPLATES_DIR/hyprland-colors.conf.tpl" ]]; then
    envsubst < "$TEMPLATES_DIR/hyprland-colors.conf.tpl" > "$THEME_DIR/colors.conf"
    echo "  ✓ Hyprland colors.conf"
fi

# Generate WezTerm colors
if [[ -f "$TEMPLATES_DIR/wezterm-colors.lua.tpl" ]]; then
    envsubst < "$TEMPLATES_DIR/wezterm-colors.lua.tpl" > "$THEME_DIR/wezterm-colors.lua"
    echo "  ✓ WezTerm colors"
fi

# Generate Waybar CSS
if [[ -f "$TEMPLATES_DIR/waybar.css.tpl" ]]; then
    envsubst < "$TEMPLATES_DIR/waybar.css.tpl" > "$THEME_DIR/waybar/style.css"
    echo "  ✓ Waybar style.css"
fi

# Generate swaync CSS
if [[ -f "$TEMPLATES_DIR/swaync.css.tpl" ]]; then
    envsubst < "$TEMPLATES_DIR/swaync.css.tpl" > "$THEME_DIR/swaync/style.css"
    echo "  ✓ swaync style.css"
fi

# Generate Rofi colors
if [[ -f "$TEMPLATES_DIR/rofi-colors.rasi.tpl" ]]; then
    envsubst < "$TEMPLATES_DIR/rofi-colors.rasi.tpl" > "$THEME_DIR/rofi/colors.rasi"
    echo "  ✓ Rofi colors.rasi"
fi

# Generate Hyprlock
if [[ -f "$TEMPLATES_DIR/hyprlock.conf.tpl" ]]; then
    envsubst < "$TEMPLATES_DIR/hyprlock.conf.tpl" > "$THEME_DIR/hyprlock.conf"
    echo "  ✓ Hyprlock config"
fi

# Update current mode marker
echo "$MODE" > "$HOME/.current-mode"
echo "  ✓ Updated ~/.current-mode"

echo ""
echo "✨ Theme generation complete!"
echo "   Run 'hyprctl reload' to apply Hyprland changes."
