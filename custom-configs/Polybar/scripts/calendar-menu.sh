#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/polybar-script-lib.sh"

if ! command -v gsimplecal >/dev/null 2>&1; then
  notify_user "Calendar" "gsimplecal not found"
  exit 1
fi

gsimplecal
