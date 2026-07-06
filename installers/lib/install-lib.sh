#!/usr/bin/env bash
set -euo pipefail

INSTALL_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd -- "$INSTALL_LIB_DIR/../.." && pwd)}"

# shellcheck source=../../scripts/lib/vault-lib.sh
source "$REPO_ROOT/scripts/lib/vault-lib.sh"

repo_root() {
    printf '%s\n' "$REPO_ROOT"
}

copy_file() {
    local src="${1:?source required}"
    local dest="${2:?destination required}"
    require_file "$src"
    install -D -m 0644 "$src" "$dest"
    log_ok "Installed $dest"
}

copy_executable() {
    local src="${1:?source required}"
    local dest="${2:?destination required}"
    require_file "$src"
    install -D -m 0755 "$src" "$dest"
    log_ok "Installed executable $dest"
}

run_theme_builders() {
    log_info "Running theme builders"
    "$REPO_ROOT/custom-themes/builders/theme-builder"
}

install_i3() {
    copy_file "$REPO_ROOT/custom-configs/I3/config" "$HOME/.config/i3/config"
}

install_rofi() {
    copy_file "$REPO_ROOT/custom-configs/Rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
}

install_polybar() {
    local script src
    copy_file "$REPO_ROOT/custom-configs/Polybar/config.ini" "$HOME/.config/polybar/config.ini"
    copy_executable "$REPO_ROOT/custom-configs/Polybar/launch.sh" "$HOME/.config/polybar/launch.sh"
    ensure_dir "$HOME/.config/polybar/scripts"
    for src in "$REPO_ROOT"/custom-configs/Polybar/scripts/*; do
        [[ -f "$src" ]] || continue
        script="$(basename -- "$src")"
        copy_executable "$src" "$HOME/.config/polybar/scripts/$script"
    done
}

install_alacritty() {
    copy_file "$REPO_ROOT/custom-configs/Alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
}

install_micro() {
    copy_file "$REPO_ROOT/custom-configs/Micro/settings.json" "$HOME/.config/micro/settings.json"
    copy_file "$HOME/.config/custom-themes/orchis-dark.micro" "$HOME/.config/micro/colorschemes/orchis-dark.micro"
}

install_picom() {
    copy_file "$REPO_ROOT/custom-configs/Picom/picom.conf" "$HOME/.config/picom/picom.conf"
}

install_nwg_look_config() {
    copy_file "$REPO_ROOT/custom-configs/I3/nwg-look/config" "$HOME/.config/nwg-look/config"
}

install_wallpaper() {
    copy_file "$REPO_ROOT/custom-themes/wallpaper/wallpaper.jpg" "$HOME/.config/i3/wallpaper.jpg"
}

apply_cursor_hardening() {
    copy_file "$REPO_ROOT/custom-configs/I3/cursor-hardening/index.theme" "$HOME/.icons/default/index.theme"
    copy_file "$REPO_ROOT/custom-configs/I3/cursor-hardening/.Xresources" "$HOME/.Xresources"

    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped xrdb merge because VAULT_SKIP_RELOAD is set"
    elif command_exists xrdb; then
        xrdb -merge "$HOME/.Xresources"
        log_ok "Merged $HOME/.Xresources"
    else
        log_warn "xrdb not found; skipped Xresources merge"
    fi
}

run_nwg_look() {
    if [[ -n "${VAULT_SKIP_NWG_LOOK:-}" ]]; then
        log_info "Skipped nwg-look because VAULT_SKIP_NWG_LOOK is set"
    elif command_exists nwg-look; then
        log_info "Launching nwg-look"
        nwg-look &
    else
        log_warn "nwg-look not found; skipped launch"
    fi
}

reload_i3() {
    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped i3 reload because VAULT_SKIP_RELOAD is set"
    elif command_exists i3-msg; then
        i3-msg reload >/dev/null
        log_ok "Reloaded i3"
    else
        log_warn "i3-msg not found; skipped i3 reload"
    fi
}

reload_polybar() {
    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped Polybar reload because VAULT_SKIP_RELOAD is set"
    elif [[ -x "$HOME/.config/polybar/launch.sh" ]] && command_exists polybar; then
        "$HOME/.config/polybar/launch.sh"
        log_ok "Reloaded Polybar"
    else
        log_warn "Polybar reload skipped; polybar or launch script unavailable"
    fi
}

reload_picom_if_safe() {
    log_info "Picom config installed. Restart Picom manually or restart i3 if needed."
}

install_app_config() {
    local name="${1:?config name required}"
    case "$name" in
        i3) install_i3 ;;
        rofi) install_rofi ;;
        polybar) install_polybar ;;
        alacritty) install_alacritty ;;
        micro) install_micro ;;
        picom) install_picom ;;
        nwg-look) install_nwg_look_config ;;
        cursor-hardening) apply_cursor_hardening ;;
        wallpaper) install_wallpaper ;;
        *) die "Unknown config group: $name" ;;
    esac
}

install_selected_configs() {
    local name
    for name in "$@"; do
        install_app_config "$name"
    done
}

install_all_configs() {
    install_i3
    install_rofi
    install_polybar
    install_alacritty
    install_micro
    install_picom
    install_nwg_look_config
    install_wallpaper
    apply_cursor_hardening
    reload_i3
    reload_polybar
    reload_picom_if_safe
}
