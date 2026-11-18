import Carbon.HIToolbox
import XCTest
@testable import KeycapKit

/// The recorder's rules, tested through the pure decision seam so they run
/// without a window. These cover the ported recorder-rule tests: Escape
/// cancels, a bare key is rejected, shift-only is rejected, bare delete is a
/// delete, and a chorded delete is a chord.
final class ShortcutRecorderDecisionTests: XCTestCase {

    func testEscapeCancelsWithOrWithoutModifiers() {
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.escape, modifiers: 0), .cancel)
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.escape, modifiers: 0x0100), .cancel)
    }

    func testBareKeyIsRejected() {
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.a, modifiers: 0), .reject)
    }

    func testShiftOnlyChordIsRejected() {
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.a, modifiers: 0x0200), .reject)
    }

    func testDeleteIsADeleteOnlyWhenBare() {
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.delete, modifiers: 0), .delete)
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.forwardDelete, modifiers: 0), .delete)
    }

    func testModifiedDeleteRecordsAsChord() {
        XCTAssertEqual(
            ShortcutRecorderButton.decision(for: KeyCode.delete, modifiers: 0x0800),
            .accept(KeyCombo(keyCode: KeyCode.delete, modifiers: [.option]))
        )
        XCTAssertEqual(
            ShortcutRecorderButton.decision(for: KeyCode.forwardDelete, modifiers: 0x0100),
            .accept(KeyCombo(keyCode: KeyCode.forwardDelete, modifiers: [.command]))
        )
    }

    func testCommandingChordIsAccepted() {
        XCTAssertEqual(
            ShortcutRecorderButton.decision(for: KeyCode.x, modifiers: 0x0100 | 0x0800),
            .accept(KeyCombo(keyCode: KeyCode.x, modifiers: [.command, .option]))
        )
    }

    func testBareFunctionKeyIsAccepted() {
        XCTAssertEqual(
            ShortcutRecorderButton.decision(for: KeyCode.f12, modifiers: 0),
            .accept(KeyCombo(keyCode: KeyCode.f12, modifiers: []))
        )
    }

    func testSystemReservedChordIsRejected() {
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.q, modifiers: 0x0100), .reject)
        XCTAssertEqual(ShortcutRecorderButton.decision(for: KeyCode.four, modifiers: 0x0100 | 0x0200), .reject)
    }
}
