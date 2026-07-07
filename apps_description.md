# CachyOS-Vault Apps And Theme Architecture

`apps_description.md` is the source of truth for supported config groups, install targets, generated theme files, import syntax, and special setup actions.

## Theme Build Flow

Run all app-specific builders with:

```bash
custom-themes/builders/theme-builder
```

Generated theme files are written under:

```text
~/.config/custom-themes/
```

## Package Manifest

Install core system packages used by these configs with:

```bash
sudo pacman -S --needed - < packages/core.txt
```

Install personal apps with:

```bash
sudo pacman -S --needed - < packages/apps.txt
```

Install AUR-only dependencies with an AUR helper:

```bash
xargs -r -a packages/aur.txt paru -S --needed
```

The package lists are kept comment-free for direct package-manager use. Details and caveats live in `packages/README.md`.

The compatibility wrapper remains available:

```bash
custom-themes/builders/theme-build
```

## Supported Apps And Config Groups

| App/group | Repo config source | Install target | Generated theme | Include/import mechanism | Notes |
|---|---|---|---|---|---|
| I3 | `custom-configs/I3/config` | `~/.config/i3/config` | `~/.config/custom-themes/i3-theme.i3` | `include ~/.config/custom-themes/i3-theme.i3` | Also installs `custom-configs/I3/scripts/*` to `~/.config/i3/scripts/*`; installer reloads i3 when available and not skipped. |
| Rofi | `custom-configs/Rofi/config.rasi` | `~/.config/rofi/config.rasi` | `~/.config/custom-themes/rofi-theme.rasi` | `@import "~/.config/custom-themes/rofi-theme.rasi"` | Uses an app-specific Rasi theme builder with darker Orchis row and selection colors. |
| Polybar | `custom-configs/Polybar/config.ini` | `~/.config/polybar/config.ini` | `~/.config/custom-themes/polybar-theme.ini` | `include-file = ~/.config/custom-themes/polybar-theme.ini` | `launch.sh` and `scripts/*` are installed executable; focused workspace keeps the existing green color. |
| Dunst | `custom-configs/Dunst/dunstrc` | `~/.config/dunst/dunstrc` | `~/.config/custom-themes/dunst-theme.dunstrc` | `~/.config/dunst/dunstrc.d/90-vault-theme.conf` symlink | Compact top-right notifications; low/normal time out after 2 seconds, critical stays until dismissed; installer reloads Dunst with `dunstctl reload` when available. |
| Alacritty | `custom-configs/Alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | `~/.config/custom-themes/alacritty-theme.toml` | `import = ["~/.config/custom-themes/alacritty-theme.toml"]` | TOML theme import generated from the central palette. |
| Micro | `custom-configs/Micro/settings.json` | `~/.config/micro/settings.json` | `~/.config/custom-themes/orchis-dark.micro` | `"colorscheme": "orchis-dark"` | Micro loads named colorschemes from `~/.config/micro/colorschemes`; installer copies the generated theme to `~/.config/micro/colorschemes/orchis-dark.micro`. |
| Picom | `custom-configs/Picom/picom.conf` | `~/.config/picom/picom.conf` | none | none | No clean include/import mechanism is currently documented here; restart Picom manually or restart i3 if needed. |
| nwg-look | `custom-configs/I3/nwg-look/config` | `~/.config/nwg-look/config` | none | n/a | `install-all` may launch `nwg-look`; no-nwg and `VAULT_SKIP_NWG_LOOK=1` skip it. |
| Cursor hardening | `custom-configs/I3/cursor-hardening/index.theme`, `.Xresources` | `~/.icons/default/index.theme`, `~/.Xresources` | none | `xrdb -merge ~/.Xresources` | Uses `Bibata-Modern-Ice`; `xrdb` merge is skipped when `VAULT_SKIP_RELOAD=1` or `xrdb` is unavailable. |
| Wallpaper | `custom-themes/wallpaper/wallpaper.jpg` | `~/.config/i3/wallpaper.jpg` | none | `exec feh --bg-fill ~/.config/i3/wallpaper.jpg` | Installed as part of all configs or as a separate interactive group. |
| I3 scripts | `custom-configs/I3/scripts/*` | `~/.config/i3/scripts/*` | none | referenced by `custom-configs/I3/config` | Installed executable. Includes helpers for screenshots, volume/XOB, Picom restart, mouse warping, and XOB listening. Included in the `i3` installer group and also selectable as `i3-scripts` in the interactive installer. |

## Polybar Runtime And Scripts

Config:

```text
Repo: custom-configs/Polybar/config.ini
Target: ~/.config/polybar/config.ini
```

Generated theme:

```text
Repo builder: custom-themes/builders/theme-build-polybar
Generated target: ~/.config/custom-themes/polybar-theme.ini
Included by config.ini: include-file = ~/.config/custom-themes/polybar-theme.ini
```

Runtime helper:

```text
Repo: custom-configs/Polybar/scripts/polybar-runtime.sh
Target: ~/.config/polybar/scripts/polybar-runtime.sh
Purpose: shared Polybar formatting/color helper for module scripts
```

Script helper:

```text
Repo: custom-configs/Polybar/scripts/polybar-script-lib.sh
Target: ~/.config/polybar/scripts/polybar-script-lib.sh
Purpose: shared runtime sourcing and notification helper for Polybar scripts
```

Scripts:

```text
audio-player.sh: playerctl-based audio player controls
audio-output.sh: pactl + rofi audio output switcher
calendar-menu.sh: gsimplecal popup opened by clicking the date
screen-record.sh: ffmpeg + x11grab focused-window screen recorder; saves to ~/Videos/Recordings; attempts system audio via the default sink monitor and falls back to video-only
notification-history.sh: Dunst history icon; left-click opens Rofi history and copies selected notification text, right-click clears Dunst history
power-menu.sh: Rofi power menu
polybar-runtime.sh: shared runtime formatting/color helper for Polybar scripts
polybar-script-lib.sh: shared loader/helper sourced by module scripts
shortcuts.sh: app/folder shortcut icons
weather-openmeteo.sh: weather module using Open-Meteo
```

Polybar script dependencies:

```text
Required base: bash, polybar, rofi
Audio: playerctl, pactl
Weather: curl, jq
Calendar: gsimplecal
Recording: ffmpeg, xdotool, xwininfo; notify-send optional
Notifications: dunst, dunstctl, jq, xclip or xsel
```

## I3 Runtime Scripts

Scripts installed from `custom-configs/I3/scripts/*`:

```text
mouse-warp: moves focus by direction and warps the pointer to the focused window center
picom-restart: restarts Picom from ~/.config/picom/picom.conf on i3 reload
screenshot-current-monitor: captures the monitor under the pointer, saves it, and copies it to clipboard
screenshot-menu: Rofi menu for area, window, or current-monitor screenshots
screenshot-lib: shared screenshot helper functions
volume-osd: handles volume up/down/mute and writes the current value to XOB
xob-listener: owns the XOB FIFO and lock under ${XDG_RUNTIME_DIR:-/tmp}/cachyos-vault
```

## Dunst Runtime And Theme

Config:

```text
Repo: custom-configs/Dunst/dunstrc
Target: ~/.config/dunst/dunstrc
```

Generated theme:

```text
Repo builder: custom-themes/builders/theme-build-dunst
Generated target: ~/.config/custom-themes/dunst-theme.dunstrc
Dunst drop-in target: ~/.config/dunst/dunstrc.d/90-vault-theme.conf
```

Behavior:

```text
Position: top-right
Timeouts: low/normal 2 seconds, critical persistent
Icons: enabled, medium size
Clicks: left closes current popup, right opens Dunst context menu
History: Polybar notification icon opens Rofi history and copies selected text
```

Recommended CachyOS/Arch packages for the recording feature:

```bash
sudo pacman -S ffmpeg xdotool xorg-xwininfo libnotify
```

## Builders

| Builder | Output |
|---|---|
| `custom-themes/builders/theme-build-i3` | `~/.config/custom-themes/i3-theme.i3` |
| `custom-themes/builders/theme-build-rofi` | `~/.config/custom-themes/rofi-theme.rasi` |
| `custom-themes/builders/theme-build-polybar` | `~/.config/custom-themes/polybar-theme.ini` |
| `custom-themes/builders/theme-build-dunst` | `~/.config/custom-themes/dunst-theme.dunstrc` |
| `custom-themes/builders/theme-build-alacritty` | `~/.config/custom-themes/alacritty-theme.toml` |
| `custom-themes/builders/theme-build-micro` | `~/.config/custom-themes/orchis-dark.micro` |

All builders source `custom-themes/builders/theme-build-lib`, which loads the generic palette from `custom-themes/color-palette/orchis-dark-palette.sh`. App-specific color decisions belong in the app builders, not in the palette.

Builder and installer group names are listed in `scripts/lib/vault-registry.sh`. `custom-themes/builders/theme-builder` and `installers/install-interactive` use that registry to avoid duplicated app lists.

## Validation

Run the full repo validation suite with:

```bash
scripts/validate
```

It checks shell syntax, theme generation, installer dry-runs, stale references, Dunst config parsing, basic Polybar script output, registry consistency, and optional ShellCheck when available.

## Installers

```bash
installers/install-all
installers/install-all-no-nwg-look
installers/install-interactive
```

The installers share implementation through `installers/lib/install-lib.sh`. They use `install -D`, respect `$HOME`, log every copied file, and do not delete files or create backups.

Useful validation toggles:

```bash
VAULT_SKIP_NWG_LOOK=1
VAULT_SKIP_RELOAD=1
```

## Logging

Scripts use the shared logging helpers from `scripts/lib/vault-lib.sh`:

```text
[INFO] message
[OK] message
[WARN] message
[ERROR] message
```
