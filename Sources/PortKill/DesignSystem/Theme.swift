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
        static let small: CGFloat = 5
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Colors {
        // Port badge: dynamic contrast for dark and light
        static let portBadgeText = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor.white
                : NSColor.labelColor
        }))

        static let portBadgeBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.12)
                : NSColor(white: 0.0, alpha: 0.06)
        }))

        static let portBadgeBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.16)
                : NSColor(white: 0.0, alpha: 0.09)
        }))

        // Kill action: crisp coral in dark, punchy ruby in light
        static let killRed = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.45, blue: 0.42, alpha: 1.0)
                : NSColor(red: 0.82, green: 0.18, blue: 0.20, alpha: 1.0)
        }))

        static let killRedBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.45, blue: 0.42, alpha: 0.18)
                : NSColor(red: 0.85, green: 0.18, blue: 0.20, alpha: 0.08)
        }))

        static let killRedBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1.0, green: 0.45, blue: 0.42, alpha: 0.28)
                : NSColor(red: 0.85, green: 0.18, blue: 0.20, alpha: 0.18)
        }))

        // Status active dot
        static let statusActive = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.30, green: 0.85, blue: 0.50, alpha: 1.0)
                : NSColor(red: 0.15, green: 0.68, blue: 0.35, alpha: 1.0)
        }))

        // Cards & Dividers
        static let cardHover = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.06)
                : NSColor(white: 0.0, alpha: 0.04)
        }))

        static let cardBorder = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.08)
                : NSColor(white: 0.0, alpha: 0.06)
        }))

        static let rowSeparator = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.08)
                : NSColor(white: 0.0, alpha: 0.06)
        }))
    }

    enum Typography {
        static let portNumber = Font.system(size: 13, weight: .semibold, design: .monospaced)
        static let projectTitle = Font.system(size: 12.5, weight: .semibold, design: .default)
        static let metaText = Font.system(size: 10.5, weight: .regular, design: .monospaced)
        static let actionLabel = Font.system(size: 11, weight: .medium, design: .default)
        static let headerTitle = Font.system(size: 11, weight: .semibold, design: .default)
        static let shortcutGlyph = Font.system(size: 10, weight: .medium, design: .rounded)
    }

    enum Dimensions {
        static let popoverWidth: CGFloat = 380
        static let popoverHeight: CGFloat = 420
        static let minRowHeight: CGFloat = 42
        static let searchHeight: CGFloat = 30
    }
}
