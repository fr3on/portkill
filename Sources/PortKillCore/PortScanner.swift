import Foundation

public struct PortScanner: Sendable {
    private let runner: any CommandRunning
    private let projects: ProjectResolver
    private let docker: DockerResolver

    public init(runner: any CommandRunning = CommandRunner(), projects: ProjectResolver? = nil, docker: DockerResolver? = nil) {
        self.runner = runner
        self.projects = projects ?? ProjectResolver(runner: runner)
        self.docker = docker ?? DockerResolver()
    }

    /// TCP listeners only, from a single `lsof`. Cheap enough to count ports while the popover is closed.
    public func scanListeners() async throws -> [ListeningPort] {
        let output = try await runner.run("/usr/sbin/lsof", arguments: ["-nP", "-iTCP", "-sTCP:LISTEN", "-F", "pcuLnP"])
        return LsofParser.parseListeningPorts(output)
    }

    /// `includeUDP` adds bound UDP sockets. They are noisy, so callers opt in.
    public func scan(includeUDP: Bool = false) async throws -> [ListeningPort] {
        let output = try await runner.run(
            "/usr/sbin/lsof",
            arguments: ["-nP", "-iTCP", "-sTCP:LISTEN", "-F", "pcuLnP"]
        )
        var ports = LsofParser.parseListeningPorts(output)
        if includeUDP, let udp = try? await runner.run("/usr/sbin/lsof", arguments: ["-nP", "-iUDP", "-F", "pcuLnP"]) {
            ports = (ports + LsofParser.parseListeningPorts(udp)).sorted {
                ($0.port, $0.pid, $0.transport.rawValue) < ($1.port, $1.pid, $1.transport.rawValue)
            }
        }
        guard !ports.isEmpty else { return [] }

        let pids = Set(ports.map(\.pid))
        let stats = await processStats(for: pids)
        let timed = ports.map {
            $0.withStartDate(stats.startDates[$0.pid]).withMemory(stats.memory[$0.pid])
        }
        let resolved = await projects.resolve(timed)
        return await attachContainers(to: resolved)
    }

    /// Only asks Docker when a Docker proxy is actually listening.
    private func attachContainers(to ports: [ListeningPort]) async -> [ListeningPort] {
        guard ports.contains(where: { DockerPorts.isProxy(command: $0.command) }) else { return ports }
        let containers = await docker.containers()
        guard !containers.isEmpty else { return ports }
        return ports.map { port in
            guard DockerPorts.isProxy(command: port.command), let container = containers[port.port] else { return port }
            return port.withContainer(container)
        }
    }

    /// One `ps` call for all pids; a failure only costs us the uptime and memory labels.
    private func processStats(for pids: Set<Int>) async -> (startDates: [Int: Date], memory: [Int: UInt64]) {
        let list = pids.sorted().map(String.init).joined(separator: ",")
        guard let output = try? await runner.run("/bin/ps", arguments: ["-o", "pid=,etime=,rss=", "-p", list]) else {
            return ([:], [:])
        }
        return (ProcessTiming.startDates(fromPS: output, now: Date()), ProcessMemory.bytes(fromPS: output))
    }
}
