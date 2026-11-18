import XCTest
#if canImport(Carbon)
import Carbon.HIToolbox
#endif
import KeycapCore

final class HotkeyModifiersTests: XCTestCase {

    func testModifierSymbolsAreInCanonicalOrder() {
        let all: HotkeyModifiers = [.command, .control, .option, .shift]
        XCTAssertEqual(all.symbols, "⌃⌥⇧⌘")
        XCTAssertEqual(HotkeyModifiers([]).symbols, "")
        XCTAssertEqual(HotkeyModifiers.shift.symbols, "⇧")
    }

    func testCarbonFlagsKeepsOnlyTheFourBits() {
        let flags = HotkeyModifiers(carbonFlags: 0xFFFF_FFFF)
        XCTAssertEqual(flags, [.command, .shift, .option, .control])
        XCTAssertEqual(HotkeyModifiers(carbonFlags: 0x0000_0000), [])
        // Caps lock and function are not part of a Carbon hotkey.
        XCTAssertEqual(HotkeyModifiers(carbonFlags: UInt32(1 << 16)), [])
    }

    func testCommandingIsCommandOptionControl() {
        XCTAssertEqual(HotkeyModifiers.commanding, [.command, .option, .control])
    }

    /// The literals are a persisted storage format, so they must be exactly
    /// Carbon's. Asserted where Carbon exists; Linux cannot compare.
    #if canImport(Carbon)
    func testModifierLiteralsMatchCarbon() {
        XCTAssertEqual(HotkeyModifiers.command.rawValue, UInt32(cmdKey))
        XCTAssertEqual(HotkeyModifiers.shift.rawValue, UInt32(shiftKey))
        XCTAssertEqual(HotkeyModifiers.option.rawValue, UInt32(optionKey))
        XCTAssertEqual(HotkeyModifiers.control.rawValue, UInt32(controlKey))
    }
    #endif
}
