#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_HELPER="$HOME/.config/polybar/scripts/polybar-runtime.sh"

# shellcheck source=/dev/null
if [ -r "$RUNTIME_HELPER" ]; then
  source "$RUNTIME_HELPER"
else
  source "$SCRIPT_DIR/polybar-runtime.sh"
fi

notify_user() {
  local title="$1"
  local body="${2:-}"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body"
  fi
}
