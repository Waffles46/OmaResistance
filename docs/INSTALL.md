# Lock installation and rollback

These instructions apply to the Omarchy shell plugin. The SDDM login theme has its own [setup guide](SDDM.md).

## Before switching

Use an unlocked session. Test the first release on a disposable Omarchy installation with a working TTY before relying on it for session security.

1. Record `omarchy version` and `omarchy plugin list`.
2. Save a dated backup of `~/.config/omarchy/shell.json` outside this checkout.
3. Note the ID of any enabled custom clone of `omarchy.lock` for rollback.
4. Confirm Omarchy's normal lock and password authentication already work, including `/etc/pam.d/omarchy-lock-password`.

For example:

```sh
backup="$HOME/.config/omarchy/shell.json.before-omaresistance-$(date +%Y%m%d-%H%M%S)"
cp -p -- "$HOME/.config/omarchy/shell.json" "$backup"
printf 'Shell configuration backup: %s\n' "$backup"
```

## Install and enable

Once the repository is published, add it and decline the enable prompt while reviewing the source:

```sh
omarchy plugin add https://github.com/Waffles46/OmaResistance
omarchy plugin list
```

Disable any existing custom lock using its specific ID while unlocked. Then enable OmaResistance:

```sh
omarchy plugin enable waffles46.omaresistance
omarchy plugin list
```

Verify this is the only enabled custom clone of `omarchy.lock`. Omarchy's host disables the built-in source when appropriate, but does not automatically disable competing custom clones. Keep `omarchy.clonedFrom` set to `omarchy.lock`: the host uses it for routing and inherited authentication-service isolation.

## Preview

```sh
omarchy shell lock preview
```

Click to close it, or run `omarchy shell lock hidePreview`. This is a visual preview, not an authentication test. Complete the checks in [VALIDATION.md](VALIDATION.md) before adopting the plugin. `omarchy system lock` performs a real lock and requires the user's authentication to return.

## Rollback and recovery

Switch or remove lock services while unlocked. Destroying a Wayland session-lock client while locked can leave the compositor's failsafe in place.

Restore the built-in lock:

```sh
omarchy plugin disable waffles46.omaresistance
omarchy plugin enable omarchy.lock
```

To restore another custom lock, enable its saved ID after disabling OmaResistance. Inspect `omarchy plugin list`, then verify the restored lock works. Remove this plugin with:

```sh
omarchy plugin remove waffles46.omaresistance
```

If a real test leaves the desktop inaccessible, authenticate on a separate TTY (`Ctrl` + `Alt` + `F3`) and restore the saved `shell.json`. A fresh desktop session/reboot can then load the previous lock configuration; preserve recoverable work first. Do not recover by weakening password checks or adding a public unlock IPC method.

SDDM installation is independent: removing this plugin does not undo a separately selected login theme. Follow [SDDM rollback](SDDM.md#rollback) if applicable.

## Update

From an unlocked session, review the update diff and repeat relevant validation:

```sh
omarchy plugin update waffles46.omaresistance
```
