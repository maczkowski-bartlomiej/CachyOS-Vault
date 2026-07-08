# Theme Builders

## Entrypoints

Run all app-specific builders with:

```bash
custom-configs/Themes/builders/theme-builder
```

The legacy compatibility wrapper remains available:

```bash
custom-configs/Themes/builders/theme-build
```

## Outputs

| Builder | Output |
|---|---|
| `custom-configs/Themes/builders/theme-build-i3` | `~/.config/custom-themes/i3-theme.i3` |
| `custom-configs/Themes/builders/theme-build-rofi` | `~/.config/custom-themes/rofi-theme.rasi` |
| `custom-configs/Themes/builders/theme-build-polybar` | `~/.config/custom-themes/polybar-theme.ini` |
| `custom-configs/Themes/builders/theme-build-dunst` | `~/.config/custom-themes/dunst-theme.dunstrc` |
| `custom-configs/Themes/builders/theme-build-betterlockscreen` | `~/.config/custom-themes/betterlockscreenrc` |
| `custom-configs/Themes/builders/theme-build-ly` | `~/.config/custom-themes/ly-config.ini` |
| `custom-configs/Themes/builders/theme-build-alacritty` | `~/.config/custom-themes/alacritty-theme.toml` |
| `custom-configs/Themes/builders/theme-build-micro` | `~/.config/custom-themes/orchis-dark.micro` |

All builders source `custom-configs/Themes/builders/theme-build-lib`, which loads the generic palette from `custom-configs/Themes/color-palette/orchis-dark-palette.sh`. App-specific color decisions belong in the app builders, not in the palette.

Builder names are registered in `scripts/lib/vault-registry.sh`.
