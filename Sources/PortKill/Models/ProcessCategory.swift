import Foundation
import PortKillCore

enum ProcessCategory: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case dev = "Dev"
    case docker = "Docker"
    case helpers = "Helpers"

    var id: String { rawValue }
}

extension ProcessGroup {
    var isDocker: Bool {
        primary.container != nil || primary.command.lowercased().contains("docker")
    }

    var isHelper: Bool {
        let cmd = primary.command.lowercased()
        return cmd.contains("helper") || cmd.contains("renderer") || cmd.contains("electron")
            || cmd.contains("chrome") || cmd.contains("edge") || cmd.contains("language_server")
            || cmd.contains("replicatord")
    }

    var isDev: Bool {
        if isDocker { return true }
        if primary.project != nil { return true }
        let cmd = primary.command.lowercased()
        if cmd.contains("node") || cmd.contains("bun") || cmd.contains("deno")
            || cmd.contains("python") || cmd.contains("uvicorn") || cmd.contains("gunicorn")
            || cmd.contains("fastapi") || cmd.contains("flask") || cmd.contains("django")
            || cmd.contains("vite") || cmd.contains("next") || cmd.contains("go")
            || cmd.contains("cargo") || cmd.contains("ruby") || cmd.contains("rails")
            || cmd.contains("php") || cmd.contains("artisan") || cmd.contains("postgres")
            || cmd.contains("mysql") || cmd.contains("redis") || cmd.contains("mongod") {
            return true
        }
        let commonDevPorts: Set<Int> = [3000, 3001, 3002, 3333, 4000, 4200, 4321, 5000, 5001, 5173, 5174, 8000, 8080, 8081, 8888, 9000, 1337]
        if ports.contains(where: { commonDevPorts.contains($0.port) }) && !isHelper {
            return true
        }
        return false
    }

    var category: ProcessCategory {
        if isDocker { return .docker }
        if isDev { return .dev }
        return .helpers
    }
}

struct CategorizedGroups {
    let all: [ProcessGroup]
    let dev: [ProcessGroup]
    let docker: [ProcessGroup]
    let helpers: [ProcessGroup]

    init(_ groups: [ProcessGroup]) {
        var dev: [ProcessGroup] = []
        var docker: [ProcessGroup] = []
        var helpers: [ProcessGroup] = []
        for group in groups {
            if group.isDev { dev.append(group) } else { helpers.append(group) }
            if group.isDocker { docker.append(group) }
        }
        let byPort: (ProcessGroup, ProcessGroup) -> Bool = { $0.primary.port < $1.primary.port }
        all = groups
        self.dev = dev.sorted(by: byPort)
        self.docker = docker.sorted(by: byPort)
        self.helpers = helpers.sorted(by: byPort)
    }
}
