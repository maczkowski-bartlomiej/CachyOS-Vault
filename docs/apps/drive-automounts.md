# Drive Automounts

## Files

```text
Repo source: custom-configs/System/fstab-drive-automounts
Install target: managed CachyOS-Vault block in /etc/fstab
Mount targets: /mnt/dev, /mnt/dev-data, /mnt/data-hdd
```

## Behavior

```text
/mnt/dev: NTFS, user-writable, automounted on access
/mnt/dev-data: NTFS, user-writable, automounted on access
/mnt/data-hdd: Btrfs, noatime, zstd compression, automounted on access
```

All entries use `nofail` and a short systemd device timeout so missing drives do not block boot.

## Install Notes

This writes to `/etc/fstab`, so the installer uses sudo unless run as root. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` to skip it during validation or user-only installs.

For shared NTFS writes, Windows Fast Startup and hibernation should stay disabled.
