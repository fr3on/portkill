import AppKit
import PortKillCore
import SwiftUI

struct ProcessRowView: View {
    let item: ListeningPort
    let extraPorts: [ListeningPort]
    let readOnlyReason: ReadOnlyReason?
    let terminalName: String
    let onOpenTerminal: (Project) -> Void
    let onKill: () -> Bool
    let onForceKill: () -> Void
    let isAlive: () -> Bool

    @UIState private var isHovered = false
    @UIState private var isExpanded = false
    @UIState private var copiedPath = false
    @UIState private var copiedKill = false
    @UIState private var copiedLsof = false

    private var identity: ProcessIdentity {
        ProcessIdentity.resolve(
            pid: item.pid,
            command: item.command,
            project: item.project,
            container: item.container
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Theme.Spacing.md) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        PortBadge(port: item.port, transport: item.transport)

                        if !extraPorts.isEmpty {
                            Text(verbatim: "+\(extraPorts.count)")
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4.5)
                                .padding(.vertical, 2.5)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radius.micro, style: .continuous)
                                        .fill(Color.primary.opacity(0.06))
                                )
                                .help(extraPorts.map { String($0.port) }.joined(separator: ", "))
                        }
                    }
                }

                ZStack {
                    if let appIcon = identity.appIcon {
                        Image(nsImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 1, y: 0.5)
                    } else {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(identity.tintColor.opacity(0.12))
                            .frame(width: 26, height: 26)

                        Image(systemName: identity.iconName)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(identity.tintColor)
                    }
                }
                .frame(width: 26, height: 26)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(displayName)
                            .font(Theme.Typography.projectTitle)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        if let tag = runtimeTag {
                            Text(tag)
                                .font(Theme.Typography.microTag)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4.5)
                                .padding(.vertical, 1.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                                        .fill(Color.primary.opacity(0.05))
                                )
                                .lineLimit(1)
                        }
                    }

                    HStack(spacing: 5) {
                        if item.container != nil {
                            Text("Docker container")
                        } else {
                            Text(verbatim: "PID \(item.pid)")
                                .font(Theme.Typography.metaMono)
                            Text("•")
                                .foregroundStyle(Color.secondary.opacity(0.5))
                            Text(ProcessTiming.format(uptime: item.startedAt))
                                .font(Theme.Typography.metaMono)
                            if let memory = ProcessMemory.format(item.memoryBytes) {
                                Text("•")
                                    .foregroundStyle(Color.secondary.opacity(0.5))
                                Text(memory)
                                    .font(Theme.Typography.metaMono)
                            }
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color.secondary.opacity(0.6))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: isExpanded)
                    }
                    .font(Theme.Typography.metaText)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: Theme.Spacing.xs)

                HStack(spacing: 6) {
                    if isHovered && item.transport == .tcp && (readOnlyReason == nil || item.container != nil) {
                        Button {
                            openInBrowser()
                        } label: {
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                                        .fill(Color.primary.opacity(0.06))
                                )
                        }
                        .buttonStyle(.plain)
                        .help("Open in browser (\(item.localURLString))")
                        .accessibilityLabel("Open \(item.localURLString) in browser")
                        .transition(.scale.combined(with: .opacity))
                    }

                    KillButton(
                        subject: "\(displayName) on port \(item.port)",
                        readOnlyLabel: readOnlyReason?.label,
                        onKill: onKill,
                        onForceKill: onForceKill,
                        isAlive: isAlive
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 9) {
                    Divider()
                        .overlay(Theme.Colors.rowSeparator)

                    if let project = item.project {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("PROJECT DIRECTORY")
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundStyle(Color.secondary.opacity(0.8))

                                Spacer()

                                HStack(spacing: 5) {
                                    actionPill(
                                        icon: "folder",
                                        label: "Reveal",
                                        action: { revealInFinder(path: project.path) }
                                    )

                                    actionPill(
                                        icon: "terminal",
                                        label: terminalName,
                                        action: { onOpenTerminal(project) }
                                    )

                                    actionPill(
                                        icon: copiedPath ? "checkmark" : "doc.on.doc",
                                        label: copiedPath ? "Copied" : "Copy Path",
                                        tint: copiedPath ? Theme.Colors.statusActive : .secondary,
                                        action: {
                                            copyToClipboard(text: project.path)
                                            flash($copiedPath)
                                        }
                                    )
                                }
                            }

                            Text(formatDisplayPath(project.path))
                                .font(Theme.Typography.metaMono)
                                .foregroundStyle(Color.primary.opacity(0.9))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .textSelection(.enabled)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(Color.primary.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                )
                                .help(project.path)
                        }
                    }

                    HStack(spacing: 6) {
                        snippetPill(
                            icon: copiedKill ? "checkmark" : "doc.on.doc",
                            command: stopSnippet,
                            isCopied: copiedKill,
                            action: {
                                copyToClipboard(text: stopSnippet)
                                flash($copiedKill)
                            }
                        )

                        snippetPill(
                            icon: copiedLsof ? "checkmark" : "doc.on.doc",
                            command: CommandSnippets.listeners(port: item.port, transport: item.transport),
                            isCopied: copiedLsof,
                            action: {
                                copyToClipboard(text: CommandSnippets.listeners(port: item.port, transport: item.transport))
                                flash($copiedLsof)
                            }
                        )
                    }

                    HStack(spacing: 5) {
                        specTile(title: "RUNTIME", value: item.command)
                        specTile(title: "USER", value: "\(item.user) (\(item.uid))")
                        if let startedAt = item.startedAt {
                            specTile(title: "STARTED", value: formatTime(startedAt))
                        }
                        if let memory = ProcessMemory.format(item.memoryBytes) {
                            specTile(title: "MEMORY", value: memory)
                        }
                    }

                    safetyStatusBanner
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .padding(.top, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(minHeight: Theme.Dimensions.minRowHeight)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(isHovered || isExpanded ? Theme.Colors.cardHover : Theme.Colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(isExpanded ? Theme.Colors.cardBorderActive : (isHovered ? Theme.Colors.cardBorder : Color.clear), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }

    private var displayName: String {
        item.container?.name ?? item.project?.name ?? item.command
    }

    private var runtimeTag: String? {
        if let container = item.container {
            return container.image
        }
        if item.project != nil {
            return item.command
        }
        return nil
    }

    private var stopSnippet: String {
        item.container.map { CommandSnippets.stopContainer(name: $0.name) } ?? CommandSnippets.terminate(pid: item.pid)
    }

    private func actionPill(icon: String, label: String, tint: Color = .secondary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3.5) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                Text(label)
                    .font(.system(size: 9.5, weight: .medium))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.micro, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.micro, style: .continuous)
                    .stroke(Color.primary.opacity(0.07), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func snippetPill(icon: String, command: String, isCopied: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 8.5, weight: .semibold))
                    .foregroundStyle(isCopied ? Theme.Colors.statusActive : .secondary)

                Text(command)
                    .font(Theme.Typography.metaMono)
                    .foregroundStyle(isCopied ? Theme.Colors.statusActive : Color.primary.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(
                        isCopied ? Theme.Colors.statusActive.opacity(0.3) : Color.primary.opacity(0.06),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .help("Click to copy: \(command)")
    }

    private func specTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Color.secondary.opacity(0.75))

            Text(value)
                .font(Theme.Typography.metaMono)
                .foregroundStyle(Color.primary.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
    }

    private var safetyStatusBanner: some View {
        HStack(spacing: 5) {
            if let container = item.container {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Color.blue)
                Text("Docker Container • Stop via docker stop \(container.name)")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Color.blue)
                    .lineLimit(1)
            } else if let reason = readOnlyReason {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Theme.Colors.killRed)
                Text("Protected process (\(reason.label)) • Cannot be killed")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Theme.Colors.killRed)
                    .lineLimit(1)
            } else {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Theme.Colors.statusActive)
                Text("Owned by you • Safe to terminate")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Theme.Colors.statusActive)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    item.container != nil ? Color.blue.opacity(0.08) :
                    (readOnlyReason != nil ? Theme.Colors.killRedBackground : Theme.Colors.statusActive.opacity(0.08))
                )
        )
    }

    private func formatDisplayPath(_ path: String) -> String {
        let home = NSHomeDirectory()
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    private func flash(_ flag: Binding<Bool>) {
        flag.wrappedValue = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            flag.wrappedValue = false
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
