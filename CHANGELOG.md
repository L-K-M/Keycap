# Changelog

## Unreleased

- `KeycapCore`: new Foundation-only target. `KeyCombo`, `KeyNames`, `KeyCode`
  and `HotkeyModifiers` come from Invoque's `HotkeyCombination`, Top Drawer's
  `KeyCodes`/`HotkeySpec` and Jetty's `KeyCodes` literals. The usability rules
  adopt Top Drawer's open PR #163 (⌘Q-style system shortcuts refused) and
  Vervellum's `cc1a297` (shift-only refused), keeping Top Drawer's function-key
  exception.
- `CarbonHotkey`: from Zap's post-fix `CarbonHotkey` (commit `6092eb6`), with
  the fixed handler that returns `eventNotHandledErr` for foreign events, the
  unconditional rollback on failure, and Invoque's install-failure logging.
  Adds a classified `HotkeyRegistrationResult` (`eventHotKeyExistsErr` and
  `eventInternalErr`) where Zap, Jetty, Gans and Top Drawer returned a bare
  `Bool`.
- `GlobalHotkeyRegistering`, `HotkeyToken`, `CarbonHotkeyRegistrar`: from Top
  Drawer's `GlobalHotkeyRegistering`. The registrar owns instances, mints ids
  from 1, and treats an unknown token as a no-op.
- `ShortcutRecorder` and `ShortcutRecorderButton`: from Jetty/Vervellum's
  `HotkeyRecorder` NSButton, plus Gans's `88ff76e` key-equivalent
  interception, Invoque's Delete handling and live modifier preview, and the
  shared usability rule. Adds `DeleteAction` for the bare-⌫/⌦ policy.
- `AccessibilityAuthorizer`: from Invoque's copy, carrying `hasPrompted` and
  the modern Privacy & Security URL with a fallback to the legacy pane.
- Package scaffolding: SwiftPM manifest with Linux-only Core targets,
  Linux-safe `scripts/build.sh` and `scripts/release.sh`, CI and release
  workflows, README and tests.
