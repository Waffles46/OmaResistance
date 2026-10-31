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
- The packaged service instantiated successfully in a standalone Quickshell process with the real Omarchy imports. No lock was requested; wake, brightness, session-state, and service commands were stubbed for this smoke check.
- Package metadata, documentation links, GIF structure, and all documented shell-command syntax passed local preflight checks.
- The SDDM installation recipe was exercised against a disposable filesystem and correctly refused an existing destination.
- A local-only run of the official marketplace static rules reported no findings and required review for `service-management`. Snapshot reads were served from local Git; this is not a public marketplace validation or approval.

## Isolated integration results

On 2026-10-31, the package was installed through the standard Omarchy CLI from a local Git snapshot into a fresh, separate home/profile. The test used a nested headless compositor, private user/group databases and PAM configuration, synthetic credentials, and no connection to the host display, bus, home, physical input, or KMS devices. System power and brightness actions were disabled in the test environment.

All 13 integration checks passed. This exercises real Wayland session locking and real PAM conversations with a controlled policy; it does not test the user's production password backend, fingerprint hardware, or physical sleep/display devices. See [TEST-RESULTS.json](TEST-RESULTS.json) for source hashes, outcomes, and limits.

The draft's stranded-lock check was restored to Omarchy's upstream `omarchy-hyprland-session-lock-stranded` helper, which defers recovery while another locker is alive. Crash recovery was checked with Omarchy's normal `misc.allow_session_lock_restore = true` setting. The compositor stayed locked after the client was killed; the restarted service re-established the lock and required successful authentication to unlock.

For SDDM, the packaged `Main.qml` matches the existing installed login theme byte for byte. The current boot's SDDM journal records loading that theme and a successful authentication/session start on 2026-10-28, after the matching source was installed. This establishes a real login with that QML on the preparation machine, not a fresh installation or rollback test of the renamed package.

## Real-session checks before publication

Use a disposable Omarchy installation with a working TTY and saved shell configuration. Record versions, dates, and outcomes without recording passwords.

- [x] Install into a clean isolated profile from the local Git snapshot and verify the service/imports load.
- [x] Verify the custom lock is enabled and normal lock calls reach it in that profile.
- [x] Open and dismiss the non-locking visual preview.
- [x] Lock and confirm the compositor establishes a secure session lock.
- [x] Verify a rejected synthetic PAM password keeps the session locked with visible feedback.
- [x] Verify Escape/Ctrl+U clearing and a 200-character password.
- [x] Verify the correct synthetic PAM password unlocks the session.
- [ ] Test an enrolled fingerprint and password fallback, or record fingerprint support as unavailable.
- [ ] Test blank/wake and suspend/resume without revealing the desktop while locked.
- [x] Add a second headless output while locked, preserve secure state, and unlock with both outputs active.
- [ ] Verify physical monitor coverage and hotplug on target hardware.
- [x] Disable/remove while unlocked and restore the built-in lock in the isolated profile.
- [x] Verify recovery from a killed lock client and successful authentication after restart.

## SDDM checks before publication

- [ ] Verify Qt modules and fonts are available to the `sddm` account.
- [x] Confirm a real login on the existing installation using identical `Main.qml` (2026-10-28 journal evidence).
- [ ] Verify a fresh installation of this renamed SDDM package.
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
