# Environment

## Files

```text
Repo config: custom-configs/Environment/90-gaming.conf
Install target: ~/.config/environment.d/90-gaming.conf
```

## Gaming Variables

```conf
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_SIZE=12000000000
```

These variables are read by systemd user environment handling for new sessions. Log out and back in, or restart the user session, before expecting games launched from the desktop to inherit them.
