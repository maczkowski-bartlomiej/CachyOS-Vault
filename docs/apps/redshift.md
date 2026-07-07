# Redshift

## Files

```text
Repo config: custom-configs/Redshift/redshift.conf
Install target: ~/.config/redshift/redshift.conf
```

## Behavior

```text
Location provider: manual
Coordinates: 54.16, 19.40
Day temperature: 6500K
Night temperature: 4200K
Transition: enabled, so Redshift changes gradually around sunset/sunrise
Autostart: i3 runs redshift -c ~/.config/redshift/redshift.conf
```

GeoClue is not required because the config uses manual coordinates.
