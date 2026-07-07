# Package Manifests

These package lists are plain package-name files. They intentionally have no comments or blank lines, so they can be passed directly to `pacman`.

Install core dependencies used by tracked configs and scripts:

```bash
sudo pacman -Syu
sudo pacman -S --needed - < packages/core.txt
```

Install personal apps that are intentionally not part of the core config dependency list:

```bash
sudo pacman -S --needed - < packages/apps.txt
```

Install AUR-only dependencies with an AUR helper:

```bash
xargs -r -a packages/aur.txt paru -S --needed
```

Or with `yay`:

```bash
xargs -r -a packages/aur.txt yay -S --needed
```

Notes:

```text
core.txt excludes i3-wm because this machine gets i3 from the Arch/CachyOS installer.
core.txt excludes xorg-server and xorg-xinit for the same reason; it only lists X11 helper tools directly called by scripts.
core.txt includes orchis-theme because the theme builders are based on the Orchis palette.
core.txt includes papirus-icon-theme because the Dunst config explicitly uses Papirus icons.
core.txt includes ly because this repo installs a generated Ly config.
core.txt includes brightnessctl and xorg-xauth because the Ly config references them directly.
core.txt includes flatpak because the Rofi launcher explicitly exposes Flatpak desktop exports.
core.txt includes btrfs-progs because the repo configures Btrfs automount/scrub behavior.
core.txt includes pacman-contrib because the system tweaks enable paccache.timer.
core.txt includes zsh and the zsh plugin packages because Alacritty launches zsh and the tracked zshrc loads those helpers.
pactl is provided by libpulse.
notify-send is provided by libnotify.
xwininfo is provided by xorg-xwininfo.
xrandr is provided by xorg-xrandr.
xsetroot is provided by xorg-xsetroot.
maim area selection uses slop.
aur.txt contains betterlockscreen because it is referenced by the i3 config and is AUR-only here.
aur.txt contains oh-my-posh-bin because the tracked zshrc uses Oh My Posh for the prompt and it is not in the enabled pacman repositories here.
Audio features expect an active PulseAudio-compatible server, for example PipeWire Pulse, but this list does not force a specific audio server package.
Redshift uses manual coordinates from custom-configs/Redshift/redshift.conf, so GeoClue is not required.
The Bibata cursor theme referenced by cursor hardening is not listed because its package name varies by repository.
```
