import Foundation

/// Finds the project behind each pid. Results are cached per process (pid + start time),
/// including "no project", so `lsof` only runs for processes we haven't seen yet.
public actor ProjectResolver {
    private struct Key: Hashable {
        let pid: Int
        let startedAt: Date?
    }

    private let runner: any CommandRunning
    private let homeDirectory: String
    private var cache: [Key: Project?] = [:]

    public init(runner: any CommandRunning = CommandRunner(), homeDirectory: String = NSHomeDirectory()) {
        self.runner = runner
        self.homeDirectory = homeDirectory
    }

    public func resolve(_ ports: [ListeningPort]) async -> [ListeningPort] {
        let unseen = Set(ports.filter { cache[key(for: $0)] == nil }.map(\.pid))
        if !unseen.isEmpty {
            let directories = await workingDirectories(for: unseen)
            for port in ports where unseen.contains(port.pid) {
                let project = directories[port.pid].flatMap {
                    ProjectDetector.project(forWorkingDirectory: $0, homeDirectory: homeDirectory)
                }
                cache[key(for: port)] = .some(project)
            }
        }
        // Forget processes that are gone.
        let live = Set(ports.map(key(for:)))
        cache = cache.filter { live.contains($0.key) }

        return ports.map { $0.withProject(cache[key(for: $0)] ?? nil) }
    }

    private func key(for port: ListeningPort) -> Key {
        Key(pid: port.pid, startedAt: port.startedAt.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970.rounded()) })
    }

    private func workingDirectories(for pids: Set<Int>) async -> [Int: String] {
        let list = pids.sorted().map(String.init).joined(separator: ",")
        guard let output = try? await runner.run("/usr/sbin/lsof", arguments: ["-a", "-p", list, "-d", "cwd", "-Fpn"]) else {
            return [:]
        }
        return LsofParser.parseWorkingDirectories(output)
    }
}
