import Foundation

public enum ReadOnlyReason: Sendable, Equatable {
    case protectedPID
    case ownProcess
    case otherUser
    case systemProcess
    case dockerContainer

    public var label: String {
        switch self {
        case .protectedPID, .ownProcess: "Protected"
        case .otherUser: "Other user"
        case .systemProcess: "System"
        case .dockerContainer: "Docker"
        }
    }
}

public struct KillPolicy: Sendable {
    public static let systemProcessNames: Set<String> = [
        "ControlCenter", "rapportd", "sharingd", "identityservicesd", "AirPlayXPCHelper",
    ]

    public let currentUID: UInt32
    public let ownPID: Int

    public init(currentUID: UInt32 = getuid(), ownPID: Int = Int(getpid())) {
        self.currentUID = currentUID
        self.ownPID = ownPID
    }

    /// nil means the process may be killed.
    public func readOnlyReason(for port: ListeningPort) -> ReadOnlyReason? {
        if port.pid <= 1 { return .protectedPID }
        if port.pid == ownPID { return .ownProcess }
        // The listener is Docker's proxy; signalling it would stop the engine, not the container.
        // This holds even when the container lookup failed, so the proxy is never offered for killing.
        if port.container != nil || DockerPorts.isProxy(command: port.command) { return .dockerContainer }
        if port.uid != currentUID { return .otherUser }
        if Self.systemProcessNames.contains(port.command) { return .systemProcess }
        return nil
    }

    /// Rows hidden unless the user opts in to seeing system processes.
    public func isSystemOrOtherUser(_ port: ListeningPort) -> Bool {
        switch readOnlyReason(for: port) {
        case .otherUser, .systemProcess: true
        default: false
        }
    }
}
