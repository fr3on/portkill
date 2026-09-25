# Security Policy

PortKill can send signals to processes on your Mac, so safety bugs matter. Examples: bypassing the read-only rules (PID 0/1, its own process, other users' processes), signalling the wrong process, or any unexpected network access.

## Reporting a vulnerability

Please do not open a public issue. Report it privately through GitHub:
**[Report a vulnerability](https://github.com/fr3on/portkill/security/advisories/new)**

Include the macOS version, PortKill version, and steps to reproduce. You can expect an acknowledgement within a few days.

## Supported versions

Only the latest release receives fixes.

## What PortKill does and doesn't do

- Runs `lsof` and `ps` locally, and sends `SIGTERM` or `SIGKILL` only to processes owned by the current user.
- Makes no network requests and collects no data.
- Is not sandboxed, because it needs to inspect other processes. It uses the Hardened Runtime with no extra entitlements.
