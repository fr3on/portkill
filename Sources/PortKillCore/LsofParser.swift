import Foundation

/// Parses `lsof -F pcuLn` output: one field per line, the first character is the field id.
/// `p` starts a process record; `c`, `u`, `L` describe it; each `n` is one listening socket.
public enum LsofParser {
    public static func parseListeningPorts(_ output: String) -> [ListeningPort] {
        var results: [ListeningPort] = []
        var seen = Set<String>()

        var pid: Int?
        var command = ""
        var uid: UInt32 = 0
        var user = ""

        for line in output.split(whereSeparator: \.isNewline) {
            guard let tag = line.first else { continue }
            let value = String(line.dropFirst())

            switch tag {
            case "p":
                pid = Int(value)
                command = ""
                uid = 0
                user = ""
            case "c":
                command = decodeCommand(value)
            case "u":
                uid = UInt32(value) ?? 0
            case "L":
                user = value
            case "n":
                guard let pid, let port = port(fromName: value) else { continue }
                let entry = ListeningPort(port: port, pid: pid, command: command, uid: uid, user: user)
                if seen.insert(entry.id).inserted { results.append(entry) }
            default:
                continue
            }
        }
        return results.sorted { ($0.port, $0.pid) < ($1.port, $1.pid) }
    }

    /// Parses `lsof -Fpn -d cwd` output into pid -> working directory.
    public static func parseWorkingDirectories(_ output: String) -> [Int: String] {
        var result: [Int: String] = [:]
        var pid: Int?
        for line in output.split(whereSeparator: \.isNewline) {
            let value = String(line.dropFirst())
            switch line.first {
            case "p": pid = Int(value)
            case "n": if let pid { result[pid] = value }
            default: continue
            }
        }
        return result
    }

    /// Handles `*:3000`, `127.0.0.1:3000` and `[::1]:3000`.
    static func port(fromName name: String) -> Int? {
        guard let colon = name.lastIndex(of: ":") else { return nil }
        return Int(name[name.index(after: colon)...])
    }

    /// lsof escapes spaces and non-printables in command names as `\xNN`.
    static func decodeCommand(_ raw: String) -> String {
        guard raw.contains("\\x") else { return raw }
        var bytes: [UInt8] = []
        var index = raw.startIndex
        while index < raw.endIndex {
            if raw[index...].hasPrefix("\\x"),
               let hexStart = raw.index(index, offsetBy: 2, limitedBy: raw.endIndex),
               let hexEnd = raw.index(hexStart, offsetBy: 2, limitedBy: raw.endIndex),
               let byte = UInt8(raw[hexStart..<hexEnd], radix: 16) {
                bytes.append(byte)
                index = hexEnd
            } else {
                bytes.append(contentsOf: String(raw[index]).utf8)
                index = raw.index(after: index)
            }
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}
