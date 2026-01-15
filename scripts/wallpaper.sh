#!/bin/bash
# =============================================================================
# Minerva V3 — Wallpaper Script
# =============================================================================
# Applies wallpaper using swww with smooth transitions
# =============================================================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_MODE=$(cat "$HOME/.current-mode" 2>/dev/null | tr -d '[:space:]')

# Select wallpaper based on mode
if [[ "$CURRENT_MODE" == "ghost" ]]; then
    WALLPAPER="$WALLPAPER_DIR/ghost-wallpaper.jpg"
    TRANSITION="wipe"
else
    WALLPAPER="$WALLPAPER_DIR/arcana-wallpaper.jpg"
    TRANSITION="fade"
fi

# Check if wallpaper exists
if [[ ! -f "$WALLPAPER" ]]; then
    notify-send "Wallpaper" "File not found: $WALLPAPER" -u critical
    exit 1
fi

# Ensure swww daemon is running
if ! pgrep -x swww-daemon > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Apply wallpaper with transition
swww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-duration 1 \
    --transition-fps 60
