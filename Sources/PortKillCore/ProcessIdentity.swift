import Darwin
import Foundation

/// Guards against PID reuse: a pid seen in a scan may belong to a different process by the time the user clicks Kill.
public enum ProcessIdentity {
    /// Start time and name of the process currently holding `pid`, or nil if it no longer exists.
    public static func current(pid: Int) -> (startedAt: Date, name: String)? {
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        guard proc_pidinfo(pid_t(pid), PROC_PIDTBSDINFO, 0, &info, size) == size else { return nil }
        let started = Date(timeIntervalSince1970: TimeInterval(info.pbi_start_tvsec))
        let name = withUnsafePointer(to: info.pbi_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXCOMLEN) * 2) { String(cString: $0) }
        }
        return (started, name)
    }

    /// True when `pid` still refers to the process we scanned. The scan derives start time from `ps` elapsed
    /// seconds, so allow a few seconds of skew. Unknown start time cannot be checked and is treated as matching.
    public static func matches(_ port: ListeningPort, tolerance: TimeInterval = 5) -> Bool {
        guard let live = current(pid: port.pid) else { return false }
        guard let expected = port.startedAt else { return true }
        return abs(live.startedAt.timeIntervalSince(expected)) <= tolerance
    }
}
