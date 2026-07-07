# Installers

## Entrypoints

Install packages from `packages/core.txt`, `packages/apps.txt`, `packages/aur.txt`, and `packages/flatpak.txt`:

```bash
installers/install-packages
```

Install only selected package groups:

```bash
installers/install-packages --core --apps --aur --flatpak
```

Install all configs without launching `nwg-look`:

```bash
installers/install-all
```

Install all configs and launch `nwg-look` when available:

```bash
installers/install-all-with-nwg-look
```

The old interactive installer has been removed. Config group names still live in `scripts/lib/vault-registry.sh` so installer dispatch and validation share one registry.

## Behavior

`installers/install-packages` installs pacman manifests first, then AUR packages, then Flatpak apps. It defaults to `paru` or `yay` for AUR packages. For Flatpak, it uses a user `flathub` remote when available, otherwise a system `flathub` remote.

The installers share implementation through `installers/lib/install-lib.sh`. They use `install -D`, respect `$HOME`, log every copied file, and do not delete files or create backups.

`installers/install-all` still installs the managed `nwg-look` config file; it only avoids launching the GUI. Use `installers/install-all-with-nwg-look` for the GUI pass.

## Useful Toggles

```bash
VAULT_SKIP_NWG_LOOK=1
VAULT_SKIP_RELOAD=1
VAULT_SKIP_SYSTEM_CONFIGS=1
VAULT_AUR_HELPER=paru
VAULT_SKIP_AUR=1
VAULT_SKIP_FLATPAK=1
VAULT_FLATPAK_REMOTE=flathub
VAULT_FLATPAK_SCOPE=auto
```

System-level installer groups such as Ly, drive automounts, and system tweaks may use sudo. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` for a user-only install or dry run.

Headless dry run:

```bash
HOME="$(mktemp -d)" VAULT_SKIP_RELOAD=1 VAULT_SKIP_SYSTEM_CONFIGS=1 installers/install-all
```
