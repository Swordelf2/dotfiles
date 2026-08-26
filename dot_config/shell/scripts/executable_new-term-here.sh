#!/usr/bin/env bash
#
# Usage: new-term-here <terminal-command> [terminal-args...]
#
# Example:
#   new-term-here alacritty
#   new-term-here foot -o font=monospace:size=12
#

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <terminal-command> [args...]" >&2
    exit 1
fi
term_cmd=("$@")

# get focused window PID
pid=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid' 2>/dev/null || true)

# if PID unavailable, launch terminal normally
if [[ -z "$pid" || "$pid" == "null" ]]; then
    exec "${term_cmd[@]}"
fi

# descend to deepest child
deepest="$pid"
while true; do
    children=$(pgrep -P "$deepest" || true)
    [[ -z "$children" ]] && break
    deepest=$(ps -o pid= --sort=start_time $children | tail -n 1)
done

# resolve cwd
cwd_link="/proc/$deepest/cwd"
if [[ -e "$cwd_link" ]]; then
    cwd=$(realpath "$cwd_link" 2>/dev/null || true)
else
    cwd=""
fi

# launch terminal with cwd if available, else fallback
if [[ -n "$cwd" && -d "$cwd" ]]; then
    exec "${term_cmd[@]}" --working-directory "$cwd"
else
    exec "${term_cmd[@]}"
fi
