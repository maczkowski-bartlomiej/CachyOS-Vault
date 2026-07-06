#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

# shellcheck source=../../../scripts/lib/vault-lib.sh
source "$REPO_ROOT/scripts/lib/vault-lib.sh"

if command_exists xrdb; then
    xrdb -merge "$HOME/.Xresources"
    log_ok "Merged $HOME/.Xresources"
else
    log_warn "xrdb not found; skipped Xresources merge"
fi
