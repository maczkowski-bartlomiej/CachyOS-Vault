# CachyOS-Vault

Collection of personal CachyOS/Linux scripts, configs, themes, builders, and installers.

## Theme Generation

Generate all app-specific theme files under `~/.config/custom-themes/`:

```bash
custom-themes/builders/theme-builder
```

The legacy entrypoint remains as a compatibility wrapper:

```bash
custom-themes/builders/theme-build
```

Generated files:

```text
~/.config/custom-themes/i3-theme.i3
~/.config/custom-themes/rofi-theme.rasi
~/.config/custom-themes/polybar-theme.ini
~/.config/custom-themes/dunst-theme.dunstrc
~/.config/custom-themes/alacritty-theme.toml
~/.config/custom-themes/orchis-dark.micro
```

## Installers

Install all configs and launch `nwg-look` when available:

```bash
installers/install-all
```

Install all configs without launching `nwg-look`:

```bash
installers/install-all-no-nwg-look
```

Select config groups interactively:

```bash
installers/install-interactive
```

For headless validation:

```bash
HOME="$(mktemp -d)" VAULT_SKIP_NWG_LOOK=1 VAULT_SKIP_RELOAD=1 installers/install-all-no-nwg-look
```

See `apps_description.md` for supported apps, install targets, generated theme paths, and caveats.
