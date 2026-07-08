# Dunst

## Files

```text
Repo config: custom-configs/Dunst/dunstrc
Install target: ~/.config/dunst/dunstrc
Generated theme: ~/.config/custom-themes/dunst-theme.dunstrc
Theme drop-in: ~/.config/dunst/dunstrc.d/90-vault-theme.conf
Builder: custom-configs/Themes/builders/theme-build-dunst
```

## Behavior

```text
Position: top-right
Timeouts: low/normal 2 seconds, critical persistent
Icons: enabled, medium size
Clicks: left closes current popup, right opens Dunst context menu
History: Polybar notification icon opens Rofi history and copies selected text
```

The installer symlinks the generated theme into Dunst's drop-in directory and reloads Dunst with `dunstctl reload` when available.
