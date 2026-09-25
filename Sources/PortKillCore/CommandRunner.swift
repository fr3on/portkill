import Foundation

public protocol CommandRunning: Sendable {
    func run(_ executable: String, arguments: [String]) async throws -> String
}

public enum CommandError: Error, Equatable {
    case timedOut(String)
    case launchFailed(String)
}

public struct CommandRunner: CommandRunning {
    public var timeout: Duration

    public init(timeout: Duration = .seconds(5)) {
        self.timeout = timeout
    }

    public func run(_ executable: String, arguments: [String]) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            throw CommandError.launchFailed(executable)
        }

        let timedOut = Flag()
        let timeoutTask = Task {
            try await Task.sleep(for: timeout)
            timedOut.set()
            if process.isRunning { process.terminate() }
        }
        defer { timeoutTask.cancel() }

        // Drain the pipe on a background thread so a large output cannot block the child.
        let data: Data = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                continuation.resume(returning: pipe.fileHandleForReading.readDataToEndOfFile())
            }
        }

        if timedOut.isSet { throw CommandError.timedOut(executable) }
        return String(decoding: data, as: UTF8.self)
    }
}

private final class Flag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false

    var isSet: Bool { lock.withLock { value } }
    func set() { lock.withLock { value = true } }
}
