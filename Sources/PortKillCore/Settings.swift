import Foundation

/// User preferences, persisted in `UserDefaults`. Missing values fall back to defaults.
public struct Settings: Equatable, Sendable {
    public static let defaultTerminalBundleID = "com.apple.Terminal"

    public var showSystemProcesses = false
    public var showMenuBarCount = false
    public var showUDP = false
    public var terminalBundleID = Settings.defaultTerminalBundleID

    public init() {}

    enum Key {
        static let showSystemProcesses = "showSystemProcesses"
        static let showMenuBarCount = "showMenuBarCount"
        static let showUDP = "showUDP"
        static let terminalBundleID = "terminalBundleID"
    }

    public static func load(from defaults: UserDefaults = .standard) -> Settings {
        var settings = Settings()
        settings.showSystemProcesses = defaults.bool(forKey: Key.showSystemProcesses)
        settings.showMenuBarCount = defaults.bool(forKey: Key.showMenuBarCount)
        settings.showUDP = defaults.bool(forKey: Key.showUDP)
        if let id = defaults.string(forKey: Key.terminalBundleID), !id.isEmpty {
            settings.terminalBundleID = id
        }
        return settings
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(showSystemProcesses, forKey: Key.showSystemProcesses)
        defaults.set(showMenuBarCount, forKey: Key.showMenuBarCount)
        defaults.set(showUDP, forKey: Key.showUDP)
        defaults.set(terminalBundleID, forKey: Key.terminalBundleID)
    }

    /// Falls back to the default terminal when the chosen one is no longer installed.
    public func normalized(installedTerminals: Set<String>) -> Settings {
        var copy = self
        if !installedTerminals.contains(terminalBundleID) {
            copy.terminalBundleID = Settings.defaultTerminalBundleID
        }
        return copy
    }
}
