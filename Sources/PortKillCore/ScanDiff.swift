import Foundation

/// Whether a new scan differs from the last in anything the UI shows. Start times are derived as
/// "now minus elapsed" and drift by about a second between scans, so exact equality would always fail.
public enum ScanDiff {
    public static func isEquivalent(_ a: [ListeningPort], _ b: [ListeningPort], startTolerance: TimeInterval = 3) -> Bool {
        guard a.count == b.count else { return false }
        return zip(a, b).allSatisfy { isEquivalent($0, $1, startTolerance: startTolerance) }
    }

    /// Only a change bigger than 2 MB or 3% is worth a redraw.
    static func isMemoryEquivalent(_ a: UInt64?, _ b: UInt64?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case let (l?, r?):
            let difference = l > r ? l - r : r - l
            return difference <= max(2 * 1_048_576, max(l, r) / 33)
        default: return false
        }
    }

    static func isEquivalent(_ x: ListeningPort, _ y: ListeningPort, startTolerance: TimeInterval) -> Bool {
        guard x.id == y.id, x.command == y.command, x.uid == y.uid, x.user == y.user,
              x.project == y.project, x.container == y.container
        else { return false }
        guard isMemoryEquivalent(x.memoryBytes, y.memoryBytes) else { return false }
        switch (x.startedAt, y.startedAt) {
        case (nil, nil): return true
        case let (l?, r?): return abs(l.timeIntervalSince(r)) <= startTolerance
        default: return false
        }
    }
}
