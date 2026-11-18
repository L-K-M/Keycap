import AppKit
import Foundation
import KeycapCore

extension HotkeyModifiers {
    /// Maps Cocoa modifier flags to Carbon's `RegisterEventHotKey` bits. The
    /// layouts differ, so raw `NSEvent.ModifierFlags` never pass through.
    public init(eventFlags: NSEvent.ModifierFlags) {
        var carbon: UInt32 = 0
        if eventFlags.contains(.command) { carbon |= HotkeyModifiers.command.rawValue }
        if eventFlags.contains(.option) { carbon |= HotkeyModifiers.option.rawValue }
        if eventFlags.contains(.control) { carbon |= HotkeyModifiers.control.rawValue }
        if eventFlags.contains(.shift) { carbon |= HotkeyModifiers.shift.rawValue }
        self.init(rawValue: carbon)
    }

    /// The Cocoa flags for the four modeled bits. Other Cocoa flags (caps lock,
    /// function, numeric pad) are not part of a Carbon hotkey and are dropped.
    public var eventFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if contains(.command) { flags.insert(.command) }
        if contains(.option) { flags.insert(.option) }
        if contains(.control) { flags.insert(.control) }
        if contains(.shift) { flags.insert(.shift) }
        return flags
    }
}
