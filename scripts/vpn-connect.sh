#!/bin/bash
# =============================================================================
# Minerva V3 — VPN Connect (Ghost Mode)
# =============================================================================
# Auto-connects to ProtonVPN and enables UFW kill-switch.
# Run on Ghost mode startup.
# =============================================================================

CURRENT_MODE=$(cat "$HOME/.current-mode" 2>/dev/null | tr -d '[:space:]')

# Only run in Ghost mode
if [[ "$CURRENT_MODE" != "ghost" ]]; then
    exit 0
fi

echo "👻 Ghost Mode: Connecting to VPN..."

# Check if ProtonVPN CLI is installed
if ! command -v protonvpn-cli &> /dev/null; then
    notify-send "VPN Error" "ProtonVPN CLI not installed" -u critical
    exit 1
fi

# Connect to fastest server (or specify country with protonvpn-cli c --cc US)
protonvpn-cli c -f

# Check connection status
if protonvpn-cli s | grep -q "Connected"; then
    IP=$(protonvpn-cli s | grep "IP:" | awk '{print $2}')
    notify-send "VPN Connected" "Ghost Mode active\nIP: $IP" -i network-vpn
    
    # Enable UFW kill-switch (optional - requires sudo/polkit)
    # Uncomment if you want automatic kill-switch:
    # pkexec ~/.config/hypr/scripts/ufw-killswitch.sh enable
else
    notify-send "VPN Failed" "Could not connect to ProtonVPN" -u critical
fi
