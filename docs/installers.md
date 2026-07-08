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

Force a package installer mode:

```bash
installers/install-packages --manager shelly
installers/install-packages --manager legacy
```

Install all configs without launching `nwg-look`:

```bash
installers/install-all
```

Install all configs and launch `nwg-look` when available:

```bash
installers/install-all-with-nwg-look
```

The old interactive config installer has been removed. Config group names still live in `scripts/lib/vault-registry.sh` so installer dispatch and validation share one registry.

## Behavior

`installers/install-packages` installs core/app manifests first, then AUR packages, then Flatpak apps. It uses Shelly by default when `shelly` is installed, so Shelly can show its package and optional dependency prompts. Without Shelly, it falls back to `pacman`, `paru` or `yay`, and `flatpak`.

Flatpak installs default to user scope. The installer adds the user `flathub` remote first when it is missing, then installs Flatpak apps from that remote.

The installers share implementation through `installers/lib/install-lib.sh`. They use `install -D`, respect `$HOME`, and log copied files. The file-associations installer also removes old repo-managed MIME helper artifacts before applying current defaults.

`installers/install-all` still installs the managed `nwg-look` config file; it only avoids launching the GUI. Use `installers/install-all-with-nwg-look` for the GUI pass.

## Useful Toggles

```bash
VAULT_PACKAGE_MANAGER=auto
VAULT_SKIP_NWG_LOOK=1
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

System-level installer groups such as Ly, drive automounts, and system tweaks may use sudo. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` for a user-only install or dry run.

Headless dry run:

```bash
HOME="$(mktemp -d)" VAULT_SKIP_RELOAD=1 VAULT_SKIP_SYSTEM_CONFIGS=1 installers/install-all
```
