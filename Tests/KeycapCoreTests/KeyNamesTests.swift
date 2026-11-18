import XCTest
import KeycapCore

final class KeyNamesTests: XCTestCase {

    func testSymbolNamesSpecialKeys() {
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.space), "Space")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.`return`), "↩")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.keypadEnter), "⌅")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.tab), "⇥")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.escape), "⎋")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.delete), "⌫")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.forwardDelete), "⌦")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.leftArrow), "←")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.rightArrow), "→")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.downArrow), "↓")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.upArrow), "↑")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.home), "↖")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.end), "↘")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.pageUp), "⇞")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.pageDown), "⇟")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.help), "Help")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.keypadClear), "⌧")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.f1), "F1")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.f20), "F20")
    }

    func testSymbolNamesLettersAndDigitsAsUppercase() {
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.a), "A")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.z), "Z")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.zero), "0")
        XCTAssertEqual(KeyNames.symbol(for: KeyCode.nine), "9")
    }

    func testSymbolIsNilForKeysWithoutAFixedName() {
        // Grave has no fixed glyph name; the layout names it in KeycapKit.
        XCTAssertNil(KeyNames.symbol(for: KeyCode.grave))
        XCTAssertNil(KeyNames.symbol(for: 500))
    }

    func testFallbackName() {
        XCTAssertEqual(KeyNames.fallbackName(for: 500), "Key 500")
        XCTAssertEqual(KeyNames.fallbackName(for: 0), "Key 0")
    }
}
