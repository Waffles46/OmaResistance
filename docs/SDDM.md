# Optional SDDM login theme

This theme runs before the desktop starts. Installation is separate from the Omarchy plugin and requires administrator access. Test it first on a disposable machine.

## Dependencies and limits

Use SDDM with `sddm-greeter-qt6`, Qt Quick, `SddmComponents`, and a system-wide JetBrainsMono Nerd Font available to the `sddm` account. The current layout uses SDDM's last selected user/session and has no user or session picker.

Authentication is handled by SDDM. The theme does not install PAM policies or change passwords.

## Preview first

From the checkout or installed plugin directory:

```sh
sddm-greeter-qt6 --test-mode --theme ./sddm-theme
```

Check the fonts, panel placement, text, and power menu. Test mode cannot prove a real SDDM login succeeds.

## Install deliberately

Inspect the current `[Theme]` settings in `/etc/sddm.conf.d/*.conf` and `/etc/sddm.conf`. Save a dated backup of the existing configuration. Settings in `/etc/sddm.conf` can override the drop-ins; resolve that on your system before selecting this theme.

Run the optional commands below yourself in a terminal after reviewing them. They create a separate local theme directory and selection file and stop if either destination exists:

```bash
(
  set -euo pipefail
  theme_dir=/usr/local/share/sddm/themes/omaresistance
  selection_file=/etc/sddm.conf.d/zz-omaresistance.conf

  for destination in "$theme_dir" "$selection_file"; do
    if sudo test -e "$destination"; then
      printf 'Stop: destination already exists: %s\n' "$destination" >&2
      exit 1
    fi
  done

  sudo install -d -m0755 "$theme_dir" /etc/sddm.conf.d
  sudo install -m0644 sddm-theme/Main.qml sddm-theme/metadata.desktop \
    sddm-theme/theme.conf LICENSE OMARCHY-LICENSE "$theme_dir/"
  printf '[Theme]\nThemeDir=%s\nCurrent=omaresistance\n' \
    /usr/local/share/sddm/themes | sudo tee "$selection_file" >/dev/null
)
```

Verify the selection is effective with your other configuration. Apply it during a planned reboot after saving work. Restarting SDDM during an active desktop session ends that session.

## Rollback

Disable the dedicated selection file:

```sh
sudo mv -n /etc/sddm.conf.d/zz-omaresistance.conf \
  /etc/sddm.conf.d/zz-omaresistance.conf.disabled
```

Confirm the `.conf` file is gone and the `.disabled` copy exists. `-n` refuses to overwrite an existing disabled copy; if one exists, choose another backup name yourself.

If the greeter fails, authenticate on a TTY (`Ctrl` + `Alt` + `F3`), disable the selection file, and reboot when ready. Restore any existing SDDM file you changed yourself from its saved backup. Keep the theme files until recovery is complete. Test a real login and TTY rollback before considering this component verified.

## References

- [SDDM theming](https://github.com/sddm/sddm/blob/develop/docs/THEMING.md)
- [SDDM configuration](https://github.com/sddm/sddm/blob/develop/data/man/sddm.conf.rst.in)
