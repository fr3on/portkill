import AppKit
import SwiftUI

struct StatusBarFooter: View {
    let activeDevCount: Int
    var message: String?
    var onQuit: () -> Void = { NSApplication.shared.terminate(nil) }

    @UIState private var isHoveringQuit: Bool = false

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Live status badge with soft glowing halo
            HStack(spacing: 6) {
                ZStack {
                    if activeDevCount > 0 {
                        Circle()
                            .fill(Theme.Colors.statusActive.opacity(0.25))
                            .frame(width: 12, height: 12)
                    }
                    Circle()
                        .fill(activeDevCount > 0 ? Theme.Colors.statusActive : Color.secondary.opacity(0.4))
                        .frame(width: 6, height: 6)
                }

                Text(activeDevCount == 1 ? "1 dev port active" : "\(activeDevCount) dev ports active")
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let message {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9.5))
                    Text(message)
                        .font(.system(size: 10.5, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundStyle(Theme.Colors.killRed)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Theme.Colors.killRedBackground)
                )
                .transition(.opacity)
            }

            Button {
                onQuit()
            } label: {
                HStack(spacing: 4) {
                    Text("Quit")
                        .font(.system(size: 11, weight: .medium))

                    HStack(spacing: 1) {
                        Text("⌘")
                        Text("Q")
                    }
                    .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                    )
                }
                .foregroundStyle(isHoveringQuit ? Color.primary : .secondary)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isHoveringQuit ? Color.primary.opacity(0.05) : Color.clear)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHoveringQuit = $0 }
            .keyboardShortcut("q", modifiers: .command)
            .help("Quit PortKill (⌘Q)")
        }
    }
}

