#!/usr/bin/env bash
# Unified screenshot pipeline. Saves to disk AND copies to clipboard.
# Modes:
#   selection  super+shift+s        — region select, no editor
#   full       super+s | Print      — full screen
#   edit       super+shift+ctrl+s   — region select + satty editor
#   window     super+shift+alt+s    — active Hyprland window (grim+hyprctl workaround)
set -euo pipefail

mode="${1:-selection}"
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
ts=$(date +%Y%m%d-%H%M%S)
out="$dir/${ts}-ss.png"

notify() {
  command -v notify-send >/dev/null && notify-send -i "$out" "Screenshot" "$1"
}

case "$mode" in
  selection)
    geo=$(slurp) || exit 0
    grim -g "$geo" "$out"
    ;;
  full)
    grim "$out"
    ;;
  window)
    # Hyprland active window geometry (grim+hyprctl, no Wayland-native window picker exists)
    read -r x y w h < <(hyprctl -j activewindow | jq -r '"\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"')
    grim -g "${x},${y} ${w}x${h}" "$out"
    ;;
  edit)
    # Region select, then satty for annotation. Satty writes the file and copies to clipboard.
    geo=$(slurp) || exit 0
    grim -g "$geo" - | satty -f - --output-filename "$out" --copy-command wl-copy --early-exit
    [ -f "$out" ] || exit 0
    ;;
  *)
    echo "Usage: $0 {selection|full|window|edit}" >&2
    exit 2
    ;;
esac

# Unified clipboard copy (edit mode already copies, but re-copying is idempotent)
wl-copy --type image/png < "$out"
notify "Saved to $out"
