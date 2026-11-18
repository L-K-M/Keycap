/// Fixed display names for virtual key codes, plus a readable fallback.
public enum KeyNames {
    /// The fixed name for a key code, or nil when the key has none.
    ///
    /// Letters and digits are named as uppercase characters; special keys use
    /// their macOS glyphs. Keys outside the table (for example `grave`) have no
    /// fixed name and are named by the keyboard layout in KeycapKit.
    public static func symbol(for keyCode: UInt32) -> String? {
        specialNames[keyCode] ?? letterOrDigitName(for: keyCode)
    }

    /// A legible fallback for a key with no fixed or layout name.
    public static func fallbackName(for keyCode: UInt32) -> String {
        "Key \(keyCode)"
    }

    /// The uppercase letter or digit at an ANSI position, or nil.
    static func letterOrDigitName(for keyCode: UInt32) -> String? {
        switch keyCode {
        case KeyCode.a: return "A"
        case KeyCode.b: return "B"
        case KeyCode.c: return "C"
        case KeyCode.d: return "D"
        case KeyCode.e: return "E"
        case KeyCode.f: return "F"
        case KeyCode.g: return "G"
        case KeyCode.h: return "H"
        case KeyCode.i: return "I"
        case KeyCode.j: return "J"
        case KeyCode.k: return "K"
        case KeyCode.l: return "L"
        case KeyCode.m: return "M"
        case KeyCode.n: return "N"
        case KeyCode.o: return "O"
        case KeyCode.p: return "P"
        case KeyCode.q: return "Q"
        case KeyCode.r: return "R"
        case KeyCode.s: return "S"
        case KeyCode.t: return "T"
        case KeyCode.u: return "U"
        case KeyCode.v: return "V"
        case KeyCode.w: return "W"
        case KeyCode.x: return "X"
        case KeyCode.y: return "Y"
        case KeyCode.z: return "Z"
        case KeyCode.zero: return "0"
        case KeyCode.one: return "1"
        case KeyCode.two: return "2"
        case KeyCode.three: return "3"
        case KeyCode.four: return "4"
        case KeyCode.five: return "5"
        case KeyCode.six: return "6"
        case KeyCode.seven: return "7"
        case KeyCode.eight: return "8"
        case KeyCode.nine: return "9"
        default: return nil
        }
    }

    /// Names for keys whose character is not printable or reads ambiguously.
    /// Indexed by Carbon virtual key code.
    private static let specialNames: [UInt32: String] = [
        KeyCode.space: "Space",
        KeyCode.`return`: "↩",
        KeyCode.keypadEnter: "⌅",
        KeyCode.tab: "⇥",
        KeyCode.escape: "⎋",
        KeyCode.delete: "⌫",
        KeyCode.forwardDelete: "⌦",
        KeyCode.leftArrow: "←",
        KeyCode.rightArrow: "→",
        KeyCode.downArrow: "↓",
        KeyCode.upArrow: "↑",
        KeyCode.home: "↖",
        KeyCode.end: "↘",
        KeyCode.pageUp: "⇞",
        KeyCode.pageDown: "⇟",
        KeyCode.help: "Help",
        KeyCode.keypadClear: "⌧",
        KeyCode.f1: "F1", KeyCode.f2: "F2", KeyCode.f3: "F3",
        KeyCode.f4: "F4", KeyCode.f5: "F5", KeyCode.f6: "F6",
        KeyCode.f7: "F7", KeyCode.f8: "F8", KeyCode.f9: "F9",
        KeyCode.f10: "F10", KeyCode.f11: "F11", KeyCode.f12: "F12",
        KeyCode.f13: "F13", KeyCode.f14: "F14", KeyCode.f15: "F15",
        KeyCode.f16: "F16", KeyCode.f17: "F17", KeyCode.f18: "F18",
        KeyCode.f19: "F19", KeyCode.f20: "F20",
    ]
}
