import Darwin
import Foundation
import IOKit

struct SystemHardware: Sendable {
    let chipName: String
    let coreCount: Int
    let gpuCoreCount: Int?
    let totalMemoryFormatted: String
    let memoryBytes: UInt64
    /// Rough peak FP32 estimate; nil when the chip generation or GPU core count is unknown.
    let tflopsFormatted: String?

    static let current: SystemHardware = {
        let chip = getChipName()
        let cores = ProcessInfo.processInfo.activeProcessorCount
        let mem = ProcessInfo.processInfo.physicalMemory
        let gpuCores = getGPUCoreCount()
        let tflopsStr = estimateTFLOPS(chipName: chip, gpuCores: gpuCores).map { String(format: "~%.1f TFLOPS", $0) }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB]
        formatter.countStyle = .memory
        let memString = formatter.string(fromByteCount: Int64(mem))

        return SystemHardware(
            chipName: chip,
            coreCount: cores,
            gpuCoreCount: gpuCores,
            totalMemoryFormatted: memString,
            memoryBytes: mem,
            tflopsFormatted: tflopsStr
        )
    }()

    private static func getChipName() -> String {
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        guard size > 0 else { return "Apple Silicon" }

        var buffer = [CChar](repeating: 0, count: Int(size))
        let result = sysctlbyname("machdep.cpu.brand_string", &buffer, &size, nil, 0)
        if result == 0 {
            let name = buffer.withUnsafeBufferPointer { ptr in
                ptr.baseAddress.map { String(cString: $0) } ?? ""
            }.trimmingCharacters(in: .whitespacesAndNewlines)

            if !name.isEmpty { return name }
        }
        return "Apple Silicon"
    }

    private static func getGPUCoreCount() -> Int? {
        let matchDict = IOServiceMatching("IOAccelerator")
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess else {
            return nil
        }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            if let prop = IORegistryEntryCreateCFProperty(service, "gpu-core-count" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() {
                if let count = prop as? Int {
                    return count
                } else if let num = prop as? NSNumber {
                    return num.intValue
                }
            }
        }
        return nil
    }

    /// Per-GPU-core FP32 throughput for M1 through M4. Newer or non-Apple chips return nil rather than a guess.
    private static func estimateTFLOPS(chipName: String, gpuCores: Int?) -> Double? {
        guard let gpuCores, chipName.hasPrefix("Apple M") else { return nil }
        let perCore: Double
        switch chipName.dropFirst("Apple M".count).first {
        case "1": perCore = 0.327
        case "2": perCore = 0.358
        case "3": perCore = 0.41
        case "4": perCore = 0.46
        default: return nil
        }
        return Double(gpuCores) * perCore
    }
}
