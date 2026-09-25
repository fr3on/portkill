import SwiftUI

struct MainPopoverView: View {
    let state: AppState
    @UIState private var isHardwareExpanded: Bool = false
    @UIState private var isOnScreen: Bool = false

    var body: some View {
        @Bindable var state = state

        VStack(spacing: 0) {
            // Clean, well-padded search header pinned to top
            SearchHeader(query: $state.searchQuery)
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .layoutPriority(1)

            Divider()
                .overlay(Theme.Colors.rowSeparator)

            // Scrollable process list fills all remaining middle space
            ScrollView {
                Group {
                    if state.filteredItems.isEmpty {
                        EmptyStateView(query: state.searchQuery)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                    } else {
                        LazyVStack(spacing: 4) {
                            ForEach(state.filteredItems) { item in
                                ProcessRowView(
                                    item: item,
                                    readOnlyReason: state.readOnlyReason(for: item),
                                    onKill: { state.terminate(item) },
                                    onForceKill: { state.forceKill(item) },
                                    isAlive: { state.isAlive(item) }
                                )
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

            // Pinned bottom telemetry & status section
            VStack(spacing: 8) {
                HardwareSpecsView(cpuPercent: state.cpuPercent, isExpanded: $isHardwareExpanded)
                StatusBarFooter(activeDevCount: state.devPortsCount, message: state.message)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .layoutPriority(1)
        }
        .frame(width: Theme.Dimensions.popoverWidth, height: Theme.Dimensions.popoverHeight)
        .background(
            ZStack {
                VisualEffectBackground()
                Color(nsColor: .windowBackgroundColor)
            }
        )
        .background(WindowVisibilityReader { isOnScreen = $0 })
        // Show data as soon as the view exists, then poll only while the popover is on screen.
        .task { await state.refresh() }
        .task(id: isOnScreen) {
            guard isOnScreen else { return }
            await state.runRefreshLoop()
        }
    }
}

