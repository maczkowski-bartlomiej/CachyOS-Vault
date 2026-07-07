# nwg-look

## Files

```text
Repo config: custom-configs/I3/nwg-look/config
Install target: ~/.config/nwg-look/config
```

## Installer Behavior

`installers/install-all` installs the config but does not launch `nwg-look`.

Use this entrypoint when you want the GUI launched after install:

```bash
installers/install-all-with-nwg-look
```

Set `VAULT_SKIP_NWG_LOOK=1` to suppress launching even from the `with-nwg-look` entrypoint.
