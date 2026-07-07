# Installers

## Entrypoints

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

The installers share implementation through `installers/lib/install-lib.sh`. They use `install -D`, respect `$HOME`, log every copied file, and do not delete files or create backups.

`installers/install-all` still installs the managed `nwg-look` config file; it only avoids launching the GUI. Use `installers/install-all-with-nwg-look` for the GUI pass.

## Useful Toggles

```bash
VAULT_SKIP_NWG_LOOK=1
VAULT_SKIP_RELOAD=1
VAULT_SKIP_SYSTEM_CONFIGS=1
```

System-level installer groups such as Ly, drive automounts, and system tweaks may use sudo. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` for a user-only install or dry run.

Headless dry run:

```bash
HOME="$(mktemp -d)" VAULT_SKIP_RELOAD=1 VAULT_SKIP_SYSTEM_CONFIGS=1 installers/install-all
```
