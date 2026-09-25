import AppKit
import SwiftUI

/// Shows `assets/icon.png` (copied into the app bundle by build-app.sh) in the menu bar.
struct MenuBarIconView: View {
    var body: some View {
        Image(nsImage: Self.image)
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
