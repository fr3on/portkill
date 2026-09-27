import PortKillCore
import SwiftUI

private struct AppLanguageKey: EnvironmentKey {
    static let defaultValue: AppLanguage = .en
}

extension EnvironmentValues {
    public var appLanguage: AppLanguage {
        get { self[AppLanguageKey.self] }
        set { self[AppLanguageKey.self] = newValue }
    }
}
