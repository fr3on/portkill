import Foundation

/// Centralized, type-safe localization strings for PortKill.
public struct LocalizedStrings: Sendable {
    public let language: AppLanguage

    public init(language: AppLanguage) {
        self.language = language.resolved
    }

    // MARK: - Settings & Menus

    public var settings: String {
        switch language {
        case .zhHans: "设置"
        case .ja: "設定"
        case .de: "Einstellungen"
        case .es: "Ajustes"
        case .fr: "Réglages"
        case .tr: "Ayarlar"
        default: "Settings"
        }
    }

    public var aboutPortKill: String {
        switch language {
        case .zhHans: "关于 PortKill…"
        case .ja: "PortKill について…"
        case .de: "Über PortKill…"
        case .es: "Acerca de PortKill…"
        case .fr: "À propos de PortKill…"
        case .tr: "PortKill Hakkında…"
        default: "About PortKill…"
        }
    }

    public var languageTitle: String {
        switch language {
        case .zhHans: "语言"
        case .ja: "言語"
        case .de: "Sprache"
        case .es: "Idioma"
        case .fr: "Langue"
        case .tr: "Dil"
        default: "Language"
        }
    }

    public var systemDefault: String {
        switch language {
        case .zhHans: "系统默认"
        case .ja: "システム標準"
        case .de: "Systemstandard"
        case .es: "Predeterminado del sistema"
        case .fr: "Par défaut du système"
        case .tr: "Sistem Varsayılanı"
        default: "System Default"
        }
    }

    public var launchAtLogin: String {
        switch language {
        case .zhHans: "开机自启"
        case .ja: "ログイン時に起動"
        case .de: "Bei der Anmeldung starten"
        case .es: "Iniciar al arrancar"
        case .fr: "Lancer à la connexion"
        case .tr: "Girişte Başlat"
        default: "Launch at Login"
        }
    }

    public var approveInLoginItems: String {
        switch language {
        case .zhHans: "在“登录项”中批准…"
        case .ja: "ログイン項目で承認…"
        case .de: "In Anmeldeobjekten genehmigen…"
        case .es: "Aprobar en Ítems de inicio…"
        case .fr: "Approuver dans les Éléments de connexion…"
        case .tr: "Giriş Öğeleri'nde Onayla…"
        default: "Approve in Login Items…"
        }
    }

    public var showPortCountInMenuBar: String {
        switch language {
        case .zhHans: "在菜单栏显示端口数量"
        case .ja: "メニューバーにポート数を表示"
        case .de: "Port-Anzahl in der Menüleiste anzeigen"
        case .es: "Mostrar contador de puertos en la barra de menús"
        case .fr: "Afficher le nombre de ports dans la barre des menus"
        case .tr: "Menü Çubuğunda Port Sayısını Göster"
        default: "Show Port Count in Menu Bar"
        }
    }

    public var showSystemProcesses: String {
        switch language {
        case .zhHans: "显示系统进程"
        case .ja: "システムプロセスを表示"
        case .de: "Systemprozesse anzeigen"
        case .es: "Mostrar procesos del sistema"
        case .fr: "Afficher les processus système"
        case .tr: "Sistem İşlemlerini Göster"
        default: "Show System Processes"
        }
    }

    public var showUDPSockets: String {
        switch language {
        case .zhHans: "显示 UDP 套接字"
        case .ja: "UDP ソケットを表示"
        case .de: "UDP-Sockets anzeigen"
        case .es: "Mostrar sockets UDP"
        case .fr: "Afficher les sockets UDP"
        case .tr: "UDP Yuvalarını Göster"
        default: "Show UDP Sockets"
        }
    }

    public var openIn: String {
        switch language {
        case .zhHans: "打开方式"
        case .ja: "開くツール"
        case .de: "Öffnen in"
        case .es: "Abrir en"
        case .fr: "Ouvrir dans"
        case .tr: "Şununla aç"
        default: "Open in"
        }
    }

    public var checkForUpdates: String {
        switch language {
        case .zhHans: "检查更新…"
        case .ja: "アップデートを確認…"
        case .de: "Nach Updates suchen…"
        case .es: "Buscar actualizaciones…"
        case .fr: "Vérifier les mises à jour…"
        case .tr: "Güncellemeleri Kontrol Et…"
        default: "Check for Updates…"
        }
    }

    public var checkingForUpdates: String {
        switch language {
        case .zhHans: "正在检查更新…"
        case .ja: "アップデートを確認中…"
        case .de: "Updates werden gesucht…"
        case .es: "Buscando actualizaciones…"
        case .fr: "Vérification des mises à jour…"
        case .tr: "Güncellemeler Aranıyor…"
        default: "Checking for Updates…"
        }
    }

    public var quit: String {
        switch language {
        case .zhHans: "退出"
        case .ja: "終了"
        case .de: "Beenden"
        case .es: "Salir"
        case .fr: "Quitter"
        case .tr: "Çıkış"
        default: "Quit"
        }
    }

    public var quitTooltip: String {
        switch language {
        case .zhHans: "退出 PortKill (⌘Q)"
        case .ja: "PortKill を終了 (⌘Q)"
        case .de: "PortKill beenden (⌘Q)"
        case .es: "Salir de PortKill (⌘Q)"
        case .fr: "Quitter PortKill (⌘Q)"
        case .tr: "PortKill'den Çık (⌘Q)"
        default: "Quit PortKill (⌘Q)"
        }
    }

    public var refreshTooltip: String {
        switch language {
        case .zhHans: "立即刷新 (⌘R)"
        case .ja: "今すぐ更新 (⌘R)"
        case .de: "Jetzt aktualisieren (⌘R)"
        case .es: "Actualizar ahora (⌘R)"
        case .fr: "Actualiser maintenant (⌘R)"
        case .tr: "Şimdi yenile (⌘R)"
        default: "Refresh now (⌘R)"
        }
    }

    public var refreshLabel: String {
        switch language {
        case .zhHans: "刷新"
        case .ja: "更新"
        case .de: "Aktualisieren"
        case .es: "Actualizar"
        case .fr: "Actualiser"
        case .tr: "Yenile"
        default: "Refresh"
        }
    }

    // MARK: - Status Bar Counts

    public var noDevPortsActive: String {
        switch language {
        case .zhHans: "无活动开发端口"
        case .ja: "アクティブな開発ポートなし"
        case .de: "Keine aktiven Dev-Ports"
        case .es: "Sin puertos dev activos"
        case .fr: "Aucun port dev actif"
        case .tr: "Aktif geliştirme portu yok"
        default: "No dev ports active"
        }
    }

    public var oneDevPortActive: String {
        switch language {
        case .zhHans: "1 个开发端口活动"
        case .ja: "1件の開発ポートがアクティブ"
        case .de: "1 aktiver Dev-Port"
        case .es: "1 puerto dev activo"
        case .fr: "1 port dev actif"
        case .tr: "1 aktif geliştirme portu"
        default: "1 dev port active"
        }
    }

    public func devPortsActive(count: Int) -> String {
        switch language {
        case .zhHans: "\(count) 个开发端口活动"
        case .ja: "\(count)件の開発ポートがアクティブ"
        case .de: "\(count) aktive Dev-Ports"
        case .es: "\(count) puertos dev activos"
        case .fr: "\(count) ports dev actifs"
        case .tr: "\(count) aktif geliştirme portu"
        default: "\(count) dev ports active"
        }
    }

    // MARK: - Notices

    public var couldNotScanPorts: String {
        switch language {
        case .zhHans: "无法扫描端口"
        case .ja: "ポートをスキャンできませんでした"
        case .de: "Ports konnten nicht gescannt werden"
        case .es: "No se pudieron escanear los puertos"
        case .fr: "Impossible d'analyser les ports"
        case .tr: "Portlar taranamadı"
        default: "Could not scan ports"
        }
    }

    public var permissionDenied: String {
        switch language {
        case .zhHans: "权限被拒绝"
        case .ja: "アクセスが拒否されました"
        case .de: "Zugriff verweigert"
        case .es: "Permiso denegado"
        case .fr: "Permission refusée"
        case .tr: "İzin reddedildi"
        default: "Permission denied"
        }
    }

    public var processChangedRefreshing: String {
        switch language {
        case .zhHans: "进程已变动，正在刷新"
        case .ja: "プロセスが変更されました。更新中"
        case .de: "Prozess geändert, wird aktualisiert"
        case .es: "Proceso cambiado, actualizando"
        case .fr: "Processus modifié, actualisation"
        case .tr: "İşlem değişti, yenileniyor"
        default: "Process changed, refreshing"
        }
    }

    public func notAllowedProcess(reason: String) -> String {
        switch language {
        case .zhHans: "\(reason) 进程，不允许操作"
        case .ja: "\(reason) プロセス、許可されていません"
        case .de: "\(reason)-Prozess, nicht erlaubt"
        case .es: "Proceso \(reason), no permitido"
        case .fr: "Processus \(reason), non autorisé"
        case .tr: "\(reason) işlemi, izin verilmiyor"
        default: "\(reason) process, not allowed"
        }
    }

    public var couldNotStopProcess: String {
        switch language {
        case .zhHans: "无法停止进程"
        case .ja: "プロセスを停止できませんでした"
        case .de: "Prozess konnte nicht beendet werden"
        case .es: "No se pudo detener el proceso"
        case .fr: "Impossible d'arrêter le processus"
        case .tr: "İşlem durdurulamadı"
        default: "Could not stop process"
        }
    }

    public var checkingForUpdatesNotice: String {
        switch language {
        case .zhHans: "正在检查更新…"
        case .ja: "アップデートを確認中…"
        case .de: "Nach Updates suchen…"
        case .es: "Buscando actualizaciones…"
        case .fr: "Recherche de mises à jour…"
        case .tr: "Güncellemeler kontrol ediliyor…"
        default: "Checking for updates…"
        }
    }

    public func updateAvailableNotice(version: String) -> String {
        switch language {
        case .zhHans: "有可用更新：v\(version)"
        case .ja: "アップデート利用可能: v\(version)"
        case .de: "Update verfügbar: v\(version)"
        case .es: "Actualización disponible: v\(version)"
        case .fr: "Mise à jour disponible : v\(version)"
        case .tr: "Güncelleme mevcut: v\(version)"
        default: "Update available: v\(version)"
        }
    }

    public func upToDateNotice(version: String) -> String {
        switch language {
        case .zhHans: "PortKill 已是最新版本 (v\(version))"
        case .ja: "PortKill は最新です (v\(version))"
        case .de: "PortKill ist auf dem neuesten Stand (v\(version))"
        case .es: "PortKill está actualizado (v\(version))"
        case .fr: "PortKill est à jour (v\(version))"
        case .tr: "PortKill güncel (v\(version))"
        default: "PortKill is up to date (v\(version))"
        }
    }

    public func updateCheckFailedNotice(error: String) -> String {
        switch language {
        case .zhHans: "检查更新失败：\(error)"
        case .ja: "アップデート確認に失敗しました: \(error)"
        case .de: "Update-Prüfung fehlgeschlagen: \(error)"
        case .es: "Error al comprobar actualizaciones: \(error)"
        case .fr: "Échec de la recherche de mise à jour : \(error)"
        case .tr: "Güncelleme kontrolü başarısız: \(error)"
        default: "Update check failed: \(error)"
        }
    }

    public var approveInLoginItemsNotice: String {
        switch language {
        case .zhHans: "请在“登录项”中允许 PortKill"
        case .ja: "ログイン項目で PortKill を承認してください"
        case .de: "PortKill in den Anmeldeobjekten genehmigen"
        case .es: "Aprueba PortKill en Ítems de inicio"
        case .fr: "Approuvez PortKill dans les Éléments de connexion"
        case .tr: "PortKill'i Giriş Öğeleri'nde onaylayın"
        default: "Approve PortKill in Login Items"
        }
    }

    public var couldNotEnableLoginNotice: String {
        switch language {
        case .zhHans: "无法启用开机自启"
        case .ja: "ログイン時起動を有効にできませんでした"
        case .de: "Autostart bei Anmeldung konnte nicht aktiviert werden"
        case .es: "No se pudo activar el inicio al iniciar sesión"
        case .fr: "Impossible d'activer le lancement à la connexion"
        case .tr: "Girişte Başlat etkinleştirilemedi"
        default: "Could not enable Launch at Login"
        }
    }

    public var couldNotDisableLoginNotice: String {
        switch language {
        case .zhHans: "无法禁用开机自启"
        case .ja: "ログイン時起動を無効にできませんでした"
        case .de: "Autostart bei Anmeldung konnte nicht deaktiviert werden"
        case .es: "No se pudo desactivar el inicio al iniciar sesión"
        case .fr: "Impossible de désactiver le lancement à la connexion"
        case .tr: "Girişte Başlat devre dışı bırakılamadı"
        default: "Could not disable Launch at Login"
        }
    }

    public func terminalNotFoundNotice(name: String) -> String {
        switch language {
        case .zhHans: "未找到 \(name)"
        case .ja: "\(name) が見つかりません"
        case .de: "\(name) nicht gefunden"
        case .es: "\(name) no encontrado"
        case .fr: "\(name) introuvable"
        case .tr: "\(name) bulunamadı"
        default: "\(name) not found"
        }
    }

    // MARK: - Sections & Categories

    public var devServersAndProjects: String {
        switch language {
        case .zhHans: "开发服务器与项目"
        case .ja: "開発サーバー＆プロジェクト"
        case .de: "DEV-SERVER & PROJEKTE"
        case .es: "SERVIDORES DEV Y PROYECTOS"
        case .fr: "SERVEURS DEV ET PROJETS"
        case .tr: "GELİŞTİRME SUNUCULARI VE PROJELER"
        default: "DEV SERVERS & PROJECTS"
        }
    }

    public var backgroundAndHelpers: String {
        switch language {
        case .zhHans: "后台与辅助进程"
        case .ja: "バックグラウンド＆ヘルパー"
        case .de: "HINTERGRUND & HELFER"
        case .es: "SEGUNDO PLANO Y AUXILIARES"
        case .fr: "ARRIÈRE-PLAN ET ASSISTANTS"
        case .tr: "ARKA PLAN VE YARDIMCILAR"
        default: "BACKGROUND & HELPERS"
        }
    }

    public var categoryAll: String {
        switch language {
        case .zhHans: "全部"
        case .ja: "すべて"
        case .de: "Alle"
        case .es: "Todos"
        case .fr: "Tous"
        case .tr: "Tümü"
        default: "All"
        }
    }

    public var categoryDev: String {
        switch language {
        case .zhHans: "开发"
        case .ja: "開発"
        case .de: "Dev"
        case .es: "Dev"
        case .fr: "Dév"
        case .tr: "Geliştirme"
        default: "Dev"
        }
    }

    public var categoryDocker: String {
        "Docker"
    }

    public var categoryHelpers: String {
        switch language {
        case .zhHans: "辅助"
        case .ja: "ヘルパー"
        case .de: "Helfer"
        case .es: "Auxiliares"
        case .fr: "Assistants"
        case .tr: "Yardımcılar"
        default: "Helpers"
        }
    }

    // MARK: - Search & Empty State

    public var searchPlaceholder: String {
        switch language {
        case .zhHans: "搜索端口、进程或项目..."
        case .ja: "ポート、プロセス、またはプロジェクトを検索..."
        case .de: "Port, Prozess oder Projekt suchen..."
        case .es: "Buscar puerto, proceso o proyecto..."
        case .fr: "Rechercher port, processus ou projet..."
        case .tr: "Port, işlem veya proje ara..."
        default: "Search port, process, or project..."
        }
    }

    public var clearSearch: String {
        switch language {
        case .zhHans: "清空搜索"
        case .ja: "検索をクリア"
        case .de: "Suche löschen"
        case .es: "Borrar búsqueda"
        case .fr: "Effacer la recherche"
        case .tr: "Aramayı temizle"
        default: "Clear search"
        }
    }

    public var noActiveDevServers: String {
        switch language {
        case .zhHans: "无正在运行的开发服务器"
        case .ja: "アクティブな開発サーバーはありません"
        case .de: "Keine aktiven Dev-Server"
        case .es: "No hay servidores de desarrollo activos"
        case .fr: "Aucun serveur dev actif"
        case .tr: "Aktif geliştirme sunucusu yok"
        default: "No active dev servers"
        }
    }

    public var noActiveDevServersHint: String {
        switch language {
        case .zhHans: "启动一个服务器（如 npm run dev 或 python -m http.server），它将显示在这里。"
        case .ja: "サーバー（例：npm run dev や python -m http.server）を起動するとここに表示されます。"
        case .de: "Starten Sie einen Server (z. B. npm run dev oder python -m http.server), damit er hier erscheint."
        case .es: "Inicia un servidor (ej. npm run dev o python -m http.server) y aparecerá aquí."
        case .fr: "Démarrez un serveur (ex. npm run dev ou python -m http.server) et il apparaîtra ici."
        case .tr: "Bir sunucu başlatın (örn. npm run dev veya python -m http.server) ve burada görünecektir."
        default: "Start a server (e.g. npm run dev or python -m http.server) and it will appear here."
        }
    }

    public func noResults(for query: String) -> String {
        switch language {
        case .zhHans: "未找到 \"\(query)\" 的结果"
        case .ja: "「\(query)」の結果は見つかりませんでした"
        case .de: "Keine Ergebnisse für „\(query)“"
        case .es: "Sin resultados para «\(query)»"
        case .fr: "Aucun résultat pour « \(query) »"
        case .tr: "\"\(query)\" için sonuç bulunamadı"
        default: "No results for \"\(query)\""
        }
    }

    public var noResultsHint: String {
        switch language {
        case .zhHans: "尝试按其他端口号、进程名或项目进行搜索。"
        case .ja: "別のポート番号、プロセス名、またはプロジェクト名で検索してみてください。"
        case .de: "Versuchen Sie die Suche nach einem anderen Port, Prozessnamen oder Projekt."
        case .es: "Prueba buscando por otro número de puerto, nombre de proceso o proyecto."
        case .fr: "Essayez de rechercher par un autre numéro de port, nom de processus ou projet."
        case .tr: "Başka bir port numarası, işlem adı veya proje ile aramayı deneyin."
        default: "Try searching by another port number, process name, or project."
        }
    }

    // MARK: - Hardware Specs

    public var cores: String {
        switch language {
        case .zhHans: "核心"
        case .ja: "コア"
        case .de: "KERNE"
        case .es: "NÚCLEOS"
        case .fr: "CŒURS"
        case .tr: "ÇEKİRDEK"
        default: "CORES"
        }
    }

    public var ram: String { "RAM" }

    public var unified: String {
        switch language {
        case .zhHans: "统一内存"
        case .ja: "統合メモリ"
        case .de: "Gemeinsam"
        case .es: "Unificada"
        case .fr: "Unifiée"
        case .tr: "Birleşik"
        default: "Unified"
        }
    }

    public var compute: String {
        switch language {
        case .zhHans: "算力"
        case .ja: "演算能力"
        case .de: "RECHENLEISTUNG"
        case .es: "CÓMPUTO"
        case .fr: "CALCUL"
        case .tr: "İŞLEM GÜCÜ"
        default: "COMPUTE"
        }
    }

    public var peakFP32: String {
        switch language {
        case .zhHans: "峰值 FP32"
        case .ja: "最大 FP32"
        case .de: "Peak FP32"
        case .es: "Pico FP32"
        case .fr: "Pic FP32"
        case .tr: "Pik FP32"
        default: "Peak FP32"
        }
    }

    public var cpuLoad: String {
        switch language {
        case .zhHans: "CPU 负载"
        case .ja: "CPU 負荷"
        case .de: "CPU-LAST"
        case .es: "CARGA CPU"
        case .fr: "CHARGE CPU"
        case .tr: "CPU YÜKÜ"
        default: "CPU LOAD"
        }
    }

    public var highLoad: String {
        switch language {
        case .zhHans: "高负载"
        case .ja: "高負荷"
        case .de: "Hohe Last"
        case .es: "Carga alta"
        case .fr: "Charge élevée"
        case .tr: "Yüksek Yük"
        default: "High Load"
        }
    }

    public var nominal: String {
        switch language {
        case .zhHans: "正常"
        case .ja: "正常"
        case .de: "Normal"
        case .es: "Normal"
        case .fr: "Normal"
        case .tr: "Normal"
        default: "Nominal"
        }
    }

    public func cpuCores(count: Int) -> String {
        switch language {
        case .zhHans: "\(count) 核 CPU"
        case .ja: "\(count)コア CPU"
        default: "\(count)c CPU"
        }
    }

    public func gpuCores(count: Int) -> String {
        switch language {
        case .zhHans: "\(count) 核 GPU"
        case .ja: "\(count)コア GPU"
        default: "\(count)c GPU"
        }
    }

    // MARK: - Process Row & Details

    public var dockerContainer: String {
        switch language {
        case .zhHans: "Docker 容器"
        case .ja: "Docker コンテナ"
        case .de: "Docker-Container"
        case .es: "Contenedor Docker"
        case .fr: "Conteneur Docker"
        case .tr: "Docker konteyneri"
        default: "Docker container"
        }
    }

    public func openInBrowserTooltip(url: String) -> String {
        switch language {
        case .zhHans: "在浏览器中打开 (\(url))"
        case .ja: "ブラウザで開く (\(url))"
        case .de: "Im Browser öffnen (\(url))"
        case .es: "Abrir en el navegador (\(url))"
        case .fr: "Ouvrir dans le navigateur (\(url))"
        case .tr: "Tarayıcıda aç (\(url))"
        default: "Open in browser (\(url))"
        }
    }

    public func openInBrowserAccessibility(url: String) -> String {
        switch language {
        case .zhHans: "在浏览器中打开 \(url)"
        case .ja: "ブラウザで \(url) を開く"
        case .de: "\(url) im Browser öffnen"
        case .es: "Abrir \(url) en el navegador"
        case .fr: "Ouvrir \(url) dans le navigateur"
        case .tr: "Tarayıcıda \(url) aç"
        default: "Open \(url) in browser"
        }
    }

    public var projectDirectory: String {
        switch language {
        case .zhHans: "项目目录"
        case .ja: "プロジェクトディレクトリ"
        case .de: "PROJEKTVERZEICHNIS"
        case .es: "DIRECTORIO DEL PROYECTO"
        case .fr: "RÉPERTOIRE DU PROJET"
        case .tr: "PROJE DİZİNİ"
        default: "PROJECT DIRECTORY"
        }
    }

    public var reveal: String {
        switch language {
        case .zhHans: "显示"
        case .ja: "表示"
        case .de: "Zeigen"
        case .es: "Mostrar"
        case .fr: "Afficher"
        case .tr: "Göster"
        default: "Reveal"
        }
    }

    public var copyPath: String {
        switch language {
        case .zhHans: "复制路径"
        case .ja: "パスをコピー"
        case .de: "Pfad kopieren"
        case .es: "Copiar ruta"
        case .fr: "Copier le chemin"
        case .tr: "Yolu Kopyala"
        default: "Copy Path"
        }
    }

    public var copied: String {
        switch language {
        case .zhHans: "已复制"
        case .ja: "コピー完了"
        case .de: "Kopiert"
        case .es: "Copiado"
        case .fr: "Copié"
        case .tr: "Kopyalandı"
        default: "Copied"
        }
    }

    public func clickToCopy(command: String) -> String {
        switch language {
        case .zhHans: "点击复制：\(command)"
        case .ja: "クリックしてコピー: \(command)"
        case .de: "Klicken zum Kopieren: \(command)"
        case .es: "Haz clic para copiar: \(command)"
        case .fr: "Cliquer pour copier : \(command)"
        case .tr: "Kopyalamak için tıklayın: \(command)"
        default: "Click to copy: \(command)"
        }
    }

    public var runtime: String {
        switch language {
        case .zhHans: "运行时"
        case .ja: "ランタイム"
        case .de: "LAUFZEIT"
        case .es: "ENTORNO"
        case .fr: "EXÉCUTION"
        case .tr: "ÇALIŞMA"
        default: "RUNTIME"
        }
    }

    public var user: String {
        switch language {
        case .zhHans: "用户"
        case .ja: "ユーザー"
        case .de: "BENUTZER"
        case .es: "USUARIO"
        case .fr: "UTILISATEUR"
        case .tr: "KULLANICI"
        default: "USER"
        }
    }

    public var started: String {
        switch language {
        case .zhHans: "已启动"
        case .ja: "開始日時"
        case .de: "GESTARTET"
        case .es: "INICIADO"
        case .fr: "DÉMARRÉ"
        case .tr: "BAŞLATILDI"
        default: "STARTED"
        }
    }

    public var memory: String {
        switch language {
        case .zhHans: "内存"
        case .ja: "メモリ"
        case .de: "SPEICHER"
        case .es: "MEMORIA"
        case .fr: "MÉMOIRE"
        case .tr: "BELLEK"
        default: "MEMORY"
        }
    }

    public func dockerContainerStopBanner(name: String) -> String {
        switch language {
        case .zhHans: "Docker 容器 • 通过 docker stop \(name) 停止"
        case .ja: "Docker コンテナ • docker stop \(name) で停止"
        case .de: "Docker-Container • Beenden mit docker stop \(name)"
        case .es: "Contenedor Docker • Detener con docker stop \(name)"
        case .fr: "Conteneur Docker • Arrêter via docker stop \(name)"
        case .tr: "Docker Konteyneri • docker stop \(name) ile durdurun"
        default: "Docker Container • Stop via docker stop \(name)"
        }
    }

    public func protectedProcessBanner(reason: String) -> String {
        switch language {
        case .zhHans: "受保护进程 (\(reason)) • 无法终止"
        case .ja: "保護されたプロセス (\(reason)) • 終了できません"
        case .de: "Geschützter Prozess (\(reason)) • Kann nicht beendet werden"
        case .es: "Proceso protegido (\(reason)) • No se puede detener"
        case .fr: "Processus protégé (\(reason)) • Ne peut pas être arrêté"
        case .tr: "Korumalı işlem (\(reason)) • Kapatılamaz"
        default: "Protected process (\(reason)) • Cannot be killed"
        }
    }

    public var safeToTerminateBanner: String {
        switch language {
        case .zhHans: "您的进程 • 可安全终止"
        case .ja: "ユーザー所有 • 安全に終了できます"
        case .de: "Eigener Prozess • Sicher zu beenden"
        case .es: "De tu propiedad • Seguro de detener"
        case .fr: "Votre processus • Arrêt sans risque"
        case .tr: "Size ait • Güvenle kapatılabilir"
        default: "Owned by you • Safe to terminate"
        }
    }

    // MARK: - Kill Button

    public var kill: String {
        switch language {
        case .zhHans: "终止"
        case .ja: "終了"
        case .de: "Beenden"
        case .es: "Matar"
        case .fr: "Tuer"
        case .tr: "Kapat"
        default: "Kill"
        }
    }

    public func killAccessibility(subject: String) -> String {
        switch language {
        case .zhHans: "终止 \(subject)"
        case .ja: "\(subject) を終了"
        case .de: "\(subject) beenden"
        case .es: "Detener \(subject)"
        case .fr: "Arrêter \(subject)"
        case .tr: "\(subject) kapat"
        default: "Kill \(subject)"
        }
    }

    public func stoppingAccessibility(subject: String, remainingSeconds: Int) -> String {
        switch language {
        case .zhHans: "正在停止 \(subject)，剩余 \(remainingSeconds) 秒"
        case .ja: "\(subject) を停止中、残り \(remainingSeconds) 秒"
        case .de: "\(subject) wird beendet, noch \(remainingSeconds) Sekunden"
        case .es: "Deteniendo \(subject), \(remainingSeconds) segundos"
        case .fr: "Arrêt de \(subject), \(remainingSeconds) secondes"
        case .tr: "\(subject) durduruluyor, \(remainingSeconds) saniye"
        default: "Stopping \(subject), \(remainingSeconds) seconds"
        }
    }

    public var forceKill: String {
        switch language {
        case .zhHans: "强制终止"
        case .ja: "強制終了"
        case .de: "Sofort beenden"
        case .es: "Forzar detención"
        case .fr: "Forcer l'arrêt"
        case .tr: "Zorla Kapat"
        default: "Force Kill"
        }
    }

    public func forceKillAccessibility(subject: String) -> String {
        switch language {
        case .zhHans: "强制终止 \(subject)"
        case .ja: "\(subject) を強制終了"
        case .de: "\(subject) sofort beenden"
        case .es: "Forzar detención de \(subject)"
        case .fr: "Forcer l'arrêt de \(subject)"
        case .tr: "\(subject) zorla kapat"
        default: "Force kill \(subject)"
        }
    }

    public var stopped: String {
        switch language {
        case .zhHans: "已停止"
        case .ja: "停止済み"
        case .de: "Beendet"
        case .es: "Detenido"
        case .fr: "Arrêté"
        case .tr: "Durduruldu"
        default: "Stopped"
        }
    }

    public func readOnlyTooltip(reason: String) -> String {
        switch language {
        case .zhHans: "\(reason) 进程，只读"
        case .ja: "\(reason) プロセス、読み取り専用"
        case .de: "\(reason)-Prozess, schreibgeschützt"
        case .es: "Proceso \(reason), de solo lectura"
        case .fr: "Processus \(reason), en lecture seule"
        case .tr: "\(reason) işlemi, salt okunur"
        default: "\(reason) process, read-only"
        }
    }

    public func readOnlyAccessibility(subject: String, reason: String) -> String {
        switch language {
        case .zhHans: "\(subject)，\(reason) 进程，无法终止"
        case .ja: "\(subject)、\(reason) プロセス、終了できません"
        case .de: "\(subject), \(reason)-Prozess, kann nicht beendet werden"
        case .es: "\(subject), proceso \(reason), no se puede detener"
        case .fr: "\(subject), processus \(reason), ne peut pas être arrêté"
        case .tr: "\(subject), \(reason) işlemi, kapatılamaz"
        default: "\(subject), \(reason) process, cannot be killed"
        }
    }

    // MARK: - Reasons

    public var reasonProtected: String {
        switch language {
        case .zhHans: "受保护"
        case .ja: "保護済み"
        case .de: "Geschützt"
        case .es: "Protegido"
        case .fr: "Protégé"
        case .tr: "Korumalı"
        default: "Protected"
        }
    }

    public var reasonOtherUser: String {
        switch language {
        case .zhHans: "其他用户"
        case .ja: "別ユーザー"
        case .de: "Anderer Benutzer"
        case .es: "Otro usuario"
        case .fr: "Autre utilisateur"
        case .tr: "Diğer kullanıcı"
        default: "Other user"
        }
    }

    public var reasonSystem: String {
        switch language {
        case .zhHans: "系统"
        case .ja: "システム"
        case .de: "System"
        case .es: "Sistema"
        case .fr: "Système"
        case .tr: "Sistem"
        default: "System"
        }
    }

    public var reasonDocker: String {
        "Docker"
    }

    // MARK: - Port Badge

    public func clickToCopyPort(port: Int) -> String {
        switch language {
        case .zhHans: "点击复制 localhost:\(port)"
        case .ja: "クリックして localhost:\(port) をコピー"
        case .de: "Klicken zum Kopieren von localhost:\(port)"
        case .es: "Haz clic para copiar localhost:\(port)"
        case .fr: "Cliquer pour copier localhost:\(port)"
        case .tr: "localhost:\(port) kopyalamak için tıklayın"
        default: "Click to copy localhost:\(port)"
        }
    }

    public func copyPortAccessibility(port: Int) -> String {
        switch language {
        case .zhHans: "复制 localhost:\(port)"
        case .ja: "localhost:\(port) をコピー"
        case .de: "localhost:\(port) kopieren"
        case .es: "Copiar localhost:\(port)"
        case .fr: "Copier localhost:\(port)"
        case .tr: "localhost:\(port) kopyala"
        default: "Copy localhost:\(port)"
        }
    }

    // MARK: - About Modal

    public var aboutTagline: String {
        switch language {
        case .zhHans: "轻快、小巧的 macOS 菜单栏端口管理器"
        case .ja: "macOS向けの高速でミニマルなメニューバーポート管理ツール"
        case .de: "Schneller, minimalistischer Port-Manager für die macOS-Menüleiste"
        case .es: "Administrador de puertos rápido y minimalista para la barra de menús de macOS"
        case .fr: "Gestionnaire de ports rapide et minimaliste pour la barre des menus macOS"
        case .tr: "macOS için hızlı ve minimal menü çubuğu port yöneticisi"
        default: "Fast, minimal menu bar port manager for macOS"
        }
    }

    public var createdBy: String {
        switch language {
        case .zhHans: "由 @fr3on 开发"
        case .ja: "@fr3on によって作成"
        case .de: "Erstellt von @fr3on"
        case .es: "Creado por @fr3on"
        case .fr: "Créé par @fr3on"
        case .tr: "@fr3on tarafından geliştirildi"
        default: "Created by @fr3on"
        }
    }

    public var sourceAndReleases: String {
        switch language {
        case .zhHans: "源代码、发布版本和问题反馈"
        case .ja: "ソースコード、リリース、イシュートラッカー"
        case .de: "Quellcode, Releases & Issue-Tracker"
        case .es: "Código fuente, versiones y seguimiento de problemas"
        case .fr: "Code source, versions et suivi des tickets"
        case .tr: "Kaynak kodları, sürümler ve sorun takibi"
        default: "Source code, releases & issue tracker"
        }
    }

    public var checkUpdatesButton: String {
        switch language {
        case .zhHans: "检查更新"
        case .ja: "アップデートを確認"
        case .de: "Nach Updates suchen"
        case .es: "Buscar actualizaciones"
        case .fr: "Rechercher des mises à jour"
        case .tr: "Güncellemeleri Kontrol Et"
        default: "Check for Updates"
        }
    }

    public var done: String {
        switch language {
        case .zhHans: "完成"
        case .ja: "完了"
        case .de: "Fertig"
        case .es: "Listo"
        case .fr: "Terminé"
        case .tr: "Bitti"
        default: "Done"
        }
    }

    // MARK: - Update Modal

    public var updateAvailableTitle: String {
        switch language {
        case .zhHans: "发现新版本"
        case .ja: "アップデートがあります"
        case .de: "Update verfügbar"
        case .es: "Actualización disponible"
        case .fr: "Mise à jour disponible"
        case .tr: "Güncelleme Mevcut"
        default: "Update Available"
        }
    }

    public func updateAvailableDescription(currentVersion: String) -> String {
        switch language {
        case .zhHans: "当前版本为 v\(currentVersion)。GitHub 上已有新版本可供下载。"
        case .ja: "現在 v\(currentVersion) です。GitHub に新しいバージョンが用意されています。"
        case .de: "Sie verwenden v\(currentVersion). Eine neuere Version ist auf GitHub verfügbar."
        case .es: "Estás en la v\(currentVersion). Hay una nueva versión lista en GitHub."
        case .fr: "Vous utilisez la v\(currentVersion). Une nouvelle version est disponible sur GitHub."
        case .tr: "Şu an v\(currentVersion) sürümündesiniz. GitHub'da daha yeni bir sürüm hazır."
        default: "You're on v\(currentVersion). A newer version is ready on GitHub."
        }
    }

    public var whatsNew: String {
        switch language {
        case .zhHans: "更新内容"
        case .ja: "新機能・変更点"
        case .de: "WAS IST NEU"
        case .es: "NOVEDADES"
        case .fr: "NOUVEAUTÉS"
        case .tr: "YENİLİKLER"
        default: "WHAT'S NEW"
        }
    }

    public var later: String {
        switch language {
        case .zhHans: "稍后"
        case .ja: "後で"
        case .de: "Später"
        case .es: "Más tarde"
        case .fr: "Plus tard"
        case .tr: "Daha sonra"
        default: "Later"
        }
    }

    public var downloadDMG: String {
        switch language {
        case .zhHans: "下载 DMG"
        case .ja: "DMGをダウンロード"
        case .de: "DMG herunterladen"
        case .es: "Descargar DMG"
        case .fr: "Télécharger le DMG"
        case .tr: "DMG İndir"
        default: "Download DMG"
        }
    }

    public var viewRelease: String {
        switch language {
        case .zhHans: "查看发布页面"
        case .ja: "リリースを表示"
        case .de: "Release ansehen"
        case .es: "Ver lanzamiento"
        case .fr: "Voir la release"
        case .tr: "Sürümü Görüntüle"
        default: "View Release"
        }
    }

    public func updateAvailableBadgeTooltip(version: String) -> String {
        switch language {
        case .zhHans: "有可用更新：v\(version)（点击查看）"
        case .ja: "アップデート利用可能: v\(version)（クリックして表示）"
        case .de: "Update verfügbar: v\(version) (Klicken zum Anzeigen)"
        case .es: "Actualización disponible: v\(version) (Clic para ver)"
        case .fr: "Mise à jour disponible : v\(version) (Cliquer pour voir)"
        case .tr: "Güncelleme mevcut: v\(version) (Görüntülemek için tıklayın)"
        default: "Update available: v\(version) (Click to view)"
        }
    }
}

extension AppLanguage {
    public var strings: LocalizedStrings {
        LocalizedStrings(language: self)
    }
}

extension ReadOnlyReason {
    public func localized(for language: AppLanguage) -> String {
        switch self {
        case .protectedPID, .ownProcess: language.strings.reasonProtected
        case .otherUser: language.strings.reasonOtherUser
        case .systemProcess: language.strings.reasonSystem
        case .dockerContainer: language.strings.reasonDocker
        }
    }
}
