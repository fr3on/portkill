import Foundation

/// Terminal one-liners the UI can copy. Termination stays graceful: no `kill -9`.
public enum CommandSnippets {
    public static func terminate(pid: Int) -> String { "kill \(pid)" }

    public static func listeners(port: Int, transport: TransportProtocol = .tcp) -> String {
        transport == .tcp ? "lsof -nP -iTCP:\(port) -sTCP:LISTEN" : "lsof -nP -iUDP:\(port)"
    }

    public static func stopContainer(name: String) -> String { "docker stop \(name)" }
}
