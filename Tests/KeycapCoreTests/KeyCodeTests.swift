import XCTest
#if canImport(Carbon)
import Carbon.HIToolbox
#endif
import KeycapCore

final class KeyCodeTests: XCTestCase {

    func testFunctionKeys() {
        for key in [KeyCode.f1, KeyCode.f5, KeyCode.f12, KeyCode.f20] {
            XCTAssertTrue(KeyCode.isFunctionKey(key))
        }
        for key in [KeyCode.a, KeyCode.space, KeyCode.return, KeyCode.escape, KeyCode.zero] {
            XCTAssertFalse(KeyCode.isFunctionKey(key))
        }
    }

    /// Every literal is pinned to the Carbon symbol it mirrors. The literals
    /// are persisted, so a wrong value would silently rewrite users' saved
    /// hotkeys; Linux cannot compare, and Darwin only checks what is written
    /// down here.
    #if canImport(Carbon)
    func testEveryLiteralMatchesCarbon() {
        XCTAssertEqual(KeyCode.a, UInt32(kVK_ANSI_A))
        XCTAssertEqual(KeyCode.b, UInt32(kVK_ANSI_B))
        XCTAssertEqual(KeyCode.c, UInt32(kVK_ANSI_C))
        XCTAssertEqual(KeyCode.d, UInt32(kVK_ANSI_D))
        XCTAssertEqual(KeyCode.e, UInt32(kVK_ANSI_E))
        XCTAssertEqual(KeyCode.f, UInt32(kVK_ANSI_F))
        XCTAssertEqual(KeyCode.g, UInt32(kVK_ANSI_G))
        XCTAssertEqual(KeyCode.h, UInt32(kVK_ANSI_H))
        XCTAssertEqual(KeyCode.i, UInt32(kVK_ANSI_I))
        XCTAssertEqual(KeyCode.j, UInt32(kVK_ANSI_J))
        XCTAssertEqual(KeyCode.k, UInt32(kVK_ANSI_K))
        XCTAssertEqual(KeyCode.l, UInt32(kVK_ANSI_L))
        XCTAssertEqual(KeyCode.m, UInt32(kVK_ANSI_M))
        XCTAssertEqual(KeyCode.n, UInt32(kVK_ANSI_N))
        XCTAssertEqual(KeyCode.o, UInt32(kVK_ANSI_O))
        XCTAssertEqual(KeyCode.p, UInt32(kVK_ANSI_P))
        XCTAssertEqual(KeyCode.q, UInt32(kVK_ANSI_Q))
        XCTAssertEqual(KeyCode.r, UInt32(kVK_ANSI_R))
        XCTAssertEqual(KeyCode.s, UInt32(kVK_ANSI_S))
        XCTAssertEqual(KeyCode.t, UInt32(kVK_ANSI_T))
        XCTAssertEqual(KeyCode.u, UInt32(kVK_ANSI_U))
        XCTAssertEqual(KeyCode.v, UInt32(kVK_ANSI_V))
        XCTAssertEqual(KeyCode.w, UInt32(kVK_ANSI_W))
        XCTAssertEqual(KeyCode.x, UInt32(kVK_ANSI_X))
        XCTAssertEqual(KeyCode.y, UInt32(kVK_ANSI_Y))
        XCTAssertEqual(KeyCode.z, UInt32(kVK_ANSI_Z))
        XCTAssertEqual(KeyCode.zero, UInt32(kVK_ANSI_0))
        XCTAssertEqual(KeyCode.one, UInt32(kVK_ANSI_1))
        XCTAssertEqual(KeyCode.two, UInt32(kVK_ANSI_2))
        XCTAssertEqual(KeyCode.three, UInt32(kVK_ANSI_3))
        XCTAssertEqual(KeyCode.four, UInt32(kVK_ANSI_4))
        XCTAssertEqual(KeyCode.five, UInt32(kVK_ANSI_5))
        XCTAssertEqual(KeyCode.six, UInt32(kVK_ANSI_6))
        XCTAssertEqual(KeyCode.seven, UInt32(kVK_ANSI_7))
        XCTAssertEqual(KeyCode.eight, UInt32(kVK_ANSI_8))
        XCTAssertEqual(KeyCode.nine, UInt32(kVK_ANSI_9))
        XCTAssertEqual(KeyCode.space, UInt32(kVK_Space))
        XCTAssertEqual(KeyCode.`return`, UInt32(kVK_Return))
        XCTAssertEqual(KeyCode.keypadEnter, UInt32(kVK_ANSI_KeypadEnter))
        XCTAssertEqual(KeyCode.tab, UInt32(kVK_Tab))
        XCTAssertEqual(KeyCode.escape, UInt32(kVK_Escape))
        XCTAssertEqual(KeyCode.delete, UInt32(kVK_Delete))
        XCTAssertEqual(KeyCode.forwardDelete, UInt32(kVK_ForwardDelete))
        XCTAssertEqual(KeyCode.leftArrow, UInt32(kVK_LeftArrow))
        XCTAssertEqual(KeyCode.rightArrow, UInt32(kVK_RightArrow))
        XCTAssertEqual(KeyCode.downArrow, UInt32(kVK_DownArrow))
        XCTAssertEqual(KeyCode.upArrow, UInt32(kVK_UpArrow))
        XCTAssertEqual(KeyCode.home, UInt32(kVK_Home))
        XCTAssertEqual(KeyCode.end, UInt32(kVK_End))
        XCTAssertEqual(KeyCode.pageUp, UInt32(kVK_PageUp))
        XCTAssertEqual(KeyCode.pageDown, UInt32(kVK_PageDown))
        XCTAssertEqual(KeyCode.help, UInt32(kVK_Help))
        XCTAssertEqual(KeyCode.keypadClear, UInt32(kVK_ANSI_KeypadClear))
        XCTAssertEqual(KeyCode.grave, UInt32(kVK_ANSI_Grave))
        XCTAssertEqual(KeyCode.f1, UInt32(kVK_F1))
        XCTAssertEqual(KeyCode.f2, UInt32(kVK_F2))
        XCTAssertEqual(KeyCode.f3, UInt32(kVK_F3))
        XCTAssertEqual(KeyCode.f4, UInt32(kVK_F4))
        XCTAssertEqual(KeyCode.f5, UInt32(kVK_F5))
        XCTAssertEqual(KeyCode.f6, UInt32(kVK_F6))
        XCTAssertEqual(KeyCode.f7, UInt32(kVK_F7))
        XCTAssertEqual(KeyCode.f8, UInt32(kVK_F8))
        XCTAssertEqual(KeyCode.f9, UInt32(kVK_F9))
        XCTAssertEqual(KeyCode.f10, UInt32(kVK_F10))
        XCTAssertEqual(KeyCode.f11, UInt32(kVK_F11))
        XCTAssertEqual(KeyCode.f12, UInt32(kVK_F12))
        XCTAssertEqual(KeyCode.f13, UInt32(kVK_F13))
        XCTAssertEqual(KeyCode.f14, UInt32(kVK_F14))
        XCTAssertEqual(KeyCode.f15, UInt32(kVK_F15))
        XCTAssertEqual(KeyCode.f16, UInt32(kVK_F16))
        XCTAssertEqual(KeyCode.f17, UInt32(kVK_F17))
        XCTAssertEqual(KeyCode.f18, UInt32(kVK_F18))
        XCTAssertEqual(KeyCode.f19, UInt32(kVK_F19))
        XCTAssertEqual(KeyCode.f20, UInt32(kVK_F20))
    }
    #endif
}
