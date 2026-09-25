import Darwin
import Foundation

public struct CPUTicks: Sendable, Equatable {
    public let active: UInt64
    public let total: UInt64

    public init(active: UInt64, total: UInt64) {
        self.active = active
        self.total = total
    }

    /// Cumulative ticks since boot. Compare two samples with `usage(from:to:)`.
    public static func read() -> CPUTicks? {
        var processorCount: natural_t = 0
        var infoCount: mach_msg_type_number_t = 0
        var info: processor_info_array_t?

        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount, &info, &infoCount)
        guard result == KERN_SUCCESS, let info else { return nil }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: info)),
                vm_size_t(Int(infoCount) * MemoryLayout<integer_t>.size)
            )
        }

        var active: UInt64 = 0
        var idle: UInt64 = 0
        for cpu in 0..<Int(processorCount) {
            let base = cpu * Int(CPU_STATE_MAX)
            active += UInt64(info[base + Int(CPU_STATE_USER)])
            active += UInt64(info[base + Int(CPU_STATE_SYSTEM)])
            active += UInt64(info[base + Int(CPU_STATE_NICE)])
            idle += UInt64(info[base + Int(CPU_STATE_IDLE)])
        }
        return CPUTicks(active: active, total: active + idle)
    }

    /// Load between two samples, 0...100. nil when no time passed.
    public static func usage(from old: CPUTicks, to new: CPUTicks) -> Double? {
        guard new.total > old.total, new.active >= old.active else { return nil }
        return Double(new.active - old.active) / Double(new.total - old.total) * 100
    }
}
