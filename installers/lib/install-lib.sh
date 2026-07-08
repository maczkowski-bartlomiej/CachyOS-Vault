#!/usr/bin/env bash
set -euo pipefail

INSTALL_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd -- "$INSTALL_LIB_DIR/../.." && pwd)}"

# shellcheck source=../../scripts/lib/vault-lib.sh
source "$REPO_ROOT/scripts/lib/vault-lib.sh"
# shellcheck source=../../scripts/lib/vault-registry.sh
source "$REPO_ROOT/scripts/lib/vault-registry.sh"

THEME_SOURCE_DIR="$REPO_ROOT/custom-configs/Themes"
TWEAK_SOURCE_DIR="$REPO_ROOT/custom-tweaks"

display_path() {
    local path="${1:?path required}"

    if [[ "$path" == "$HOME"* ]]; then
        printf '~%s\n' "${path#"$HOME"}"
    elif [[ "$path" == "$REPO_ROOT"* ]]; then
        printf '%s\n' "${path#"$REPO_ROOT"/}"
    else
        printf '%s\n' "$path"
    fi
}

copy_file() {
    local src="${1:?source required}"
    local dest="${2:?destination required}"

    require_file "$src"
    install -D -m 0644 "$src" "$dest"
}

copy_executable() {
    local src="${1:?source required}"
    local dest="${2:?destination required}"

    require_file "$src"
    install -D -m 0755 "$src" "$dest"
}

copy_system_file() {
    local src="${1:?source required}"
    local dest="${2:?destination required}"
    local mode="${3:-0644}"

    require_file "$src"

    if [[ -n "${VAULT_SKIP_SYSTEM_CONFIGS:-}" ]]; then
        log_info "Skipped system install $dest because VAULT_SKIP_SYSTEM_CONFIGS is set"
        return 0
    fi

    if ((EUID == 0)); then
        install -D -m "$mode" "$src" "$dest"
    elif command_exists sudo; then
        sudo install -D -m "$mode" "$src" "$dest"
    else
        die "sudo is required to install $dest"
    fi
}

run_system_command() {
    if [[ -n "${VAULT_SKIP_SYSTEM_CONFIGS:-}" ]]; then
        log_info "Skipped system command because VAULT_SKIP_SYSTEM_CONFIGS is set: $*"
        return 0
    fi

    if ((EUID == 0)); then
        "$@"
    elif command_exists sudo; then
        sudo "$@"
    else
        die "sudo is required to run: $*"
    fi
}

copy_executables_from_dir() {
    local src_dir="${1:?source directory required}"
    local dest_dir="${2:?destination directory required}"
    local count=0 src

    ensure_dir "$dest_dir"
    for src in "$src_dir"/*; do
        [[ -f "$src" ]] || continue
        copy_executable "$src" "$dest_dir/$(basename -- "$src")"
        count=$((count + 1))
    done

    printf '%s\n' "$count"
}

run_theme_builders() {
    log_info "Running theme builders"
    "$THEME_SOURCE_DIR/builders/theme-builder"
}

ensure_generated_theme() {
    local file="${1:?theme file required}"
    local builder="${2:?theme builder required}"

    if [[ -f "$file" ]]; then
        return 0
    fi

    log_info "Generating missing theme file $(display_path "$file")"
    "$THEME_SOURCE_DIR/builders/$builder"
    require_file "$file"
}

install_i3_scripts() {
    local count

    count="$(copy_executables_from_dir "$REPO_ROOT/custom-configs/I3/scripts" "$HOME/.config/i3/scripts")"
    log_ok "Installed i3 scripts ($count)"
}

install_i3() {
    copy_file "$REPO_ROOT/custom-configs/I3/config" "$HOME/.config/i3/config"
    install_i3_scripts
    log_ok "Installed i3 config"
}

install_rofi() {
    copy_file "$REPO_ROOT/custom-configs/Rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
    log_ok "Installed Rofi config"
}

install_redshift() {
    copy_file "$REPO_ROOT/custom-configs/Redshift/redshift.conf" "$HOME/.config/redshift/redshift.conf"
    log_ok "Installed Redshift config"
}

install_dunst() {
    ensure_generated_theme "$HOME/.config/custom-themes/dunst-theme.dunstrc" theme-build-dunst
    copy_file "$REPO_ROOT/custom-configs/Dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
    ensure_dir "$HOME/.config/dunst/dunstrc.d"
    ln -sfn "$HOME/.config/custom-themes/dunst-theme.dunstrc" "$HOME/.config/dunst/dunstrc.d/90-vault-theme.conf"
    log_ok "Installed Dunst config and theme drop-in"
}

install_betterlockscreen() {
    ensure_generated_theme "$HOME/.config/custom-themes/betterlockscreenrc" theme-build-betterlockscreen
    copy_file "$HOME/.config/custom-themes/betterlockscreenrc" "$HOME/.config/betterlockscreen/betterlockscreenrc"
    log_ok "Installed Betterlockscreen config"
}

install_ly() {
    ensure_generated_theme "$HOME/.config/custom-themes/ly-config.ini" theme-build-ly
    copy_system_file "$REPO_ROOT/custom-configs/Ly/xsessions/i3.desktop" "/etc/ly/xsessions/i3.desktop" 0644
    copy_system_file "$HOME/.config/custom-themes/ly-config.ini" "/etc/ly/config.ini" 0644
    log_ok "Installed Ly config and i3 session"
}

install_polybar() {
    local count

    copy_file "$REPO_ROOT/custom-configs/Polybar/config.ini" "$HOME/.config/polybar/config.ini"
    copy_executable "$REPO_ROOT/custom-configs/Polybar/launch.sh" "$HOME/.config/polybar/launch.sh"
    count="$(copy_executables_from_dir "$REPO_ROOT/custom-configs/Polybar/scripts" "$HOME/.config/polybar/scripts")"
    log_ok "Installed Polybar config, launch script, and $count scripts"
}

install_alacritty() {
    copy_file "$REPO_ROOT/custom-configs/Alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    log_ok "Installed Alacritty config"
}

install_zsh() {
    copy_file "$REPO_ROOT/custom-configs/Zsh/.zshrc" "$HOME/.zshrc"
    copy_file "$REPO_ROOT/custom-configs/Zsh/oh-my-posh/cachyos-compact.omp.json" "$HOME/.config/oh-my-posh/cachyos-compact.omp.json"
    log_ok "Installed Zsh config and Oh My Posh theme"
}

remove_stale_managed_file() {
    local path="${1:?path required}"

    if [[ -e "$path" || -L "$path" ]]; then
        rm -f "$path"
        log_ok "Removed stale managed file $(display_path "$path")"
    fi
}

install_environment() {
    copy_file "$REPO_ROOT/custom-configs/Environment/session-env.sh" "$HOME/.config/env/session-env.sh"
    copy_file "$REPO_ROOT/custom-configs/Environment/.xprofile" "$HOME/.xprofile"
    copy_file "$REPO_ROOT/custom-configs/GTK/settings-3.ini" "$HOME/.config/gtk-3.0/settings.ini"
    copy_file "$REPO_ROOT/custom-configs/GTK/settings-4.ini" "$HOME/.config/gtk-4.0/settings.ini"
    copy_file "$REPO_ROOT/custom-configs/GTK/gtkrc-2.0" "$HOME/.gtkrc-2.0"
    copy_file "$REPO_ROOT/custom-configs/Qt/qt5ct.conf" "$HOME/.config/qt5ct/qt5ct.conf"
    copy_file "$REPO_ROOT/custom-configs/Qt/qt6ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
    copy_file "$REPO_ROOT/custom-configs/Kvantum/kvantum.kvconfig" "$HOME/.config/Kvantum/kvantum.kvconfig"
    remove_stale_managed_file "$HOME/.config/environment.d/90-gaming.conf"
    log_ok "Installed session, GTK, Qt, and Kvantum configs"
}

install_micro() {
    ensure_generated_theme "$HOME/.config/custom-themes/orchis-dark.micro" theme-build-micro
    copy_file "$REPO_ROOT/custom-configs/Micro/settings.json" "$HOME/.config/micro/settings.json"
    copy_file "$HOME/.config/custom-themes/orchis-dark.micro" "$HOME/.config/micro/colorschemes/orchis-dark.micro"
    log_ok "Installed Micro config and theme"
}

install_picom() {
    copy_file "$REPO_ROOT/custom-configs/Picom/picom.conf" "$HOME/.config/picom/picom.conf"
    log_ok "Installed Picom config"
}

install_nwg_look_config() {
    copy_file "$REPO_ROOT/custom-configs/I3/nwg-look/config" "$HOME/.config/nwg-look/config"
    log_ok "Installed nwg-look config"
}

install_wallpaper() {
    copy_file "$THEME_SOURCE_DIR/wallpaper/wallpaper.jpg" "$HOME/.config/i3/wallpaper.jpg"
    log_ok "Installed i3 wallpaper"
}

install_gtk_bookmark_file() {
    local src="${1:?source required}"
    local dest="${2:?destination required}"
    local line next tmp uri

    require_file "$src"
    ensure_dir "$(dirname -- "$dest")"

    tmp="$(mktemp)"
    if [[ -f "$dest" ]]; then
        cat "$dest" > "$tmp"
    else
        : > "$tmp"
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "$line" ]] || continue
        uri="${line%% *}"
        next="$(mktemp)"
        awk -v uri="$uri" '
            {
                split($0, fields, /[[:space:]]+/)
                if (fields[1] != uri) {
                    print
                }
            }
        ' "$tmp" > "$next"
        mv "$next" "$tmp"
        printf '%s\n' "$line" >> "$tmp"
    done < "$src"

    install -m 0644 "$tmp" "$dest"
    rm -f "$tmp"
}

install_gtk_bookmarks() {
    local src="$TWEAK_SOURCE_DIR/gtk-bookmarks/bookmarks"

    install_gtk_bookmark_file "$src" "$HOME/.config/gtk-3.0/bookmarks"
    install_gtk_bookmark_file "$src" "$HOME/.config/gtk-4.0/bookmarks"
    log_ok "Installed GTK drive bookmarks"
}

refresh_desktop_database() {
    if command_exists update-desktop-database; then
        if update-desktop-database "$HOME/.local/share/applications"; then
            log_ok "Updated desktop application cache"
        else
            log_warn "Desktop application cache update failed; continuing"
        fi
    else
        log_warn "update-desktop-database not found; skipped desktop application cache update"
    fi
}

apply_managed_mime_defaults() {
    if [[ -n "${VAULT_SKIP_MIME_DEFAULTS:-}" ]]; then
        log_info "Skipped managed MIME defaults because VAULT_SKIP_MIME_DEFAULTS is set"
    elif command_exists xdg-mime; then
        "$HOME/.local/bin/set-file-extensions" --managed
        log_ok "Applied managed MIME defaults"
    else
        log_warn "xdg-mime not found; managed MIME defaults were not changed"
    fi
}

install_file_associations() {
    copy_executable "$TWEAK_SOURCE_DIR/file-associations/set-file-extensions" "$HOME/.local/bin/set-file-extensions"
    ensure_dir "$HOME/.local/share/applications"
    remove_stale_managed_file "$HOME/.local/bin/archive-smart-extract"
    remove_stale_managed_file "$HOME/.local/share/applications/archive-smart-extract.desktop"
    remove_stale_managed_file "$HOME/.local/share/applications/nvim-alacritty.desktop"
    refresh_desktop_database
    apply_managed_mime_defaults
    log_ok "Installed file-association helper"
}

reload_systemd_if_safe() {
    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped systemd daemon-reload because VAULT_SKIP_RELOAD is set"
    elif command_exists systemctl; then
        run_system_command systemctl daemon-reload
        log_ok "Reloaded systemd manager configuration"
    else
        log_warn "systemctl not found; skipped systemd daemon-reload"
    fi
}

findmnt_has_error() {
    local output="${1:-}"

    printf '%s\n' "$output" | grep -Eq \
        'parse error at line|(^|[^0-9])[1-9][0-9]* parse errors?|(^|[^0-9])[1-9][0-9]* errors?'
}

filter_findmnt_output() {
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "$line" ]] || continue
        [[ "$line" == *"Success, no errors or warnings detected"* ]] && continue
        [[ "$line" == *"0 parse errors"* && "$line" == *"0 errors"* && "$line" == *"0 warnings"* ]] && continue
        printf '%s\n' "$line"
    done
}

install_drive_automounts() {
    local src="$TWEAK_SOURCE_DIR/drive-automounts/fstab-drive-automounts"
    local begin="# BEGIN CachyOS-Vault drive automounts"
    local end="# END CachyOS-Vault drive automounts"
    local fstab_file="/etc/fstab" relevant_output tmp validation_output validation_status=0

    require_file "$src"

    if [[ -n "${VAULT_SKIP_SYSTEM_CONFIGS:-}" ]]; then
        log_info "Skipped drive automount install because VAULT_SKIP_SYSTEM_CONFIGS is set"
        return 0
    fi

    run_system_command install -d -m 0755 /mnt/dev /mnt/dev-data /mnt/data-hdd

    tmp="$(mktemp)"
    if [[ -r "$fstab_file" ]]; then
        awk -v begin="$begin" -v end="$end" '
            $0 == begin { skip = 1; next }
            $0 == end { skip = 0; next }
            !skip { print }
        ' "$fstab_file" > "$tmp"
    else
        : > "$tmp"
    fi

    {
        printf '\n%s\n' "$begin"
        cat "$src"
        printf '%s\n' "$end"
    } >> "$tmp"

    if command_exists findmnt; then
        validation_output="$(LC_ALL=C findmnt --verify --tab-file "$tmp" 2>&1)" || validation_status=$?
        relevant_output="$(filter_findmnt_output <<< "$validation_output")"
        if findmnt_has_error "$relevant_output"; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                [[ -n "$line" ]] || continue
                log_error "findmnt: $line"
            done <<< "$relevant_output"
            rm -f "$tmp"
            die "Generated fstab failed validation"
        fi
        if ((validation_status != 0)); then
            log_warn "findmnt exited with status $validation_status; no parse errors were reported"
        fi
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -n "$line" ]] || continue
            log_warn "findmnt: $line"
        done <<< "$relevant_output"
    else
        log_warn "findmnt not found; skipped generated fstab validation"
    fi

    run_system_command install -m 0644 "$tmp" "$fstab_file"
    rm -f "$tmp"
    log_ok "Installed managed drive automount block in $fstab_file"
    reload_systemd_if_safe
}

enable_system_unit() {
    local unit="${1:?systemd unit required}"

    if [[ -n "${VAULT_SKIP_SYSTEM_CONFIGS:-}" ]]; then
        log_info "Skipped enabling $unit because VAULT_SKIP_SYSTEM_CONFIGS is set"
        return 0
    fi

    if command_exists systemctl; then
        run_system_command systemctl enable --now "$unit"
        log_ok "Enabled $unit"
    else
        log_warn "systemctl not found; skipped $unit"
    fi
}

apply_system_units() {
    local src="$TWEAK_SOURCE_DIR/system-units/enabled-units.txt"
    local unit

    require_file "$src"
    while IFS= read -r unit || [[ -n "$unit" ]]; do
        [[ -n "$unit" ]] || continue
        enable_system_unit "$unit"
    done < "$src"
}

apply_system_tweaks() {
    apply_system_units
}

apply_cursor_hardening() {
    copy_file "$TWEAK_SOURCE_DIR/cursor-hardening/index.theme" "$HOME/.icons/default/index.theme"
    copy_file "$TWEAK_SOURCE_DIR/cursor-hardening/.Xresources" "$HOME/.Xresources"

    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped xrdb merge because VAULT_SKIP_RELOAD is set"
    elif command_exists xrdb; then
        xrdb -merge "$HOME/.Xresources"
        log_ok "Merged ~/.Xresources"
    else
        log_warn "xrdb not found; skipped Xresources merge"
    fi

    log_ok "Installed cursor hardening"
}

expand_home_path() {
    local path="${1:?path required}"

    if [[ "$path" == "~/"* ]]; then
        printf '%s/%s\n' "$HOME" "${path#"~/"}"
    else
        printf '%s\n' "$path"
    fi
}

render_betterlockscreen_cache() {
    local src="$TWEAK_SOURCE_DIR/betterlockscreen-cache/wallpaper-path"
    local wallpaper

    require_file "$src"
    IFS= read -r wallpaper < "$src"
    wallpaper="$(expand_home_path "$wallpaper")"

    betterlockscreen -u "$wallpaper"
    log_ok "Rendered Betterlockscreen cache from $(display_path "$wallpaper")"
}

reload_i3() {
    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped i3 reload/restart because VAULT_SKIP_RELOAD is set"
        return 0
    fi

    if ! command_exists i3-msg; then
        log_warn "i3-msg not found; skipped i3 reload/restart"
        return 0
    fi

    if command_exists timeout; then
        timeout 5s i3-msg reload >/dev/null
        timeout 5s i3-msg restart >/dev/null
    else
        i3-msg reload >/dev/null
        i3-msg restart >/dev/null
    fi

    log_ok "Reloaded and restarted i3"
}

install_app_config() {
    local name="${1:?config name required}"

    if ! vault_config_group_exists "$name"; then
        die "Unknown config group: $name"
    fi

    case "$name" in
        i3) install_i3 ;;
        i3-scripts) install_i3_scripts ;;
        rofi) install_rofi ;;
        redshift) install_redshift ;;
        dunst) install_dunst ;;
        betterlockscreen) install_betterlockscreen ;;
        ly) install_ly ;;
        polybar) install_polybar ;;
        alacritty) install_alacritty ;;
        zsh) install_zsh ;;
        environment) install_environment ;;
        micro) install_micro ;;
        picom) install_picom ;;
        nwg-look) install_nwg_look_config ;;
        wallpaper) install_wallpaper ;;
        *) die "Config group is registered but has no installer: $name" ;;
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
    install_redshift
    install_dunst
    install_betterlockscreen
    install_ly
    install_polybar
    install_alacritty
    install_zsh
    install_environment
    install_micro
    install_picom
    install_nwg_look_config
    install_wallpaper
}

run_tweak() {
    local name="${1:?tweak name required}"

    if ! vault_tweak_exists "$name"; then
        die "Unknown tweak: $name"
    fi

    case "$name" in
        file-associations) install_file_associations ;;
        drive-automounts) install_drive_automounts ;;
        gtk-bookmarks) install_gtk_bookmarks ;;
        cursor-hardening) apply_cursor_hardening ;;
        system-units) apply_system_units ;;
        betterlockscreen-cache) render_betterlockscreen_cache ;;
        *) die "Tweak is registered but has no installer: $name" ;;
    esac
}

run_selected_tweaks() {
    local name

    for name in "$@"; do
        run_tweak "$name"
    done
}
