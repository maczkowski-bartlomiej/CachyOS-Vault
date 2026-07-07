#!/usr/bin/env bash
set -euo pipefail

SELF="$HOME/.config/polybar/scripts/audio-output.sh"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_HELPER="$HOME/.config/polybar/scripts/polybar-runtime.sh"
# shellcheck source=/dev/null
if [ -r "$RUNTIME_HELPER" ]; then
  source "$RUNTIME_HELPER"
else
  source "$SCRIPT_DIR/polybar-runtime.sh"
fi

notify_user() {
  local title="$1"
  local body="${2:-}"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body"
  fi
}

default_sink() {
  pactl get-default-sink 2>/dev/null || true
}

sink_description() {
  local sink="$1"

  pactl list sinks 2>/dev/null |
    awk -v sink="$sink" '
      $1 == "Name:" && $2 == sink { in_sink = 1 }
      in_sink && $1 == "Description:" {
        sub(/^[ \t]*Description:[ \t]*/, "")
        print
        exit
      }
      in_sink && $1 == "Name:" && $2 != sink { in_sink = 0 }
    '
}

print_icon() {
  local sink desc icon color

  if ! command -v pactl >/dev/null 2>&1; then
    echo "${T_ICON_MD}$(F "$C_ALERT" "󰝟")${T_RESET}"
    return
  fi

  sink="$(default_sink)"
  if [ -z "$sink" ]; then
    echo "${T_ICON_MD}$(F "$C_ALERT" "󰝟")${T_RESET}"
    return
  fi

  desc="$(sink_description "$sink")"
  icon="󰓃"
  color="$C_PRIMARY"

  echo "${T_ICON_MD}$(F "$color" "$icon")${T_RESET}"
}

select_sink() {
  local current menu choice sink sink_id desc

  if ! command -v pactl >/dev/null 2>&1; then
    notify_user "Audio Output" "pactl not found"
    exit 1
  fi

  if ! command -v rofi >/dev/null 2>&1; then
    notify_user "Audio Output" "rofi not found"
    exit 1
  fi

  current="$(default_sink)"

  menu="$(
    pactl list short sinks |
      while IFS=$'\t' read -r sink_id sink _rest; do
        [ -n "$sink_id" ] || continue
        desc="$(sink_description "$sink")"
        [ -n "$desc" ] || desc="$sink"

        if [ "$sink" = "$current" ]; then
          printf '● %s\t%s\n' "$desc" "$sink"
        else
          printf '  %s\t%s\n' "$desc" "$sink"
        fi
      done
  )"

  [ -n "$menu" ] || exit 0

  choice="$(
    printf '%s\n' "$menu" |
      rofi -dmenu -i -p "Audio Output" \
        -font "JetBrainsMono Nerd Font 12" \
        -theme-str 'listview { lines: 8; } element { padding: 8px; }'
  )"

  [ -n "$choice" ] || exit 0

  sink="$(printf '%s\n' "$choice" | awk -F '\t' '{print $2}')"
  [ -n "$sink" ] || exit 0

  pactl set-default-sink "$sink"

  pactl list short sink-inputs 2>/dev/null |
    awk '{print $1}' |
    while read -r input_id; do
      [ -n "$input_id" ] || continue
      pactl move-sink-input "$input_id" "$sink" >/dev/null 2>&1 || true
    done

  notify_user "Audio Output" "Switched output"
}

case "${1:-print}" in
  print)
    print_icon
    ;;
  menu)
    select_sink
    ;;
  *)
    print_icon
    ;;
esac
