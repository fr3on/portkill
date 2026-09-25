import Foundation

public struct ListeningPort: Identifiable, Hashable, Sendable {
    public let port: Int
    public let pid: Int
    public let command: String
    public let uid: UInt32
    public let user: String
    public let startedAt: Date?
    public let project: Project?

    public var id: String { "\(pid):\(port)" }
    public var localURLString: String { "http://localhost:\(port)" }

    public init(port: Int, pid: Int, command: String, uid: UInt32, user: String, startedAt: Date? = nil, project: Project? = nil) {
        self.port = port
        self.pid = pid
        self.command = command
        self.uid = uid
        self.user = user
        self.startedAt = startedAt
        self.project = project
    }

    public func withStartDate(_ date: Date?) -> ListeningPort {
        ListeningPort(port: port, pid: pid, command: command, uid: uid, user: user, startedAt: date, project: project)
    }

    public func withProject(_ project: Project?) -> ListeningPort {
        ListeningPort(port: port, pid: pid, command: command, uid: uid, user: user, startedAt: startedAt, project: project)
    }
}
