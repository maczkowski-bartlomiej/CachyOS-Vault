# Package Manifest

`pacman.txt` is a plain package list for this desktop setup. It intentionally has no comments or blank lines, so it can be passed directly to `pacman`.

Install everything in the list:

```bash
sudo pacman -Syu
sudo pacman -S --needed - < packages/pacman.txt
```

The list includes packages required by the tracked configs, scripts, Polybar modules, theme builders, and installers, plus personal apps that do not currently have repo configs:

```text
bitwarden
brave-bin
zen-browser-bin
```

Notes:

```text
pactl is provided by libpulse.
notify-send is provided by libnotify.
xwininfo is provided by xorg-xwininfo.
xrandr is provided by xorg-xrandr.
xsetroot is provided by xorg-xsetroot.
gtk-launch is provided by gtk3.
maim area selection uses slop.
betterlockscreen is referenced by the i3 config but is not in this pacman list because it was not available in the local pacman sync database during inspection.
The Bibata cursor theme referenced by cursor hardening is also not listed because its package name varies by repository.
```
