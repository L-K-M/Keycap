/// A global-hotkey chord: a Carbon virtual key code plus Carbon modifier bits.
///
/// This is the currency Keycap passes around; each app converts its own
/// persisted binding type to and from it. Keycap deliberately has no `Codable`
/// conformance and never touches `UserDefaults`: the persisted format belongs
/// to the app, and a shared `Codable` shape would silently rewrite every saved
/// shortcut if its encoding ever changed.
public struct KeyCombo: Hashable, Sendable {
    public var keyCode: UInt32
    public var modifiers: HotkeyModifiers

    public init(keyCode: UInt32, modifiers: HotkeyModifiers) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    /// The modifier bits `RegisterEventHotKey` consumes.
    public var carbonModifiers: UInt32 {
        modifiers.rawValue
    }

    /// The display string, e.g. `"⌃⌥⌘D"`.
    ///
    /// `separator` sits between the modifier glyphs and the key name; it is
    /// omitted entirely when there are no modifiers, so a bare function key
    /// reads `"F12"` rather than `" F12"`. `keyName` overrides the fixed name,
    /// which is how an app shows a label captured at record time.
    public func displayString(keyName: String? = nil, separator: String = "") -> String {
        let name = keyName
            ?? KeyNames.symbol(for: keyCode)
            ?? KeyNames.fallbackName(for: keyCode)
        guard !modifiers.symbols.isEmpty else { return name }
        return modifiers.symbols + separator + name
    }

    /// Whether the combo carries ⌘, ⌃ or ⌥. Shift alone changes the character
    /// being typed; it does not make that character safe to capture
    /// system-wide.
    public var hasCommandingModifier: Bool {
        !modifiers.intersection(.commanding).isEmpty
    }

    /// Whether the OS owns this combo. Only plain ⌘ and ⇧⌘ combinations are
    /// reserved; adding ⌥ or ⌃ produces a combo the system does not claim.
    /// Registering a reserved combo would swallow it for every app.
    public var isSystemReserved: Bool {
        let fourBits = modifiers.intersection([.command, .shift, .option, .control])
        if fourBits == .command {
            return Self.commandReservedKeys.contains(keyCode)
        }
        if fourBits == [.command, .shift] {
            return Self.commandReservedKeys.contains(keyCode)
                || Self.commandShiftReservedKeys.contains(keyCode)
        }
        return false
    }

    /// Whether the combo makes a usable global hotkey: not system-reserved, and
    /// either carrying a commanding modifier or a bare function key.
    public var isUsableGlobalHotkey: Bool {
        !isSystemReserved && (hasCommandingModifier || KeyCode.isFunctionKey(keyCode))
    }

    /// Keys the OS owns under plain ⌘ or ⇧⌘.
    private static let commandReservedKeys: Set<UInt32> = [
        KeyCode.q,   // ⌘Q quit app · ⇧⌘Q log out
        KeyCode.w,   // ⌘W close window
        KeyCode.h,   // ⌘H hide
        KeyCode.m,   // ⌘M minimize
        KeyCode.space, // ⌘Space Spotlight
        KeyCode.tab, // ⌘Tab app switcher
    ]

    /// Keys the OS owns only together with ⇧⌘: the screenshot shortcuts.
    private static let commandShiftReservedKeys: Set<UInt32> = [
        KeyCode.three, KeyCode.four, KeyCode.five, KeyCode.six,
    ]
}
