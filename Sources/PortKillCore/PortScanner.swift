import Foundation

public struct PortScanner: Sendable {
    private let runner: any CommandRunning
    private let projects: ProjectResolver

    public init(runner: any CommandRunning = CommandRunner(), projects: ProjectResolver? = nil) {
        self.runner = runner
        self.projects = projects ?? ProjectResolver(runner: runner)
    }

    public func scan() async throws -> [ListeningPort] {
        let output = try await runner.run(
            "/usr/sbin/lsof",
            arguments: ["-nP", "-iTCP", "-sTCP:LISTEN", "-F", "pcuLn"]
        )
        let ports = LsofParser.parseListeningPorts(output)
        guard !ports.isEmpty else { return [] }

        let pids = Set(ports.map(\.pid))
        let startDates = await startDates(for: pids)
        let timed = ports.map { $0.withStartDate(startDates[$0.pid]) }
        return await projects.resolve(timed)
    }

    /// One `ps` call for all pids; a failure only costs us the uptime label.
    private func startDates(for pids: Set<Int>) async -> [Int: Date] {
        let list = pids.sorted().map(String.init).joined(separator: ",")
        guard let output = try? await runner.run("/bin/ps", arguments: ["-o", "pid=,etime=", "-p", list]) else {
            return [:]
        }
        return ProcessTiming.startDates(fromPS: output, now: Date())
    }
}
