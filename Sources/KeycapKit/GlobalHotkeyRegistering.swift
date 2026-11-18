import Foundation
import KeycapCore

/// The global-hotkey seam: register and unregister a system-wide hotkey by
/// `KeyCombo`. macOS backs this with Carbon's `RegisterEventHotKey`
/// (`CarbonHotkeyRegistrar`); a platform without a global-hotkey backend has no
/// conformer, so nothing on that platform registers a hotkey.
///
/// Threading: `register` and `unregister` must be called on the main thread.
/// Carbon is main-event-loop oriented and the registrar keeps unsynchronized
/// state.
public protocol GlobalHotkeyRegistering {
    /// Attempts to register `combo` as a global hotkey that invokes `onPressed`
    /// on the main thread. Returns an opaque token on success (pass it to
    /// `unregister`), or nil if the platform refused the registration — a
    /// system-reserved combination, one another app already owns, or (on a
    /// platform with no hotkey backend) always.
    func register(_ combo: KeyCombo, onPressed: @escaping () -> Void) -> HotkeyToken?

    /// Releases a token previously returned by `register`. An unknown token is
    /// a no-op.
    func unregister(_ token: HotkeyToken)
}

/// An opaque handle to one live global-hotkey registration. The caller stores
/// it and passes it back to `unregister`; only the registrar that issued it
/// interprets the underlying value. `id` is module-internal so a registrar
/// defined in another file can mint and read its own tokens; it stays
/// non-public, so the handle remains opaque outside the module.
public struct HotkeyToken: Hashable {
    let id: UInt32
}
