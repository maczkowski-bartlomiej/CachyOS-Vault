# Environment

## Files

```text
Repo session env: custom-configs/Environment/session-env.sh
Install target: ~/.config/env/session-env.sh
Repo X hook: custom-configs/Environment/.xprofile
Install target: ~/.xprofile
Repo toolkit defaults:
  custom-configs/GTK/settings-3.ini
  custom-configs/GTK/settings-4.ini
  custom-configs/GTK/gtkrc-2.0
  custom-configs/Qt/qt5ct.conf
  custom-configs/Qt/qt6ct.conf
  custom-configs/Kvantum/kvantum.kvconfig
```

## Session Variables

```bash
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=kvantum
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SIZE=12000000000
```

`.xprofile` and `.zshrc` source the session environment so X sessions and interactive shells share the same values. The script also imports the values into the user systemd and DBus activation environments when those tools are available.

GTK, qt5ct, qt6ct, and Kvantum defaults keep non-terminal application fonts on Inter 11. Alacritty still owns its terminal font separately.
