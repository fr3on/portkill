import Foundation
import Testing
@testable import PortKillCore

struct SettingsTests {
    private func makeDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: "pk-settings-\(UUID().uuidString)")!
        return defaults
    }

    @Test func emptyDefaultsGiveTheDefaultSettings() {
        #expect(Settings.load(from: makeDefaults()) == Settings())
    }

    @Test func roundTripsThroughUserDefaults() {
        let defaults = makeDefaults()
        var settings = Settings()
        settings.showSystemProcesses = true
        settings.showMenuBarCount = true
        settings.showUDP = true
        settings.terminalBundleID = "com.googlecode.iterm2"
        settings.save(to: defaults)
        #expect(Settings.load(from: defaults) == settings)
    }

    @Test func anEmptyTerminalIDFallsBackToDefault() {
        let defaults = makeDefaults()
        defaults.set("", forKey: "terminalBundleID")
        #expect(Settings.load(from: defaults).terminalBundleID == Settings.defaultTerminalBundleID)
    }

    @Test func aMissingTerminalFallsBackToTheDefault() {
        var settings = Settings()
        settings.terminalBundleID = "com.googlecode.iterm2"
        #expect(settings.normalized(installedTerminals: ["com.apple.Terminal"]).terminalBundleID == "com.apple.Terminal")
        #expect(settings.normalized(installedTerminals: ["com.googlecode.iterm2"]).terminalBundleID == "com.googlecode.iterm2")
    }
}
