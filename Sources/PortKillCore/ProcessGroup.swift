import Foundation

/// The listeners behind one row: all ports of a process, or of a Docker container.
public struct ProcessGroup: Identifiable, Hashable, Sendable {
    public let ports: [ListeningPort]

    public var primary: ListeningPort { ports[0] }
    public var id: String {
        if let container = primary.container { return "container:\(container.name)" }
        return "pid:\(primary.pid)"
    }

    /// Groups `ports` (already sorted by port) and keeps rows ordered by their lowest port.
    public static func group(_ ports: [ListeningPort]) -> [ProcessGroup] {
        var order: [String] = []
        var buckets: [String: [ListeningPort]] = [:]
        for port in ports {
            let key = port.container.map { "container:\($0.name)" } ?? "pid:\(port.pid)"
            if buckets[key] == nil { order.append(key) }
            buckets[key, default: []].append(port)
        }
        return order.compactMap { key in
            buckets[key].map { members in
                ProcessGroup(ports: members.sorted { (a, b) in
                    (a.port, a.transport.rawValue) < (b.port, b.transport.rawValue)
                })
            }
        }
    }
}
