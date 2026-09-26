import AppKit
import Foundation
import PortKillCore
import SwiftUI

struct ProcessIdentity {
    let appIcon: NSImage?
    let iconName: String
    let tintColor: Color
    let category: String

    static func resolve(pid: Int, command: String, project: Project?, container: ContainerInfo?) -> ProcessIdentity {
        if let icon = AppIconResolver.shared.icon(for: pid) {
            return ProcessIdentity(
                appIcon: icon,
                iconName: "app.fill",
                tintColor: Color.secondary,
                category: "App"
            )
        }

        if container != nil {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "shippingbox.fill",
                tintColor: Color(red: 0.16, green: 0.58, blue: 0.98),
                category: "Docker"
            )
        }

        let cmd = command.lowercased()
        let proj = (project?.name ?? "").lowercased()

        if cmd.contains("node") || cmd.contains("next") || cmd.contains("vite") || cmd.contains("bun")
            || cmd.contains("deno") || cmd.contains("npm") || cmd.contains("yarn") || cmd.contains("pnpm")
            || cmd.contains("astro") || cmd.contains("remix") || cmd.contains("nuxt") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "curlybraces",
                tintColor: Color(red: 0.22, green: 0.78, blue: 0.45),
                category: "Node.js"
            )
        }

        if cmd.contains("python") || cmd.contains("uvicorn") || cmd.contains("gunicorn")
            || cmd.contains("fastapi") || cmd.contains("flask") || cmd.contains("django")
            || cmd.contains("celery") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "chevron.left.forwardslash.chevron.right",
                tintColor: Color(red: 0.28, green: 0.65, blue: 0.95),
                category: "Python"
            )
        }

        if cmd.contains("postgres") || cmd.contains("psql") || cmd.contains("mysql") || cmd.contains("mysqld")
            || cmd.contains("redis") || cmd.contains("mongod") || cmd.contains("mariadb") || cmd.contains("clickhouse") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "cylinder.split.1x2.fill",
                tintColor: Color(red: 0.72, green: 0.42, blue: 0.95),
                category: "Database"
            )
        }

        if cmd.contains("go") || cmd.contains("air") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "arrow.triangle.swap",
                tintColor: Color(red: 0.05, green: 0.75, blue: 0.85),
                category: "Go"
            )
        }

        if cmd.contains("cargo") || proj.contains("cargo") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "gearshape.2.fill",
                tintColor: Color(red: 0.95, green: 0.48, blue: 0.22),
                category: "Rust"
            )
        }

        if cmd.contains("ruby") || cmd.contains("rails") || cmd.contains("puma") || cmd.contains("sidekiq") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "suit.diamond.fill",
                tintColor: Color(red: 0.92, green: 0.28, blue: 0.35),
                category: "Ruby"
            )
        }

        if cmd.contains("java") || cmd.contains("gradle") || cmd.contains("mvn") || cmd.contains("kotlin") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "cup.and.saucer.fill",
                tintColor: Color(red: 0.95, green: 0.55, blue: 0.20),
                category: "Java"
            )
        }

        if cmd.contains("php") || cmd.contains("artisan") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "ellipsis.curlybraces",
                tintColor: Color(red: 0.55, green: 0.50, blue: 0.85),
                category: "PHP"
            )
        }

        if cmd.contains("electron") || cmd.contains("chrome") || cmd.contains("helper") || cmd.contains("renderer") {
            return ProcessIdentity(
                appIcon: nil,
                iconName: "macwindow",
                tintColor: Color(red: 0.50, green: 0.65, blue: 0.80),
                category: "App"
            )
        }

        return ProcessIdentity(
            appIcon: nil,
            iconName: "terminal.fill",
            tintColor: Color.secondary,
            category: "Process"
        )
    }
}
