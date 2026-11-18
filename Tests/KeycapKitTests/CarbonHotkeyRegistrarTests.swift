import Carbon.HIToolbox
import XCTest
@testable import KeycapKit

final class CarbonHotkeyRegistrarTests: XCTestCase {

    /// A test-only signature, so these registrations cannot collide with the
    /// dispatch tests' default `'KCAP'` registrations.
    private static let signature: OSType = 0x5445_5354 // 'TEST'

    func testRegistrarMintsSequentialIdsAndUnregisters() {
        let registrar = CarbonHotkeyRegistrar(signature: CarbonHotkeyRegistrarTests.signature)
        var tokens: [HotkeyToken] = []
        defer { tokens.forEach(registrar.unregister) }

        let first = registrar.register(
            KeyCombo(keyCode: KeyCode.f19, modifiers: [.command, .option]),
            onPressed: {})
        let second = registrar.register(
            KeyCombo(keyCode: KeyCode.f20, modifiers: [.command, .option]),
            onPressed: {})
        XCTAssertEqual(first?.id, 1)
        XCTAssertEqual(second?.id, 2)
        XCTAssertNotEqual(first, second)
        tokens = [first, second].compactMap { $0 }

        registrar.unregister(tokens[0])
        registrar.unregister(tokens[0]) // idempotent
        registrar.unregister(tokens[1])
    }

    func testUnknownTokenIsANoOp() {
        let registrar = CarbonHotkeyRegistrar(signature: CarbonHotkeyRegistrarTests.signature)
        registrar.unregister(HotkeyToken(id: 999))
    }

    /// A second registrar using the same signature and id cannot claim the same
    /// hotkey; the failed registration returns nil and leaves no live token.
    func testDuplicateRegistrationIsRefused() {
        let first = CarbonHotkeyRegistrar(signature: CarbonHotkeyRegistrarTests.signature)
        let second = CarbonHotkeyRegistrar(signature: CarbonHotkeyRegistrarTests.signature)
        var token: HotkeyToken?
        defer { if let token { first.unregister(token) } }

        let combo = KeyCombo(keyCode: KeyCode.f18, modifiers: [.control, .option])
        token = first.register(combo, onPressed: {})
        XCTAssertNotNil(token)

        XCTAssertNil(second.register(combo, onPressed: {}))
    }
}
