import Foundation
import Observation
import os
import PortKillCore

@MainActor
@Observable
final class AppState {
    var searchQuery: String = ""
    var showSystemProcesses = false
    private(set) var items: [ListeningPort] = []
    private(set) var cpuPercent: Double?
    private(set) var message: String?

    @ObservationIgnored private let scanner = PortScanner()
    @ObservationIgnored private let killer = ProcessKiller()
    @ObservationIgnored private var lastCPUTicks: CPUTicks?
    @ObservationIgnored private var messageTask: Task<Void, Never>?

    @ObservationIgnored private let log = Logger(subsystem: "com.75bit.portkill", category: "app")

    private var policy: KillPolicy { killer.policy }

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

    var devPortsCount: Int {
        visibleItems.filter { policy.readOnlyReason(for: $0) == nil }.count
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
            items = try await scanner.scan()
        } catch {
            log.error("scan failed: \(String(describing: error), privacy: .public)")
            show("Could not scan ports")
        }
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
            show("Permission denied")
        } catch KillError.processChanged {
            show("Process changed, refreshing")
            Task { await refresh() }
        } catch KillError.notAllowed(let reason) {
            show("\(reason.label) process, not allowed")
        } catch {
            show("Could not stop process")
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

    private func show(_ text: String) {
        message = text
        messageTask?.cancel()
        messageTask = Task {
            try? await Task.sleep(for: .seconds(4))
            if !Task.isCancelled { message = nil }
        }
    }
}
