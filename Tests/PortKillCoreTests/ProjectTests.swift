import Foundation
import Testing
@testable import PortKillCore

struct ProjectDetectorTests {
    private func makeTree(_ paths: [String]) throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("pk-\(UUID().uuidString)")
        for path in paths {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: path.contains(".") && !path.hasSuffix(".git") ? url.deletingLastPathComponent() : url,
                withIntermediateDirectories: true
            )
            if path.contains("."), !path.hasSuffix(".git") {
                FileManager.default.createFile(atPath: url.path, contents: Data())
            }
        }
        return root.standardizedFileURL
    }

    @Test func findsNearestMarkerWalkingUp() throws {
        let root = try makeTree(["app/.git", "app/web/package.json", "app/web/src/deep/x"])
        defer { try? FileManager.default.removeItem(at: root) }
        let cwd = root.appendingPathComponent("app/web/src/deep").path
        let project = ProjectDetector.project(forWorkingDirectory: cwd, homeDirectory: root.path)
        #expect(project == Project(name: "web", path: root.appendingPathComponent("app/web").path))
    }

    @Test func recognisesEveryMarker() throws {
        for marker in ["package.json", "Package.swift", "pyproject.toml", "Cargo.toml"] {
            let root = try makeTree(["proj/\(marker)", "proj/sub/x"])
            defer { try? FileManager.default.removeItem(at: root) }
            let project = ProjectDetector.project(
                forWorkingDirectory: root.appendingPathComponent("proj/sub").path,
                homeDirectory: root.path
            )
            #expect(project?.name == "proj", "marker \(marker)")
        }
    }

    @Test func gitDirectoryCountsAsAMarker() throws {
        let root = try makeTree(["repo/.git", "repo/sub/x"])
        defer { try? FileManager.default.removeItem(at: root) }
        let project = ProjectDetector.project(
            forWorkingDirectory: root.appendingPathComponent("repo/sub").path,
            homeDirectory: root.path
        )
        #expect(project?.name == "repo")
    }

    @Test func neverClaimsTheHomeFolder() throws {
        let root = try makeTree([".git", "notes/x"])
        defer { try? FileManager.default.removeItem(at: root) }
        let project = ProjectDetector.project(
            forWorkingDirectory: root.appendingPathComponent("notes").path,
            homeDirectory: root.path
        )
        #expect(project == nil)
    }

    @Test func returnsNilOutsideAnyProject() throws {
        let root = try makeTree(["plain/x"])
        defer { try? FileManager.default.removeItem(at: root) }
        #expect(ProjectDetector.project(forWorkingDirectory: root.appendingPathComponent("plain").path, homeDirectory: root.path) == nil)
        #expect(ProjectDetector.project(forWorkingDirectory: "/", homeDirectory: root.path) == nil)
    }

    @Test func parsesWorkingDirectoryOutput() {
        let out = "p100\nn/Users/me/app\np200\nn/\np300\n"
        #expect(LsofParser.parseWorkingDirectories(out) == [100: "/Users/me/app", 200: "/"])
    }
}

private actor CallCounter {
    var lsofCalls = 0
    func hit() { lsofCalls += 1 }
}

private struct CountingRunner: CommandRunning {
    let counter: CallCounter
    let cwd: String

    func run(_ executable: String, arguments: [String]) async throws -> String {
        await counter.hit()
        return "p10\nn\(cwd)\n"
    }
}

struct ProjectResolverTests {
    @Test func cachesPerProcessAndQueriesOnce() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("pk-\(UUID().uuidString)").standardizedFileURL
        let projectDir = root.appendingPathComponent("my-app")
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: projectDir.appendingPathComponent("package.json").path, contents: Data())
        defer { try? FileManager.default.removeItem(at: root) }

        let counter = CallCounter()
        let resolver = ProjectResolver(runner: CountingRunner(counter: counter, cwd: projectDir.path), homeDirectory: root.path)
        let port = ListeningPort(port: 3000, pid: 10, command: "node", uid: 501, user: "me", startedAt: Date(timeIntervalSince1970: 1000))

        let first = await resolver.resolve([port])
        let second = await resolver.resolve([port])

        #expect(first[0].project?.name == "my-app")
        #expect(second[0].project?.name == "my-app")
        #expect(await counter.lsofCalls == 1)
    }

    @Test func aReusedPIDWithADifferentStartTimeIsLookedUpAgain() async throws {
        let counter = CallCounter()
        let resolver = ProjectResolver(runner: CountingRunner(counter: counter, cwd: "/"), homeDirectory: "/nonexistent")
        let a = ListeningPort(port: 3000, pid: 10, command: "node", uid: 501, user: "me", startedAt: Date(timeIntervalSince1970: 1000))
        let b = ListeningPort(port: 3000, pid: 10, command: "node", uid: 501, user: "me", startedAt: Date(timeIntervalSince1970: 5000))
        _ = await resolver.resolve([a])
        _ = await resolver.resolve([b])
        #expect(await counter.lsofCalls == 2)
    }
}
