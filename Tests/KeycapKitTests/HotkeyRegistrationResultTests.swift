import Carbon.HIToolbox
import XCTest
@testable import KeycapKit

final class HotkeyRegistrationResultTests: XCTestCase {

    func testClassifiesCarbonStatuses() {
        XCTAssertEqual(HotkeyRegistrationResult(status: noErr), .registered)
        XCTAssertEqual(HotkeyRegistrationResult(status: OSStatus(eventHotKeyExistsErr)), .alreadyTaken)
        XCTAssertEqual(HotkeyRegistrationResult(status: OSStatus(eventInternalErr)), .refusedBySystem)
        XCTAssertEqual(HotkeyRegistrationResult(status: -1), .failed(-1))
    }

    func testIsRegistered() {
        XCTAssertTrue(HotkeyRegistrationResult.registered.isRegistered)
        XCTAssertFalse(HotkeyRegistrationResult.alreadyTaken.isRegistered)
        XCTAssertFalse(HotkeyRegistrationResult.refusedBySystem.isRegistered)
        XCTAssertFalse(HotkeyRegistrationResult.failed(-1).isRegistered)
    }

    func testFailureDescription() {
        XCTAssertNil(HotkeyRegistrationResult.registered.failureDescription)
        XCTAssertEqual(HotkeyRegistrationResult.alreadyTaken.failureDescription,
                       "Another app is already using this shortcut.")
        XCTAssertNotNil(HotkeyRegistrationResult.refusedBySystem.failureDescription)
        XCTAssertNotNil(HotkeyRegistrationResult.failed(-1).failureDescription)
    }
}
