import PortKillCore
import SwiftUI

struct MainPopoverView: View {
    let state: AppState
    @UIState private var isHardwareExpanded: Bool = false
    @UIState private var isOnScreen: Bool = false
    @FocusState private var searchFocused: Bool
    @AppStorage("popoverHeight") private var popoverHeight: Double = Double(Theme.Dimensions.defaultPopoverHeight)
    @UIState private var selectedCategory: ProcessCategory = .all

    var body: some View {
        @Bindable var state = state

        VStack(spacing: 0) {
            SearchHeader(query: $state.searchQuery, isFocused: $searchFocused)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 7)
                .layoutPriority(1)

            filterChipsBar
                .layoutPriority(1)

            Divider()
                .overlay(Theme.Colors.rowSeparator)

            ScrollView {
                Group {
                    if displayedGroups.isEmpty {
                        EmptyStateView(query: state.searchQuery)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                    } else {
                        LazyVStack(spacing: 5) {
                            if selectedCategory == .all && devGroups.count > 0 && helperGroups.count > 0 {
                                sectionHeader(title: "DEV SERVERS & PROJECTS", count: devGroups.count)
                                ForEach(devGroups) { group in
                                    processRow(for: group)
                                }

                                sectionHeader(title: "BACKGROUND & HELPERS", count: helperGroups.count)
                                    .padding(.top, 6)
                                ForEach(helperGroups) { group in
                                    processRow(for: group)
                                }
                            } else {
                                ForEach(displayedGroups) { group in
                                    processRow(for: group)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .overlay(Theme.Colors.rowSeparator)

            VStack(spacing: 7) {
                HardwareSpecsView(cpuPercent: state.cpuPercent, isExpanded: $isHardwareExpanded)
                StatusBarFooter(
                    activeDevCount: state.devPortsCount,
                    state: state,
                    onRefresh: { Task { await state.refresh() } }
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .layoutPriority(1)

            ResizeHandle(
                height: $popoverHeight,
                defaultHeight: Double(Theme.Dimensions.defaultPopoverHeight),
                minHeight: Double(Theme.Dimensions.minPopoverHeight),
                maxHeight: Double(Theme.Dimensions.maxPopoverHeight)
            )
            .padding(.bottom, 3)
            .layoutPriority(1)
        }
        .frame(width: Theme.Dimensions.popoverWidth, height: CGFloat(popoverHeight))
        .background(
            ZStack {
                VisualEffectBackground(material: .popover, blendingMode: .behindWindow)
                Theme.Colors.surfaceBackground
            }
        )
        .background(WindowVisibilityReader {
            isOnScreen = $0
            state.isPopoverVisible = $0
            if $0 { state.refreshEnvironment() }
        })
        .background {
            // Invisible button that gives the popover its ⌘F shortcut.
            Button("Search") { searchFocused = true }
                .keyboardShortcut("f", modifiers: .command)
                .opacity(0)
                .accessibilityHidden(true)
        }
        .overlay {
            if state.showAboutModal {
                ZStack {
                    Color.black.opacity(0.38)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                state.showAboutModal = false
                            }
                        }

                    AboutModalView(
                        currentVersion: state.updateChecker.currentVersion,
                        onDismiss: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                state.showAboutModal = false
                            }
                        },
                        onCheckUpdates: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                state.showAboutModal = false
                            }
                            state.checkForUpdates(manual: true)
                        }
                    )
                    .padding(14)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else if state.showUpdateModal, let release = state.updateChecker.latestRelease {
                ZStack {
                    Color.black.opacity(0.38)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                state.showUpdateModal = false
                            }
                        }

                    UpdateModalView(
                        release: release,
                        currentVersion: state.updateChecker.currentVersion,
                        onDismiss: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                state.showUpdateModal = false
                            }
                        }
                    )
                    .padding(14)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: state.showUpdateModal)
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: state.showAboutModal)
        // Show data as soon as the view exists, then poll only while the popover is on screen.
        .task { await state.refresh() }
        .task(id: isOnScreen) {
            guard isOnScreen else { return }
            await state.runRefreshLoop()
        }
    }

    // Classified once per scan in `AppState.categorized`, not on every render.
    private var allGroups: [ProcessGroup] { state.categorized.all }
    private var devGroups: [ProcessGroup] { state.categorized.dev }
    private var dockerGroups: [ProcessGroup] { state.categorized.docker }
    private var helperGroups: [ProcessGroup] { state.categorized.helpers }

    private var displayedGroups: [ProcessGroup] {
        switch selectedCategory {
        case .all:
            return devGroups + helperGroups
        case .dev:
            return devGroups
        case .docker:
            return dockerGroups
        case .helpers:
            return helperGroups
        }
    }

    private var filterChipsBar: some View {
        HStack(spacing: 5) {
            chipButton(category: .all, count: allGroups.count)
            chipButton(category: .dev, count: devGroups.count)
            if dockerGroups.count > 0 {
                chipButton(category: .docker, count: dockerGroups.count)
            }
            if helperGroups.count > 0 {
                chipButton(category: .helpers, count: helperGroups.count)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 7)
    }

    private func chipButton(category: ProcessCategory, count: Int) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 3.5) {
                Text(category.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))

                Text("\(count)")
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary.opacity(0.85))
                    .padding(.horizontal, 3.5)
                    .padding(.vertical, 1)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.primary.opacity(0.12) : Color.primary.opacity(0.06))
                    )
            }
            .padding(.horizontal, 6.5)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(isSelected ? Color.primary.opacity(0.10) : Color.primary.opacity(0.035))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(isSelected ? Color.primary.opacity(0.18) : Color.primary.opacity(0.06), lineWidth: 0.8)
            )
            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8.5, weight: .bold))
                .foregroundStyle(Color.secondary.opacity(0.75))
                .tracking(0.4)

            Spacer()

            Text("\(count)")
                .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.secondary.opacity(0.65))
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 1)
    }

    private func processRow(for group: ProcessGroup) -> some View {
        let item = group.primary
        return ProcessRowView(
            item: item,
            extraPorts: Array(group.ports.dropFirst()),
            readOnlyReason: state.readOnlyReason(for: item),
            terminalName: state.terminal.name,
            onOpenTerminal: { state.openInTerminal($0) },
            onKill: { state.terminate(item) },
            onForceKill: { state.forceKill(item) },
            isAlive: { state.isAlive(item) }
        )
    }
}
