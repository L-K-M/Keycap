import XCTest
import KeycapCore

final class KeyComboTests: XCTestCase {

    // MARK: Display

    func testDisplayStringConcatenatesModifiersAndKey() {
        let combo = KeyCombo(keyCode: KeyCode.d, modifiers: [.control, .option, .command])
        XCTAssertEqual(combo.displayString(), "⌃⌥⌘D")
        XCTAssertEqual(combo.displayString(separator: " "), "⌃⌥⌘ D")
    }

    func testDisplayStringForBareFunctionKey() {
        let combo = KeyCombo(keyCode: KeyCode.f12, modifiers: [])
        XCTAssertEqual(combo.displayString(), "F12")
        XCTAssertEqual(combo.displayString(separator: " "), "F12")
    }

    func testDisplayStringUsesCustomKeyName() {
        let combo = KeyCombo(keyCode: KeyCode.space, modifiers: [.option])
        XCTAssertEqual(combo.displayString(keyName: "Leertaste"), "⌥Leertaste")
    }

    func testDisplayStringFallsBackForUnknownKeyCode() {
        let combo = KeyCombo(keyCode: 500, modifiers: [.command])
        XCTAssertEqual(combo.displayString(), "⌘Key 500")
    }

    func testDisplayStringForLetterUsesFixedUppercaseName() {
        let combo = KeyCombo(keyCode: KeyCode.a, modifiers: [.option])
        XCTAssertEqual(combo.displayString(), "⌥A")
    }

    // MARK: Commanding modifiers

    func testCommandOptionControlAreCommanding() {
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.a, modifiers: [.command]).hasCommandingModifier)
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.a, modifiers: [.option]).hasCommandingModifier)
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.a, modifiers: [.control]).hasCommandingModifier)
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.a, modifiers: [.command, .shift]).hasCommandingModifier)
    }

    func testShiftAloneIsNotCommanding() {
        XCTAssertFalse(KeyCombo(keyCode: KeyCode.a, modifiers: [.shift]).hasCommandingModifier)
        XCTAssertFalse(KeyCombo(keyCode: KeyCode.a, modifiers: []).hasCommandingModifier)
    }

    // MARK: Usable hotkeys

    func testShiftOnlyLetterIsNotAUsableHotkey() {
        // ⇧A would swallow every typed capital "A" system-wide.
        XCTAssertFalse(KeyCombo(keyCode: KeyCode.a, modifiers: [.shift]).isUsableGlobalHotkey)
    }

    func testBareLetterIsNotAUsableHotkey() {
        XCTAssertFalse(KeyCombo(keyCode: KeyCode.a, modifiers: []).isUsableGlobalHotkey)
    }

    func testCommandLetterIsUsable() {
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.a, modifiers: [.command, .shift]).isUsableGlobalHotkey)
    }

    func testBareFunctionKeysAreUsable() {
        for key in [KeyCode.f1, KeyCode.f12, KeyCode.f20] {
            XCTAssertTrue(KeyCombo(keyCode: key, modifiers: []).isUsableGlobalHotkey)
        }
    }

    func testShiftedFunctionKeyIsUsable() {
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.f5, modifiers: [.shift]).isUsableGlobalHotkey)
    }

    // MARK: System-reserved combos

    func testSystemQuitCloseHideMinimizeAreNotUsable() {
        for key in [KeyCode.q, KeyCode.w, KeyCode.h, KeyCode.m] {
            XCTAssertTrue(KeyCombo(keyCode: key, modifiers: [.command]).isSystemReserved)
            XCTAssertFalse(KeyCombo(keyCode: key, modifiers: [.command]).isUsableGlobalHotkey)
            XCTAssertTrue(KeyCombo(keyCode: key, modifiers: [.command, .shift]).isSystemReserved)
            XCTAssertFalse(KeyCombo(keyCode: key, modifiers: [.command, .shift]).isUsableGlobalHotkey)
        }
    }

    func testSpotlightAndAppSwitcherAreNotUsable() {
        XCTAssertFalse(KeyCombo(keyCode: KeyCode.space, modifiers: [.command]).isUsableGlobalHotkey)
        XCTAssertFalse(KeyCombo(keyCode: KeyCode.tab, modifiers: [.command]).isUsableGlobalHotkey)
    }

    func testScreenshotCombosAreNotUsable() {
        for key in [KeyCode.three, KeyCode.four, KeyCode.five, KeyCode.six] {
            XCTAssertFalse(KeyCombo(keyCode: key, modifiers: [.command, .shift]).isUsableGlobalHotkey)
        }
        // Plain ⌘3/⌘4 aren't screenshot shortcuts — the system doesn't claim them.
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.three, modifiers: [.command]).isUsableGlobalHotkey)
    }

    func testReservedKeyWithExtraModifierStaysUsable() {
        // ⌘⌥Q / ⌘⌃W aren't system shortcuts — refusing them would over-block.
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.q, modifiers: [.command, .option]).isUsableGlobalHotkey)
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.w, modifiers: [.command, .control]).isUsableGlobalHotkey)
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.q, modifiers: [.command, .option, .shift]).isUsableGlobalHotkey)
    }

    func testNeighbourOfReservedKeyIsStillUsable() {
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.e, modifiers: [.command]).isUsableGlobalHotkey)
        XCTAssertTrue(KeyCombo(keyCode: KeyCode.two, modifiers: [.command, .shift]).isUsableGlobalHotkey)
    }

    func testCarbonModifiersRoundTrip() {
        let modifiers = HotkeyModifiers([.command, .option, .control])
        let combo = KeyCombo(keyCode: KeyCode.space, modifiers: modifiers)
        XCTAssertEqual(combo.carbonModifiers, 0x0100 | 0x0800 | 0x1000)
        XCTAssertEqual(HotkeyModifiers(carbonFlags: combo.carbonModifiers), modifiers)
    }
}
