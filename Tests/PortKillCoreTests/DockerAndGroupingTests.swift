import Foundation
import Testing
@testable import PortKillCore

struct DockerPortsTests {
    @Test func parsesPublishedPortsAndRanges() {
        let out = """
        web\tnginx:latest\t0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
        db\tpostgres:16\t0.0.0.0:5432-5433->5432-5433/tcp
        idle\talpine\t
        internal\tredis\t6379/tcp
        """
        let map = DockerPorts.parse(out)
        #expect(map[8080] == ContainerInfo(name: "web", image: "nginx:latest"))
        #expect(map[5432]?.name == "db")
        #expect(map[5433]?.name == "db")
        #expect(map[6379] == nil)
        #expect(map.count == 3)
    }

    @Test func dropsContainerNamesThatAreNotSafeToPaste() {
        let out = "ok-name_1.2\tnginx\t0.0.0.0:80->80/tcp\nbad name\tnginx\t0.0.0.0:81->80/tcp\nx;rm -rf ~\tnginx\t0.0.0.0:82->80/tcp\n-lead\tnginx\t0.0.0.0:83->80/tcp\n"
        let map = DockerPorts.parse(out)
        #expect(map.keys.sorted() == [80])
        #expect(DockerPorts.isValidContainerName("web"))
        #expect(!DockerPorts.isValidContainerName("$(id)"))
        #expect(!DockerPorts.isValidContainerName(""))
    }

    @Test func refusesWritableOrForeignDockerBinaries() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("pk-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let bin = dir.appendingPathComponent("docker")
        FileManager.default.createFile(atPath: bin.path, contents: Data("#!/bin/sh\n".utf8))
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: bin.path)
        #expect(DockerResolver.isTrustedExecutable(bin.path, currentUID: getuid()))
        #expect(!DockerResolver.isTrustedExecutable(bin.path, currentUID: getuid() &+ 1))
        try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: bin.path)
        #expect(!DockerResolver.isTrustedExecutable(bin.path, currentUID: getuid()))
        #expect(!DockerResolver.isTrustedExecutable(dir.appendingPathComponent("missing").path))
    }

    @Test func recognisesDockerProxies() {
        #expect(DockerPorts.isProxy(command: "com.docker.backend"))
        #expect(DockerPorts.isProxy(command: "OrbStack Helper"))
        #expect(!DockerPorts.isProxy(command: "node"))
    }

    @Test func containerRowsAreReadOnly() {
        let policy = KillPolicy(currentUID: 501, ownPID: 999)
        let plain = ListeningPort(port: 8080, pid: 50, command: "com.docker.backend", uid: 501, user: "me")
        // Even without a container match the Docker proxy is never killable.
        #expect(policy.readOnlyReason(for: plain) == .dockerContainer)
        #expect(policy.readOnlyReason(for: ListeningPort(port: 3000, pid: 60, command: "node", uid: 501, user: "me")) == nil)
        let container = plain.withContainer(ContainerInfo(name: "web", image: "nginx"))
        #expect(policy.readOnlyReason(for: container) == .dockerContainer)
        #expect(!policy.isSystemOrOtherUser(container))
    }
}

private struct DockerStub: CommandRunning {
    let lsof: String
    let docker: String
    func run(_ executable: String, arguments: [String]) async throws -> String {
        if executable.hasSuffix("lsof") { return lsof }
        if executable.hasSuffix("docker") { return docker }
        throw CommandError.timedOut(executable)
    }
}

struct ScannerDockerTests {
    @Test func attachesContainersToDockerProxyPortsOnly() async throws {
        let lsof = "p50\ncom.docker.backend\nu501\nLme\nn*:8080\np60\ncnode\nu501\nLme\nn*:3000\n"
        let runner = DockerStub(lsof: lsof, docker: "web\tnginx\t0.0.0.0:8080->80/tcp\n")
        let scanner = PortScanner(runner: runner, docker: DockerResolver(runner: runner, executable: "/x/docker", socket: "/x/docker.sock"))
        let ports = try await scanner.scan()
        #expect(ports.first { $0.port == 8080 }?.container?.name == "web")
        #expect(ports.first { $0.port == 3000 }?.container == nil)
    }

    @Test func missingDockerCLILeavesPortsUntouched() async throws {
        let lsof = "p50\ncom.docker.backend\nu501\nLme\nn*:8080\n"
        let runner = DockerStub(lsof: lsof, docker: "")
        let scanner = PortScanner(runner: runner, docker: DockerResolver(runner: runner, executable: nil, socket: nil))
        #expect(try await scanner.scan().first?.container == nil)
    }
}

struct UDPAndGroupingTests {
    @Test func parsesUDPAndSkipsConnectedSockets() {
        let out = "p10\ncdnsmasq\nu501\nLme\nfa\nPUDP\nn*:5353\nfb\nPUDP\nn10.0.0.2:5000->1.1.1.1:53\np11\ncnode\nu501\nLme\nPTCP\nn*:3000\n"
        let ports = LsofParser.parseListeningPorts(out)
        #expect(ports.map(\.port) == [3000, 5353])
        #expect(ports.first { $0.port == 5353 }?.transport == .udp)
        #expect(ports.first { $0.port == 3000 }?.transport == .tcp)
    }

    @Test func tcpAndUDPOnOnePortAreDistinct() {
        let out = "p10\ncdns\nu501\nLme\nPTCP\nn*:53\nPUDP\nn*:53\n"
        #expect(LsofParser.parseListeningPorts(out).count == 2)
    }

    @Test func groupsPortsByProcessAndContainer() {
        let node1 = ListeningPort(port: 3000, pid: 10, command: "node", uid: 501, user: "me")
        let node2 = ListeningPort(port: 9229, pid: 10, command: "node", uid: 501, user: "me")
        let other = ListeningPort(port: 4000, pid: 20, command: "ruby", uid: 501, user: "me")
        let web = ListeningPort(port: 8080, pid: 50, command: "com.docker.backend", uid: 501, user: "me")
            .withContainer(ContainerInfo(name: "web", image: "nginx"))
        let db = ListeningPort(port: 5432, pid: 50, command: "com.docker.backend", uid: 501, user: "me")
            .withContainer(ContainerInfo(name: "db", image: "postgres"))
        let groups = ProcessGroup.group([node1, other, db, web, node2].sorted { $0.port < $1.port })
        #expect(groups.count == 4)
        #expect(groups.first { $0.primary.pid == 10 }?.ports.map(\.port) == [3000, 9229])
        #expect(Set(groups.map(\.id)).count == 4)
    }

    @Test func snippetsCoverUDPAndContainers() {
        #expect(CommandSnippets.listeners(port: 53, transport: .udp) == "lsof -nP -iUDP:53")
        #expect(CommandSnippets.stopContainer(name: "web") == "docker stop web")
    }
}

private actor ArgsRecorder {
    var args: [String] = []
    func set(_ value: [String]) { args = value }
}

private struct RecordingRunner: CommandRunning {
    let recorder: ArgsRecorder
    func run(_ executable: String, arguments: [String]) async throws -> String {
        await recorder.set(arguments)
        return ""
    }
}

struct DockerLocalOnlyTests {
    @Test func alwaysTargetsTheLocalSocketAndNeverCallsWithoutOne() async {
        let recorder = ArgsRecorder()
        let resolver = DockerResolver(runner: RecordingRunner(recorder: recorder), executable: "/x/docker", socket: "/x/docker.sock")
        _ = await resolver.containers()
        let args = await recorder.args
        #expect(Array(args.prefix(2)) == ["-H", "unix:///x/docker.sock"])

        let none = ArgsRecorder()
        let idle = DockerResolver(runner: RecordingRunner(recorder: none), executable: "/x/docker", socket: nil)
        _ = await idle.containers()
        #expect(await none.args.isEmpty)
    }
}

struct ScanDiffTests {
    private func port(started: Double? = 1000, memory: UInt64? = 100 * 1_048_576, command: String = "node") -> ListeningPort {
        ListeningPort(
            port: 3000, pid: 10, command: command, uid: 501, user: "me",
            startedAt: started.map { Date(timeIntervalSince1970: $0) }, memoryBytes: memory
        )
    }

    @Test func ignoresStartTimeDriftAndTinyMemoryChanges() {
        let old = [port(started: 1000, memory: 100 * 1_048_576)]
        let new = [port(started: 1001, memory: 100 * 1_048_576 + 200_000)]
        #expect(ScanDiff.isEquivalent(old, new))
        #expect(ScanDiff.isEquivalent(old, [port(memory: 102 * 1_048_576)]))   // 2 MB wobble
        #expect(ScanDiff.isEquivalent([port(memory: 176 * 1_048_576)], [port(memory: 181 * 1_048_576)]))   // under 3%
    }

    @Test func noticesRealChanges() {
        let base = [port()]
        #expect(!ScanDiff.isEquivalent(base, []))
        #expect(!ScanDiff.isEquivalent(base, [port(started: 5000)]))
        #expect(!ScanDiff.isEquivalent(base, [port(memory: 250 * 1_048_576)]))
        #expect(!ScanDiff.isEquivalent(base, [port(memory: 110 * 1_048_576)]))
        #expect(!ScanDiff.isEquivalent(base, [port(memory: nil)]))
        #expect(!ScanDiff.isEquivalent(base, [port(command: "ruby")]))
        #expect(!ScanDiff.isEquivalent(base, [port(started: nil)]))
        #expect(!ScanDiff.isEquivalent(base, [port().withProject(Project(name: "a", path: "/a"))]))
    }
}

private struct ListenersOnlyRunner: CommandRunning {
    let lsof: String
    func run(_ executable: String, arguments: [String]) async throws -> String {
        guard executable.hasSuffix("lsof") else { throw CommandError.launchFailed("\(executable) must not run") }
        return lsof
    }
}

struct LightScanTests {
    @Test func scanListenersRunsOnlyLsof() async throws {
        let runner = ListenersOnlyRunner(lsof: "p10\ncnode\nu501\nLme\nn*:3000\n")
        let ports = try await PortScanner(runner: runner).scanListeners()
        #expect(ports.map(\.port) == [3000])
        #expect(ports[0].startedAt == nil && ports[0].memoryBytes == nil && ports[0].project == nil)
    }
}
