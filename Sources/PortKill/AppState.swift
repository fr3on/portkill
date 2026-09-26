import Foundation
import Observation
import os
import PortKillCore
import ServiceManagement

@MainActor
@Observable
final class AppState {
    var searchQuery: String = ""
    private(set) var settings: Settings
    private(set) var installedTerminals: [TerminalApp]
    private(set) var launchStatus: SMAppService.Status
    var isPopoverVisible = false
    var showUpdateModal = false
    var showAboutModal = false
    private(set) var items: [ListeningPort] = []
    /// Bumped only when a scan changed something visible; keys the grouping cache.
    private(set) var itemsVersion = 0
    /// Ports shown in the menu bar.
    private(set) var badgeCount = 0
    private(set) var cpuPercent: Double?
    private(set) var notice: AppNotice?

    var updateChecker: UpdateChecker { UpdateChecker.shared }

    @ObservationIgnored private let defaults = UserDefaults.standard
    @ObservationIgnored private let scanner = PortScanner()
    @ObservationIgnored private let killer = ProcessKiller()
    @ObservationIgnored private var lastCPUTicks: CPUTicks?
    @ObservationIgnored private var messageTask: Task<Void, Never>?
    @ObservationIgnored private var lastPublish = Date.distantPast
    @ObservationIgnored private var groupCache: (key: GroupKey, value: CategorizedGroups)?

    private struct GroupKey: Equatable {
        let version: Int
        let query: String
        let showSystem: Bool
    }

    @ObservationIgnored private let log = Logger(subsystem: "com.0x200.portkill", category: "app")

    init() {
        settings = Settings.load(from: defaults)
        installedTerminals = []
        launchStatus = SMAppService.mainApp.status
        refreshEnvironment()
    }

    private var policy: KillPolicy { killer.policy }

    var showSystemProcesses: Bool { settings.showSystemProcesses }
    var showMenuBarCount: Bool { settings.showMenuBarCount }
    var showUDP: Bool { settings.showUDP }
    var terminal: TerminalApp { TerminalApp.with(bundleID: settings.terminalBundleID) }

    /// On when registered. `requiresApproval` counts as on: it is registered, the user still has to allow it.
    var launchAtLogin: Bool { launchStatus == .enabled || launchStatus == .requiresApproval }
    var launchNeedsApproval: Bool { launchStatus == .requiresApproval }

    func setShowSystemProcesses(_ value: Bool) { update { $0.showSystemProcesses = value } }
    func setShowMenuBarCount(_ value: Bool) { update { $0.showMenuBarCount = value } }
    func setShowUDP(_ value: Bool) {
        update { $0.showUDP = value }
        Task { await refresh() }
    }
    func setTerminal(_ app: TerminalApp) { update { $0.terminalBundleID = app.bundleID } }

    private func update(_ change: (inout Settings) -> Void) {
        var copy = settings
        change(&copy)
        settings = copy
        copy.save(to: defaults)
    }

    /// Re-reads what can change outside the app: installed terminals and the Login Items state.
    func refreshEnvironment() {
        installedTerminals = TerminalApp.installed
        launchStatus = SMAppService.mainApp.status
        let normalized = settings.normalized(installedTerminals: Set(installedTerminals.map(\.bundleID)))
        if normalized != settings { update { $0 = normalized } }
    }

    /// Unsigned builds can be refused by the system, so failures are shown instead of swallowed.
    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            log.error("launch at login failed: \(String(describing: error), privacy: .public)")
            showNotice(enabled ? "Could not enable Launch at Login" : "Could not disable Launch at Login", style: .error)
        }
        launchStatus = SMAppService.mainApp.status
        if launchNeedsApproval { showNotice("Approve PortKill in Login Items", style: .info) }
    }

    func openLoginItemsSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }

    func openInTerminal(_ project: Project) {
        if !terminal.open(folder: project.path) {
            showNotice("\(terminal.name) not found", style: .error)
        }
    }

    /// One `lsof` every 10 seconds while the popover is closed and the count is shown. It never touches `items`,
    /// so the hidden popover is not re-rendered.
    func runBadgeLoop() async {
        while !Task.isCancelled && showMenuBarCount {
            if !isPopoverVisible, let ports = try? await scanner.scanListeners() {
                badgeCount = Self.devPortCount(ports, policy: policy)
            }
            try? await Task.sleep(for: .seconds(10))
        }
    }

    /// Killable TCP listeners. UDP sockets are opt-in noise and never counted as dev ports.
    private static func devPortCount(_ ports: [ListeningPort], policy: KillPolicy) -> Int {
        ports.filter { $0.transport == .tcp && policy.readOnlyReason(for: $0) == nil }.count
    }

    var visibleItems: [ListeningPort] {
        showSystemProcesses ? items : items.filter { !policy.isSystemOrOtherUser($0) }
    }

    var filteredItems: [ListeningPort] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return visibleItems }
        return visibleItems.filter { item in
            String(item.port).contains(query)
                || item.command.lowercased().contains(query)
                || (item.project?.name.lowercased().contains(query) ?? false)
        }
    }

    var filteredGroups: [ProcessGroup] { categorized.all }

    /// Cached per scan, search and system-process setting. The key is read first so SwiftUI still tracks it.
    var categorized: CategorizedGroups {
        let key = GroupKey(version: itemsVersion, query: searchQuery, showSystem: showSystemProcesses)
        if let cache = groupCache, cache.key == key { return cache.value }
        let value = CategorizedGroups(ProcessGroup.group(filteredItems))
        groupCache = (key, value)
        return value
    }

    var devPortsCount: Int {
        Self.devPortCount(visibleItems, policy: policy)
    }

    func readOnlyReason(for item: ListeningPort) -> ReadOnlyReason? {
        policy.readOnlyReason(for: item)
    }

    /// Runs while the popover is on screen; cancelling the task stops all polling.
    func runRefreshLoop() async {
        log.info("polling started")
        defer { log.info("polling stopped") }
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(for: .seconds(2))
        }
    }

    func refresh() async {
        sampleCPU()
        do {
            publish(try await scanner.scan(includeUDP: settings.showUDP))
        } catch {
            log.error("scan failed: \(String(describing: error), privacy: .public)")
            showNotice("Could not scan ports", style: .error)
        }
    }

    /// Replaces `items` only when something visible changed, or every 30 seconds so uptime labels stay fresh.
    private func publish(_ scanned: [ListeningPort]) {
        let now = Date()
        guard now.timeIntervalSince(lastPublish) >= 30 || !ScanDiff.isEquivalent(scanned, items) else { return }
        items = scanned
        itemsVersion &+= 1
        lastPublish = now
        badgeCount = devPortsCount
    }

    /// Returns false when the kill was refused, so the button can stay in its idle state.
    func terminate(_ item: ListeningPort) -> Bool {
        send { try killer.terminate(item) }
    }

    func forceKill(_ item: ListeningPort) {
        _ = send { try killer.forceKill(item) }
        Task { await refresh() }
    }

    func isAlive(_ item: ListeningPort) -> Bool {
        ProcessKiller.isAlive(pid: item.pid)
    }

    private func send(_ action: () throws -> Void) -> Bool {
        do {
            try action()
            return true
        } catch KillError.permissionDenied {
            showNotice("Permission denied", style: .error)
        } catch KillError.processChanged {
            showNotice("Process changed, refreshing", style: .info)
            Task { await refresh() }
        } catch KillError.notAllowed(let reason) {
            showNotice("\(reason.label) process, not allowed", style: .error)
        } catch {
            showNotice("Could not stop process", style: .error)
        }
        return false
    }

    private func sampleCPU() {
        guard let ticks = CPUTicks.read() else { return }
        if let last = lastCPUTicks, let usage = CPUTicks.usage(from: last, to: ticks) {
            cpuPercent = usage
        }
        lastCPUTicks = ticks
    }

    /// The only network request PortKill makes, and only when the user asks for it. Never call this on launch or on a timer.
    func checkForUpdates(manual: Bool = true) {
        Task {
            if manual {
                showNotice("Checking for updates…", style: .info, duration: 1.5)
            }
            let result = await updateChecker.checkForUpdates(manual: manual)
            if manual {
                switch result {
                case .updateAvailable(let release):
                    showNotice("Update available: v\(release.version)", style: .success, duration: 4.0)
                    showUpdateModal = true
                case .upToDate:
                    showNotice("PortKill is up to date (v\(updateChecker.currentVersion))", style: .success, duration: 3.5)
                case .failed(let error):
                    showNotice("Update check failed: \(error)", style: .error, duration: 4.0)
                }
            }
        }
    }

    func showNotice(_ text: String, style: AppNotice.Style = .info, duration: TimeInterval = 3.5) {
        notice = AppNotice(style: style, text: text)
        messageTask?.cancel()
        messageTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            if !Task.isCancelled { notice = nil }
        }
    }
}

public struct AppNotice: Equatable, Sendable {
    public enum Style: Sendable {
        case success
        case error
        case info
    }
    public let style: Style
    public let text: String

    public init(style: Style, text: String) {
        self.style = style
        self.text = text
    }
}
