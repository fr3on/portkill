import AppKit
import SwiftUI

enum Theme {
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
    }

    enum Radius {
        static let micro: CGFloat = 4
        static let small: CGFloat = 6
        static let medium: CGFloat = 9
        static let large: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Colors {
        static let surfaceBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 0.12, alpha: 0.70)
                : NSColor(white: 0.98, alpha: 0.82)
        }))

        // Modal solid surface background (100% opaque, prevents content bleed-through)
        static let modalBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1.0)
                : NSColor(white: 0.99, alpha: 1.0)
        }))

        static let portBadgeText = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor.white
                : NSColor(white: 0.1, alpha: 1.0)
        }))

        static let portBadgeBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.11)
                : NSColor(white: 0.0, alpha: 0.06)
        }))

        static let portBadgeBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.15)
                : NSColor(white: 0.0, alpha: 0.09)
        }))

        static let devPortBadgeText = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.55, green: 0.82, blue: 1.0, alpha: 1.0)
                : NSColor(red: 0.08, green: 0.42, blue: 0.85, alpha: 1.0)
        }))

        static let devPortBadgeBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.25, green: 0.55, blue: 0.95, alpha: 0.16)
                : NSColor(red: 0.15, green: 0.45, blue: 0.95, alpha: 0.08)
        }))

        static let devPortBadgeBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.40, green: 0.70, blue: 1.0, alpha: 0.28)
                : NSColor(red: 0.20, green: 0.50, blue: 0.95, alpha: 0.20)
        }))

        static let killRed = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.42, blue: 0.40, alpha: 1.0)
                : NSColor(red: 0.88, green: 0.18, blue: 0.20, alpha: 1.0)
        }))

        static let killRedBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.40, blue: 0.38, alpha: 0.16)
                : NSColor(red: 0.90, green: 0.20, blue: 0.22, alpha: 0.08)
        }))

        static let killRedBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.40, blue: 0.38, alpha: 0.28)
                : NSColor(red: 0.90, green: 0.20, blue: 0.22, alpha: 0.18)
        }))

        static let statusActive = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.32, green: 0.86, blue: 0.52, alpha: 1.0)
                : NSColor(red: 0.14, green: 0.70, blue: 0.36, alpha: 1.0)
        }))

        static let statusWarning = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.75, blue: 0.25, alpha: 1.0)
                : NSColor(red: 0.85, green: 0.55, blue: 0.08, alpha: 1.0)
        }))

        static let cardBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.035)
                : NSColor(white: 0.0, alpha: 0.025)
        }))

        static let cardHover = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.065)
                : NSColor(white: 0.0, alpha: 0.045)
        }))

        static let cardBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.09)
                : NSColor(white: 0.0, alpha: 0.07)
        }))

        static let cardBorderActive = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.15)
                : NSColor(white: 0.0, alpha: 0.12)
        }))

        static let rowSeparator = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.07)
                : NSColor(white: 0.0, alpha: 0.05)
        }))
    }

    enum Typography {
        static let portNumber = Font.system(size: 12.5, weight: .bold, design: .monospaced)
        static let projectTitle = Font.system(size: 13, weight: .semibold, design: .default)
        static let metaText = Font.system(size: 11, weight: .regular, design: .default)
        static let metaMono = Font.system(size: 10.5, weight: .medium, design: .monospaced)
        static let actionLabel = Font.system(size: 11, weight: .medium, design: .default)
        static let headerTitle = Font.system(size: 11, weight: .semibold, design: .default)
        static let shortcutGlyph = Font.system(size: 9.5, weight: .semibold, design: .rounded)
        static let microTag = Font.system(size: 9, weight: .semibold, design: .default)
    }

    enum Dimensions {
        static let popoverWidth: CGFloat = 390
        static let defaultPopoverHeight: CGFloat = 445
        static let minPopoverHeight: CGFloat = 360
        static let maxPopoverHeight: CGFloat = 820
        static let popoverHeight: CGFloat = defaultPopoverHeight
        static let minRowHeight: CGFloat = 46
        static let searchHeight: CGFloat = 32
    }
}
