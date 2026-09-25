# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com), and versions follow [Semantic Versioning](https://semver.org).

## [Unreleased]

### Added
- Menu bar popover listing every process listening on a local TCP port, with PID, uptime and owning project.
- Project detection from the process working directory (`.git`, `package.json`, `Package.swift`, `pyproject.toml`, `Cargo.toml`).
- Two-stage kill: `SIGTERM`, then an explicit Force Kill after 3 seconds.
- Safety rules: PID 0/1, PortKill itself, other users' processes and known system processes are read-only.
- Guard against PID reuse: a process is only signalled if it is still the one that was scanned.
- Search by port, command or project. Click a port to copy `localhost:<port>`.
- Universal (arm64 + x86_64) build, DMG packaging, and a GitHub Actions release workflow that publishes a draft release with the DMG (signed and notarized when secrets are set).
