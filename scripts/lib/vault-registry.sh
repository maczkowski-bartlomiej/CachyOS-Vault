#!/usr/bin/env bash

VAULT_THEME_BUILDERS=(
    theme-build-i3
    theme-build-rofi
    theme-build-polybar
    theme-build-dunst
    theme-build-betterlockscreen
    theme-build-ly
    theme-build-alacritty
    theme-build-micro
)

VAULT_CONFIG_GROUPS=(
    i3
    rofi
    redshift
    polybar
    dunst
    betterlockscreen
    ly
    alacritty
    micro
    picom
    nwg-look
    gtk-bookmarks
    cursor-hardening
    wallpaper
    i3-scripts
    drive-automounts
    system-tweaks
)

vault_config_group_exists() {
    local expected="$1"
    local group

    for group in "${VAULT_CONFIG_GROUPS[@]}"; do
        [[ "$group" == "$expected" ]] && return 0
    done

    return 1
}

vault_theme_builder_exists() {
    local expected="$1"
    local builder

    for builder in "${VAULT_THEME_BUILDERS[@]}"; do
        [[ "$builder" == "$expected" ]] && return 0
    done

    return 1
}
