import Foundation

public struct Project: Hashable, Sendable {
    public let name: String
    public let path: String

    public init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}

public enum ProjectDetector {
    static let markers = [".git", "package.json", "Package.swift", "pyproject.toml", "Cargo.toml"]

    /// Walks up from `cwd` to the nearest folder holding a project marker.
    /// The home folder and `/` never count, so a dotfiles repo in `~` doesn't claim every process.
    public static func project(
        forWorkingDirectory cwd: String,
        homeDirectory: String = NSHomeDirectory(),
        fileManager: FileManager = .default
    ) -> Project? {
        let home = URL(fileURLWithPath: homeDirectory).standardizedFileURL.path
        var url = URL(fileURLWithPath: cwd).standardizedFileURL

        while url.path != "/" && url.path != home {
            if markers.contains(where: { fileManager.fileExists(atPath: url.appendingPathComponent($0).path) }) {
                return Project(name: url.lastPathComponent, path: url.path)
            }
            let parent = url.deletingLastPathComponent()
            if parent.path == url.path { break }
            url = parent
        }
        return nil
    }
}
