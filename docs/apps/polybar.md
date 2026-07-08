# Polybar

## Files

```text
Repo config: custom-configs/Polybar/config.ini
Install target: ~/.config/polybar/config.ini
Generated theme: ~/.config/custom-themes/polybar-theme.ini
Builder: custom-configs/Themes/builders/theme-build-polybar
```

The config imports the generated theme with:

```text
include-file = ~/.config/custom-themes/polybar-theme.ini
```

## Runtime Helpers

```text
Repo: custom-configs/Polybar/scripts/polybar-runtime.sh
Target: ~/.config/polybar/scripts/polybar-runtime.sh
Purpose: shared Polybar formatting/color helper for module scripts

Repo: custom-configs/Polybar/scripts/polybar-script-lib.sh
Target: ~/.config/polybar/scripts/polybar-script-lib.sh
Purpose: shared runtime sourcing and notification helper for Polybar scripts
```

## Scripts

```text
audio-player.sh: playerctl-based audio player controls
audio-output.sh: pactl + rofi audio output switcher
calendar-menu.sh: gsimplecal popup opened by clicking the date
screen-record.sh: ffmpeg + x11grab focused-window screen recorder; saves to ~/Videos/Recordings; attempts system audio via the default sink monitor and falls back to video-only
notification-history.sh: Dunst history icon; left-click opens Rofi history and copies selected notification text, right-click clears Dunst history
power-menu.sh: Rofi power menu
polybar-runtime.sh: shared runtime formatting/color helper for Polybar scripts
polybar-script-lib.sh: shared loader/helper sourced by module scripts
weather-openmeteo.sh: weather module using Open-Meteo
```

## Dependencies

```text
Required base: bash, polybar, rofi
Audio: playerctl, pactl
Weather: curl, jq
Calendar: gsimplecal
Recording: ffmpeg, xdotool, xwininfo; notify-send optional
Notifications: dunst, dunstctl, jq, xclip or xsel
```

Recommended CachyOS/Arch packages for the recording feature:

```bash
sudo pacman -S ffmpeg xdotool xorg-xwininfo libnotify
```
