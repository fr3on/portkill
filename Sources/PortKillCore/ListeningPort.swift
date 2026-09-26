import Foundation

public enum TransportProtocol: String, Sendable, Hashable {
    case tcp
    case udp
}

public struct ContainerInfo: Hashable, Sendable {
    public let name: String
    public let image: String

    public init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}

public struct ListeningPort: Identifiable, Hashable, Sendable {
    public let port: Int
    public let pid: Int
    public let command: String
    public let uid: UInt32
    public let user: String
    public private(set) var startedAt: Date?
    public private(set) var project: Project?
    public private(set) var memoryBytes: UInt64?
    public let transport: TransportProtocol
    public private(set) var container: ContainerInfo?

    /// TCP ids stay `pid:port`; UDP adds a suffix so both can exist on the same port.
    public var id: String { transport == .tcp ? "\(pid):\(port)" : "\(pid):\(port)/udp" }
    public var localURLString: String { "http://localhost:\(port)" }

    public init(
        port: Int, pid: Int, command: String, uid: UInt32, user: String,
        startedAt: Date? = nil, project: Project? = nil, memoryBytes: UInt64? = nil,
        transport: TransportProtocol = .tcp, container: ContainerInfo? = nil
    ) {
        self.port = port
        self.pid = pid
        self.command = command
        self.uid = uid
        self.user = user
        self.startedAt = startedAt
        self.project = project
        self.memoryBytes = memoryBytes
        self.transport = transport
        self.container = container
    }

    public func withStartDate(_ date: Date?) -> ListeningPort { changing { $0.startedAt = date } }
    public func withProject(_ project: Project?) -> ListeningPort { changing { $0.project = project } }
    public func withMemory(_ bytes: UInt64?) -> ListeningPort { changing { $0.memoryBytes = bytes } }
    public func withContainer(_ container: ContainerInfo?) -> ListeningPort { changing { $0.container = container } }

    private func changing(_ change: (inout ListeningPort) -> Void) -> ListeningPort {
        var copy = self
        change(&copy)
        return copy
    }
}
