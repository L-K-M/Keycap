/// Carbon modifier bits for `RegisterEventHotKey`, spelled as literals.
///
/// These numbers are a persisted storage format: apps store them in their own
/// binding types, so a value must never change. They are literals rather than
/// `cmdKey`-derived so this file compiles on Linux, where Carbon does not
/// exist. The KeycapKit tests assert each literal against its Carbon symbol.
public struct HotkeyModifiers: OptionSet, Hashable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Keeps only the four bits Keycap models. Cocoa flags such as caps lock
    /// and function are not part of a Carbon hotkey.
    public init(carbonFlags: UInt32) {
        let mask = HotkeyModifiers.command.rawValue
            | HotkeyModifiers.shift.rawValue
            | HotkeyModifiers.option.rawValue
            | HotkeyModifiers.control.rawValue
        self.init(rawValue: carbonFlags & mask)
    }

    public static let command = HotkeyModifiers(rawValue: 0x0100)
    public static let shift = HotkeyModifiers(rawValue: 0x0200)
    public static let option = HotkeyModifiers(rawValue: 0x0800)
    public static let control = HotkeyModifiers(rawValue: 0x1000)

    /// ⌘, ⌃ and ⌥: the modifiers that turn a chord into a shortcut rather than
    /// text. Shift alone only changes the character being typed.
    public static let commanding: HotkeyModifiers = [.command, .option, .control]

    /// The modifier glyphs in canonical macOS menu order, ⌃⌥⇧⌘.
    public var symbols: String {
        var result = ""
        if contains(.control) { result += "⌃" }
        if contains(.option) { result += "⌥" }
        if contains(.shift) { result += "⇧" }
        if contains(.command) { result += "⌘" }
        return result
    }
}
