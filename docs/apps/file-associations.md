# File Associations

## Files

```text
MIME helper source: custom-tweaks/file-associations/set-file-extensions
MIME helper target: ~/.local/bin/set-file-extensions
```

## Behavior

The installer applies managed XDG defaults with:

```bash
~/.local/bin/set-file-extensions --managed
```

Managed defaults:

```text
Text and editable source/config files: org.gnome.gedit.desktop
Folders: doublecmd.desktop
Archives: org.gnome.FileRoller.desktop
```

`text/html` stays with the browser default. Set `VAULT_SKIP_MIME_DEFAULTS=1` to install the helper without changing MIME defaults.
