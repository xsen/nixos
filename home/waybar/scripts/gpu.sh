#!/usr/bin/env bash

load=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$load" ]; then
    class=""
    if [ "$load" -gt 80 ]; then
        class="high"
    elif [ "$load" -gt 50 ]; then
        class="medium"
    fi

    printf '{"text":"%s%%", "class":"%s", "tooltip":"GPU Load: %s%%"}\n' \
        "$load" "$class" "$load"
else
    echo '{"text":"N/A", "tooltip":"NVIDIA GPU not available"}'
fi