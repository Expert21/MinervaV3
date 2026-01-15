#!/bin/bash
# =============================================================================
# Minerva V3 — Quick Notes
# =============================================================================
# Opens a floating WezTerm with Micro for quick markdown notes.
# Notes are saved to ~/.config/minerva-v3/notes/ with timestamp filenames.
# =============================================================================

NOTES_DIR="$HOME/.config/minerva-v3/notes"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_HEADER=$(date "+%Y-%m-%d %H:%M")
NOTE_FILE="$NOTES_DIR/$TIMESTAMP.md"

# Ensure notes directory exists
mkdir -p "$NOTES_DIR"

# Create note with markdown header
cat > "$NOTE_FILE" << EOF
# Quick Note

**Date:** $DATE_HEADER

---

EOF

# Open in floating WezTerm with Micro
# The 'floating-note' class triggers the window rule for floating
wezterm start --class floating-note -- micro "$NOTE_FILE"
