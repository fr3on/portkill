# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com), and versions follow [Semantic Versioning](https://semver.org).

## [0.2.0] - 2026-09-26

### Added
- Memory usage (RSS) next to uptime on every row.
- Project detection for Go (`go.mod`), Ruby (`Gemfile`), PHP (`composer.json`), Java/Kotlin (`pom.xml`, `build.gradle`, `build.gradle.kts`), Elixir (`mix.exs`) and Python (`Pipfile`).
- `⌘F` focuses search, `Esc` clears it, `⌘R` and a refresh button update the list immediately.
- Expanded rows can open the project folder in your terminal (Terminal, iTerm2, Ghostty, Warp, kitty or Alacritty) and copy `kill <PID>` or `lsof` snippets. The kill snippet sends `SIGTERM`, not `SIGKILL`.
- Docker containers: ports published by Docker (Docker Desktop, OrbStack) show the container name and image instead of `com.docker.backend`. These rows are read-only, since signalling the proxy would stop the engine; the row offers a `docker stop <name>` snippet instead. PortKill only runs `docker ps` when a Docker proxy is listening.
- One row per process: a process listening on several ports shows all its ports together, and a Docker container's ports are grouped the same way.
- Optional UDP sockets ("Show UDP Sockets" in the gear menu, off by default). UDP rows are tagged and copy a `lsof -iUDP` snippet.
- Settings menu with Launch at Login, an optional port count in the menu bar, a Show System Processes toggle and a terminal picker. Choices are remembered.
- **Process identity & runtime icons**: Automatic stack detection for Node.js, Python, Docker, Go, Rust, Ruby, Java, PHP, and databases with distinctive SF symbols and color-coded squircle badges.
- **Raycast/macOS-native glass aesthetic**: Translucent frosted glass popover background, refined surface borders, and dynamic dark/light theme tokens.
- **Redesigned process row & inspector**:
  - Tilde-collapsed project paths (`~/...`) with quick action toolbar for Reveal in Finder, Terminal, and Copy Path.
  - Interactive terminal quick snippet pills (`kill <pid>`, `lsof :<port>`) with instant checkmark copy feedback.
  - 4-column structured process telemetry grid (Runtime, User, Started, Memory).
  - Safety and ownership status banner (Docker, Protected, or User-owned).
  - Dev port badge highlights for common ports (3000, 5173, 8080, etc.).
- **Hardware telemetry refinement**: Precision frosted chip bar with live dynamic CPU load gauge and detailed hardware specs grid.
- **Interactive footer**: Tactile keycap styling for `⌘Q`, animated 360° rotation on refresh, and pulsing live status halo.
- **Vertical popup resizing**: Drag the tactile bottom grip or window border to expand/shrink the popup height (from 360px up to 820px) while maintaining fixed 390px width. Double-clicking the grip snaps it back to the default 445px height. User height preferences are automatically remembered.
- **Category filter chips & smart grouping**: One-click filter pills below search (`All`, `Dev`, `Docker`, `Helpers`) with live counts. Active development servers and projects are automatically prioritized at the top of the list with distinct section headers.
- **GitHub Releases Update System**:
  - **Manual only.** PortKill never checks for updates on launch or in the background. Choosing "Check for Updates…" (gear menu or About) sends one request to `https://api.github.com/repos/fr3on/portkill/releases/latest`, the only network request the app makes. Nothing is sent beyond that request itself (your IP address and a `PortKill-Updater/<version>` user agent).
  - Live status feedback for the manual check.
  - Non-intrusive update indicator pill in the status bar footer when a newer version is available.
  - Integrated update modal sheet displaying the latest release version, changelog/release notes preview, and a one-click DMG download or release page opener. The link only opens if it is an `https` URL on `github.com`; otherwise the project's releases page opens instead.
- **App Info & Creator Showcase ("About PortKill")**:
  - Added "About PortKill…" dialog accessible directly from the settings gear menu.
  - Displays high-resolution macOS application emblem, version, and build info.
  - One-click interactive link cards to the author's GitHub profile ([github.com/fr3on](https://github.com/fr3on)) and the repository ([github.com/fr3on/portkill](https://github.com/fr3on/portkill)).
  - Direct update check trigger and clean dismissal controls.

### Changed
- The bundle identifier is now `com.0x200.portkill`, so settings from 0.1.0 are not carried over.
- With the menu bar port count on, PortKill runs a single `lsof` every 10 seconds while the popover is closed (no `ps`, memory, project, Docker or UDP lookups). It is off by default, and nothing runs while it is off.
- Lower idle cost: a scan that only differs by timing jitter no longer re-renders the popover, and the category grouping is computed once per scan. The footer's "dev ports" count and the menu bar count now count TCP ports only, even when UDP sockets are shown.

## [0.1.0] - 2026-09-25

### Added
- Menu bar popover listing every process listening on a local TCP port, with PID, uptime and owning project.
- Project detection from the process working directory (`.git`, `package.json`, `Package.swift`, `pyproject.toml`, `Cargo.toml`).
- Two-stage kill: `SIGTERM`, then an explicit Force Kill after 3 seconds.
- Safety rules: PID 0/1, PortKill itself, other users' processes and known system processes are read-only.
- Guard against PID reuse: a process is only signalled if it is still the one that was scanned.
- Search by port, command or project. Click a port to copy `localhost:<port>`.
- Universal (arm64 + x86_64) build, DMG packaging, and a GitHub Actions release workflow that publishes a draft release with the DMG (signed and notarized when secrets are set).
