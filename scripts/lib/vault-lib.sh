#!/usr/bin/env bash
set -euo pipefail

vault_color() {
    local code="${1:?color code required}"
    local stream_fd="${2:-1}"

    [[ -z "${NO_COLOR:-}" ]] || return 1
    [[ -t "$stream_fd" ]] || return 1
    printf '\033[%sm' "$code"
}

vault_log() {
    local level="${1:?level required}"
    local color="${2:?color required}"
    local stream="${3:?stream required}"
    shift 3

    if [[ "$stream" == stderr ]]; then
        if vault_color "$color" 2 >/dev/null; then
            printf '%b[%s]%b %s\n' "$(vault_color "$color" 2)" "$level" "$(vault_color 0 2)" "$*" >&2
        else
            printf '[%s] %s\n' "$level" "$*" >&2
        fi
    elif vault_color "$color" 1 >/dev/null; then
        printf '%b[%s]%b %s\n' "$(vault_color "$color" 1)" "$level" "$(vault_color 0 1)" "$*"
    else
        printf '[%s] %s\n' "$level" "$*"
    fi
}

log_info() { vault_log INFO 36 stdout "$*"; }
log_ok() { vault_log OK 32 stdout "$*"; }
log_warn() { vault_log WARN 33 stderr "$*"; }
log_error() { vault_log ERROR 31 stderr "$*"; }
die() { log_error "$*"; exit 1; }

repo_root_from_script() {
    local script_dir="${1:?script directory required}"
    local dir
    dir="$(cd -- "$script_dir" && pwd)"

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/custom-configs/Themes" && -d "$dir/custom-packages" ]]; then
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
