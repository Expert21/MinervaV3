#!/usr/bin/env bash
# =============================================================================
# Minerva V3 — Ghost Color Preset
# Neon Shadow Theme
# =============================================================================
# This is a color preset. Copy to colors/colors.sh to activate.
# Run ./generate-themes.sh after making changes.
# =============================================================================

export MODE="ghost"

# === BASE COLORS (from Cybrland) ===
export BG_BASE="#030408"         # Near Black
export BG_SURFACE="#0A0E1A"      # Dark Blue-Black
export BG_ELEVATED="#0D1120"     # Elevated Surface
export BG_HIGHLIGHT="#212638"    # Highlight
export BORDER="#212638"          # Border
export OVERLAY="#393B42"         # Overlay

# === TEXT ===
export TEXT_PRIMARY="#898D99"    # Cool Gray
export TEXT_SECONDARY="#4D5A80"  # Muted Blue-Gray
export TEXT_MUTED="#393B42"      # Darker Gray

# === ACCENTS (Neon) ===
export PRIMARY="#00FFFF"         # Neon Cyan
export PRIMARY_HOVER="#66FFFF"   # Lighter Cyan
export SECONDARY="#F230B2"       # Hot Pink
export ACCENT="#F24848"          # Neon Red
export ACCENT_DIM="#631F21"      # Dimmed Red

# === SEMANTIC (Neon) ===
export SUCCESS="#30F291"         # Neon Green
export WARNING="#F2D230"         # Neon Yellow
export ERROR="#F24848"           # Neon Red
export INFO="#29BECC"            # Teal Cyan

# === TRANSPARENCY (for rgba) ===
export TR_NONE="00"
export TR_LOW="40"
export TR_MED="80"
export TR_HIGH="CC"
export TR_FULL="FF"

# === DECORATION (minimal but not ugly) ===
export GAPS_IN="4"
export GAPS_OUT="8"
export BORDER_SIZE="1"
export ROUNDING="2"
export BLUR_SIZE="4"
export BLUR_PASSES="1"
export ANIMATIONS="true"

# === WAYBAR ===
export WAYBAR_POSITION="bottom"
