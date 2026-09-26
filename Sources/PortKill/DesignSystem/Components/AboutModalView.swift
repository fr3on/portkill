import AppKit
import SwiftUI

struct AboutModalView: View {
    let currentVersion: String
    let onDismiss: () -> Void
    var onCheckUpdates: () -> Void = {}

    private var appIcon: NSImage {
        if let icon = NSImage(named: "AppIcon") {
            return icon
        }
        if let logoURL = Bundle.main.url(forResource: "logo", withExtension: "png"),
           let img = NSImage(contentsOf: logoURL) {
            return img
        }
        return NSApplication.shared.applicationIconImage
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private let authorURL = URL(string: "https://github.com/fr3on")!
    private let repoURL = URL(string: "https://github.com/fr3on/portkill")!

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            VStack(spacing: 8) {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .shadow(color: Color.black.opacity(0.22), radius: 10, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
                    )

                VStack(spacing: 3) {
                    HStack(spacing: 6) {
                        Text("PortKill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.primary)

                        Text("v\(currentVersion)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.12))
                            )
                    }

                    Text("Fast, minimal menu bar port manager for macOS")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 4)

            VStack(spacing: 8) {
                LinkCard(
                    icon: "person.crop.circle.fill",
                    title: "Created by @fr3on",
                    subtitle: "github.com/fr3on",
                    url: authorURL
                )

                LinkCard(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: "fr3on / portkill",
                    subtitle: "Source code, releases & issue tracker",
                    url: repoURL
                )
            }

            Divider()
                .overlay(Theme.Colors.rowSeparator)

            HStack(spacing: 10) {
                Button {
                    onCheckUpdates()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .medium))
                        Text("Check for Updates")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5.5)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    )
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 5.5)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.accentColor)
                )
            }
        }
        .padding(18)
        .frame(width: 345)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(Theme.Colors.modalBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.24), radius: 20, y: 10)
    }
}

private struct LinkCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let url: URL

    @UIState private var isHovered: Bool = false

    var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(isHovered ? 0.18 : 0.10))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 1.5) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.primary)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isHovered ? Color.primary : Color.secondary.opacity(0.6))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.06) : Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isHovered ? Color.accentColor.opacity(0.3) : Color.primary.opacity(0.06), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
