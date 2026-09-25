import AppKit
import SwiftUI

struct PortBadge: View {
    let port: Int
    @UIState private var justCopied = false

    var body: some View {
        Button {
            copyPortToPasteboard()
        } label: {
            HStack(spacing: Theme.Spacing.xxs) {
                if justCopied {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Theme.Colors.statusActive)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(verbatim: "\(port)")
                    .font(Theme.Typography.portNumber)
                    .monospacedDigit()
                    .foregroundStyle(justCopied ? Theme.Colors.statusActive : Theme.Colors.portBadgeText)
            }
            .padding(.horizontal, Theme.Spacing.sm + 2)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .fill(justCopied ? Theme.Colors.statusActive.opacity(0.12) : Theme.Colors.portBadgeBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .stroke(
                        justCopied ? Theme.Colors.statusActive.opacity(0.3) : Theme.Colors.portBadgeBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .help("Click to copy localhost:\(port)")
        .accessibilityLabel("Copy localhost:\(port)")
        .animation(.easeInOut(duration: 0.18), value: justCopied)
    }

    private func copyPortToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("localhost:\(port)", forType: .string)

        justCopied = true
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            justCopied = false
        }
    }
}
