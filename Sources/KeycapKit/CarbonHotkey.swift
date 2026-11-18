import AppKit
import Carbon.HIToolbox
import Dispatch
import Foundation
import os
import KeycapCore

/// A global hotkey registered via Carbon's `RegisterEventHotKey`.
///
/// Carbon hotkeys need no Accessibility permission, unlike a `CGEventTap`. They
/// report key-down only — no modifier-release observation — which is all a
/// launcher-style trigger needs. `Sendable` is asserted: registration, teardown
/// and `onPressed` are all main-thread confined (the Carbon handler fires on the
/// main run loop).
///
/// The four-character `signature` plus `identifier` is how this hotkey's
/// handler recognises its own events among the other handlers installed on the
/// same application event target. It does not make a hotkey private: another
/// app that registers the same chord is notified too. Each app passes the
/// constant it already used so nothing changes for it.
public final class CarbonHotkey: @unchecked Sendable {

    /// Signature for a new consumer that has no existing Carbon constant.
    public static let defaultSignature: OSType = 0x4B43_4150 // 'KCAP'

    /// Invoked on the main thread when the hotkey fires.
    public var onPressed: (() -> Void)?

    private let identifier: UInt32
    private let signature: OSType
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    /// Advances whenever a registration ends (unregister, re-register or a
    /// failed register). A press is delivered only if the counter has not moved
    /// since Carbon reported it; see `handleHotkeyEvent(_:)`.
    private var registrationGeneration: UInt64 = 0
    private let logger: Logger

    public init(identifier: UInt32, signature: OSType = CarbonHotkey.defaultSignature) {
        self.identifier = identifier
        self.signature = signature
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "Keycap",
            category: "hotkey"
        )
    }

    // No main-thread precondition here: the last reference can be dropped on
    // any thread, and trapping in deinit would crash a release build. Carbon's
    // remove calls are safe to make once nothing else can reach this object.
    deinit { teardown() }

    /// Handles a `kEventHotKeyPressed` event delivered to the installed handler.
    ///
    /// Several handlers can share `GetApplicationEventTarget()`, and Carbon stops
    /// the handler chain at the first one that returns `noErr`. This must
    /// therefore refuse foreign events: a nil event, a missing or malformed
    /// `kEventParamDirectObject` hotkey ID, or a signature/ID that is not this
    /// hotkey's returns `eventNotHandledErr`. Only a matching event schedules
    /// `onPressed` on the main queue and returns `noErr`.
    ///
    /// The callback runs on a later main-queue turn, so the app can unregister
    /// (or move the hotkey to another combo) in between. Such a press belongs
    /// to a registration that no longer exists and is dropped, rather than
    /// firing an action the user has just switched off.
    func handleHotkeyEvent(_ event: EventRef?) -> OSStatus {
        guard let event else { return OSStatus(eventNotHandledErr) }

        var pressedID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &pressedID
        )
        guard status == noErr else { return OSStatus(eventNotHandledErr) }

        guard pressedID.signature == signature, pressedID.id == identifier else {
            return OSStatus(eventNotHandledErr)
        }

        let pressGeneration = registrationGeneration
        DispatchQueue.main.async { [self] in
            guard registrationGeneration == pressGeneration else { return }
            onPressed?()
        }
        return noErr
    }

    /// Registers the combo, replacing any previous registration.
    @discardableResult
    public func register(_ combo: KeyCombo) -> HotkeyRegistrationResult {
        register(keyCode: combo.keyCode, modifiers: combo.carbonModifiers)
    }

    /// Registers a key code and Carbon modifier mask, replacing any previous
    /// registration.
    @discardableResult
    public func register(keyCode: UInt32, modifiers: UInt32) -> HotkeyRegistrationResult {
        dispatchPrecondition(condition: .onQueue(.main))
        unregister()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerCallback: EventHandlerUPP = { _, event, userData in
            guard let userData else { return OSStatus(eventNotHandledErr) }
            let me = Unmanaged<CarbonHotkey>.fromOpaque(userData).takeUnretainedValue()
            return me.handleHotkeyEvent(event)
        }

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            handlerCallback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        guard installStatus == noErr else {
            // Roll back unconditionally so a failed registration cannot leave a
            // dangling event handler behind.
            unregister()
            logger.error("failed to install hotkey event handler \(self.identifier, privacy: .public): status \(installStatus, privacy: .public)")
            return .failed(installStatus)
        }

        let hotKeyID = EventHotKeyID(signature: signature, id: identifier)
        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard registerStatus == noErr else {
            // Roll back the installed handler so a failed registration doesn't
            // leave a dangling event handler behind.
            unregister()
            logger.error("failed to register Carbon hotkey \(self.identifier, privacy: .public): status \(registerStatus, privacy: .public)")
            return HotkeyRegistrationResult(status: registerStatus)
        }
        return .registered
    }

    /// Releases the hotkey and removes the event handler. Idempotent.
    public func unregister() {
        dispatchPrecondition(condition: .onQueue(.main))
        teardown()
    }

    private func teardown() {
        registrationGeneration &+= 1
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
}
