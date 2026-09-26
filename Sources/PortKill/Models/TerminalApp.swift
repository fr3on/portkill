import AppKit

/// Terminal emulators "Open in Terminal" can target. Only installed ones are offered.
struct TerminalApp: Identifiable, Hashable {
    let name: String
    let bundleID: String

    var id: String { bundleID }
    var url: URL? { NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) }

    static let terminal = TerminalApp(name: "Terminal", bundleID: "com.apple.Terminal")

    static let known = [
        terminal,
        TerminalApp(name: "iTerm2", bundleID: "com.googlecode.iterm2"),
        TerminalApp(name: "Ghostty", bundleID: "com.mitchellh.ghostty"),
        TerminalApp(name: "Warp", bundleID: "dev.warp.Warp-Stable"),
        TerminalApp(name: "kitty", bundleID: "net.kovidgoyal.kitty"),
        TerminalApp(name: "Alacritty", bundleID: "org.alacritty"),
    ]

    static var installed: [TerminalApp] { known.filter { $0.url != nil } }

    static func with(bundleID: String) -> TerminalApp {
        known.first { $0.bundleID == bundleID } ?? terminal
    }

    /// Opens `folder` in this terminal. Returns false if the app is missing.
    @discardableResult
    func open(folder: String) -> Bool {
        guard let appURL = url else { return false }
        NSWorkspace.shared.open(
            [URL(fileURLWithPath: folder)],
            withApplicationAt: appURL,
            configuration: NSWorkspace.OpenConfiguration()
        )
        return true
    }
}
