import SwiftUI

enum KillState: Equatable {
    case idle
    case terminating(remainingSeconds: Int)
    case requiresForceKill
    case dead
}

struct KillButton: View {
    let subject: String
    let readOnlyLabel: String?
    let onKill: () -> Bool
    let onForceKill: () -> Void
    let isAlive: () -> Bool

    @UIState private var state: KillState = .idle
    @UIState private var timerTask: Task<Void, Never>? = nil

    var body: some View {
        Group {
            if let readOnlyLabel {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .help("\(readOnlyLabel) process, read-only")
                    .accessibilityLabel("\(subject), \(readOnlyLabel) process, cannot be killed")
            } else {
                switch state {
                case .idle:
                    Button {
                        initiateKill()
                    } label: {
                        Text("Kill")
                            .font(Theme.Typography.actionLabel)
                            .foregroundStyle(Theme.Colors.killRed)
                            .padding(.horizontal, Theme.Spacing.sm + 2)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                    .fill(Theme.Colors.killRedBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                    .stroke(Theme.Colors.killRedBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Kill \(subject)")

                case .terminating(let remaining):
                    HStack(spacing: Theme.Spacing.xs) {
                        ProgressView()
                            .controlSize(.mini)
                        Text("\(remaining)s")
                            .font(Theme.Typography.metaText)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Stopping \(subject), \(remaining) seconds")

                case .requiresForceKill:
                    Button {
                        timerTask?.cancel()
                        state = .dead
                        onForceKill()
                    } label: {
                        Text("Force Kill")
                            .font(Theme.Typography.actionLabel)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Theme.Spacing.sm + 2)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                    .fill(Theme.Colors.killRed)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Force kill \(subject)")

                case .dead:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.Colors.statusActive)
                        .padding(.horizontal, Theme.Spacing.sm)
                }
            }
        }
        .animation(.easeInOut(duration: 0.16), value: state)
        .onDisappear { timerTask?.cancel() }
    }

    private func initiateKill() {
        guard onKill() else { return }
        state = .terminating(remainingSeconds: 3)

        timerTask = Task {
            for remaining in (1...3).reversed() {
                state = .terminating(remainingSeconds: remaining)
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                if !isAlive() {
                    state = .dead
                    return
                }
            }
            state = .requiresForceKill
        }
    }
}
