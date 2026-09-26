import Foundation

public enum ProcessTiming {
    /// Parses `ps -o pid=,etime=[,...]` lines into start dates (now minus elapsed time).
    public static func startDates(fromPS output: String, now: Date) -> [Int: Date] {
        var result: [Int: Date] = [:]
        for line in output.split(whereSeparator: \.isNewline) {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 2, let pid = Int(parts[0]), let seconds = elapsedSeconds(String(parts[1])) else { continue }
            result[pid] = now.addingTimeInterval(-TimeInterval(seconds))
        }
        return result
    }

    /// Accepts `SS`, `MM:SS`, `HH:MM:SS` and `D-HH:MM:SS`.
    static func elapsedSeconds(_ etime: String) -> Int? {
        var days = 0
        var rest = Substring(etime)
        if let dash = rest.firstIndex(of: "-") {
            guard let d = Int(rest[..<dash]) else { return nil }
            days = d
            rest = rest[rest.index(after: dash)...]
        }
        let fields = rest.split(separator: ":").map { Int($0) }
        guard !fields.isEmpty, fields.count <= 3, !fields.contains(nil) else { return nil }
        let values = fields.compactMap { $0 }
        let seconds = values.reduce(0) { $0 * 60 + $1 }
        return days * 86_400 + seconds
    }

    public static func format(uptime start: Date?, now: Date = Date()) -> String {
        guard let start else { return "–" }
        let seconds = max(0, Int(now.timeIntervalSince(start)))
        switch seconds {
        case ..<60: return "\(seconds)s"
        case ..<3600: return "\(seconds / 60)m"
        case ..<86_400: return "\(seconds / 3600)h \(String(format: "%02d", seconds % 3600 / 60))m"
        default: return "\(seconds / 86_400)d \(seconds % 86_400 / 3600)h"
        }
    }
}
