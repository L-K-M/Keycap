import AppKit
import Carbon.HIToolbox
import XCTest
@testable import KeycapKit

final class KeyComboNSEventTests: XCTestCase {

    private func keyEvent(_ keyCode: UInt32,
                          modifiers: NSEvent.ModifierFlags = []) -> NSEvent {
        NSEvent.keyEvent(with: .keyDown, location: .zero,
                         modifierFlags: modifiers, timestamp: 0,
                         windowNumber: 0, context: nil,
                         characters: "x", charactersIgnoringModifiers: "x",
                         isARepeat: false, keyCode: UInt16(keyCode))!
    }

    func testInitFromEventMapsKeyCodeAndModifiers() {
        let combo = KeyCombo(event: keyEvent(KeyCode.tab, modifiers: [.option]))
        XCTAssertEqual(combo.keyCode, KeyCode.tab)
        XCTAssertEqual(combo.modifiers, [.option])
        XCTAssertEqual(combo.carbonModifiers, 0x0800)
    }

    func testDisplayStringUsesLayoutAwareName() {
        let combo = KeyCombo(event: keyEvent(KeyCode.d, modifiers: [.control, .option, .command]))
        XCTAssertEqual(combo.displayString, "⌃⌥⌘D")
        XCTAssertEqual(combo.displayString.hasPrefix("⌃⌥⌘"), true)
    }

    func testDisplayStringForSpace() {
        let combo = KeyCombo(event: keyEvent(KeyCode.space, modifiers: [.option]))
        XCTAssertEqual(combo.displayString, "⌥Space")
    }
}
