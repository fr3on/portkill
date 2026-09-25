import AppKit
import PortKillCore
import SwiftUI

struct ProcessRowView: View {
    let item: ListeningPort
    let readOnlyReason: ReadOnlyReason?
    let onKill: () -> Bool
    let onForceKill: () -> Void
    let isAlive: () -> Bool

    @UIState private var isHovered = false
    @UIState private var isExpanded = false
    @UIState private var copiedPath = false
    @UIState private var copiedURL = false

    var body: some View {
        VStack(spacing: 0) {
            // Main Row Header
            HStack(spacing: Theme.Spacing.md) {
                PortBadge(port: item.port)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Text(item.project?.name ?? item.command)
                            .font(Theme.Typography.projectTitle)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        if item.project != nil {
                            Text(item.command)
                                .font(Theme.Typography.metaText)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }

                    HStack(spacing: Theme.Spacing.xs) {
                        Text(verbatim: "PID \(item.pid)")
                        Text("•")
                        Text(ProcessTiming.format(uptime: item.startedAt))

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                    .font(Theme.Typography.metaText)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: Theme.Spacing.sm)

                HStack(spacing: Theme.Spacing.xs) {
                    if isHovered && readOnlyReason == nil {
                        Button {
                            openInBrowser()
                        } label: {
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .frame(width: 22, height: 22)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                        .fill(Color.primary.opacity(0.06))
                                )
                        }
                        .buttonStyle(.plain)
                        .help("Open in browser (\(item.localURLString))")
                        .accessibilityLabel("Open \(item.localURLString) in browser")
                        .transition(.opacity)
                    }

                    KillButton(
                        subject: "\(item.project?.name ?? item.command) on port \(item.port)",
                        readOnlyLabel: readOnlyReason?.label,
                        onKill: onKill,
                        onForceKill: onForceKill,
                        isAlive: isAlive
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            }

            // Expanded Process Details Inspection Card
            if isExpanded {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Divider()
                        .overlay(Theme.Colors.rowSeparator)

                    // Project Path & Finder Action
                    if let project = item.project {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("PROJECT DIRECTORY")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.tertiary)

                            Text(project.path)
                                .font(Theme.Typography.metaText)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .textSelection(.enabled)

                            HStack(spacing: Theme.Spacing.sm) {
                                Button {
                                    revealInFinder(path: project.path)
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "folder")
                                        Text("Reveal in Finder")
                                    }
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(Color.primary.opacity(0.06))
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    copyToClipboard(text: project.path)
                                    copiedPath = true
                                    Task {
                                        try? await Task.sleep(for: .seconds(1.2))
                                        copiedPath = false
                                    }
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: copiedPath ? "checkmark" : "doc.on.doc")
                                        Text(copiedPath ? "Copied" : "Copy Path")
                                    }
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(copiedPath ? Theme.Colors.statusActive : Color.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(Color.primary.opacity(0.06))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 2)
                        }
                    }

                    // Process Specs Breakdown
                    HStack(alignment: .top, spacing: Theme.Spacing.lg) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("COMMAND")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.tertiary)
                            Text(item.command)
                                .font(Theme.Typography.metaText)
                                .foregroundStyle(.primary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("USER / UID")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.tertiary)
                            Text("\(item.user) (\(item.uid))")
                                .font(Theme.Typography.metaText)
                                .foregroundStyle(.primary)
                        }

                        if let startedAt = item.startedAt {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("STARTED")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                                Text(formatTime(startedAt))
                                    .font(Theme.Typography.metaText)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }

                    // Safety Indicator
                    HStack(spacing: 5) {
                        if let reason = readOnlyReason {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.Colors.killRed)
                            Text("Protected process (\(reason.label)) • Cannot be killed")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Theme.Colors.killRed)
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.Colors.statusActive)
                            Text("Owned by you • Can be terminated")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Theme.Colors.statusActive)
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(minHeight: Theme.Dimensions.minRowHeight)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(isHovered || isExpanded ? Theme.Colors.cardHover : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(isHovered || isExpanded ? Theme.Colors.cardBorder : Color.clear, lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }

    private func openInBrowser() {
        guard let url = URL(string: item.localURLString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func revealInFinder(path: String) {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }

    private func copyToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
