# Contributing to PortKill

Thanks for helping. PortKill is a small menu bar app, and the goal is to keep it small, fast and safe.

## Getting set up

You need macOS 14+ and Swift 6 (Xcode or the Command Line Tools). No other dependencies.

```bash
git clone https://github.com/fr3on/portkill.git
cd portkill
swift build
swift test
./scripts/build-app.sh && open build/PortKill.app
```

If `swift test` fails with `plugin for module 'TestingMacros' not found` (seen with the Command Line Tools only), point the compiler at the plugin:

```bash
swift test -Xswiftc -plugin-path -Xswiftc /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
```

## Project layout

- `Sources/PortKillCore/` holds everything that touches the system: scanning ports, parsing `lsof`, killing processes, safety rules. It must not import SwiftUI.
- `Sources/PortKill/` is the SwiftUI app.
- `Tests/PortKillCoreTests/` are Swift Testing suites. `lsof` samples live in `Fixtures/`.

## Ground rules

- **Safety first.** Kill actions go through `KillPolicy` and `ProcessKiller`. Do not add a way around them, and do not add "kill all".
- **Offline and private.** No analytics, telemetry or network calls.
- **No new dependencies** without opening an issue first.
- **Idle when closed.** Nothing may poll while the popover is hidden.
- **Tests for core changes.** Any parser or policy change needs a test. For parser changes, add a captured `lsof` fixture.
- No force unwraps or `try!`. Keep files small, one main type per file.

## Pull requests

1. Open an issue first for anything bigger than a small fix.
2. Branch from `main`, keep the change focused, and make sure `swift build` and `swift test` pass.
3. For UI changes, attach a screenshot.
4. Fill in the pull request template.

By contributing you agree your work is released under the [MIT License](LICENSE).
