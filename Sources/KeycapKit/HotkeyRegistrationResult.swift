import Carbon.HIToolbox
import Foundation

/// The outcome of a Carbon hotkey registration.
///
/// The in-family copies returned a bare `Bool`, which hid why a shortcut could
/// not be registered. Apps keep their own failure UI policy, but they need the
/// reason: `eventHotKeyExistsErr` means another app owns the chord, while
/// `eventInternalErr` is the system refusing it.
public enum HotkeyRegistrationResult: Equatable {
    case registered
    case alreadyTaken
    case refusedBySystem
    case failed(OSStatus)

    /// Classifies a Carbon registration status.
    init(status: OSStatus) {
        switch status {
        case noErr:
            self = .registered
        case OSStatus(eventHotKeyExistsErr):
            self = .alreadyTaken
        case OSStatus(eventInternalErr):
            self = .refusedBySystem
        default:
            self = .failed(status)
        }
    }

    public var isRegistered: Bool {
        self == .registered
    }

    /// Short user-facing English for a failure, or nil on success.
    public var failureDescription: String? {
        switch self {
        case .registered:
            return nil
        case .alreadyTaken:
            return "Another app is already using this shortcut."
        case .refusedBySystem:
            return "The system refused this shortcut."
        case .failed:
            return "The shortcut could not be registered."
        }
    }
}
