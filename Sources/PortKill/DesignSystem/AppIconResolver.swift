import AppKit
import Darwin
import Foundation

final class AppIconResolver: @unchecked Sendable {
    static let shared = AppIconResolver()
    private var cache: [Int: NSImage] = [:]
    private let lock = NSLock()

    func icon(for pid: Int) -> NSImage? {
        lock.lock()
        if let cached = cache[pid] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        var iconImage: NSImage?

        // 1. Try kernel proc_pidpath to find enclosing .app bundle
        var buffer = [CChar](repeating: 0, count: 4096)
        let length = proc_pidpath(Int32(pid), &buffer, UInt32(buffer.count))
        if length > 0 {
            let path = buffer.withUnsafeBufferPointer { ptr in
                ptr.baseAddress.map { String(cString: $0) }
            } ?? ""
            if let range = path.range(of: ".app") {
                let appPath = String(path[..<range.upperBound])
                if FileManager.default.fileExists(atPath: appPath) {
                    iconImage = NSWorkspace.shared.icon(forFile: appPath)
                }
            }
        }

        // 2. Fall back to NSRunningApplication
        if iconImage == nil, let running = NSRunningApplication(processIdentifier: pid_t(pid)) {
            if let bundleURL = running.bundleURL {
                let path = bundleURL.path
                if let range = path.range(of: ".app") {
                    let appPath = String(path[..<range.upperBound])
                    if FileManager.default.fileExists(atPath: appPath) {
                        iconImage = NSWorkspace.shared.icon(forFile: appPath)
                    }
                }
            }
            if iconImage == nil {
                iconImage = running.icon
            }
        }

        if let iconImage {
            lock.lock()
            cache[pid] = iconImage
            lock.unlock()
        }

        return iconImage
    }
}
