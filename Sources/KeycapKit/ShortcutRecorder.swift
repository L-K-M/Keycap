import AppKit
import SwiftUI
import KeycapCore

/// A SwiftUI control that records a global shortcut. Click it, press the
/// desired modifier+key combination, and it reports a new `KeyCombo`. Escape
/// cancels; a bare ⌫/⌦ applies `deleteAction`; a combo that is not a usable
/// global hotkey beeps and keeps recording.
public struct ShortcutRecorder: NSViewRepresentable {

    /// What a bare ⌫/⌦ does while recording.
    public enum DeleteAction: Equatable {
        /// Clears the binding.
        case clear
        /// Restores a specific combo (the app's default).
        case restore(KeyCombo)
        /// Leaves the binding alone and keeps recording.
        case ignore
    }

    @Binding public var combo: KeyCombo?
    public var deleteAction: DeleteAction
    public var placeholder: String
    public var recordingPrompt: String

    public init(combo: Binding<KeyCombo?>,
                deleteAction: DeleteAction = .clear,
                placeholder: String = "Record Shortcut",
                recordingPrompt: String = "Type Shortcut…") {
        self._combo = combo
        self.deleteAction = deleteAction
        self.placeholder = placeholder
        self.recordingPrompt = recordingPrompt
    }

    public func makeNSView(context: Context) -> ShortcutRecorderButton {
        let button = ShortcutRecorderButton()
        let binding = _combo
        button.onChange = { binding.wrappedValue = $0 }
        button.deleteAction = deleteAction
        button.combo = combo
        button.placeholder = placeholder
        button.recordingPrompt = recordingPrompt
        button.isEnabled = context.environment.isEnabled
        return button
    }

    public func updateNSView(_ nsView: ShortcutRecorderButton, context: Context) {
        nsView.combo = combo
        nsView.deleteAction = deleteAction
        nsView.placeholder = placeholder
        nsView.recordingPrompt = recordingPrompt
        // Forward SwiftUI's `.disabled(...)` to the button — an
        // NSViewRepresentable doesn't propagate it automatically, so a
        // switched-off recorder would still record and rewrite the binding
        // despite looking dimmed.
        nsView.isEnabled = context.environment.isEnabled
        nsView.refreshTitle()
    }
}

/// An `NSButton` that, while recording, intercepts the next key event and turns
/// it into a `KeyCombo`.
public final class ShortcutRecorderButton: NSButton {

    /// The pure recording decision for one key press, so the rules can be
    /// tested without a window.
    enum Decision: Equatable {
        /// Escape: stop recording, keep the current combo.
        case cancel
        /// Bare ⌫/⌦: apply the delete action.
        case delete
        /// Not a usable global hotkey: beep and keep recording.
        case reject
        /// A usable combo: commit it.
        case accept(KeyCombo)
    }

    /// The current combo; nil means no shortcut is set.
    var combo: KeyCombo? {
        didSet {
            refreshTitle()
            updateAccessibilityValue()
        }
    }

    var placeholder = "Record Shortcut"
    var recordingPrompt = "Type Shortcut…"
    var deleteAction: ShortcutRecorder.DeleteAction = .clear
    var onChange: ((KeyCombo?) -> Void)?

    private var recording = false {
        didSet { refreshTitle() }
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        bezelStyle = .rounded
        setButtonType(.momentaryPushIn)
        target = self
        action = #selector(beginRecording)
        setAccessibilityLabel("Shortcut")
        refreshTitle()
        updateAccessibilityValue()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var acceptsFirstResponder: Bool { true }

    // MARK: Recording

    @objc private func beginRecording() {
        window?.makeFirstResponder(self)
        recording = true
    }

    /// Focus loss disarms: covers click-away and the current hotkey firing,
    /// which resigns this window's key status.
    override public func resignFirstResponder() -> Bool {
        recording = false
        return super.resignFirstResponder()
    }

    override public func keyDown(with event: NSEvent) {
        guard recording else {
            // Keyboard parity with the click: Space/Return arm the recorder.
            if isArmKey(event) {
                beginRecording()
            } else {
                super.keyDown(with: event)
            }
            return
        }
        let modifiers = HotkeyModifiers(eventFlags: event.modifierFlags)
        apply(Self.decision(for: UInt32(event.keyCode), modifiers: modifiers.rawValue))
    }

    /// Menu key equivalents are dispatched before `keyDown`, so without this
    /// hook recording ⌘Q would trigger a menu item (or quit) instead of being
    /// captured. While recording, every chord belongs to the recorder.
    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        if recording {
            keyDown(with: event)
            return true
        }
        if isArmKey(event) {
            beginRecording()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    /// Live modifier preview while recording — holding ⌃⌥ shows "⌃⌥" until the
    /// key lands.
    override public func flagsChanged(with event: NSEvent) {
        if recording {
            let glyphs = HotkeyModifiers(eventFlags: event.modifierFlags).symbols
            title = glyphs.isEmpty ? recordingPrompt : glyphs
        }
        super.flagsChanged(with: event)
    }

    func refreshTitle() {
        if recording {
            title = recordingPrompt
        } else if let combo {
            title = combo.displayString
        } else {
            title = placeholder
        }
    }

    // MARK: Decision

    /// Classifies a key press made while recording.
    static func decision(for keyCode: UInt32, modifiers: UInt32) -> Decision {
        if keyCode == KeyCode.escape { return .cancel }
        if (keyCode == KeyCode.delete || keyCode == KeyCode.forwardDelete)
            && HotkeyModifiers(carbonFlags: modifiers).isEmpty {
            return .delete
        }
        let combo = KeyCombo(keyCode: keyCode,
                             modifiers: HotkeyModifiers(carbonFlags: modifiers))
        return combo.isUsableGlobalHotkey ? .accept(combo) : .reject
    }

    // MARK: Private

    private func apply(_ decision: Decision) {
        switch decision {
        case .cancel:
            stopRecording()
        case .delete:
            applyDeleteAction()
        case .reject:
            NSSound.beep()
        case .accept(let newCombo):
            combo = newCombo
            onChange?(newCombo)
            stopRecording()
        }
    }

    private func applyDeleteAction() {
        switch deleteAction {
        case .clear:
            combo = nil
            onChange?(nil)
            stopRecording()
        case .restore(let combo):
            self.combo = combo
            onChange?(combo)
            stopRecording()
        case .ignore:
            break
        }
    }

    private func stopRecording() {
        recording = false
        window?.makeFirstResponder(nil)
    }

    private func isArmKey(_ event: NSEvent) -> Bool {
        event.keyCode == UInt16(KeyCode.space)
            || event.keyCode == UInt16(KeyCode.`return`)
    }

    private func updateAccessibilityValue() {
        setAccessibilityValue(combo?.displayString ?? "None")
    }
}
