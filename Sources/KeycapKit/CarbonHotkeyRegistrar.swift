import Carbon.HIToolbox
import Dispatch
import Foundation
import KeycapCore

/// macOS global-hotkey registrar backed by Carbon (`CarbonHotkey`). It owns the
/// live `CarbonHotkey` instances — keyed by the monotonic id it stamps into each
/// `HotkeyToken` — and needs no Accessibility permission.
///
/// The id counter is the ownership model Top Drawer settled on: one registration
/// per token, one token per live hotkey, so a tab or controller can release
/// exactly what it registered.
public final class CarbonHotkeyRegistrar: GlobalHotkeyRegistering {

    private var registrations: [UInt32: CarbonHotkey] = [:]
    private var counter: UInt32 = 1
    private let signature: OSType

    /// - Parameter signature: the app's existing four-character Carbon
    ///   signature. It must stay per app so two apps using the same id do not
    ///   claim the same event.
    public init(signature: OSType) {
        self.signature = signature
    }

    public func register(_ combo: KeyCombo, onPressed: @escaping () -> Void) -> HotkeyToken? {
        // Enforces the protocol's main-thread contract: `registrations` and
        // `counter` are unsynchronized and Carbon registration is
        // main-event-loop oriented.
        dispatchPrecondition(condition: .onQueue(.main))
        let id = counter
        counter += 1
        let hotkey = CarbonHotkey(identifier: id, signature: signature)
        hotkey.onPressed = onPressed
        guard hotkey.register(combo).isRegistered else { return nil }
        registrations[id] = hotkey
        return HotkeyToken(id: id)
    }

    public func unregister(_ token: HotkeyToken) {
        dispatchPrecondition(condition: .onQueue(.main))
        registrations.removeValue(forKey: token.id)?.unregister()
    }
}
