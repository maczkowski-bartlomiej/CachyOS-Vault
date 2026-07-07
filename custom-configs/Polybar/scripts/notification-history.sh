#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/polybar-script-lib.sh"

copy_text() {
  local text="$1"

  if command -v xclip >/dev/null 2>&1; then
    printf '%s' "$text" | xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    printf '%s' "$text" | xsel --clipboard --input
  else
    notify_user "Notifications" "No clipboard tool found"
    return 1
  fi

  notify_user "Notifications" "Copied notification text"
}

history_rows() {
  dunstctl history 2>/dev/null |
    jq -r '
      def value:
        if type == "object" and has("data") then .data else . end;

      (.data // [])
      | flatten
      | map(select(type == "object"))
      | to_entries[]
      | .value
      | {
          app: (.appname | value // ""),
          summary: (.summary | value // ""),
          body: (.body | value // "")
        }
      | .text = (
          [ .app, .summary, .body ]
          | map(select(. != null and . != ""))
          | join("\n")
        )
      | select(.text != "")
      | .label = (
          [ .app, .summary, .body ]
          | map(select(. != null and . != ""))
          | join(" - ")
          | gsub("[\r\n\t]+"; " ")
        )
      | "\(.label)\t\(.text | @base64)"
    ' 2>/dev/null || true
}

print_icon() {
  echo "${T_ICON_MD}$(F "$C_PRIMARY" "")${T_RESET}"
}

show_empty_menu() {
  printf 'No notification history\n' |
    rofi -dmenu -i -p "Notifications" \
      -font "JetBrainsMono Nerd Font 12" \
      -theme-str 'listview { lines: 1; } element { padding: 8px; }' >/dev/null || true
}

show_history_menu() {
  local rows menu choice payload text

  if ! command -v dunstctl >/dev/null 2>&1; then
    notify_user "Notifications" "dunstctl not found"
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    notify_user "Notifications" "jq not found"
    exit 1
  fi

  if ! command -v rofi >/dev/null 2>&1; then
    notify_user "Notifications" "rofi not found"
    exit 1
  fi

  rows="$(history_rows)"
  if [ -z "$rows" ]; then
    show_empty_menu
    exit 0
  fi

  menu="$(printf '%s\n' "$rows" | awk -F '\t' '{printf "%02d  %s\n", NR, $1}')"
  choice="$(
    printf '%s\n' "$menu" |
      rofi -dmenu -i -p "Notifications" \
        -font "JetBrainsMono Nerd Font 12" \
        -theme-str 'window { width: 560px; } listview { lines: 10; } element { padding: 8px; }'
  )"

  [ -n "$choice" ] || exit 0

  payload="$(printf '%s\n' "$rows" | awk -F '\t' -v choice="$choice" '{
    row = sprintf("%02d  %s", NR, $1)
    if (row == choice) {
      print $2
      exit
    }
  }')"
  [ -n "$payload" ] || exit 0

  text="$(printf '%s' "$payload" | base64 -d 2>/dev/null || true)"
  [ -n "$text" ] || exit 0

  copy_text "$text"
}

clear_history() {
  if command -v dunstctl >/dev/null 2>&1; then
    dunstctl history-clear >/dev/null 2>&1 || true
    notify_user "Notifications" "History cleared"
  fi
}

case "${1:-print}" in
  print)
    print_icon
    ;;
  menu)
    show_history_menu
    ;;
  clear)
    clear_history
    ;;
  *)
    print_icon
    ;;
esac
