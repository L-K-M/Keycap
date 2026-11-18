# Keycap

Global hotkeys for macOS apps: Carbon registration, key-combo model, display strings and the shortcut recorder, shared by the L-K-M apps.

Released into the public domain; see `LICENSE`.

## Consumers

| App | Keycap components |
|---|---|
| Zap | `CarbonHotkey`, `AccessibilityAuthorizer` |
| Jetty | `KeyCombo` model, `CarbonHotkey`, `ShortcutRecorder` |
| Gans | `KeyCombo` model, `CarbonHotkey`, `ShortcutRecorder` |
| Top Drawer | `KeyCombo` model, `CarbonHotkeyRegistrar`, `ShortcutRecorder` |
| Invoque | `KeyCombo` model, `CarbonHotkey`, `AccessibilityAuthorizer`; keeps its own recorder UI |
| Vervellum | `KeyCombo` model, `CarbonHotkey`, `ShortcutRecorder`; macOS app only |

Every app keeps its own persisted binding type (`HotkeyBinding`,
`HotkeyCombination`, `HotkeySpec`) and its `UserDefaults` keys, and converts to
and from `KeyCombo`. Keycap has no `Codable` types and never touches
`UserDefaults`. Each app also passes its existing four-character Carbon
signature (`ZAPH`, `JETY`, `GANS`, `MDRH`, `INVQ`, `VRVL`) so the wire format
does not change.

## API overview

`KeycapCore` (Foundation only, builds on Linux):

- `KeyCombo` — a key code plus `HotkeyModifiers`, with display strings and the
  `isUsableGlobalHotkey` / `isSystemReserved` rules.
- `HotkeyModifiers` — Carbon modifier bits as literals, with `symbols` in menu
  order and `init(carbonFlags:)`.
- `KeyCode` — Carbon virtual key codes as literals, with `isFunctionKey`.
- `KeyNames` — fixed key names and the `"Key N"` fallback.

`KeycapKit` (AppKit + Carbon + SwiftUI, re-exports KeycapCore):

- `CarbonHotkey` — register one hotkey; returns a `HotkeyRegistrationResult`.
- `GlobalHotkeyRegistering`, `HotkeyToken`, `CarbonHotkeyRegistrar` — own
  several hotkeys and mint opaque tokens.
- `ShortcutRecorder` / `ShortcutRecorderButton` — click-to-record control.
- `AccessibilityAuthorizer` — Accessibility trust, prompt and Settings pane.
- `NSEvent` conversions for `KeyCombo`, `HotkeyModifiers` and `KeyNames`.

### Registering a combo

```swift
import KeycapKit

let hotkey = CarbonHotkey(identifier: 1, signature: 0x5A41_5048) // 'ZAPH'
hotkey.onPressed = { activate() }
let result = hotkey.register(KeyCombo(keyCode: KeyCode.tab, modifiers: [.option]))
if !result.isRegistered {
    print(result.failureDescription ?? "unavailable")
}
```

### Recording a combo in SwiftUI

```swift
import KeycapKit
import SwiftUI

struct ShortcutsSettings: View {
    @Binding var combo: KeyCombo?

    var body: some View {
        ShortcutRecorder(combo: $combo)
    }
}
```

To react while the recorder is listening, for example to hide a separate
Clear button that would otherwise take the next click, pass
`onRecordingChange`. It runs on the main queue on the turn after each
change, in order:

```swift
struct ShortcutsSettings: View {
    @Binding var combo: KeyCombo?
    @State private var isRecording = false

    var body: some View {
        HStack {
            ShortcutRecorder(combo: $combo,
                             onRecordingChange: { isRecording = $0 })
            if combo != nil && !isRecording {
                Button("Clear") { combo = nil }
            }
        }
    }
}
```

With an app-owned persisted type, convert at the boundary:

```swift
struct ShortcutsSettings: View {
    @AppStorage("summonHotkey") private var stored: Data?

    var body: some View {
        ShortcutRecorder(combo: Binding(
            get: { stored.flatMap { try? JSONDecoder().decode(MyHotkey.self, from: $0)?.combo } },
            set: { stored = $0.flatMap { try? JSONEncoder().encode(MyHotkey(combo: $0)) } }
        ))
    }
}
```

## Behaviour changes when an app adopts Keycap

Shared rules, every app:

- `KeyCombo.isUsableGlobalHotkey` refuses the OS-owned ⌘Q, ⌘W, ⌘H, ⌘M,
  ⌘Space, ⌘Tab and ⇧⌘3–6, so a registration can no longer swallow them. The
  shared `ShortcutRecorder` enforces the rule; Invoque keeps its own recorder UI
  and gets the same refusal by calling `isUsableGlobalHotkey`.
- Shift-only chords are refused: ⇧A collides with typing a capital "A".
  Bare function keys (F1–F20) stay usable without a modifier.

Zap:

- No change to hotkey dispatch; Zap already carries the fixed handler. Its
  `AccessibilityAuthorizer.openSystemSettings()` now opens the modern
  Privacy & Security pane and falls back to the legacy URL (the Zap copy
  force-unwrapped the old URL).

Jetty:

- Both hotkeys fire again. Jetty's copy returns `noErr` for every hot-key
  press, and Carbon stops at the first handler that returns `noErr`, so only
  the last-registered hotkey ever fired. Keycap's handler returns
  `eventNotHandledErr` for events it does not own.
- Shift-only shortcuts are refused by the recorder (Jetty accepted any non-zero
  modifier mask).
- Registration failures are classified as `HotkeyRegistrationResult` instead
  of a bare `Bool`; Jetty's own UI policy decides what to show.

Gans:

- Failed registrations roll back the installed event handler; Gans's copy left
  a live handler behind when `RegisterEventHotKey` failed.
- Shift-only shortcuts are refused by the recorder.
- The recorder gains a live modifier preview and bare ⌫/⌦ delete handling, and
  keeps intercepting menu-equivalent chords.

Top Drawer:

- The recorder now captures chords that are menu key equivalents. Top Drawer's
  pure-SwiftUI local monitor cannot intercept key equivalents; the shared
  `NSButton` overrides `performKeyEquivalent` while recording.
- The reserved-combo rule from Top Drawer's own open PR moves into the shared
  model; the function-key exception and the shift-only refusal are unchanged.
- The registrar becomes the shared `CarbonHotkeyRegistrar`; Top Drawer keeps
  `HotkeyRegistrationPolicy`, its tab reconciliation and its `HotkeySpec`
  document format.

Invoque:

- Keeps its own recorder UI; its persisted `HotkeyCombination` maps to
  `KeyCombo` (`keyCode`, `modifiers`) without a format change.
- Registration failures are classified and rolled back (Invoque already rolled
  back).
- `AccessibilityAuthorizer` keeps `hasPrompted` and the modern Settings URL.

Vervellum:

- ⌘ or ⇧⌘ with Q, W, H, M, Space or Tab, and ⇧⌘3–6, are refused; Vervellum
  accepted any shortcut with ⌘, ⌃ or ⌥. A refused shortcut saved earlier is
  not registered, and Settings ▸ Shortcuts says why.
- Bare function keys (F1–F20) are accepted; Vervellum's recorder beeped.
- Escape cancels recording even with modifiers held (Vervellum recorded ⌘Esc
  as a shortcut), Space or Return starts recording when the recorder has
  focus, and held modifiers show while recording.
- Bare ⌫ still leaves the shortcut alone and keeps recording
  (`deleteAction: .ignore`): every Vervellum shortcut has a key, and its
  Enabled toggle turns it off.
- The recorder names keypad Enter `⌅`, function keys `F1`–`F20`, Help and
  keypad Clear `⌧`, and a newly recorded shortcut stores those names. The
  panel's hint shows the stored name, so a shortcut saved earlier with
  Vervellum's old `↩` or `Key <code>` keeps it there until it is recorded
  again.
- The recorder gains a VoiceOver label and value.
- Registration keeps Vervellum's two `CarbonHotkey` instances (identifiers 1
  and 2) and its `UserDefaults` JSON; only the macOS app links Keycap, and the
  Linux build is unchanged.
