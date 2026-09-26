import AppKit
import SwiftUI

/// Shows `assets/icon.png` (copied into the app bundle by build-app.sh) in the menu bar.
struct MenuBarIconView: View {
    let state: AppState

    var body: some View {
        HStack(spacing: 3) {
            Image(nsImage: Self.image)
            if state.showMenuBarCount && state.badgeCount > 0 {
                Text(verbatim: "\(state.badgeCount)")
                    .monospacedDigit()
            }
        }
        // Restarts when the setting flips, so nothing runs at all while the count is off.
        .task(id: state.showMenuBarCount) { await state.runBadgeLoop() }
    }

    static let image: NSImage = {
        let image = Bundle.main.url(forResource: "icon", withExtension: "png")
            .flatMap { NSImage(contentsOf: $0) }
            ?? NSImage(systemSymbolName: "bolt.horizontal.circle", accessibilityDescription: nil)
            ?? NSImage()
        image.size = NSSize(width: 18, height: 18)
        image.isTemplate = true
        image.accessibilityDescription = "PortKill"
        return image
    }()
}
