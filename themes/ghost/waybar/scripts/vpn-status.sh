#!/bin/bash
# =============================================================================
# Minerva V3 — VPN Status (Waybar)
# =============================================================================
# Returns JSON for Waybar custom module showing VPN connection status.
# =============================================================================

if command -v protonvpn-cli &> /dev/null; then
    STATUS=$(protonvpn-cli s 2>/dev/null)
    
    if echo "$STATUS" | grep -q "Connected"; then
        IP=$(echo "$STATUS" | grep "IP:" | awk '{print $2}')
        SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2}')
        echo "{\"text\": \"󰌾 $IP\", \"tooltip\": \"ProtonVPN: $SERVER\", \"class\": \"connected\"}"
    else
        echo "{\"text\": \"󰦞 VPN Off\", \"tooltip\": \"Click to reconnect\", \"class\": \"disconnected\"}"
    fi
else
    echo "{\"text\": \"\", \"tooltip\": \"ProtonVPN not installed\"}"
fi
