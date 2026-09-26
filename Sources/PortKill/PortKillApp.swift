import AppKit
import SwiftUI

@main
struct PortKillApp: App {
    @UIState private var state = AppState()

    init() {
        Self.quitIfAlreadyRunning()
    }

    /// A second copy would add a second, duplicate menu bar icon.
    private static func quitIfAlreadyRunning() {
        guard let id = Bundle.main.bundleIdentifier else { return }
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: id)
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        if !others.isEmpty { exit(0) }
    }

    var body: some Scene {
        MenuBarExtra {
            MainPopoverView(state: state)
        } label: {
            MenuBarIconView(state: state)
        }
        .menuBarExtraStyle(.window)
    }
}
