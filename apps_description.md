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
| Redshift | `custom-configs/Redshift/redshift.conf` | `~/.config/redshift/redshift.conf` | none | n/a | Night light transitions automatically at local sunset using manual coordinates shared with the weather module. |
| Polybar | `custom-configs/Polybar/config.ini` | `~/.config/polybar/config.ini` | `~/.config/custom-themes/polybar-theme.ini` | `include-file = ~/.config/custom-themes/polybar-theme.ini` | `launch.sh` and `scripts/*` are installed executable; focused workspace keeps the existing green color. |
| Dunst | `custom-configs/Dunst/dunstrc` | `~/.config/dunst/dunstrc` | `~/.config/custom-themes/dunst-theme.dunstrc` | `~/.config/dunst/dunstrc.d/90-vault-theme.conf` symlink | Compact top-right notifications; low/normal time out after 2 seconds, critical stays until dismissed; installer reloads Dunst with `dunstctl reload` when available. |
| Betterlockscreen | `custom-configs/BetterLockScreen/betterlockscreenrc` | `~/.config/betterlockscreen/betterlockscreenrc` | `~/.config/custom-themes/betterlockscreenrc` | Installer copies the generated full config | Uses the Orchis palette for i3lock-color values; package is listed in `packages/aur.txt`. |
| Ly | `custom-configs/Ly/config.ini` | `/etc/ly/config.ini` | `~/.config/custom-themes/ly-config.ini` | Installer copies the generated full config with sudo | System config install is skipped when `VAULT_SKIP_SYSTEM_CONFIGS=1`; generated config disables empty-password login. |
| Alacritty | `custom-configs/Alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | `~/.config/custom-themes/alacritty-theme.toml` | `import = ["~/.config/custom-themes/alacritty-theme.toml"]` | TOML theme import generated from the central palette. |
| Micro | `custom-configs/Micro/settings.json` | `~/.config/micro/settings.json` | `~/.config/custom-themes/orchis-dark.micro` | `"colorscheme": "orchis-dark"` | Micro loads named colorschemes from `~/.config/micro/colorschemes`; installer copies the generated theme to `~/.config/micro/colorschemes/orchis-dark.micro`. |
| Picom | `custom-configs/Picom/picom.conf` | `~/.config/picom/picom.conf` | none | none | No clean include/import mechanism is currently documented here; restart Picom manually or restart i3 if needed. |
| nwg-look | `custom-configs/I3/nwg-look/config` | `~/.config/nwg-look/config` | none | n/a | `install-all` may launch `nwg-look`; no-nwg and `VAULT_SKIP_NWG_LOOK=1` skip it. |
| Cursor hardening | `custom-configs/I3/cursor-hardening/index.theme`, `.Xresources` | `~/.icons/default/index.theme`, `~/.Xresources` | none | `xrdb -merge ~/.Xresources` | Uses `Bibata-Modern-Ice`; `xrdb` merge is skipped when `VAULT_SKIP_RELOAD=1` or `xrdb` is unavailable. |
| Wallpaper | `custom-themes/wallpaper/wallpaper.jpg` | `~/.config/i3/wallpaper.jpg` | none | `exec feh --bg-fill ~/.config/i3/wallpaper.jpg` | Installed as part of all configs or as a separate interactive group. |
| I3 scripts | `custom-configs/I3/scripts/*` | `~/.config/i3/scripts/*` | none | referenced by `custom-configs/I3/config` | Installed executable. Includes helpers for screenshots, volume/XOB, Picom restart, mouse warping, and XOB listening. Included in the `i3` installer group and also selectable as `i3-scripts` in the interactive installer. |
| Drive automounts | `custom-configs/System/fstab-drive-automounts` | managed block in `/etc/fstab` | none | systemd fstab automount units | Creates `/mnt/dev`, `/mnt/dev-data`, and `/mnt/data-hdd`; install is skipped when `VAULT_SKIP_SYSTEM_CONFIGS=1`. |
| System tweaks | installer-managed | systemd unit state | none | `systemctl enable --now` | Enables `paccache.timer` and Btrfs scrub timers for `/` and `/mnt/data-hdd`; skipped when `VAULT_SKIP_SYSTEM_CONFIGS=1`. |

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
rofi-launcher: launches Rofi with Flatpak desktop export paths added to XDG_DATA_DIRS
screenshot-current-monitor: captures the monitor under the pointer, saves it, and copies it to clipboard
screenshot-menu: Rofi menu for area, window, or current-monitor screenshots
screenshot-lib: shared screenshot helper functions
volume-osd: handles volume up/down/mute and writes the current value to XOB
xob-listener: owns the XOB FIFO and lock under ${XDG_RUNTIME_DIR:-/tmp}/cachyos-vault
```

## Redshift Night Light

Config:

```text
Repo: custom-configs/Redshift/redshift.conf
Target: ~/.config/redshift/redshift.conf
```

Behavior:

```text
Location provider: manual
Coordinates: 54.16, 19.40
Day temperature: 6500K
Night temperature: 4200K
Transition: enabled, so Redshift changes gradually around sunset/sunrise
Autostart: i3 runs redshift -c ~/.config/redshift/redshift.conf
```

## Rofi Flatpak Launching

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

## System Tweaks And Drive Automounts

Drive automount source:

```text
Repo: custom-configs/System/fstab-drive-automounts
Install target: managed CachyOS-Vault block in /etc/fstab
Mount targets: /mnt/dev, /mnt/dev-data, /mnt/data-hdd
```

Behavior:

```text
/mnt/dev: NTFS, user-writable, automounted on access
/mnt/dev-data: NTFS, user-writable, automounted on access
/mnt/data-hdd: Btrfs, noatime, zstd compression, automounted on access
All entries use nofail and a short systemd device timeout so missing drives do not block boot.
```

System tweaks:

```text
paccache.timer: keeps the pacman cache trimmed automatically
btrfs-scrub@-.timer: periodic Btrfs scrub for /
btrfs-scrub@mnt-data\x2dhdd.timer: periodic Btrfs scrub for /mnt/data-hdd
```

Install notes:

```text
These actions write to /etc/fstab or systemd unit state, so the installer uses sudo unless run as root.
Set VAULT_SKIP_SYSTEM_CONFIGS=1 to skip them during validation or user-only installs.
For shared NTFS writes, Windows Fast Startup/hibernation should stay disabled.
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

## Betterlockscreen And Ly

Betterlockscreen:

```text
Repo config: custom-configs/BetterLockScreen/betterlockscreenrc
Repo builder: custom-themes/builders/theme-build-betterlockscreen
Generated target: ~/.config/custom-themes/betterlockscreenrc
Installed target: ~/.config/betterlockscreen/betterlockscreenrc
```

Ly:

```text
Repo config: custom-configs/Ly/config.ini
Repo builder: custom-themes/builders/theme-build-ly
Generated target: ~/.config/custom-themes/ly-config.ini
Installed target: /etc/ly/config.ini
Install note: requires sudo unless run as root; set VAULT_SKIP_SYSTEM_CONFIGS=1 to skip /etc writes
```

Both tools keep theme values inline in their runtime config, so their builders generate full themed config files instead of include snippets.

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
| `custom-themes/builders/theme-build-betterlockscreen` | `~/.config/custom-themes/betterlockscreenrc` |
| `custom-themes/builders/theme-build-ly` | `~/.config/custom-themes/ly-config.ini` |
| `custom-themes/builders/theme-build-alacritty` | `~/.config/custom-themes/alacritty-theme.toml` |
| `custom-themes/builders/theme-build-micro` | `~/.config/custom-themes/orchis-dark.micro` |

All builders source `custom-themes/builders/theme-build-lib`, which loads the generic palette from `custom-themes/color-palette/orchis-dark-palette.sh`. App-specific color decisions belong in the app builders, not in the palette.

Builder and installer group names are listed in `scripts/lib/vault-registry.sh`. `custom-themes/builders/theme-builder` and `installers/install-interactive` use that registry to avoid duplicated app lists.

## Validation

Run the full repo validation suite with:

```bash
scripts/validate
```

It checks shell syntax, theme generation, installer dry-runs, drive automount parsing, package manifest sorting, stale references, Dunst config parsing, basic Polybar script output, registry consistency, and optional ShellCheck when available.

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
VAULT_SKIP_SYSTEM_CONFIGS=1
```

## Logging

Scripts use the shared logging helpers from `scripts/lib/vault-lib.sh`:

```text
[INFO] message
[OK] message
[WARN] message
[ERROR] message
```
