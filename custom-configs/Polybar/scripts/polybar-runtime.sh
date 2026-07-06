#!/usr/bin/env bash

POLYBAR_CONFIG="${POLYBAR_CONFIG:-$HOME/.config/polybar/config.ini}"

read_color() {
  local key="$1"
  local fallback="$2"

  awk -F '=' -v key="$key" -v fallback="$fallback" '
    $0 ~ /^\[colors\]/ { in_colors = 1; next }
    $0 ~ /^\[/ { in_colors = 0 }
    in_colors {
      k = $1
      v = $2
      gsub(/^[ \t]+|[ \t]+$/, "", k)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      if (k == key) {
        print v
        found = 1
        exit
      }
    }
    END {
      if (!found) print fallback
    }
  ' "$POLYBAR_CONFIG"
}

C_BG="$(read_color background '#2f343f')"
C_BG_ALT="$(read_color background-alt '#383c4a')"
C_FG="$(read_color foreground '#d3dae3')"
C_MUTED="$(read_color foreground-alt '#7f8fa6')"
C_PRIMARY="$(read_color primary '#5294e2')"
C_SECONDARY="$(read_color secondary '#73d216')"
C_ALERT="$(read_color alert '#cc575d')"
C_WARNING="$(read_color warning '#f9c859')"

G_ICON="%{O3}"
G_CONTROL="%{O6}"
G_ITEM="%{O8}"
G_MODULE="%{O10}"
G_SECTION="%{O12}"

T_BASE="%{T1}"
T_TEXT="%{T4}"
T_ICON_XL="%{T5}"
T_ICON_LG="%{T5}"
T_ICON_MD="%{T6}"
T_ICON_SM="%{T7}"
T_MUSIC_TEXT="%{T7}"
T_RESET="%{T-}"

F_RESET="%{F-}"

F() {
  printf '%%{F%s}%s%%{F-}' "$1" "$2"
}

T() {
  printf '%%{T%s}%s%%{T-}' "$1" "$2"
}

A1() {
  printf '%%{A1:%s:}%s%%{A}' "$1" "$2"
}

A3() {
  printf '%%{A3:%s:}%s%%{A}' "$1" "$2"
}
