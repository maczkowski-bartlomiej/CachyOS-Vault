# Installers

## Entrypoints

Install packages with an interactive manifest picker:

```bash
installers/install-packages
```

Install configs, build themes, and reload/restart i3 once:

```bash
installers/install-configs
```

Run optional tweaks with an interactive picker:

```bash
installers/install-tweaks
```

Configure desktop themes with GUI tools:

```bash
installers/configure-themes
```

Print an optional prerequisite report:

```bash
installers/check-prereqs
```

## Packages

`installers/install-packages` reads sorted manifests from `custom-packages/*.txt`.

Picker input:

```text
blank  cancel
all    install every manifest
1 3 5  install selected manifest numbers
```

Package manager mode is controlled by `VAULT_PACKAGE_MANAGER=auto|shelly|legacy`. In `auto`, Shelly is used when available; otherwise the installer falls back to `pacman`, an AUR helper, and `flatpak`.

## Configs

`installers/install-configs` runs the theme builders, installs all app configs, installs generated theme configs where an app needs a concrete file, then runs:

```bash
i3-msg reload
i3-msg restart
```

It does not directly reload Polybar. The i3 restart handles Polybar through the i3 startup config.

System-level config writes such as Ly may use `sudo`. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` for user-only dry runs.

## Tweaks

`installers/install-tweaks` runs selected stateful tweaks fail-fast:

```text
file-associations
drive-automounts
gtk-bookmarks
cursor-hardening
system-units
betterlockscreen-cache
```

Drive automounts and system units may use `sudo`. `betterlockscreen-cache` runs `betterlockscreen -u ~/.config/i3/wallpaper.jpg`.

## Theme GUIs

`installers/configure-themes` prints the exact GTK, icon, cursor, font, Qt, and Kvantum settings. It launches `nwg-look`, `qt5ct`, `qt6ct`, and `kvantummanager` in the background with output redirected to temp log files, waiting for Enter after each tool.

## Useful Toggles

```bash
VAULT_PACKAGE_MANAGER=auto
VAULT_SKIP_RELOAD=1
VAULT_SKIP_SYSTEM_CONFIGS=1
VAULT_SKIP_MIME_DEFAULTS=1
VAULT_AUR_HELPER=paru
VAULT_SKIP_AUR=1
VAULT_SKIP_FLATPAK=1
VAULT_FLATPAK_REMOTE=flathub
VAULT_FLATPAK_REMOTE_URL=https://dl.flathub.org/repo/flathub.flatpakrepo
VAULT_FLATPAK_SCOPE=user
```
