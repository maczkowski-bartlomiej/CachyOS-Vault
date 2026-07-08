# CachyOS-Vault

Personal CachyOS/Linux package manifests, configs, tweaks, theme builders, and installers.

## Flows

Install packages from `custom-packages/*.txt` with a numbered picker:

```bash
installers/install-packages
```

Install every managed config, generate theme files under `~/.config/custom-themes/`, then reload and restart i3 once:

```bash
installers/install-configs
```

Run optional system/user tweaks with a numbered picker:

```bash
installers/install-tweaks
```

Open GUI theme tools and apply the printed settings:

```bash
installers/configure-themes
```

Run an optional prerequisite report:

```bash
installers/check-prereqs
```

Run validation:

```bash
scripts/validate
```

## Theme Generation

Generate all app-specific theme files:

```bash
custom-configs/Themes/builders/theme-builder
```

Generated files stay under `~/.config/custom-themes/` so app configs can keep stable runtime imports:

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

## Environment

Package manager mode is environment-driven:

```bash
VAULT_PACKAGE_MANAGER=auto
VAULT_PACKAGE_MANAGER=shelly
VAULT_PACKAGE_MANAGER=legacy
```

Useful toggles:

```bash
VAULT_SKIP_RELOAD=1
VAULT_SKIP_SYSTEM_CONFIGS=1
VAULT_SKIP_MIME_DEFAULTS=1
VAULT_AUR_HELPER=paru
VAULT_SKIP_AUR=1
VAULT_SKIP_FLATPAK=1
VAULT_FLATPAK_REMOTE=flathub
VAULT_FLATPAK_SCOPE=user
```

Headless config validation:

```bash
HOME="$(mktemp -d)" VAULT_SKIP_RELOAD=1 VAULT_SKIP_SYSTEM_CONFIGS=1 installers/install-configs
```

Per-app notes live under `docs/apps/`.
