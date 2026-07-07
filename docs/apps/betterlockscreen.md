# Betterlockscreen

## Files

```text
Repo config: custom-configs/BetterLockScreen/betterlockscreenrc
Generated target: ~/.config/custom-themes/betterlockscreenrc
Installed target: ~/.config/betterlockscreen/betterlockscreenrc
Builder: custom-themes/builders/theme-build-betterlockscreen
```

## Runtime Notes

Betterlockscreen keeps theme values inline, so the builder generates a full themed config file and the installer copies that generated file into place.

Run this manually if the lockscreen wallpaper cache needs refreshing:

```bash
betterlockscreen -u ~/.config/i3/wallpaper.jpg
```
