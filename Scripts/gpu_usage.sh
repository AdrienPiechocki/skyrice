#!/bin/bash

# --- AMD ---
check_amd() {
    if ls /sys/class/drm/card*/device/vendor 2>/dev/null | xargs grep -l "0x1002" &>/dev/null; then
        for card in /sys/class/drm/card*/device; do
            vendor=$(cat "$card/vendor" 2>/dev/null)
            if [[ "$vendor" == "0x1002" ]]; then
                gpu_busy=$(cat "$card/gpu_busy_percent" 2>/dev/null)
                echo -e "${gpu_busy}" | tr -d '\n'
                break
            fi
        done
        return 0
    fi
    return 1
}

# --- Main ---
check_amd
