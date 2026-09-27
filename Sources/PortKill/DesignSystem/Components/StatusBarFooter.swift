import AppKit
import PortKillCore
import SwiftUI

struct StatusBarFooter: View {
    let state: AppState
    var onRefresh: () -> Void = {}
    var onQuit: () -> Void = { NSApplication.shared.terminate(nil) }

    private var activeDevCount: Int { state.devPortsCount }

    @UIState private var isHoveringQuit: Bool = false
    @UIState private var isHoveringRefresh: Bool = false
    @UIState private var isRotatingRefresh: Bool = false

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Group {
                if let notice = state.notice {
                    HStack(spacing: 5) {
                        switch notice.style {
                        case .success:
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundStyle(Theme.Colors.statusActive)
                        case .error:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.Colors.killRed)
                        case .info:
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundStyle(Color.accentColor)
                        }

                        Text(notice.text)
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(noticeTextColor(for: notice.style))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 6.5)
                    .padding(.vertical, 2.5)
                    .background(
                        Capsule()
                            .fill(noticeBackgroundColor(for: notice.style))
                    )
                    .overlay(
                        Capsule()
                            .stroke(noticeBorderColor(for: notice.style), lineWidth: 0.8)
                    )
                    .transition(.opacity)
                } else {
                    HStack(spacing: 6) {
                        ZStack {
                            if activeDevCount > 0 {
                                Circle()
                                    .fill(Theme.Colors.statusActive.opacity(0.25))
                                    .frame(width: 13, height: 13)
                            }
                            Circle()
                                .fill(activeDevCount > 0 ? Theme.Colors.statusActive : Color.secondary.opacity(0.4))
                                .frame(width: 6.5, height: 6.5)
                        }

                        Text(statusText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.secondary.opacity(0.85))
                            .lineLimit(1)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: state.notice != nil)

            Spacer()

            if state.updateChecker.updateAvailable, let release = state.updateChecker.latestRelease {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        state.showUpdateModal = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 9.5, weight: .semibold))
                        Text("v\(release.version)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2.5)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.12))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.accentColor.opacity(0.25), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)
                .help(state.strings.updateAvailableBadgeTooltip(version: release.version))
                .transition(.opacity)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isRotatingRefresh.toggle()
                }
                onRefresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isHoveringRefresh ? Color.primary : Color.secondary.opacity(0.8))
                    .frame(width: 22, height: 22)
                    .rotationEffect(.degrees(isRotatingRefresh ? 360 : 0))
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(isHoveringRefresh ? Color.primary.opacity(0.06) : Color.clear)
                    )
            }
            .buttonStyle(.plain)
            .onHover { isHoveringRefresh = $0 }
            .keyboardShortcut("r", modifiers: .command)
            .help(state.strings.refreshTooltip)
            .accessibilityLabel(state.strings.refreshLabel)

            settingsMenu

            Button {
                onQuit()
            } label: {
                HStack(spacing: 4) {
                    Text(state.strings.quit)
                        .font(.system(size: 11, weight: .medium))

                    HStack(spacing: 1) {
                        Text("⌘")
                        Text("Q")
                    }
                    .font(Theme.Typography.shortcutGlyph)
                    .foregroundStyle(Color.secondary.opacity(0.8))
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
                .foregroundStyle(isHoveringQuit ? Color.primary : Color.secondary.opacity(0.85))
                .padding(.horizontal, 6)
                .padding(.vertical, 3.5)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isHoveringQuit ? Color.primary.opacity(0.06) : Color.clear)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHoveringQuit = $0 }
            .keyboardShortcut("q", modifiers: .command)
            .help(state.strings.quitTooltip)
        }
    }

    private var statusText: String {
        if activeDevCount == 0 {
            return state.strings.noDevPortsActive
        } else if activeDevCount == 1 {
            return state.strings.oneDevPortActive
        } else {
            return state.strings.devPortsActive(count: activeDevCount)
        }
    }

    private var settingsMenu: some View {
        Menu {
            Button(state.strings.aboutPortKill) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    state.showAboutModal = true
                }
            }
            Divider()
            Picker(state.strings.languageTitle, selection: Binding(
                get: { state.settings.language },
                set: { state.setLanguage($0) }
            )) {
                Text("\(state.strings.systemDefault) (\(AppLanguage.resolveSystemLanguage().displayName))")
                    .tag(AppLanguage.system)
                Divider()
                ForEach(AppLanguage.supportedLanguages) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            Divider()
            Toggle(state.strings.launchAtLogin, isOn: Binding(
                get: { state.launchAtLogin },
                set: { state.setLaunchAtLogin($0) }
            ))
            if state.launchNeedsApproval {
                Button(state.strings.approveInLoginItems) { state.openLoginItemsSettings() }
            }
            Toggle(state.strings.showPortCountInMenuBar, isOn: Binding(
                get: { state.showMenuBarCount },
                set: { state.setShowMenuBarCount($0) }
            ))
            Toggle(state.strings.showSystemProcesses, isOn: Binding(
                get: { state.showSystemProcesses },
                set: { state.setShowSystemProcesses($0) }
            ))
            Toggle(state.strings.showUDPSockets, isOn: Binding(
                get: { state.showUDP },
                set: { state.setShowUDP($0) }
            ))
            Divider()
            Picker(state.strings.openIn, selection: Binding(
                get: { state.terminal },
                set: { state.setTerminal($0) }
            )) {
                ForEach(state.installedTerminals) { app in
                    Text(app.name).tag(app)
                }
            }
            Divider()
            Button {
                state.checkForUpdates(manual: true)
            } label: {
                if state.updateChecker.isChecking {
                    Text(state.strings.checkingForUpdates)
                } else {
                    Text(state.strings.checkForUpdates)
                }
            }
            .disabled(state.updateChecker.isChecking)
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.secondary.opacity(0.8))
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help(state.strings.settings)
        .accessibilityLabel(state.strings.settings)
    }

    private func noticeTextColor(for style: AppNotice.Style) -> Color {
        switch style {
        case .success:
            return Color.primary.opacity(0.9)
        case .error:
            return Theme.Colors.killRed
        case .info:
            return Color.primary.opacity(0.9)
        }
    }

    private func noticeBackgroundColor(for style: AppNotice.Style) -> Color {
        switch style {
        case .success:
            return Theme.Colors.statusActive.opacity(0.12)
        case .error:
            return Theme.Colors.killRedBackground
        case .info:
            return Color.accentColor.opacity(0.12)
        }
    }

    private func noticeBorderColor(for style: AppNotice.Style) -> Color {
        switch style {
        case .success:
            return Theme.Colors.statusActive.opacity(0.24)
        case .error:
            return Theme.Colors.killRedBorder
        case .info:
            return Color.accentColor.opacity(0.24)
        }
    }
}
