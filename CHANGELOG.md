# Changelog

## 0.1.1

- `CarbonHotkey` drops a press that Carbon reported before the hotkey was
  unregistered or moved to another combo. The callback runs on a later
  main-queue turn, so a press arriving just as the user cleared or changed a
  binding used to fire the old action anyway. From Top Drawer's open PR #192.
- `ShortcutRecorder` gains an optional `onRecordingChange` callback that
  reports when recording starts and stops, so an app can hide controls such
  as a separate Clear button while the recorder is listening. It is delivered
  on the next main-queue turn so it can update SwiftUI state.

## 0.1.0

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
