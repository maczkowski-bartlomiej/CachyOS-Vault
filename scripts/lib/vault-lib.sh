#!/usr/bin/env bash
set -euo pipefail

log_info() { printf '[INFO] %s\n' "$*"; }
log_ok() { printf '[OK] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }
die() { log_error "$*"; exit 1; }

repo_root_from_script() {
    local script_dir="${1:?script directory required}"
    local dir
    dir="$(cd -- "$script_dir" && pwd)"

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/custom-themes" && -d "$dir/custom-configs" ]]; then
            printf '%s\n' "$dir"
            return 0
        fi
        dir="$(dirname -- "$dir")"
    done

    die "Unable to locate repository root from $script_dir"
}

require_file() {
    local file="${1:?file required}"
    [[ -f "$file" ]] || die "Required file not found: $file"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
    local dir="${1:?directory required}"
    install -d "$dir"
}

write_file_atomic() {
    local dest="${1:?destination required}"
    local dest_dir tmp

    dest_dir="$(dirname -- "$dest")"
    ensure_dir "$dest_dir"
    tmp="$(mktemp "$dest_dir/.tmp.$(basename -- "$dest").XXXXXX")"
    cat > "$tmp"
    chmod 0644 "$tmp"
    mv "$tmp" "$dest"
}
