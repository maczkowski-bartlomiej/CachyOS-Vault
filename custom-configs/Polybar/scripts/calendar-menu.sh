#!/usr/bin/env bash
set -euo pipefail

notify_user() {
  local title="$1"
  local body="${2:-}"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body"
  fi
}

if ! command -v rofi >/dev/null 2>&1; then
  notify_user "Calendar" "rofi not found"
  exit 1
fi

if ! command -v cal >/dev/null 2>&1; then
  notify_user "Calendar" "cal not found"
  exit 1
fi

title="$(date '+%B %Y')"

cal -m |
  rofi -dmenu -i -p "$title" \
    -font "JetBrainsMono Nerd Font 12" \
    -theme-str '
      window { width: 360px; }
      listview { lines: 8; }
      element { padding: 4px 8px; }
      element-text { font: "JetBrainsMono Nerd Font 12"; }
    ' >/dev/null
