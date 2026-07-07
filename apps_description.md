# CachyOS-Vault Apps And Theme Architecture

`apps_description.md` is the index for supported config groups. Detailed runtime notes live in per-app files under `docs/apps/`, with shared builder and installer notes in `docs/builders.md` and `docs/installers.md`.

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

## Supported Apps And Config Groups

| App/group | Repo config source | Install target | Generated theme | Include/import mechanism | Details |
|---|---|---|---|---|---|
| I3 | `custom-configs/I3/config` | `~/.config/i3/config` | `~/.config/custom-themes/i3-theme.i3` | `include ~/.config/custom-themes/i3-theme.i3` | `docs/apps/i3.md` |
| Rofi | `custom-configs/Rofi/config.rasi` | `~/.config/rofi/config.rasi` | `~/.config/custom-themes/rofi-theme.rasi` | `@import "~/.config/custom-themes/rofi-theme.rasi"` | `docs/apps/rofi.md` |
| Redshift | `custom-configs/Redshift/redshift.conf` | `~/.config/redshift/redshift.conf` | none | n/a | `docs/apps/redshift.md` |
| Polybar | `custom-configs/Polybar/config.ini` | `~/.config/polybar/config.ini` | `~/.config/custom-themes/polybar-theme.ini` | `include-file = ~/.config/custom-themes/polybar-theme.ini` | `docs/apps/polybar.md` |
| Dunst | `custom-configs/Dunst/dunstrc` | `~/.config/dunst/dunstrc` | `~/.config/custom-themes/dunst-theme.dunstrc` | `~/.config/dunst/dunstrc.d/90-vault-theme.conf` symlink | `docs/apps/dunst.md` |
| Betterlockscreen | `custom-configs/BetterLockScreen/betterlockscreenrc` | `~/.config/betterlockscreen/betterlockscreenrc` | `~/.config/custom-themes/betterlockscreenrc` | installer copies generated full config | `docs/apps/betterlockscreen.md` |
| Ly | `custom-configs/Ly/config.ini`, `custom-configs/Ly/xsessions/i3.desktop` | `/etc/ly/config.ini`, `/etc/ly/xsessions/i3.desktop` | `~/.config/custom-themes/ly-config.ini` | installer copies generated full config with sudo | `docs/apps/ly.md` |
| Alacritty | `custom-configs/Alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | `~/.config/custom-themes/alacritty-theme.toml` | `import = ["~/.config/custom-themes/alacritty-theme.toml"]` | `docs/apps/alacritty.md` |
| Zsh | `custom-configs/Zsh/.zshrc`, `custom-configs/Zsh/oh-my-posh/cachyos-compact.omp.json` | `~/.zshrc`, `~/.config/oh-my-posh/cachyos-compact.omp.json` | none | `oh-my-posh init zsh` | `docs/apps/zsh.md` |
| Environment | `custom-configs/Environment/90-gaming.conf` | `~/.config/environment.d/90-gaming.conf` | none | systemd user environment.d | `docs/apps/environment.md` |
| Micro | `custom-configs/Micro/settings.json` | `~/.config/micro/settings.json` | `~/.config/custom-themes/orchis-dark.micro` | `"colorscheme": "orchis-dark"` | `docs/apps/micro.md` |
| Picom | `custom-configs/Picom/picom.conf` | `~/.config/picom/picom.conf` | none | none | `docs/apps/picom.md` |
| nwg-look | `custom-configs/I3/nwg-look/config` | `~/.config/nwg-look/config` | none | n/a | `docs/apps/nwg-look.md` |
| GTK bookmarks | `custom-configs/GTK/bookmarks` | `~/.config/gtk-3.0/bookmarks`, `~/.config/gtk-4.0/bookmarks` | none | GTK bookmarks / Thunar Places | `docs/apps/gtk-bookmarks.md` |
| Cursor hardening | `custom-configs/I3/cursor-hardening/index.theme`, `.Xresources` | `~/.icons/default/index.theme`, `~/.Xresources` | none | `xrdb -merge ~/.Xresources` | `docs/apps/cursor-hardening.md` |
| Wallpaper | `custom-themes/wallpaper/wallpaper.jpg` | `~/.config/i3/wallpaper.jpg` | none | `exec feh --bg-fill ~/.config/i3/wallpaper.jpg` | `docs/apps/wallpaper.md` |
| I3 scripts | `custom-configs/I3/scripts/*` | `~/.config/i3/scripts/*` | none | referenced by `custom-configs/I3/config` | `docs/apps/i3.md` |
| Drive automounts | `custom-configs/System/fstab-drive-automounts` | managed block in `/etc/fstab` | none | systemd fstab automount units | `docs/apps/drive-automounts.md` |
| System tweaks | installer-managed | systemd unit state | none | `systemctl enable --now` | `docs/apps/system-tweaks.md` |

## Shared Notes

| Topic | Doc |
|---|---|
| Theme builders | `docs/builders.md` |
| Installers | `docs/installers.md` |
| Package manifests | `packages/README.md` |

## Validation

Run the full repo validation suite with:

```bash
scripts/validate
```

It checks shell syntax, theme generation, installer dry-runs, drive automount parsing, package manifest sorting, stale references, Dunst config parsing, basic Polybar script output, registry consistency, and optional ShellCheck when available.
