import PortKillCore
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
    @UIState private var isHovered = false
    @Environment(\.appLanguage) private var language

    var body: some View {
        Group {
            if let readOnlyLabel {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.tertiary)
                    .frame(width: 24, height: 22)
                    .help(language.strings.readOnlyTooltip(reason: readOnlyLabel))
                    .accessibilityLabel(language.strings.readOnlyAccessibility(subject: subject, reason: readOnlyLabel))
            } else {
                switch state {
                case .idle:
                    Button {
                        initiateKill()
                    } label: {
                        Text(language.strings.kill)
                            .font(Theme.Typography.actionLabel)
                            .foregroundStyle(Theme.Colors.killRed)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3.5)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                    .fill(isHovered ? Theme.Colors.killRed.opacity(0.22) : Theme.Colors.killRedBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                    .stroke(Theme.Colors.killRedBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { isHovered = $0 }
                    .accessibilityLabel(language.strings.killAccessibility(subject: subject))

                case .terminating(let remaining):
                    HStack(spacing: 4) {
                        ProgressView()
                            .controlSize(.mini)
                        Text("\(remaining)s")
                            .font(Theme.Typography.metaMono)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                            .fill(Color.primary.opacity(0.04))
                    )
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(language.strings.stoppingAccessibility(subject: subject, remainingSeconds: remaining))

                case .requiresForceKill:
                    Button {
                        timerTask?.cancel()
                        state = .dead
                        onForceKill()
                    } label: {
                        Text(language.strings.forceKill)
                            .font(Theme.Typography.actionLabel)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3.5)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                    .fill(Theme.Colors.killRed)
                            )
                            .shadow(color: Theme.Colors.killRed.opacity(0.3), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(language.strings.forceKillAccessibility(subject: subject))

                case .dead:
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                        Text(language.strings.stopped)
                            .font(Theme.Typography.metaMono)
                    }
                    .foregroundStyle(Theme.Colors.statusActive)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                }
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: state)
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
