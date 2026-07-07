#!/usr/bin/env bash
set -euo pipefail

SELF="$HOME/.config/polybar/scripts/audio-player.sh"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/polybar-script-lib.sh"

AUDIO_ICON=" "
MAX_TEXT_WIDTH="${AUDIO_PLAYER_MAX_TEXT_WIDTH:-42}"
SCROLL_GAP="${AUDIO_PLAYER_SCROLL_GAP:-2}"
AUDIO_PLAYER_INTERVAL="${AUDIO_PLAYER_INTERVAL:-1}"

get_player() {
  local player

  player="$(playerctl -l 2>/dev/null | grep -Eim1 'brave|chromium|chrome|youtube|spotify|firefox' || true)"
  if [ -n "$player" ]; then
    printf '%s\n' "$player"
    return
  fi

  playerctl -l 2>/dev/null | head -n1 || true
}

open_audio_app() {
  local desktop_file browser

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

scroll_text() {
  local input="$1"
  local max_width="${2:-42}"
  local gap="${3:-6}"
  local state_dir state_file old_key pos padded len visible

  state_dir="${XDG_RUNTIME_DIR:-/tmp}/cachyos-vault-polybar"
  state_file="$state_dir/audio-player-scroll"
  mkdir -p "$state_dir"

  if [ "${#input}" -le "$max_width" ]; then
    printf '%s\n' "$input"
    printf '%s\t0\n' "$input" > "$state_file"
    return
  fi

  old_key=""
  pos=0

  if [ -r "$state_file" ]; then
    IFS=$'\t' read -r old_key pos < "$state_file" || true
  fi

  case "${pos:-}" in
    ''|*[!0-9]*) pos=0 ;;
  esac

  if [ "$old_key" != "$input" ]; then
    pos=0
  fi

  padded="$input$(printf '%*s' "$gap" '')$input"
  len=$((${#input} + gap))
  visible="${padded:$pos:$max_width}"

  pos=$((pos + 1))
  if [ "$pos" -ge "$len" ]; then
    pos=0
  fi

  printf '%s\n' "$visible"
  printf '%s\t%s\n' "$input" "$pos" > "$state_file"
}

build_track_text() {
  local artist="$1"
  local title="$2"

  if [ -n "$artist" ] && [ -n "$title" ]; then
    printf '%s - %s\n' "$artist" "$title"
  elif [ -n "$title" ]; then
    printf '%s\n' "$title"
  else
    printf ''
  fi
}

notify_track() {
  local player artist title status

  player="$(get_player)"
  if [ -z "$player" ]; then
    notify_user "Audio Player" "Not running"
    exit 0
  fi

  status="$(playerctl -p "$player" status 2>/dev/null || true)"
  artist="$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || true)"
  title="$(playerctl -p "$player" metadata xesam:title 2>/dev/null || true)"

  if [ -n "$artist" ] && [ -n "$title" ]; then
    notify_user "Audio Player - $status" "$artist - $title"
  elif [ -n "$title" ]; then
    notify_user "Audio Player - $status" "$title"
  else
    notify_user "Audio Player" "$status"
  fi
}

player_action() {
  local action="$1"
  local player

  player="$(get_player)"
  if [ -z "$player" ]; then
    open_audio_app
    exit 0
  fi

  playerctl -p "$player" "$action" >/dev/null 2>&1 || true
}

print_once() {
  local player status artist title raw_text visible_text text toggle_icon toggle_color inactive_icon active_icon controls

  player="$(get_player)"

  inactive_icon="$(A1 "$SELF open" "${T_ICON_MD}$(F "$C_PRIMARY" "$AUDIO_ICON")${T_RESET}")"

  if [ -z "$player" ]; then
    echo "$inactive_icon"
    return
  fi

  status="$(playerctl -p "$player" status 2>/dev/null || true)"

  case "$status" in
    Playing)
      toggle_icon=""
      toggle_color="$C_SECONDARY"
      ;;
    Paused)
      toggle_icon=""
      toggle_color="$C_ALERT"
      ;;
    *)
      echo "$inactive_icon"
      return
      ;;
  esac

  artist="$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || true)"
  title="$(playerctl -p "$player" metadata xesam:title 2>/dev/null || true)"

  raw_text="$(build_track_text "$artist" "$title")"
  if [ -n "$raw_text" ]; then
    visible_text="$(scroll_text "$raw_text" "$MAX_TEXT_WIDTH" "$SCROLL_GAP")"
    text="${G_MODULE}${T_MUSIC_TEXT}$(F "$C_PRIMARY" "$visible_text")${T_RESET}"
  else
    text=""
  fi

  active_icon="$(A1 "$SELF open" "${T_ICON_MD}$(F "$C_PRIMARY" "$AUDIO_ICON")${T_RESET}")"

  controls="$active_icon"
  controls+="${G_CONTROL}$(A1 "$SELF previous" "${T_ICON_MD}$(F "$C_PRIMARY" "")${T_RESET}")"
  controls+="${G_CONTROL}$(A1 "$SELF play-pause" "${T_ICON_MD}$(F "$toggle_color" "$toggle_icon")${T_RESET}")"
  controls+="${G_CONTROL}$(A1 "$SELF next" "${T_ICON_MD}$(F "$C_PRIMARY" "")${T_RESET}")"

  echo "$(A3 "$SELF notify" "$controls")$text"
}

case "${1:-watch}" in
  open) open_audio_app ;;
  notify) notify_track ;;
  play-pause) player_action play-pause ;;
  previous) player_action previous ;;
  next) player_action next ;;
  once) print_once ;;
  watch|*)
    while true; do
      print_once
      sleep "$AUDIO_PLAYER_INTERVAL"
    done
    ;;
esac
