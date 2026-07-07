# System Tweaks

## Installer Actions

```text
paccache.timer: keeps the pacman cache trimmed automatically
btrfs-scrub@-.timer: periodic Btrfs scrub for /
btrfs-scrub@mnt-data\x2dhdd.timer: periodic Btrfs scrub for /mnt/data-hdd
```

## Install Notes

These actions change systemd unit state, so the installer uses sudo unless run as root. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` to skip them during validation or user-only installs.
