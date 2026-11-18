import AppKit
import Carbon.HIToolbox
import XCTest
@testable import KeycapKit

final class HotkeyModifiersNSEventTests: XCTestCase {

    func testCarbonModifiersMapping() {
        let mods = HotkeyModifiers(eventFlags: [.command, .shift])
        XCTAssertEqual(mods.rawValue & UInt32(cmdKey), UInt32(cmdKey))
        XCTAssertEqual(mods.rawValue & UInt32(shiftKey), UInt32(shiftKey))
        XCTAssertEqual(mods.rawValue & UInt32(controlKey), 0)
    }

    func testEventFlagsRoundTrip() {
        let all: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
        XCTAssertEqual(HotkeyModifiers(eventFlags: all).eventFlags, all)
        XCTAssertEqual(HotkeyModifiers(eventFlags: [.command, .shift]).eventFlags,
                       [.command, .shift])
        XCTAssertEqual(HotkeyModifiers(eventFlags: []).eventFlags, [])
    }

    func testCocoaOnlyFlagsAreDropped() {
        // Caps lock and function are not part of a Carbon hotkey.
        XCTAssertEqual(HotkeyModifiers(eventFlags: [.capsLock, .function]).eventFlags, [])
        XCTAssertEqual(HotkeyModifiers(eventFlags: [.command, .capsLock]).eventFlags, [.command])
    }
}
