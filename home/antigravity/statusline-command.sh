#!/usr/bin/env bash
# Antigravity CLI statusLine — Catppuccin Mocha
set -f

input=$(cat)

cwd=$(echo "$input"         | jq -r '.cwd // .workspace.current_dir // ""')
ctx_used=$(echo "$input"    | jq -r '.context_window.used_percentage // empty | round')
session_id=$(echo "$input"  | jq -r '.session_id // ""')
state=$(echo "$input"       | jq -r '.agent_state // "idle"')

# ── Catppuccin Mocha palette ──────────────────────────────────────────────────
blue=$'\x1b[38;2;137;180;250m'
yellow=$'\x1b[38;2;249;226;175m'
green=$'\x1b[38;2;166;227;161m'
pink=$'\x1b[38;2;245;194;231m'
red=$'\x1b[38;2;243;139;168m'
peach=$'\x1b[38;2;250;179;135m'
mauve=$'\x1b[38;2;203;166;247m'
subtext=$'\x1b[38;2;166;173;200m'
reset=$'\x1b[0m'

# New Catppuccin Mocha colors for tags & dividers
lavender=$'\x1b[38;2;180;190;254m'
sapphire=$'\x1b[38;2;116;199;236m'
flamingo=$'\x1b[38;2;242;205;205m'
teal=$'\x1b[38;2;148;226;213m'
maroon=$'\x1b[38;2;235;160;172m'
overlay=$'\x1b[38;2;108;112;134m'

# ── Helper: color by percentage (used%) ──────────────────────────────────────
color_for_pct() {
    local pct=$1
    if [ -z "$pct" ]; then pct=0; fi
    if   [ "$pct" -ge 90 ]; then printf "%s" "$red"
    elif [ "$pct" -ge 70 ]; then printf "%s" "$yellow"
    elif [ "$pct" -ge 50 ]; then printf "%s" "$peach"
    else printf "%s" "$green"
    fi
}

# ── Helper: format epoch as HH:MM or "28.06 23:50" ───────────────────────────
fmt_epoch_time() {
    date -d "@$1" +"%H:%M" 2>/dev/null || date -r "$1" +"%H:%M" 2>/dev/null
}
fmt_epoch_date() {
    date -d "@$1" +"%d.%m %H:%M" 2>/dev/null || date -r "$1" +"%d.%m %H:%M" 2>/dev/null
}

# ── Agent State ───────────────────────────────────────────────────────────────
state_part=""
case "$state" in
    working)
        state_part="${green}● work${reset}"
        ;;
    thinking)
        state_part="${yellow}● think${reset}"
        ;;
    tool_use)
        state_part="${blue}● tool${reset}"
        ;;
    idle)
        state_part="${subtext}● idle${reset}"
        ;;
    *)
        state_part="${subtext}● $state${reset}"
        ;;
esac

# ── Directory ─────────────────────────────────────────────────────────────────
short_dir=""
if [ -n "$cwd" ]; then
    short_dir=$(echo "$cwd" | awk -F'/' '{
        n=NF; if(n<=3) print $0;
        else { out="…"; for(i=n-2;i<=n;i++) out=out"/"$i; print out }
    }')
fi

# ── Git info ──────────────────────────────────────────────────────────────────
git_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    status_short=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    git_status_flags=""
    if [ -n "$status_short" ]; then
        modified=$(echo "$status_short" | grep -c '^ M\|^M')
        untracked=$(echo "$status_short" | grep -c '^??')
        [ "$modified" -gt 0 ] && git_status_flags="${git_status_flags}!${modified}"
        [ "$untracked" -gt 0 ] && git_status_flags="${git_status_flags}?${untracked}"
    fi
    if [ -n "$branch" ]; then
        git_part=" ${branch}"
        [ -n "$git_status_flags" ] && git_part="${git_part} ${git_status_flags}"
    fi
fi

# ── Context window ────────────────────────────────────────────────────────────
ctx_part=""
if [ -n "$ctx_used" ]; then
    col=$(color_for_pct "$ctx_used")
    ctx_part="${flamingo}context:${col}${ctx_used}%${reset}"
fi

# ── Quota limits ──────────────────────────────────────────────────────────────
rem_5h=$(echo "$input" | jq -r '.quota["gemini-5h"].remaining_fraction // empty')
reset_5h=$(echo "$input" | jq -r '.quota["gemini-5h"].reset_in_seconds // empty')

rem_weekly=$(echo "$input" | jq -r '.quota["gemini-weekly"].remaining_fraction // empty')
reset_weekly=$(echo "$input" | jq -r '.quota["gemini-weekly"].reset_in_seconds // empty')

now_epoch=$(date +%s)

rl_5h_pct=""
if [ -n "$rem_5h" ]; then
    rl_5h_pct=$(echo "$rem_5h" | awk '{printf "%d", (1 - $1) * 100 + 0.5}')
    if [ -n "$reset_5h" ]; then
        rl_5h_reset=$(( now_epoch + reset_5h ))
    fi
fi

rl_7d_pct=""
if [ -n "$rem_weekly" ]; then
    rl_7d_pct=$(echo "$rem_weekly" | awk '{printf "%d", (1 - $1) * 100 + 0.5}')
    if [ -n "$reset_weekly" ]; then
        rl_7d_reset=$(( now_epoch + reset_weekly ))
    fi
fi

spr_part=""
if [ -n "$rl_5h_pct" ]; then
    col=$(color_for_pct "$rl_5h_pct")
    reset_str=""
    [ -n "$rl_5h_reset" ] && reset_str=" ${mauve}($(fmt_epoch_time "$rl_5h_reset")${mauve})${reset}"
    spr_part=$(printf "${mauve}sprint:${col}%d%%%s${reset}" "$rl_5h_pct" "$reset_str")
fi

wk_part=""
if [ -n "$rl_7d_pct" ]; then
    col=$(color_for_pct "$rl_7d_pct")
    reset_str=""
    [ -n "$rl_7d_reset" ] && reset_str=" ${sapphire}($(fmt_epoch_date "$rl_7d_reset")${sapphire})${reset}"
    wk_part=$(printf "${sapphire}weekly:${col}%d%%%s${reset}" "$rl_7d_pct" "$reset_str")
fi

# ── Assemble Single Line ──────────────────────────────────────────────────────
# Block 1: State
printf "%s" "$state_part"

# Divider + Block 2: Directory
printf " ${overlay}│${reset} ${blue}%s${reset}" "$short_dir"

# Divider + Block 3: Git
if [ -n "$git_part" ]; then
    printf " ${overlay}│${reset} ${yellow}%s${reset}" "$git_part"
fi

# Divider + Block 4: Context
if [ -n "$ctx_part" ]; then
    printf " ${overlay}│${reset} %s" "$ctx_part"
fi

# Divider + Block 5: Sprint
if [ -n "$spr_part" ]; then
    printf " ${overlay}│${reset} %s" "$spr_part"
fi

# Divider + Block 6: Weekly
if [ -n "$wk_part" ]; then
    printf " ${overlay}│${reset} %s" "$wk_part"
fi

printf "\n"
