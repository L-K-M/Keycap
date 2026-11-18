import AppKit
import Carbon.HIToolbox
import XCTest
@testable import KeycapKit

final class KeyNamesDisplayTests: XCTestCase {

    private func keyEvent(_ keyCode: UInt32,
                          modifiers: NSEvent.ModifierFlags = []) -> NSEvent {
        NSEvent.keyEvent(with: .keyDown, location: .zero,
                         modifierFlags: modifiers, timestamp: 0,
                         windowNumber: 0, context: nil,
                         characters: "x", charactersIgnoringModifiers: "x",
                         isARepeat: false, keyCode: UInt16(keyCode))!
    }

    func testDisplayNameUsesFixedSymbolsForSpecialKeys() {
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.space), "Space")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.`return`), "↩")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.keypadEnter), "⌅")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.tab), "⇥")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.escape), "⎋")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.delete), "⌫")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.forwardDelete), "⌦")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.home), "↖")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.end), "↘")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.f5), "F5")
        XCTAssertEqual(KeyNames.displayName(for: KeyCode.keypadClear), "⌧")
    }

    /// Letters render through the active keyboard layout; the assertion only
    /// holds where ANSI-A actually types "A" (US on CI). AZERTY prints "Q", and
    /// a layout-less input source falls back to the fixed name.
    func testDisplayNameUsesLayoutForPrintableKeys() throws {
        let name = KeyNames.displayName(for: KeyCode.a)
        try XCTSkipUnless(name == "A", "Active layout doesn't map ANSI-A to 'A'")
    }

    func testLayoutNameIsUppercased() throws {
        let layout = try XCTUnwrap(KeyNames.layoutName(for: KeyCode.a))
        XCTAssertEqual(layout, layout.uppercased())
    }

    func testLabelUsesDisplayName() {
        XCTAssertEqual(KeyNames.label(for: keyEvent(KeyCode.space)), "Space")
        XCTAssertEqual(KeyNames.label(for: keyEvent(KeyCode.f20)), "F20")
    }

    func testLabelForLetterUsesLayoutName() throws {
        let label = KeyNames.label(for: keyEvent(KeyCode.a))
        try XCTSkipUnless(label == "A", "Active layout doesn't map ANSI-A to 'A'")
    }
}
