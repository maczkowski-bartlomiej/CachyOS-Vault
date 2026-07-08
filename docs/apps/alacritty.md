# Alacritty

## Files

```text
Repo config: custom-configs/Alacritty/alacritty.toml
Install target: ~/.config/alacritty/alacritty.toml
Generated theme: ~/.config/custom-themes/alacritty-theme.toml
Builder: custom-configs/Themes/builders/theme-build-alacritty
```

## Runtime Notes

`alacritty.toml` imports the generated theme with:

```toml
import = ["~/.config/custom-themes/alacritty-theme.toml"]
```

The static config owns terminal behavior, font, opacity, key bindings, and window settings. The builder only writes the color palette import.
