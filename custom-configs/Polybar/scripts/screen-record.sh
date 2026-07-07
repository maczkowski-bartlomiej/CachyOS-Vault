#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/polybar-script-lib.sh"

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/cachyos-vault-polybar"
PID_FILE="$STATE_DIR/screen-record.pid"
LOG_FILE="$STATE_DIR/screen-record.log"
RECORDINGS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"

is_recording() {
  local pid

  [ -r "$PID_FILE" ] || return 1
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null
}

print_status() {
  if is_recording; then
    echo "${T_ICON_MD}$(F "$C_ALERT" "●")${T_RESET}"
  else
    echo "${T_ICON_MD}$(F "$C_MUTED" "●")${T_RESET}"
  fi
}

get_focused_geometry() {
  local window_id info x y width height

  window_id="$(xdotool getactivewindow 2>/dev/null || true)"
  [ -n "$window_id" ] || return 1

  info="$(xwininfo -id "$window_id" 2>/dev/null || true)"
  [ -n "$info" ] || return 1

  x="$(printf '%s\n' "$info" | awk -F: '/Absolute upper-left X/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
  y="$(printf '%s\n' "$info" | awk -F: '/Absolute upper-left Y/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
  width="$(printf '%s\n' "$info" | awk -F: '/Width:/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
  height="$(printf '%s\n' "$info" | awk -F: '/Height:/ {gsub(/[ \t]/, "", $2); print $2; exit}')"

  [[ "$x" =~ ^-?[0-9]+$ ]] || return 1
  [[ "$y" =~ ^-?[0-9]+$ ]] || return 1
  [[ "$width" =~ ^[0-9]+$ ]] || return 1
  [[ "$height" =~ ^[0-9]+$ ]] || return 1
  [ "$width" -gt 0 ] || return 1
  [ "$height" -gt 0 ] || return 1

  printf '%s %s %s %s\n' "$x" "$y" "$width" "$height"
}

default_monitor_source() {
  local sink source

  command -v pactl >/dev/null 2>&1 || return 1

  sink="$(pactl get-default-sink 2>/dev/null || true)"
  if [ -n "$sink" ]; then
    source="${sink}.monitor"
    if pactl list short sources 2>/dev/null | awk '{print $2}' | grep -Fxq "$source"; then
      printf '%s\n' "$source"
      return 0
    fi
  fi

  pactl list short sources 2>/dev/null |
    awk '$2 ~ /\.monitor$/ {print $2; exit}'
}

start_recording() {
  local geometry x y width height audio_source output display_name cmd
  local -a ffmpeg_cmd

  if is_recording; then
    notify_user "Screen Recording" "Already recording"
    exit 0
  fi

  for cmd in ffmpeg xdotool xwininfo; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      notify_user "Screen Recording" "$cmd not found"
      exit 1
    fi
  done

  if [ -z "${DISPLAY:-}" ]; then
    notify_user "Screen Recording" "DISPLAY is not set"
    exit 1
  fi

  mkdir -p "$STATE_DIR" "$RECORDINGS_DIR"

  geometry="$(get_focused_geometry || true)"
  if [ -z "$geometry" ]; then
    notify_user "Screen Recording" "Could not read focused window geometry"
    exit 1
  fi

  read -r x y width height <<< "$geometry"

  output="$RECORDINGS_DIR/$(date '+%Y-%m-%d_%H-%M-%S').mkv"
  display_name="$DISPLAY"
  audio_source="$(default_monitor_source || true)"

  ffmpeg_cmd=(
    ffmpeg
    -y
    -hide_banner
    -loglevel warning
    -f x11grab
    -framerate 30
    -video_size "${width}x${height}"
    -i "${display_name}+${x},${y}"
  )

  if [ -n "$audio_source" ]; then
    ffmpeg_cmd+=(
      -f pulse
      -i "$audio_source"
      -c:a aac
      -b:a 192k
    )
  fi

  ffmpeg_cmd+=(
    -c:v libx264
    -preset veryfast
    -crf 23
    -pix_fmt yuv420p
    "$output"
  )

  "${ffmpeg_cmd[@]}" > "$LOG_FILE" 2>&1 &
  echo "$!" > "$PID_FILE"

  if [ -n "$audio_source" ]; then
    notify_user "Screen Recording" "Started with system audio"
  else
    notify_user "Screen Recording" "Started without audio"
  fi
}

stop_recording() {
  local pid

  if ! is_recording; then
    rm -f "$PID_FILE"
    notify_user "Screen Recording" "Not recording"
    exit 0
  fi

  pid="$(cat "$PID_FILE")"

  kill -INT "$pid" 2>/dev/null || true

  for _ in 1 2 3 4 5; do
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f "$PID_FILE"
      notify_user "Screen Recording" "Saved to Recordings"
      exit 0
    fi
    sleep 0.2
  done

  kill -TERM "$pid" 2>/dev/null || true
  rm -f "$PID_FILE"
  notify_user "Screen Recording" "Stopped"
}

toggle_recording() {
  if is_recording; then
    stop_recording
  else
    start_recording
  fi
}

case "${1:-status}" in
  status)
    print_status
    ;;
  start)
    start_recording
    ;;
  stop)
    stop_recording
    ;;
  toggle)
    toggle_recording
    ;;
  *)
    print_status
    ;;
esac
