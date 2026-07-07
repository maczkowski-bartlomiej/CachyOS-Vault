# Ly

## Files

```text
Repo config: custom-configs/Ly/config.ini
Repo managed XSession: custom-configs/Ly/xsessions/i3.desktop
Generated target: ~/.config/custom-themes/ly-config.ini
Installed target: /etc/ly/config.ini
Installed XSession target: /etc/ly/xsessions/i3.desktop
Builder: custom-themes/builders/theme-build-ly
```

## Runtime Notes

Ly keeps theme values inline, so the builder generates a full themed config file.

Session policy:

```text
plain i3 only
shell sessions disabled
xinitrc disabled
Wayland sessions disabled
saved session state disabled
```

The installer writes to `/etc/ly`, so it uses sudo unless run as root. Set `VAULT_SKIP_SYSTEM_CONFIGS=1` to skip these writes.
