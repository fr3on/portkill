import Foundation

public enum DockerPorts {
    /// Listeners that are really Docker's port proxy. Killing these would take down the whole engine.
    public static func isProxy(command: String) -> Bool {
        command.hasPrefix("com.docker") || command.contains("OrbStack")
    }

    /// Parses `docker ps --format '{{.Names}}\t{{.Image}}\t{{.Ports}}'` into host port -> container.
    /// Handles `0.0.0.0:8080->80/tcp, [::]:8080->80/tcp` and ranges like `5432-5434->5432-5434/tcp`.
    public static func parse(_ output: String) -> [Int: ContainerInfo] {
        var result: [Int: ContainerInfo] = [:]
        for line in output.split(whereSeparator: \.isNewline) {
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard columns.count >= 3, isValidContainerName(columns[0]) else { continue }
            let info = ContainerInfo(name: columns[0], image: columns[1])
            for mapping in columns[2].split(separator: ",") {
                guard let arrow = mapping.range(of: "->") else { continue }
                let host = mapping[..<arrow.lowerBound]
                guard let colon = host.lastIndex(of: ":") else { continue }
                for port in ports(in: host[host.index(after: colon)...]) where result[port] == nil {
                    result[port] = info
                }
            }
        }
        return result
    }

    /// Docker's own naming rule. Names end up in a copyable `docker stop <name>`, so anything else is dropped.
    public static func isValidContainerName(_ name: String) -> Bool {
        guard let first = name.unicodeScalars.first, first.properties.numericType != nil || isAlnum(first) else { return false }
        return name.unicodeScalars.allSatisfy { isAlnum($0) || $0 == "_" || $0 == "." || $0 == "-" }
    }

    private static func isAlnum(_ scalar: Unicode.Scalar) -> Bool {
        (scalar.value >= 48 && scalar.value <= 57) || (scalar.value >= 65 && scalar.value <= 90) || (scalar.value >= 97 && scalar.value <= 122)
    }

    private static func ports(in spec: Substring) -> [Int] {
        let bounds = spec.split(separator: "-").compactMap { Int($0) }
        switch bounds.count {
        case 1: return [bounds[0]]
        case 2 where bounds[0] <= bounds[1] && bounds[1] - bounds[0] < 1000: return Array(bounds[0]...bounds[1])
        default: return []
        }
    }
}

/// Asks the local Docker daemon which containers publish which ports. The CLI is always pointed at a local
/// unix socket, so a remote `DOCKER_HOST` or context is never used, and the binary must be trusted.
public actor DockerResolver {
    public static let candidatePaths = [
        "/usr/local/bin/docker",
        "/opt/homebrew/bin/docker",
        "/Applications/Docker.app/Contents/Resources/bin/docker",
        "\(NSHomeDirectory())/.docker/bin/docker",
        "\(NSHomeDirectory())/.orbstack/bin/docker",
    ]

    public static let candidateSockets = [
        "/var/run/docker.sock",
        "\(NSHomeDirectory())/.docker/run/docker.sock",
        "\(NSHomeDirectory())/.orbstack/run/docker.sock",
        "\(NSHomeDirectory())/.colima/default/docker.sock",
    ]

    /// Executable, owned by the current user or root, and not group/world-writable, after following symlinks.
    public static func isTrustedExecutable(_ path: String, currentUID: UInt32 = getuid()) -> Bool {
        let resolved = URL(fileURLWithPath: path).resolvingSymlinksInPath().path
        guard FileManager.default.isExecutableFile(atPath: resolved),
              let attributes = try? FileManager.default.attributesOfItem(atPath: resolved),
              let mode = attributes[.posixPermissions] as? NSNumber,
              let owner = attributes[.ownerAccountID] as? NSNumber
        else { return false }
        let ownerID = owner.uint32Value
        return mode.uint16Value & 0o022 == 0 && (ownerID == currentUID || ownerID == 0)
    }

    private let runner: any CommandRunning
    private let executable: String?
    private let socket: String?
    private let ttl: TimeInterval
    private var cache: (date: Date, containers: [Int: ContainerInfo])?

    public init(
        runner: any CommandRunning = CommandRunner(timeout: .seconds(3)),
        executable: String? = DockerResolver.candidatePaths.first { DockerResolver.isTrustedExecutable($0) },
        socket: String? = DockerResolver.candidateSockets.first { FileManager.default.fileExists(atPath: $0) },
        ttl: TimeInterval = 5
    ) {
        self.runner = runner
        self.executable = executable
        self.socket = socket
        self.ttl = ttl
    }

    public func containers(now: Date = Date()) async -> [Int: ContainerInfo] {
        guard let executable, let socket else { return [:] }
        if let cache, now.timeIntervalSince(cache.date) < ttl { return cache.containers }
        let output = try? await runner.run(
            executable,
            arguments: ["-H", "unix://\(socket)", "ps", "--format", "{{.Names}}\t{{.Image}}\t{{.Ports}}"]
        )
        let containers = output.map(DockerPorts.parse) ?? [:]
        cache = (now, containers)
        return containers
    }
}
