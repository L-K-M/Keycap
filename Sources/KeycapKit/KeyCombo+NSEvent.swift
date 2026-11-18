import AppKit
import Foundation
import KeycapCore

extension KeyCombo {
    /// Builds a combo from a recorded key event.
    public init(event: NSEvent) {
        self.init(
            keyCode: UInt32(event.keyCode),
            modifiers: HotkeyModifiers(eventFlags: event.modifierFlags)
        )
    }

    /// The display string using the layout-aware name for the key.
    public var displayString: String {
        displayString(keyName: KeyNames.displayName(for: keyCode))
    }
}
