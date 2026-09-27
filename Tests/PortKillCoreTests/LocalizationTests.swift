import Foundation
import Testing
@testable import PortKillCore

struct LocalizationTests {
    @Test func systemLanguageResolution() {
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["zh-Hans-CN", "en-US"]) == .zhHans)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["ja-JP", "en"]) == .ja)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["de-DE", "en"]) == .de)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["es-ES", "en"]) == .es)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["fr-FR", "en"]) == .fr)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["tr-TR", "en"]) == .tr)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["en-GB"]) == .en)
        #expect(AppLanguage.resolveSystemLanguage(preferredLanguages: ["it-IT", "ru-RU"]) == .en)
    }

    @Test func languageStringsNonEmpty() {
        for lang in AppLanguage.supportedLanguages {
            let s = lang.strings
            #expect(!s.settings.isEmpty)
            #expect(!s.aboutPortKill.isEmpty)
            #expect(!s.languageTitle.isEmpty)
            #expect(!s.systemDefault.isEmpty)
            #expect(!s.launchAtLogin.isEmpty)
            #expect(!s.approveInLoginItems.isEmpty)
            #expect(!s.showPortCountInMenuBar.isEmpty)
            #expect(!s.showSystemProcesses.isEmpty)
            #expect(!s.showUDPSockets.isEmpty)
            #expect(!s.openIn.isEmpty)
            #expect(!s.checkForUpdates.isEmpty)
            #expect(!s.checkingForUpdates.isEmpty)
            #expect(!s.quit.isEmpty)
            #expect(!s.noDevPortsActive.isEmpty)
            #expect(!s.oneDevPortActive.isEmpty)
            #expect(!s.devPortsActive(count: 3).isEmpty)
            #expect(!s.couldNotScanPorts.isEmpty)
            #expect(!s.searchPlaceholder.isEmpty)
            #expect(!s.noActiveDevServers.isEmpty)
            #expect(!s.kill.isEmpty)
            #expect(!s.forceKill.isEmpty)
            #expect(!s.stopped.isEmpty)
            #expect(!s.aboutTagline.isEmpty)
            #expect(!s.updateAvailableTitle.isEmpty)
        }
    }

    @Test func readOnlyReasonLocalized() {
        for lang in AppLanguage.supportedLanguages {
            #expect(!ReadOnlyReason.protectedPID.localized(for: lang).isEmpty)
            #expect(!ReadOnlyReason.otherUser.localized(for: lang).isEmpty)
            #expect(!ReadOnlyReason.systemProcess.localized(for: lang).isEmpty)
            #expect(!ReadOnlyReason.dockerContainer.localized(for: lang).isEmpty)
        }
    }
}
