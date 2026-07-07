#!/usr/bin/env bash
set -euo pipefail

INSTALL_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd -- "$INSTALL_LIB_DIR/../.." && pwd)}"

# shellcheck source=../../scripts/lib/vault-lib.sh
source "$REPO_ROOT/scripts/lib/vault-lib.sh"
# shellcheck source=../../scripts/lib/vault-registry.sh
source "$REPO_ROOT/scripts/lib/vault-registry.sh"

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

    log_ok "Installed system config $dest"
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

run_theme_builders() {
    log_info "Running theme builders"
    "$REPO_ROOT/custom-themes/builders/theme-builder"
}

ensure_generated_theme() {
    local file="${1:?theme file required}"
    local builder="${2:?theme builder required}"

    if [[ -f "$file" ]]; then
        return 0
    fi

    log_info "Generating missing theme file $file"
    "$REPO_ROOT/custom-themes/builders/$builder"
    require_file "$file"
}

install_i3() {
    copy_file "$REPO_ROOT/custom-configs/I3/config" "$HOME/.config/i3/config"
    install_i3_scripts
}

install_i3_scripts() {
    local script src
    ensure_dir "$HOME/.config/i3/scripts"
    for src in "$REPO_ROOT"/custom-configs/I3/scripts/*; do
        [[ -f "$src" ]] || continue
        script="$(basename -- "$src")"
        copy_executable "$src" "$HOME/.config/i3/scripts/$script"
    done
}

install_rofi() {
    copy_file "$REPO_ROOT/custom-configs/Rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
}

install_redshift() {
    copy_file "$REPO_ROOT/custom-configs/Redshift/redshift.conf" "$HOME/.config/redshift/redshift.conf"
}

install_dunst() {
    ensure_generated_theme "$HOME/.config/custom-themes/dunst-theme.dunstrc" theme-build-dunst
    copy_file "$REPO_ROOT/custom-configs/Dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
    ensure_dir "$HOME/.config/dunst/dunstrc.d"
    ln -sfn "$HOME/.config/custom-themes/dunst-theme.dunstrc" "$HOME/.config/dunst/dunstrc.d/90-vault-theme.conf"
    log_ok "Linked Dunst theme drop-in $HOME/.config/dunst/dunstrc.d/90-vault-theme.conf"
}

install_betterlockscreen() {
    ensure_generated_theme "$HOME/.config/custom-themes/betterlockscreenrc" theme-build-betterlockscreen
    copy_file "$HOME/.config/custom-themes/betterlockscreenrc" "$HOME/.config/betterlockscreen/betterlockscreenrc"
}

install_ly() {
    ensure_generated_theme "$HOME/.config/custom-themes/ly-config.ini" theme-build-ly
    copy_system_file "$REPO_ROOT/custom-configs/Ly/xsessions/i3.desktop" "/etc/ly/xsessions/i3.desktop" 0644
    copy_system_file "$HOME/.config/custom-themes/ly-config.ini" "/etc/ly/config.ini" 0644
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

install_zsh() {
    copy_file "$REPO_ROOT/custom-configs/Zsh/.zshrc" "$HOME/.zshrc"
    copy_file "$REPO_ROOT/custom-configs/Zsh/oh-my-posh/cachyos-compact.omp.json" "$HOME/.config/oh-my-posh/cachyos-compact.omp.json"
}

install_micro() {
    ensure_generated_theme "$HOME/.config/custom-themes/orchis-dark.micro" theme-build-micro
    copy_file "$REPO_ROOT/custom-configs/Micro/settings.json" "$HOME/.config/micro/settings.json"
    copy_file "$HOME/.config/custom-themes/orchis-dark.micro" "$HOME/.config/micro/colorschemes/orchis-dark.micro"
}

install_picom() {
    copy_file "$REPO_ROOT/custom-configs/Picom/picom.conf" "$HOME/.config/picom/picom.conf"
}

install_nwg_look_config() {
    copy_file "$REPO_ROOT/custom-configs/I3/nwg-look/config" "$HOME/.config/nwg-look/config"
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
    log_ok "Installed GTK bookmarks in $dest"
}

install_gtk_bookmarks() {
    local src="$REPO_ROOT/custom-configs/GTK/bookmarks"

    install_gtk_bookmark_file "$src" "$HOME/.config/gtk-3.0/bookmarks"
    install_gtk_bookmark_file "$src" "$HOME/.config/gtk-4.0/bookmarks"
}

install_wallpaper() {
    copy_file "$REPO_ROOT/custom-themes/wallpaper/wallpaper.jpg" "$HOME/.config/i3/wallpaper.jpg"
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

install_drive_automounts() {
    local src="$REPO_ROOT/custom-configs/System/fstab-drive-automounts"
    local begin="# BEGIN CachyOS-Vault drive automounts"
    local end="# END CachyOS-Vault drive automounts"
    local tmp fstab_file="/etc/fstab" validation_output

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
        validation_output="$(LC_ALL=C findmnt --verify --tab-file "$tmp" 2>&1 || true)"
        if printf '%s\n' "$validation_output" | grep -Eq 'parse error at line|(^|[^0-9])[1-9][0-9]* parse error'; then
            while IFS= read -r line; do
                [[ -n "$line" ]] || continue
                log_error "findmnt: $line"
            done <<< "$validation_output"
            rm -f "$tmp"
            die "Generated fstab has parse errors"
        fi
    else
        validation_output=""
        log_warn "findmnt not found; skipped generated fstab validation"
    fi

    if [[ -n "$validation_output" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            [[ "$line" == *"0 parse errors"* ]] && continue
            log_warn "findmnt: $line"
        done <<< "$validation_output"
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

apply_system_tweaks() {
    enable_system_unit paccache.timer
    enable_system_unit 'btrfs-scrub@-.timer'
    enable_system_unit 'btrfs-scrub@mnt-data\x2dhdd.timer'
}

apply_cursor_hardening() {
    copy_file "$REPO_ROOT/custom-configs/I3/cursor-hardening/index.theme" "$HOME/.icons/default/index.theme"
    copy_file "$REPO_ROOT/custom-configs/I3/cursor-hardening/.Xresources" "$HOME/.Xresources"

    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped xrdb merge because VAULT_SKIP_RELOAD is set"
    elif command_exists xrdb; then
        if xrdb -merge "$HOME/.Xresources"; then
            log_ok "Merged $HOME/.Xresources"
        else
            log_warn "xrdb merge failed; continuing"
        fi
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
        return 1
    elif command_exists i3-msg; then
        if command_exists timeout; then
            if timeout 5s i3-msg reload >/dev/null; then
                log_ok "Reloaded i3"
                return 0
            fi
        elif i3-msg reload >/dev/null; then
            log_ok "Reloaded i3"
            return 0
        fi
        log_warn "i3 reload did not complete cleanly; continuing"
        return 1
    else
        log_warn "i3-msg not found; skipped i3 reload"
        return 1
    fi
}

reload_polybar() {
    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped Polybar reload because VAULT_SKIP_RELOAD is set"
    elif [[ -x "$HOME/.config/polybar/launch.sh" ]] && command_exists polybar; then
        if command_exists timeout; then
            if timeout 10s "$HOME/.config/polybar/launch.sh"; then
                log_ok "Reloaded Polybar"
            else
                log_warn "Polybar reload did not complete cleanly; continuing"
            fi
        elif "$HOME/.config/polybar/launch.sh"; then
            log_ok "Reloaded Polybar"
        else
            log_warn "Polybar reload failed; continuing"
        fi
    else
        log_warn "Polybar reload skipped; polybar or launch script unavailable"
    fi
}

reload_dunst() {
    if [[ -n "${VAULT_SKIP_RELOAD:-}" ]]; then
        log_info "Skipped Dunst reload because VAULT_SKIP_RELOAD is set"
    elif command_exists dunstctl; then
        if dunstctl reload >/dev/null 2>&1; then
            log_ok "Reloaded Dunst"
        else
            log_warn "Dunst reload failed; restart Dunst manually if needed"
        fi
    else
        log_warn "Dunst reload skipped; dunstctl unavailable"
    fi
}

reload_picom_if_safe() {
    log_info "Picom config installed. Restart Picom manually or restart i3 if needed."
}

reload_betterlockscreen_if_safe() {
    log_info "Betterlockscreen config installed. Run 'betterlockscreen -u ~/.config/i3/wallpaper.jpg' if the lockscreen cache needs refreshing."
}

reload_ly_if_safe() {
    log_info "Ly config installed. Restart or enable ly manually when ready."
}

install_app_config() {
    local name="${1:?config name required}"

    if ! vault_config_group_exists "$name"; then
        die "Unknown config group: $name"
    fi

    case "$name" in
        i3)
            install_i3
            reload_i3
            ;;
        i3-scripts)
            install_i3_scripts
            reload_i3
            ;;
        rofi) install_rofi ;;
        redshift) install_redshift ;;
        dunst)
            install_dunst
            reload_dunst
            ;;
        betterlockscreen)
            install_betterlockscreen
            reload_betterlockscreen_if_safe
            ;;
        ly)
            install_ly
            reload_ly_if_safe
            ;;
        polybar)
            install_polybar
            reload_polybar
            ;;
        alacritty) install_alacritty ;;
        zsh) install_zsh ;;
        micro) install_micro ;;
        picom)
            install_picom
            reload_picom_if_safe
            ;;
        nwg-look) install_nwg_look_config ;;
        gtk-bookmarks) install_gtk_bookmarks ;;
        cursor-hardening) apply_cursor_hardening ;;
        wallpaper) install_wallpaper ;;
        drive-automounts) install_drive_automounts ;;
        system-tweaks) apply_system_tweaks ;;
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
    install_micro
    install_picom
    install_nwg_look_config
    install_gtk_bookmarks
    install_wallpaper
    install_drive_automounts
    apply_system_tweaks
    apply_cursor_hardening
    if reload_i3; then
        log_info "Skipped direct Polybar reload because i3 reload runs Polybar launch"
    else
        reload_polybar
    fi
    reload_dunst
    reload_betterlockscreen_if_safe
    reload_ly_if_safe
    reload_picom_if_safe
}
