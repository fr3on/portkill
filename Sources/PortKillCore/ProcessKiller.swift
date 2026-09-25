import Darwin
import Foundation

public enum KillError: Error, Equatable {
    case notAllowed(ReadOnlyReason)
    case permissionDenied
    case processChanged
    case failed(Int32)
}

public struct ProcessKiller: Sendable {
    public let policy: KillPolicy

    public init(policy: KillPolicy = KillPolicy()) {
        self.policy = policy
    }

    public func terminate(_ port: ListeningPort) throws {
        try send(SIGTERM, to: port)
    }

    public func forceKill(_ port: ListeningPort) throws {
        try send(SIGKILL, to: port)
    }

    public static func isAlive(pid: Int) -> Bool {
        kill(pid_t(pid), 0) == 0 || errno == EPERM
    }

    private func send(_ signal: Int32, to port: ListeningPort) throws {
        if let reason = policy.readOnlyReason(for: port) { throw KillError.notAllowed(reason) }
        guard ProcessIdentity.matches(port) else {
            // Gone entirely is fine; a different process behind the same pid must not be signalled.
            if ProcessIdentity.current(pid: port.pid) == nil { return }
            throw KillError.processChanged
        }
        guard kill(pid_t(port.pid), signal) != 0 else { return }
        switch errno {
        case ESRCH: return // already gone
        case EPERM: throw KillError.permissionDenied
        default: throw KillError.failed(errno)
        }
    }
}
