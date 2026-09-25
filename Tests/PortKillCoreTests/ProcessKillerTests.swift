import Foundation
import Testing
@testable import PortKillCore

struct ProcessKillerTests {
    private func spawnSleeper() throws -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process.arguments = ["60"]
        try process.run()
        return process
    }

    @Test func terminateStopsAnOwnedProcess() throws {
        let child = try spawnSleeper()
        defer { if child.isRunning { child.terminate() } }
        let target = ListeningPort(port: 1, pid: Int(child.processIdentifier), command: "sleep", uid: getuid(), user: "me")

        #expect(ProcessKiller.isAlive(pid: target.pid))
        try ProcessKiller().terminate(target)
        child.waitUntilExit()
        #expect(!ProcessKiller.isAlive(pid: target.pid))
    }

    @Test func killingAnAlreadyGoneProcessIsNotAnError() throws {
        let child = try spawnSleeper()
        child.terminate()
        child.waitUntilExit()
        let target = ListeningPort(port: 1, pid: Int(child.processIdentifier), command: "sleep", uid: getuid(), user: "me")
        try ProcessKiller().terminate(target)
    }

    @Test func refusesToSignalAReusedPID() throws {
        let child = try spawnSleeper()
        defer { child.terminate() }
        let pid = Int(child.processIdentifier)
        // The scan thinks this pid started an hour ago, but the live process started just now.
        let stale = ListeningPort(port: 1, pid: pid, command: "sleep", uid: getuid(), user: "me", startedAt: Date().addingTimeInterval(-3600))

        #expect(throws: KillError.processChanged) { try ProcessKiller().terminate(stale) }
        #expect(throws: KillError.processChanged) { try ProcessKiller().forceKill(stale) }
        #expect(ProcessKiller.isAlive(pid: pid))
    }

    @Test func identityMatchesTheLiveProcessWithinTolerance() throws {
        let child = try spawnSleeper()
        defer { child.terminate() }
        let pid = Int(child.processIdentifier)
        let live = try #require(ProcessIdentity.current(pid: pid))
        #expect(live.name == "sleep")

        let fresh = ListeningPort(port: 1, pid: pid, command: "sleep", uid: getuid(), user: "me", startedAt: live.startedAt.addingTimeInterval(2))
        #expect(ProcessIdentity.matches(fresh))
        let unknownStart = ListeningPort(port: 1, pid: pid, command: "sleep", uid: getuid(), user: "me")
        #expect(ProcessIdentity.matches(unknownStart))
    }
}
