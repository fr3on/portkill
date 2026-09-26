import AppKit
import PortKillCore
import SwiftUI

struct PortBadge: View {
    let port: Int
    var transport: TransportProtocol = .tcp
    var isDevPort: Bool = true
    @UIState private var justCopied = false

    private static let commonDevPorts: Set<Int> = [
        3000, 3001, 3002, 3333, 4000, 4200, 4321, 5000, 5001, 5173, 5174,
        8000, 8008, 8080, 8081, 8443, 8888, 9000, 9090, 9999, 1337
    ]

    var isHighlightedPort: Bool {
        Self.commonDevPorts.contains(port)
    }

    var body: some View {
        Button {
            copyPortToPasteboard()
        } label: {
            HStack(spacing: 3) {
                if justCopied {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundStyle(Theme.Colors.statusActive)
                        .transition(.scale.combined(with: .opacity))
                }

                Text(verbatim: "\(port)")
                    .font(Theme.Typography.portNumber)
                    .monospacedDigit()
                    .foregroundStyle(
                        justCopied ? Theme.Colors.statusActive :
                        (isHighlightedPort ? Theme.Colors.devPortBadgeText : Theme.Colors.portBadgeText)
                    )

                if transport == .udp {
                    Text("UDP")
                        .font(.system(size: 7.5, weight: .bold))
                        .foregroundStyle(Theme.Colors.statusWarning)
                        .padding(.horizontal, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.Colors.statusWarning.opacity(0.12))
                        )
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3.5)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .fill(
                        justCopied ? Theme.Colors.statusActive.opacity(0.14) :
                        (isHighlightedPort ? Theme.Colors.devPortBadgeBackground : Theme.Colors.portBadgeBackground)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .stroke(
                        justCopied ? Theme.Colors.statusActive.opacity(0.35) :
                        (isHighlightedPort ? Theme.Colors.devPortBadgeBorder : Theme.Colors.portBadgeBorder),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .help("Click to copy localhost:\(port)")
        .accessibilityLabel("Copy localhost:\(port)")
        .animation(.spring(response: 0.22, dampingFraction: 0.8), value: justCopied)
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
