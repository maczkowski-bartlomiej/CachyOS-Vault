#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_HELPER="$HOME/.config/polybar/scripts/polybar-runtime.sh"
if [ -r "$RUNTIME_HELPER" ]; then
  source "$RUNTIME_HELPER"
else
  source "$SCRIPT_DIR/polybar-runtime.sh"
fi

LAT="54.16"
LON="19.40"

URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code,is_day&timezone=auto"
json="$(curl -fsS "$URL" 2>/dev/null || true)"

if [ -z "$json" ]; then
  echo "${T_ICON_LG}$(F "$C_MUTED" "󰖐")${T_RESET}${G_ICON}--°"
  exit 0
fi

temp="$(jq -r '(.current.temperature_2m // empty) | round' <<< "$json")"
code="$(jq -r '.current.weather_code // empty' <<< "$json")"
is_day="$(jq -r '.current.is_day // 1' <<< "$json")"

icon="󰖐 "
color="$C_MUTED"

case "$code" in
  0)
    if [ "$is_day" = "1" ]; then
      icon="󰖙 "
      color="$C_WARNING"
    else
      icon="󰖔 "
      color="$C_PRIMARY"
    fi
    ;;
  1|2)
    if [ "$is_day" = "1" ]; then
      icon="󰖕 "
      color="$C_WARNING"
    else
      icon="󰼱 "
      color="$C_PRIMARY"
    fi
    ;;
  3)
    icon="󰖐 "
    color="$C_MUTED"
    ;;
  45|48)
    icon="󰖑 "
    color="$C_MUTED"
    ;;
  51|53|55|56|57)
    icon="󰖗 "
    color="$C_PRIMARY"
    ;;
  61|63|65|66|67|80|81|82)
    icon="󰖖 "
    color="$C_PRIMARY"
    ;;
  71|73|75|77|85|86)
    icon="󰼶 "
    color="$C_FG"
    ;;
  95|96|99)
    icon="󰖓 "
    color="$C_ALERT"
    ;;
esac

if [ -z "$temp" ]; then
  echo "${T_ICON_LG}$(F "$color" "$icon")${T_RESET}${G_ICON}--°"
else
  echo "${T_ICON_LG}$(F "$color" "$icon")${T_RESET}${G_ICON}${temp}°"
fi
