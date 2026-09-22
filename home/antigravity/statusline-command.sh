#!/usr/bin/env bash
# Antigravity CLI statusLine — Catppuccin Mocha
set -f
shopt -s extglob

input=$(cat)

{
  read -r cwd
  read -r ctx_used
  read -r session_id
  read -r state
  read -r model
  read -r rem_5h
  read -r reset_5h
  read -r rem_weekly
  read -r reset_weekly
  read -r active_subs
  read -r waiting_subs
  read -r task_count
  read -r conv_title
  read -r term_width
} < <(
  jq -r '
    (.cwd // .workspace.current_dir // "" | gsub("[\r\n]"; " ")),
    (.context_window.used_percentage | if type == "number" then round else "" end),
    (.session_id // "" | gsub("[\r\n]"; " ")),
    (.agent_state // "idle" | gsub("[\r\n]"; " ")),
    (.model | if type == "object" then (.display_name // .id // "") elif type == "string" then . else "" end | gsub("[\r\n]"; " ")),
    ((.quota // {}) | .["gemini-5h"].remaining_fraction // ""),
    ((.quota // {}) | .["gemini-5h"].reset_in_seconds | if type == "number" then round else "" end),
    ((.quota // {}) | .["gemini-weekly"].remaining_fraction // ""),
    ((.quota // {}) | .["gemini-weekly"].reset_in_seconds | if type == "number" then round else "" end),
    ([(.subagents | arrays | .[]) | select((.status // .state // "") as $s | $s != "completed" and $s != "failed" and $s != "cancelled" and $s != "done" and $s != "errored")] | length),
    ([(.subagents | arrays | .[]) | select((.status // .state // "") == "waiting_for_input")] | length),
    (.task_count // 0),
    (.conversation_title // "" | gsub("[\r\n]"; " ")),
    (.terminal_width // 0)
  ' <<< "$input" 2>/dev/null
)
if [ -z "$state" ]; then state="idle"; fi
if [ -z "$waiting_subs" ]; then waiting_subs=0; fi

# ── Subagent Input Notification ──────────────────────────────────────────────
sub_lock_file="${XDG_RUNTIME_DIR:-/tmp}/agy_subagent_wait_${session_id:-$PPID}.lock"
if [ "${waiting_subs:-0}" -gt 0 ]; then
    now_ts=$(date +%s)
    last_notif=0
    if [ -f "$sub_lock_file" ]; then
        last_notif=$(cat "$sub_lock_file" 2>/dev/null || echo 0)
    fi
    if (( now_ts - ${last_notif:-0} > 25 )); then
        echo "$now_ts" > "$sub_lock_file"
        notify-send -u critical -a "Antigravity CLI" "Subagent requires input" "Press Ctrl+J to review and approve pending action" 2>/dev/null &
    fi
else
    rm -f "$sub_lock_file" 2>/dev/null
fi

active_tasks=0
my_agy_pid=$PPID
child_pids=$(pgrep -P "$my_agy_pid" 2>/dev/null)
if [ -n "$child_pids" ]; then
    for cpid in $child_pids; do
        comm=$(cat "/proc/$cpid/comm" 2>/dev/null)
        cmdline=$(tr '\0' ' ' < "/proc/$cpid/cmdline" 2>/dev/null)
        if [[ "$comm" == "ps" || "$comm" == "pgrep" || "$comm" == *"statusline"* || "$cmdline" == *"statusline-command.sh"* ]]; then
            continue
        fi
        if tr '\0' '\n' < "/proc/$cpid/environ" 2>/dev/null | grep -q "^ANTIGRAVITY_SOURCE_METADATA="; then
            ((active_tasks += 1))
        fi
    done
fi

total_tasks=$(( task_count > active_tasks ? task_count : active_tasks ))

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
    local pct=${1%.*}
    if [ -z "$pct" ]; then pct=0; fi
    if   [ "$pct" -ge 90 ]; then printf "%s" "$red"
    elif [ "$pct" -ge 70 ]; then printf "%s" "$yellow"
    elif [ "$pct" -ge 50 ]; then printf "%s" "$peach"
    else printf "%s" "$green"
    fi
}

# ── Helper: format epoch as HH:MM or "28.06" ─────────────────────────────
fmt_epoch_time() {
    date -d "@$1" +"%H:%M" 2>/dev/null || date -r "$1" +"%H:%M" 2>/dev/null
}
fmt_epoch_date() {
    date -d "@$1" +"%d.%m %H:%M" 2>/dev/null || date -r "$1" +"%d.%m %H:%M" 2>/dev/null
}

# ── Agent State ───────────────────────────────────────────────────────────────
total_background_activities=$(( ${active_subs:-0} + ${total_tasks:-0} ))
if [ "${waiting_subs:-0}" -gt 0 ]; then
    state="sub_wait"
elif [ "$state" = "idle" ] && [ "$total_background_activities" -gt 0 ]; then
    state="bg"
fi

state_part=""
case "$state" in
    sub_wait)
        state_part="${red}● sub:wait [Ctrl+J]${reset}"
        ;;
    working)
        state_part="${green}● work${reset}"
        ;;
    thinking)
        state_part="${yellow}● think${reset}"
        ;;
    tool_use)
        state_part="${blue}● tool${reset}"
        ;;
    waiting|waiting_for_input)
        state_part="${lavender}● wait${reset}"
        ;;
    bg|sub)
        state_part="${mauve}● bg${reset}"
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
        git_part="${branch}"
        [ -n "$git_status_flags" ] && git_part="${git_part} ${git_status_flags}"
    fi
fi

# ── Terminal width ─────────────────────────────────────────────────────────────
term_cols="${term_width:-0}"
if [[ ! "$term_cols" =~ ^[0-9]+$ ]] || [ "$term_cols" -le 0 ]; then
    term_cols="${COLUMNS:-}"
fi
if [[ ! "$term_cols" =~ ^[0-9]+$ ]] || [ "$term_cols" -le 0 ]; then
    term_cols=$(tput cols 2>/dev/null < /dev/tty || echo 110)
fi
if [[ ! "$term_cols" =~ ^[0-9]+$ ]] || [ "$term_cols" -le 0 ]; then
    term_cols=110
fi

# ── Conversation Title ────────────────────────────────────────────────────────
if [ -z "$conv_title" ] && [ -n "$session_id" ]; then
    title_cache="${XDG_RUNTIME_DIR:-/tmp}/agy_title_${session_id}"
    if [ -f "$title_cache" ]; then
        conv_title=$(cat "$title_cache" 2>/dev/null)
    fi
    if [ -z "$conv_title" ]; then
        conv_title=$(python3 -c "
import sqlite3
try:
    con = sqlite3.connect('/home/evgeny/.gemini/antigravity-cli/conversation_summaries.db')
    row = con.cursor().execute('SELECT COALESCE(NULLIF(title, \"\"), preview) FROM conversation_summaries WHERE conversation_id=\"$session_id\"').fetchone()
    if row and row[0]:
        print(row[0].strip())
except Exception:
    pass
" 2>/dev/null)
        if [ -n "$conv_title" ]; then
            echo "$conv_title" > "$title_cache" 2>/dev/null
        fi
    fi
fi

title_part=""
if [ -n "$conv_title" ]; then
    clean_title="$conv_title"
    max_title_len=30
    if [ "$term_cols" -lt 82 ]; then
        max_title_len=$(( term_cols - 52 ))
        [ "$max_title_len" -lt 12 ] && max_title_len=12
    fi
    if [ "${#clean_title}" -gt "$max_title_len" ]; then
        clean_title="${clean_title:0:$(( max_title_len - 1 ))}…"
    fi
    title_part="${subtext}💬 ${lavender}${clean_title}${reset}"
fi

# ── Model ─────────────────────────────────────────────────────────────────────
model_part=""
if [ -n "$model" ]; then
    model_part="${subtext}mdl:${teal}${model}${reset}"
fi

# ── Context window ────────────────────────────────────────────────────────────
ctx_part=""
if [ -n "$ctx_used" ]; then
    col=$(color_for_pct "$ctx_used")
    ctx_part="${subtext}ctx:${col}${ctx_used}%${reset}"
fi

# ── Quota limits ──────────────────────────────────────────────────────────────

now_epoch=$(date +%s)

rl_5h_pct=""
if [ -n "$rem_5h" ]; then
    rl_5h_pct=$(echo "$rem_5h" | awk '{printf "%d", (1 - $1) * 100 + 0.5}')
    if [ -n "$reset_5h" ]; then
        r5_sec=${reset_5h%.*}
        rl_5h_reset=$(( now_epoch + r5_sec ))
    fi
fi

rl_7d_pct=""
if [ -n "$rem_weekly" ]; then
    rl_7d_pct=$(echo "$rem_weekly" | awk '{printf "%d", (1 - $1) * 100 + 0.5}')
    if [ -n "$reset_weekly" ]; then
        rw_sec=${reset_weekly%.*}
        rl_7d_reset=$(( now_epoch + rw_sec ))
    fi
fi

spr_part=""
if [ -n "$rl_5h_pct" ]; then
    col=$(color_for_pct "$rl_5h_pct")
    reset_str=""
    [ -n "$rl_5h_reset" ] && reset_str=" ${overlay}($(fmt_epoch_time "$rl_5h_reset"))${reset}"
    spr_part=$(printf "${subtext}spr:${col}%d%%%s${reset}" "$rl_5h_pct" "$reset_str")
fi

wk_part=""
if [ -n "$rl_7d_pct" ]; then
    col=$(color_for_pct "$rl_7d_pct")
    reset_str=""
    [ -n "$rl_7d_reset" ] && reset_str=" ${overlay}($(fmt_epoch_date "$rl_7d_reset"))${reset}"
    wk_part=$(printf "${subtext}wk:${col}%d%%%s${reset}" "$rl_7d_pct" "$reset_str")
fi

# ── Assemble Output (Responsive 1-line or 2-line layout) ───────────────────────
# Segment 1: Context & Workspace (State, Directory, Git, Title)
seg1=""
add_to_seg1() {
    local item="$1"
    if [ -n "$item" ]; then
        if [ -n "$seg1" ]; then
            seg1="${seg1} ${overlay}│${reset} ${item}"
        else
            seg1="${item}"
        fi
    fi
}
add_to_seg1 "$state_part"
[ -n "$short_dir" ] && add_to_seg1 "${blue}${short_dir}${reset}"
[ -n "$git_part" ] && add_to_seg1 "${peach}${git_part}${reset}"
[ -n "$title_part" ] && add_to_seg1 "$title_part"

# Segment 2: Model & Quotas (Model, Context, Sprint, Weekly)
seg2=""
add_to_seg2() {
    local item="$1"
    if [ -n "$item" ]; then
        if [ -n "$seg2" ]; then
            seg2="${seg2} ${overlay}│${reset} ${item}"
        else
            seg2="${item}"
        fi
    fi
}
[ -n "$model_part" ] && add_to_seg2 "$model_part"
[ -n "$ctx_part" ] && add_to_seg2 "$ctx_part"
[ -n "$spr_part" ] && add_to_seg2 "$spr_part"
[ -n "$wk_part" ] && add_to_seg2 "$wk_part"

if [ -z "$seg2" ]; then
    printf "%s\n" "$seg1"
elif [ -z "$seg1" ]; then
    printf "%s\n" "$seg2"
else
    single_line="${seg1} ${overlay}│${reset} ${seg2}"
    no_ansi="${single_line//$'\x1b'\[*([0-9;])[a-zA-Z]/}"
    single_len="${#no_ansi}"

    if [ "$single_len" -le "$term_cols" ]; then
        printf "%s\n" "$single_line"
    else
        printf "%s\n%s\n" "$seg1" "$seg2"
    fi
fi
