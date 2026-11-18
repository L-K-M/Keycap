/// Carbon virtual key codes, spelled as literals.
///
/// Apps persist these numbers, so they are a storage format: never change a
/// value. Literals keep the file compilable on Linux; the KeycapKit tests pin
/// each one to its `kVK_*` symbol. ANSI letters and digits are physical key
/// positions, not characters: the label shown to the user comes from the
/// keyboard layout at record time (see `KeyNames`).
public enum KeyCode {
    // MARK: ANSI letters and digits (physical positions)

    public static let a: UInt32 = 0x00
    public static let s: UInt32 = 0x01
    public static let d: UInt32 = 0x02
    public static let f: UInt32 = 0x03
    public static let h: UInt32 = 0x04
    public static let g: UInt32 = 0x05
    public static let z: UInt32 = 0x06
    public static let x: UInt32 = 0x07
    public static let c: UInt32 = 0x08
    public static let v: UInt32 = 0x09
    public static let b: UInt32 = 0x0B
    public static let q: UInt32 = 0x0C
    public static let w: UInt32 = 0x0D
    public static let e: UInt32 = 0x0E
    public static let r: UInt32 = 0x0F
    public static let y: UInt32 = 0x10
    public static let t: UInt32 = 0x11
    public static let one: UInt32 = 0x12
    public static let two: UInt32 = 0x13
    public static let three: UInt32 = 0x14
    public static let four: UInt32 = 0x15
    public static let six: UInt32 = 0x16
    public static let five: UInt32 = 0x17
    public static let seven: UInt32 = 0x1A
    public static let eight: UInt32 = 0x1C
    public static let nine: UInt32 = 0x19
    public static let zero: UInt32 = 0x1D
    public static let o: UInt32 = 0x1F
    public static let u: UInt32 = 0x20
    public static let i: UInt32 = 0x22
    public static let p: UInt32 = 0x23
    public static let l: UInt32 = 0x25
    public static let j: UInt32 = 0x26
    public static let k: UInt32 = 0x28
    public static let n: UInt32 = 0x2D
    public static let m: UInt32 = 0x2E

    // MARK: Layout-independent keys

    public static let `return`: UInt32 = 0x24
    public static let tab: UInt32 = 0x30
    public static let space: UInt32 = 0x31
    public static let grave: UInt32 = 0x32
    public static let delete: UInt32 = 0x33
    public static let escape: UInt32 = 0x35
    public static let keypadClear: UInt32 = 0x47
    public static let keypadEnter: UInt32 = 0x4C
    public static let help: UInt32 = 0x72
    public static let home: UInt32 = 0x73
    public static let pageUp: UInt32 = 0x74
    public static let forwardDelete: UInt32 = 0x75
    public static let end: UInt32 = 0x77
    public static let pageDown: UInt32 = 0x79
    public static let leftArrow: UInt32 = 0x7B
    public static let rightArrow: UInt32 = 0x7C
    public static let downArrow: UInt32 = 0x7D
    public static let upArrow: UInt32 = 0x7E

    // MARK: Function keys

    public static let f1: UInt32 = 0x7A
    public static let f2: UInt32 = 0x78
    public static let f3: UInt32 = 0x63
    public static let f4: UInt32 = 0x76
    public static let f5: UInt32 = 0x60
    public static let f6: UInt32 = 0x61
    public static let f7: UInt32 = 0x62
    public static let f8: UInt32 = 0x64
    public static let f9: UInt32 = 0x65
    public static let f10: UInt32 = 0x6D
    public static let f11: UInt32 = 0x67
    public static let f12: UInt32 = 0x6F
    public static let f13: UInt32 = 0x69
    public static let f14: UInt32 = 0x6B
    public static let f15: UInt32 = 0x71
    public static let f16: UInt32 = 0x6A
    public static let f17: UInt32 = 0x40
    public static let f18: UInt32 = 0x4F
    public static let f19: UInt32 = 0x50
    public static let f20: UInt32 = 0x5A

    /// Function keys don't collide with typing, so they make fine global
    /// hotkeys even without a modifier (the classic launcher convention).
    public static func isFunctionKey(_ keyCode: UInt32) -> Bool {
        functionKeys.contains(keyCode)
    }

    private static let functionKeys: Set<UInt32> = [
        f1, f2, f3, f4, f5, f6, f7, f8, f9, f10,
        f11, f12, f13, f14, f15, f16, f17, f18, f19, f20,
    ]
}
