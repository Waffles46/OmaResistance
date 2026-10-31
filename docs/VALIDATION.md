# Validation and release checks

## Environment

Omarchy 4.0.5-1; Quickshell 0.3.2 (Omarchy build); Hyprland 0.56.2; Qt 6.12.0; SDDM 0.21.0; JetBrainsMono Nerd Font 3.5.1. Development display: 1920 × 1080, scale 1.

## Verified during preparation

- Manifest validation passes with ID `waffles46.omaresistance`.
- All four QML source files pass Qt's syntax and duplicate-ID checks. This is a parsing check, not full runtime type validation.
- The packaged lock view and power menu match the visually reviewed local design.
- Both screens were rendered and recorded. Each GIF has 72 frames, lasts six seconds, loops, and has differing sampled frames.
- The packaged Qt 6 SDDM theme stayed running through a four-second offscreen test-mode check; no real login was attempted.
- Preview assets show an empty password field and contain no wallpaper or account-name labels.
- The installed host recognizes the clone declaration and inherits the source lock's authentication-service isolation.

These checks establish structure, source behavior, and appearance, not fresh-install authentication.

## Real-session checks before publication

Use a disposable Omarchy installation with a working TTY and saved shell configuration. Record versions, dates, and outcomes without recording passwords.

- [ ] Install into a clean profile and verify the service and imports load.
- [ ] Verify only one custom lock is enabled and normal lock calls reach it.
- [ ] Open and dismiss the visual preview.
- [ ] Lock and confirm the compositor establishes a secure session lock.
- [ ] Verify an incorrect password keeps the session locked with visible feedback.
- [ ] Verify Escape/Ctrl+U clearing and long-password dot fitting.
- [ ] Verify a correct password unlocks the session.
- [ ] Test an enrolled fingerprint and password fallback, or record fingerprint support as unavailable.
- [ ] Test blank/wake and suspend/resume without revealing the desktop while locked.
- [ ] Test output hotplug and multiple monitors; every active output must stay covered.
- [ ] Disable/remove while unlocked and restore the previous lock.
- [ ] Verify recovery from a failed lock client in the disposable environment.

## SDDM checks before publication

- [ ] Verify Qt modules and fonts are available to the `sddm` account.
- [ ] Verify a real login for the remembered user/session.
- [ ] Verify wrong-password feedback and retry.
- [ ] Confirm the last-user/session limitation is acceptable.
- [ ] Verify TTY rollback restores the previous greeter.
- [ ] Verify available and unavailable power actions.

## Publishing checks

- [ ] Owner confirms the exact skull artwork's redistribution permission and attribution.
- [ ] Owner approves MIT for original contributions and the final README/previews.
- [ ] The public repository exists and matches the reviewed package.
- [ ] Owner reviews the submission and confirms all five required statements.
- [ ] The issue receives its `submission` label and bot validation/baseline reports.

Local submission drafts and preparation reports are kept in the ignored `previews/submission/` directory. Preparation does not publish a repository or open an issue.
