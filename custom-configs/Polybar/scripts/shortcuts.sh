#!/usr/bin/env bash
set -euo pipefail

SELF="$HOME/.config/polybar/scripts/shortcuts.sh"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_HELPER="$HOME/.config/polybar/scripts/polybar-runtime.sh"
# shellcheck source=/dev/null
if [ -r "$RUNTIME_HELPER" ]; then
  source "$RUNTIME_HELPER"
else
  source "$SCRIPT_DIR/polybar-runtime.sh"
fi

open_brave() {
  for browser in brave brave-browser brave-bin; do
    if command -v "$browser" >/dev/null 2>&1; then
      "$browser" >/dev/null 2>&1 &
      disown
      exit 0
    fi
  done

  xdg-open "https://www.google.com" >/dev/null 2>&1 &
  disown
}

case "${1:-print}" in
  home)
    xdg-open "$HOME" >/dev/null 2>&1 &
    disown
    ;;
  downloads)
    xdg-open "$HOME/Downloads" >/dev/null 2>&1 &
    disown
    ;;
  brave)
    open_brave
    ;;
  print|*)
    home_icon="$(A1 "$SELF home" "${T_ICON_MD}$(F "$C_PRIMARY" " ")${T_RESET}")"
    downloads_icon="$(A1 "$SELF downloads" "${T_ICON_MD}$(F "$C_SECONDARY" " ")${T_RESET}")"
    brave_icon="$(A1 "$SELF brave" "${T_ICON_MD}$(F "$C_PRIMARY" " ")${T_RESET}")"

    echo "${home_icon}${G_ITEM}${downloads_icon}${G_ITEM}${brave_icon}"
    ;;
esac
