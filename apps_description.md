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
| Alacritty | `custom-configs/Alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | `~/.config/custom-themes/alacritty-theme.toml` | `import = ["~/.config/custom-themes/alacritty-theme.toml"]` | TOML theme import generated from the central palette. |
| Micro | `custom-configs/Micro/settings.json` | `~/.config/micro/settings.json` | `~/.config/custom-themes/orchis-dark.micro` | `"colorscheme": "orchis-dark"` | Micro loads named colorschemes from `~/.config/micro/colorschemes`; installer copies the generated theme to `~/.config/micro/colorschemes/orchis-dark.micro`. |
| Picom | `custom-configs/Picom/picom.conf` | `~/.config/picom/picom.conf` | none | none | No clean include/import mechanism is currently documented here; restart Picom manually or restart i3 if needed. |
| nwg-look | `custom-configs/I3/nwg-look/config` | `~/.config/nwg-look/config` | none | n/a | `install-all` may launch `nwg-look`; no-nwg and `VAULT_SKIP_NWG_LOOK=1` skip it. |
| Cursor hardening | `custom-configs/I3/cursor-hardening/index.theme`, `.Xresources` | `~/.icons/default/index.theme`, `~/.Xresources` | none | `xrdb -merge ~/.Xresources` | Uses `Bibata-Modern-Ice`; `xrdb` merge is skipped when `VAULT_SKIP_RELOAD=1` or `xrdb` is unavailable. |
| Wallpaper | `custom-themes/wallpaper/wallpaper.jpg` | `~/.config/i3/wallpaper.jpg` | none | `exec feh --bg-fill ~/.config/i3/wallpaper.jpg` | Installed as part of all configs or as a separate interactive group. |
| I3 scripts | `custom-configs/I3/scripts/*` | `~/.config/i3/scripts/*` | none | referenced by `custom-configs/I3/config` | Installed executable. Included in the `i3` installer group and also selectable as `i3-scripts` in the interactive installer. |

## Builders

| Builder | Output |
|---|---|
| `custom-themes/builders/theme-build-i3` | `~/.config/custom-themes/i3-theme.i3` |
| `custom-themes/builders/theme-build-rofi` | `~/.config/custom-themes/rofi-theme.rasi` |
| `custom-themes/builders/theme-build-polybar` | `~/.config/custom-themes/polybar-theme.ini` |
| `custom-themes/builders/theme-build-alacritty` | `~/.config/custom-themes/alacritty-theme.toml` |
| `custom-themes/builders/theme-build-micro` | `~/.config/custom-themes/orchis-dark.micro` |

All builders source `custom-themes/builders/theme-build-lib`, which loads the generic palette from `custom-themes/color-palette/orchis-dark-palette.sh`. App-specific color decisions belong in the app builders, not in the palette.

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
