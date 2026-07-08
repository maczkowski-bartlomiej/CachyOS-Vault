# Cursor Hardening

## Files

```text
Repo cursor theme: custom-tweaks/cursor-hardening/index.theme
Repo Xresources: custom-tweaks/cursor-hardening/.Xresources
Install cursor target: ~/.icons/default/index.theme
Install Xresources target: ~/.Xresources
```

## Runtime Notes

The managed cursor theme uses `Bibata-Modern-Ice`. The installer runs `xrdb -merge ~/.Xresources` when `xrdb` is available and `VAULT_SKIP_RELOAD` is not set.
