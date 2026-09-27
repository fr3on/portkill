import Foundation

/// Supported languages in PortKill.
public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case en = "en"
    case zhHans = "zh-Hans"
    case ja = "ja"
    case de = "de"
    case es = "es"
    case fr = "fr"
    case tr = "tr"

    public var id: String { rawValue }

    /// All concrete languages excluding `.system`.
    public static var supportedLanguages: [AppLanguage] {
        [.en, .zhHans, .ja, .de, .es, .fr, .tr]
    }

    /// Native localized name of the language.
    public var displayName: String {
        switch self {
        case .system: "System Default"
        case .en: "English"
        case .zhHans: "简体中文"
        case .ja: "日本語"
        case .de: "Deutsch"
        case .es: "Español"
        case .fr: "Français"
        case .tr: "Türkçe"
        }
    }

    /// Resolves `.system` to an actual supported language based on user's system preferences.
    public var resolved: AppLanguage {
        guard self == .system else { return self }
        return Self.resolveSystemLanguage()
    }

    /// Resolves the preferred language from a list of language identifiers (defaults to `Locale.preferredLanguages`).
    public static func resolveSystemLanguage(preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        for lang in preferredLanguages {
            let lower = lang.lowercased()
            if lower.hasPrefix("zh") { return .zhHans }
            if lower.hasPrefix("ja") { return .ja }
            if lower.hasPrefix("de") { return .de }
            if lower.hasPrefix("es") { return .es }
            if lower.hasPrefix("fr") { return .fr }
            if lower.hasPrefix("tr") { return .tr }
            if lower.hasPrefix("en") { return .en }
        }
        return .en
    }
}
