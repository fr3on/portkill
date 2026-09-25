import Foundation
import Testing
@testable import PortKillCore

private struct StubRunner: CommandRunning {
    let lsof: String
    let ps: String?

    func run(_ executable: String, arguments: [String]) async throws -> String {
        if executable.hasSuffix("lsof") { return lsof }
        guard let ps else { throw CommandError.timedOut(executable) }
        return ps
    }
}

struct PortScannerTests {
    @Test func attachesStartDatesFromPS() async throws {
        let scanner = PortScanner(runner: StubRunner(lsof: "p10\ncnode\nu501\nLme\nn*:3000\n", ps: "10 01:00\n"))
        let ports = try await scanner.scan()
        #expect(ports.count == 1)
        let started = try #require(ports[0].startedAt)
        #expect(abs(Date().timeIntervalSince(started) - 60) < 5)
    }

    @Test func psFailureOnlyDropsTheUptime() async throws {
        let scanner = PortScanner(runner: StubRunner(lsof: "p10\ncnode\nu501\nLme\nn*:3000\n", ps: nil))
        let ports = try await scanner.scan()
        #expect(ports.map(\.port) == [3000])
        #expect(ports[0].startedAt == nil)
    }

    @Test func realLsofRunsAndReturnsValidPorts() async throws {
        let ports = try await PortScanner().scan()
        #expect(ports.allSatisfy { $0.port > 0 && $0.pid > 0 })
    }
}
