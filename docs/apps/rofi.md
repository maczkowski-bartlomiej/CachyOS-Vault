# Rofi

## Files

```text
Repo config: custom-configs/Rofi/config.rasi
Install target: ~/.config/rofi/config.rasi
Generated theme: ~/.config/custom-themes/rofi-theme.rasi
Builder: custom-configs/Themes/builders/theme-build-rofi
```

The config imports the generated theme with:

```text
@import "~/.config/custom-themes/rofi-theme.rasi"
```

## Flatpak Launching

Rofi is launched through:

```text
~/.config/i3/scripts/rofi-launcher
```

The wrapper prepends these Flatpak export paths to `XDG_DATA_DIRS` before starting Rofi:

```text
~/.local/share/flatpak/exports/share
/var/lib/flatpak/exports/share
```

Flatpak apps then appear through Rofi `drun` from their exported `.desktop` files.
