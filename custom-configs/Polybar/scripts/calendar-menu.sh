#!/usr/bin/env bash
set -euo pipefail

notify_user() {
  local title="$1"
  local body="${2:-}"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body"
  fi
}

if ! command -v gsimplecal >/dev/null 2>&1; then
  notify_user "Calendar" "gsimplecal not found"
  exit 1
fi

gsimplecal
