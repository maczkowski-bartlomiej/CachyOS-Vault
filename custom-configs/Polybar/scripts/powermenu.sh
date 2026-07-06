#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$HOME/.config/polybar/scripts/polybar-theme.sh"

choice="$(
  printf '<span foreground="%s"></span>   Lock\n<span foreground="%s">󰒲</span>   Suspend\n<span foreground="%s"></span>   Logout i3\n<span foreground="%s"></span>   Reboot\n<span foreground="%s"></span>   Shutdown\n' \
    "$C_PRIMARY" "$C_SECONDARY" "$C_PRIMARY" "$C_PRIMARY" "$C_ALERT" |
    rofi -dmenu -i -markup-rows -p "Power" \
      -font "JetBrainsMono Nerd Font 12" \
      -theme-str 'listview { lines: 5; } element { padding: 8px; } element-text { vertical-align: 0.5; }'
)"

case "$choice" in
  *Lock*)
    if command -v i3lock >/dev/null 2>&1; then
      i3lock
    else
      loginctl lock-session
    fi
    ;;
  *Suspend*)
    systemctl suspend
    ;;
  *Logout*)
    i3-msg exit
    ;;
  *Reboot*)
    systemctl reboot
    ;;
  *Shutdown*)
    systemctl poweroff
    ;;
esac
