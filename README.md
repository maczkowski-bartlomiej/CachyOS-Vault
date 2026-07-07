# CachyOS-Vault

Collection of personal CachyOS/Linux scripts, configs, themes, builders, and installers.

## Theme Generation

Generate all app-specific theme files under `~/.config/custom-themes/`:

```bash
custom-themes/builders/theme-builder
```

The legacy entrypoint remains as a compatibility wrapper:

```bash
custom-themes/builders/theme-build
```

Generated files:

```text
~/.config/custom-themes/i3-theme.i3
~/.config/custom-themes/rofi-theme.rasi
~/.config/custom-themes/polybar-theme.ini
~/.config/custom-themes/dunst-theme.dunstrc
~/.config/custom-themes/betterlockscreenrc
~/.config/custom-themes/ly-config.ini
~/.config/custom-themes/alacritty-theme.toml
~/.config/custom-themes/orchis-dark.micro
```

## Installers

Install packages from the manifests under `packages/`:

```bash
installers/install-packages
```

For a narrower run, pass one or more groups:

```bash
installers/install-packages --core --apps --aur --flatpak
```

`installers/install-packages` uses `pacman` for `packages/core.txt` and `packages/apps.txt`, `paru` or `yay` for `packages/aur.txt`, and `flatpak` for `packages/flatpak.txt`. Flatpak installation uses a user `flathub` remote when available, otherwise a system `flathub` remote.

Install all configs:

```bash
installers/install-all
```

Install all configs and launch `nwg-look` when available:

```bash
installers/install-all-with-nwg-look
```

For headless validation:

```bash
HOME="$(mktemp -d)" VAULT_SKIP_RELOAD=1 VAULT_SKIP_SYSTEM_CONFIGS=1 installers/install-all
```

System-level installer groups such as Ly, drive automounts, and system tweaks may use `sudo`. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` for a user-only install or dry run.

Run the repo validation suite:

```bash
scripts/validate
```

Per-app notes live under `docs/apps/`.

I3 helper scripts are installed from `custom-configs/I3/scripts/*`; volume OSD state is kept under `${XDG_RUNTIME_DIR:-/tmp}/cachyos-vault`.
Rofi is launched through `~/.config/i3/scripts/rofi-launcher` so Flatpak desktop entries are visible in `drun`.
Drive automounts are sourced from `custom-configs/System/fstab-drive-automounts` and installed as a managed `/etc/fstab` block.
Thunar Places entries for those drives are sourced from `custom-configs/GTK/bookmarks`.
Zsh is installed from `custom-configs/Zsh/.zshrc` with an Oh My Posh prompt from `custom-configs/Zsh/oh-my-posh/cachyos-compact.omp.json`.
Gaming environment variables are installed from `custom-configs/Environment/90-gaming.conf` to `~/.config/environment.d/90-gaming.conf`.
