import Foundation

public enum ProcessMemory {
    /// Parses `ps -o pid=,etime=,rss=` lines into resident memory in bytes. `rss` is in KB.
    public static func bytes(fromPS output: String) -> [Int: UInt64] {
        var result: [Int: UInt64] = [:]
        for line in output.split(whereSeparator: \.isNewline) {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 3, let pid = Int(parts[0]), let kilobytes = UInt64(parts[parts.count - 1]) else { continue }
            result[pid] = kilobytes * 1024
        }
        return result
    }

    /// `142 MB`, `1.2 GB`. Uses 1024-based units, like Activity Monitor.
    public static func format(_ bytes: UInt64?) -> String? {
        guard let bytes else { return nil }
        let megabytes = Double(bytes) / 1_048_576
        switch megabytes {
        case ..<1: return "<1 MB"
        case ..<1000: return "\(Int(megabytes.rounded())) MB"
        default: return String(format: "%.1f GB", megabytes / 1024)
        }
    }
}
