#!/usr/bin/env bash
set -euo pipefail

SELF="$HOME/.config/polybar/scripts/ytmusic.sh"
# shellcheck source=/dev/null
source "$HOME/.config/polybar/scripts/polybar-theme.sh"

MUSIC_ICON=" "

get_player() {
  playerctl -l 2>/dev/null | grep -Eim1 'brave|chromium|chrome' || true
}

open_ytmusic() {
  if command -v wmctrl >/dev/null 2>&1; then
    if wmctrl -l | grep -i "YouTube Music" >/dev/null 2>&1; then
      wmctrl -a "YouTube Music"
      exit 0
    fi
  fi

  desktop_file="$(
    grep -ril "YouTube Music" "$HOME/.local/share/applications" /usr/share/applications 2>/dev/null \
      | grep '\.desktop$' \
      | head -n1 || true
  )"

  if [ -n "$desktop_file" ] && command -v gtk-launch >/dev/null 2>&1; then
    gtk-launch "$(basename "$desktop_file" .desktop)" >/dev/null 2>&1 &
    disown
    exit 0
  fi

  for browser in brave brave-browser brave-bin; do
    if command -v "$browser" >/dev/null 2>&1; then
      "$browser" --app="https://music.youtube.com" >/dev/null 2>&1 &
      disown
      exit 0
    fi
  done

  xdg-open "https://music.youtube.com" >/dev/null 2>&1 &
  disown
}

notify_track() {
  local player artist title status

  player="$(get_player)"
  if [ -z "$player" ]; then
    notify-send "YouTube Music" "Not running"
    exit 0
  fi

  status="$(playerctl -p "$player" status 2>/dev/null || true)"
  artist="$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || true)"
  title="$(playerctl -p "$player" metadata xesam:title 2>/dev/null || true)"

  if [ -n "$artist" ] && [ -n "$title" ]; then
    notify-send "YouTube Music — $status" "$artist - $title"
  elif [ -n "$title" ]; then
    notify-send "YouTube Music — $status" "$title"
  else
    notify-send "YouTube Music" "$status"
  fi
}

player_action() {
  local action="$1"
  local player

  player="$(get_player)"
  if [ -z "$player" ]; then
    open_ytmusic
    exit 0
  fi

  playerctl -p "$player" "$action" >/dev/null 2>&1 || true
}

print_once() {
  local player status artist title text toggle_icon toggle_color icon controls

  player="$(get_player)"

  icon="$(A1 "$SELF open" "${T_ICON_MD}$(F "$C_PRIMARY" "$MUSIC_ICON")${T_RESET}")"

  if [ -z "$player" ]; then
    echo "$icon"
    return
  fi

  status="$(playerctl -p "$player" status 2>/dev/null || true)"

  case "$status" in
    Playing)
      toggle_icon=""
      toggle_color="$C_SECONDARY"      # pause = green
      ;;
    Paused)
      toggle_icon=""
      toggle_color="$C_ALERT"  # play = red
      ;;
    *)
      echo "$icon"
      return
      ;;
  esac

  artist="$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || true)"
  title="$(playerctl -p "$player" metadata xesam:title 2>/dev/null || true)"

  if [ -n "$artist" ] && [ -n "$title" ]; then
    text="${G_MODULE}${T_MUSIC_TEXT}$(F "$C_PRIMARY" "${artist:0:22}")${F_RESET}${G_ICON}$(F "$C_MUTED" "-")${F_RESET}${G_ICON}${title:0:34}${T_RESET}"
  elif [ -n "$title" ]; then
    text="${G_MODULE}${T_MUSIC_TEXT}${title:0:48}${T_RESET}"
  else
    text=""
  fi

  controls="$icon"
  controls+="${G_CONTROL}$(A1 "$SELF previous" "$(F "$C_PRIMARY" "")")"
  controls+="${G_CONTROL}$(A1 "$SELF play-pause" "$(F "$toggle_color" "$toggle_icon")")"
  controls+="${G_CONTROL}$(A1 "$SELF next" "$(F "$C_PRIMARY" "")")"

  echo "$(A3 "$SELF notify" "$controls")$text"
}

case "${1:-watch}" in
  open) open_ytmusic ;;
  notify) notify_track ;;
  play-pause) player_action play-pause ;;
  previous) player_action previous ;;
  next) player_action next ;;
  once) print_once ;;
  watch|*)
    while true; do
      print_once
      sleep 1
    done
    ;;
esac
