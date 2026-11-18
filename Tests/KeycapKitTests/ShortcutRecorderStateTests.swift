import AppKit
import XCTest
@testable import KeycapKit

/// The recorder reports when recording starts and stops, so an app can hide
/// controls (such as a separate Clear button) that would compete with the
/// recorder for the next key press.
final class ShortcutRecorderStateTests: XCTestCase {

    private var window: NSWindow!
    private var button: ShortcutRecorderButton!
    private var states: [Bool] = []

    override func setUp() {
        super.setUp()
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 240, height: 60),
                          styleMask: [.titled],
                          backing: .buffered,
                          defer: true)
        window.isReleasedWhenClosed = false
        button = ShortcutRecorderButton(frame: NSRect(x: 10, y: 10, width: 200, height: 30))
        window.contentView?.addSubview(button)
        states = []
        button.onRecordingChange = { [unowned self] in self.states.append($0) }
    }

    override func tearDown() {
        window.close()
        button = nil
        window = nil
        super.tearDown()
    }

    private func key(_ keyCode: UInt16, characters: String,
                     modifiers: NSEvent.ModifierFlags = []) throws -> NSEvent {
        try XCTUnwrap(NSEvent.keyEvent(with: .keyDown,
                                       location: .zero,
                                       modifierFlags: modifiers,
                                       timestamp: 0,
                                       windowNumber: window.windowNumber,
                                       context: nil,
                                       characters: characters,
                                       charactersIgnoringModifiers: characters,
                                       isARepeat: false,
                                       keyCode: keyCode))
    }

    func testClickStartsRecordingAndEscapeStopsIt() throws {
        button.performClick(nil)
        XCTAssertIdentical(window.firstResponder, button,
                           "clicking the recorder must make it first responder")
        XCTAssertEqual(states, [true])

        button.keyDown(with: try key(UInt16(KeyCode.escape), characters: "\u{1b}"))
        XCTAssertEqual(states, [true, false])
    }

    func testCommittingAComboStopsRecording() throws {
        var committed: [KeyCombo?] = []
        button.onChange = { committed.append($0) }
        button.performClick(nil)

        button.keyDown(with: try key(UInt16(KeyCode.f12), characters: "\u{F70F}"))
        XCTAssertEqual(states, [true, false])
        XCTAssertEqual(committed, [KeyCombo(keyCode: KeyCode.f12, modifiers: [])])
    }

    func testRejectedComboKeepsRecordingWithoutAnotherReport() throws {
        button.performClick(nil)

        // A bare letter is not a usable global hotkey: beep, keep recording.
        button.keyDown(with: try key(UInt16(KeyCode.a), characters: "a"))
        XCTAssertEqual(states, [true])
    }

    func testFocusLossStopsRecording() {
        button.performClick(nil)
        window.makeFirstResponder(nil)
        XCTAssertEqual(states, [true, false])
    }

    func testClickingAgainWhileRecordingReportsNothingNew() {
        button.performClick(nil)
        button.performClick(nil)
        XCTAssertEqual(states, [true])
    }

    /// Disabling the control resigns it as first responder, so an in-flight
    /// recording stops and reports `false` rather than leaving the app's UI
    /// stuck with the recorder still swallowing keys.
    func testDisablingStopsRecording() {
        button.performClick(nil)
        button.isEnabled = false
        XCTAssertEqual(states, [true, false])
        XCTAssertEqual(button.title, "Record Shortcut")
    }

    /// SwiftUI can end recording in the middle of a view update (the recorder
    /// leaving its window resigns first responder), and writing view state
    /// from inside an update is undefined behaviour. The SwiftUI wrapper
    /// therefore delivers changes on the next main-queue turn, in order.
    func testSwiftUIHandlerIsDeliveredOnTheNextMainQueueTurnInOrder() throws {
        var received: [Bool] = []
        let delivered = expectation(description: "both changes delivered")
        delivered.expectedFulfillmentCount = 2
        let handler = try XCTUnwrap(ShortcutRecorder.deferredRecordingHandler { value in
            received.append(value)
            delivered.fulfill()
        })

        handler(true)
        handler(false)
        XCTAssertEqual(received, [], "delivered synchronously")

        waitForExpectations(timeout: 2)
        XCTAssertEqual(received, [true, false])
    }

    func testNoSwiftUIHandlerMeansNoWrapper() {
        XCTAssertNil(ShortcutRecorder.deferredRecordingHandler(nil))
    }
}
