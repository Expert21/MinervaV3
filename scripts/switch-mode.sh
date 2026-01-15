#!/bin/bash
# =============================================================================
# Minerva V3 — Mode Switcher
# =============================================================================
# Toggles between Arcana and Ghost modes.
# Updates colors, regenerates themes, and reloads Hyprland.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/hypr"
MINERVA_DIR="$HOME/.config/minerva-v3"
MODE_FILE="$HOME/.current-mode"

# Get current mode
if [[ -f "$MODE_FILE" ]]; then
    CURRENT_MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
else
    CURRENT_MODE="arcana"
fi

# Toggle mode
if [[ "$CURRENT_MODE" == "arcana" ]]; then
    NEW_MODE="ghost"
else
    NEW_MODE="arcana"
fi

echo "🔄 Switching from $CURRENT_MODE to $NEW_MODE..."

# Copy the preset to active colors
cp "$MINERVA_DIR/colors/$NEW_MODE.sh" "$MINERVA_DIR/colors/colors.sh"

# Regenerate themes
cd "$MINERVA_DIR"
./generate-themes.sh

# Update symlink to the correct theme config
ln -sf "$CONFIG_DIR/themes/$NEW_MODE/hyprland.conf" "$CONFIG_DIR/hyprland.conf"

# Symlink waybar config for new mode
WAYBAR_CONFIG="$HOME/.config/waybar"
ln -sf "$CONFIG_DIR/themes/$NEW_MODE/waybar/config.jsonc" "$WAYBAR_CONFIG/config.jsonc"
ln -sf "$CONFIG_DIR/themes/$NEW_MODE/waybar/style.css" "$WAYBAR_CONFIG/style.css"

# Symlink swaync config
SWAYNC_CONFIG="$HOME/.config/swaync"
mkdir -p "$SWAYNC_CONFIG"
ln -sf "$CONFIG_DIR/themes/$NEW_MODE/swaync/style.css" "$SWAYNC_CONFIG/style.css"

# Restart waybar
killall waybar 2>/dev/null || true
waybar &

# Restart swaync
killall swaync 2>/dev/null || true
swaync &

# Reload hyprland
hyprctl reload

# Notify user
notify-send "Mode Switched" "Now in $NEW_MODE mode" -i dialog-information

echo "✨ Switched to $NEW_MODE mode!"
