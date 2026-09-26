import AppKit
import Foundation
import Observation

public struct ReleaseAsset: Codable, Sendable, Equatable {
    public let name: String
    public let browserDownloadURL: URL
    public let size: Int64

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
        case size
    }
}

public struct GitHubRelease: Codable, Sendable, Equatable {
    public let tagName: String
    public let name: String?
    public let htmlURL: URL
    public let body: String?
    public let publishedAt: Date?
    public let assets: [ReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case htmlURL = "html_url"
        case body
        case publishedAt = "published_at"
        case assets
    }

    public var version: String {
        tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
    }

    public var dmgAsset: ReleaseAsset? {
        assets.first { $0.name.hasSuffix(".dmg") }
    }

    /// The link the "Download" button opens. The URL comes from the API response, so only `https` links on
    /// github.com are trusted; anything else falls back to the project's releases page.
    public var downloadURL: URL {
        [dmgAsset?.browserDownloadURL, htmlURL].compactMap { $0 }.first(where: Self.isTrusted) ?? Self.releasesPage
    }

    static let releasesPage = URL(string: "https://github.com/fr3on/portkill/releases")!

    static func isTrusted(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "https" && url.host?.lowercased() == "github.com" && url.user == nil
    }
}

public enum UpdateCheckResult: Sendable, Equatable {
    case updateAvailable(GitHubRelease)
    case upToDate
    case failed(String)
}

@MainActor
@Observable
public final class UpdateChecker {
    public static let shared = UpdateChecker()

    public private(set) var latestRelease: GitHubRelease?
    public private(set) var isChecking: Bool = false
    public private(set) var updateAvailable: Bool = false
    public private(set) var lastChecked: Date?
    public private(set) var lastError: String?

    public var currentVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, !version.isEmpty {
            return version
        }
        return "0.2.0"
    }

    private let repoURL = URL(string: "https://api.github.com/repos/fr3on/portkill/releases/latest")!

    public func checkForUpdates(manual: Bool = false) async -> UpdateCheckResult {
        guard !isChecking else {
            if let latest = latestRelease, updateAvailable {
                return .updateAvailable(latest)
            }
            return .upToDate
        }

        isChecking = true
        lastError = nil
        defer { isChecking = false }

        var request = URLRequest(url: repoURL)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("PortKill-Updater/\(currentVersion)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                let err = "Invalid response from server"
                lastError = err
                return .failed(err)
            }

            if httpResponse.statusCode == 404 {
                // No releases published yet
                lastChecked = Date()
                return .upToDate
            }

            guard httpResponse.statusCode == 200 else {
                let err = "GitHub API returned status \(httpResponse.statusCode)"
                lastError = err
                return .failed(err)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let release = try decoder.decode(GitHubRelease.self, from: data)

            lastChecked = Date()
            latestRelease = release

            let isNewer = Self.isVersion(release.version, newerThan: currentVersion)
            updateAvailable = isNewer

            if isNewer {
                return .updateAvailable(release)
            } else {
                return .upToDate
            }
        } catch {
            let err = error.localizedDescription
            lastError = err
            return .failed(err)
        }
    }

    public static func isVersion(_ remote: String, newerThan current: String) -> Bool {
        func parseVersion(_ str: String) -> [Int] {
            let clean = str.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "^v", with: "", options: .regularExpression)
            return clean.split(separator: ".")
                .compactMap { part -> Int? in
                    let numStr = part.split(separator: "-").first.map(String.init) ?? String(part)
                    return Int(numStr)
                }
        }

        let rParts = parseVersion(remote)
        let cParts = parseVersion(current)

        for i in 0..<max(rParts.count, cParts.count) {
            let r = i < rParts.count ? rParts[i] : 0
            let c = i < cParts.count ? cParts[i] : 0
            if r != c {
                return r > c
            }
        }
        return false
    }
}
