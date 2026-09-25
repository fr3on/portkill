import Foundation
import Testing
@testable import PortKillCore

struct EndToEndTests {
    /// Starts a real listener inside a throwaway project folder and checks the scanner attributes it correctly.
    @Test func realListenerIsAttributedToItsProjectFolder() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("pk-e2e-\(UUID().uuidString)").standardizedFileURL
        let project = root.appendingPathComponent("demo-service/src")
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: root.appendingPathComponent("demo-service/package.json").path, contents: Data())
        defer { try? FileManager.default.removeItem(at: root) }

        let child = Process()
        child.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        child.arguments = ["-c", "import socket,time;s=socket.socket();s.bind(('127.0.0.1',0));s.listen();print(s.getsockname()[1],flush=True);time.sleep(60)"]
        child.currentDirectoryURL = project
        let out = Pipe()
        child.standardOutput = out
        try child.run()
        defer { child.terminate() }

        let line = String(decoding: out.fileHandleForReading.availableData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        let port = try #require(Int(line))

        let all = try await PortScanner().scan()
        let found = all.first { $0.pid == Int(child.processIdentifier) && $0.port == port }
        let entry = try #require(found)
        #expect(entry.project?.name == "demo-service")
        #expect(entry.startedAt != nil)
        #expect(KillPolicy().readOnlyReason(for: entry) == nil)
    }
}
