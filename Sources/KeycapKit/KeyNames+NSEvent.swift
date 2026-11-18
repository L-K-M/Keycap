import AppKit
import Carbon.HIToolbox
import Foundation
import KeycapCore

extension KeyNames {
    /// The character `keyCode` types on the current keyboard layout,
    /// uppercased, or nil for non-printing keys. Uses
    /// `kUCKeyTranslateNoDeadKeysMask` so a dead-key state is never set.
    public static func layoutName(for keyCode: UInt32) -> String? {
        guard let source = TISCopyCurrentKeyboardLayoutInputSource()?
                .takeRetainedValue(),
              let property = TISGetInputSourceProperty(
                source, kTISPropertyUnicodeKeyLayoutData)
        else { return nil }
        let data = Unmanaged<CFData>.fromOpaque(UnsafeRawPointer(property))
            .takeUnretainedValue()
        guard let bytes = CFDataGetBytePtr(data) else { return nil }
        let layout = UnsafeRawPointer(bytes)
            .assumingMemoryBound(to: UCKeyboardLayout.self)
        var deadKeys: UInt32 = 0
        var length = 0
        var buffer = [UniChar](repeating: 0, count: 4)
        let status = UCKeyTranslate(
            layout, UInt16(keyCode), UInt16(kUCKeyActionDisplay), 0,
            UInt32(LMGetKbdType()),
            OptionBits(UInt32(kUCKeyTranslateNoDeadKeysMask)),
            &deadKeys, buffer.count, &length, &buffer)
        guard status == noErr, length > 0 else { return nil }
        let string = String(utf16CodeUnits: buffer, count: length)
        // Control/whitespace results belong to named keys, not glyphs.
        guard string.rangeOfCharacter(
                from: .whitespacesAndNewlines.union(.controlCharacters)) == nil
        else { return nil }
        return string.uppercased()
    }

    /// The best display name for a key: the fixed symbol for special keys, else
    /// the character the key types on the active layout (a German board's Y
    /// sits at the ANSI Z position — the hotkey records the position, and the
    /// label should name what the user pressed), else the fixed letter/digit
    /// name, else the fallback.
    ///
    /// The fixed table stores letters and digits as single uppercase
    /// characters, so a single-character alphanumeric symbol is the signal that
    /// the layout should name the key.
    public static func displayName(for keyCode: UInt32) -> String {
        if let symbol = symbol(for: keyCode), !isAlphanumericSymbol(symbol) {
            return symbol
        }
        if let layout = layoutName(for: keyCode) { return layout }
        if let symbol = symbol(for: keyCode) { return symbol }
        return fallbackName(for: keyCode)
    }

    private static func isAlphanumericSymbol(_ symbol: String) -> Bool {
        guard let only = symbol.first, symbol.count == 1 else { return false }
        return only.isASCII && (only.isLetter || only.isNumber)
    }

    /// A short label for a recorded key. Keeps the record-time semantics of the
    /// app copies: named special keys use their glyph, everything else uses the
    /// layout-aware display name.
    public static func label(for event: NSEvent) -> String {
        displayName(for: UInt32(event.keyCode))
    }
}
