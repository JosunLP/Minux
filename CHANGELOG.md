# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- `neofetch` command (`/bin/neofetch.sh`): classic system-info display
  with an ASCII logo, info panel (OS, user, uptime, disk, peripherals,
  in-game time), and a 16-colour palette bar. Available immediately via
  alias; registered in the `minux-main` package manifest for future
  installs.

### Changed

- **Boot splash** (`startup.lua`): the initial screen now shows a centred
  `ReMinux vX.Y.Z` banner with a spinner animation before handing off to
  `init.sys`.
- **Boot screen** (`boot/init.sys`): complete visual overhaul.
  - Every status line uses a dot-fill layout
    (`Label ......... [value]`) that auto-adjusts to any terminal
    width instead of hard-coded column offsets.
  - Kernel load, sanity check, and DHCP now show a live `|/-\` spinner
    on the same line; the line is rewritten in place with the final result
    once the step completes.
  - Header and footer use cyan `=` separators via the new `centeredLine()`
    and `divider()` helpers.
  - The post-login welcome section shows a cyan-framed prompt box with
    available commands listed inline.
  - The first-run verification screen shows a spinner during the check
    and reports pass/fail using the same dot-fill format.
  - Crash/repair shell message is clearer: includes stage number, bullet
    list of causes, and correct config hint for disabling the crash
    handler.
- **`apt`** (`bin/apt.sh`):
  - Install, remove, and update operations now print a progress line
    (`Installing pkg ......... [done]` / `[fail]`) instead of appearing
    to hang silently.
  - Help output is sectioned and colour-coded (cyan section headers, gray
    descriptions).
  - `apt list-available` (`-la`) shows a `[done]`/`[fail]` progress line
    while fetching the package list.
  - **Bug fix**: `apt version` / `apt -v` without a package name now
    returns a clear error instead of passing `nil` to `apt.packageinfo`.
  - **Bug fix**: `apt -U` (force-update-all) now correctly requires admin
    privileges, matching all other write operations.
- **`doctor`** (`bin/doctor.sh`):
  - A brief scan animation plays before findings are listed.
  - Findings use short symbols (`!!` error, `??` warning, `++` fixed) in
    matching colours instead of the verbose `[ERROR]`/`[WARNING]` labels.
  - Summary section is framed with a separator and lists each count on its
    own coloured line.
- **`top`** (`bin/top.sh`):
  - Output is structured into labelled sections (`System`, `Storage`,
    `Peripherals`, `Network`) with separator lines.
  - Disk free space is shown alongside an ASCII usage bar
    (`[######....]`) and the value colour shifts lime → yellow → red as
    free space drops.
  - The current user is shown with an `[admin]` badge in yellow when
    applicable.
  - Version, in-game day/time, and host binary string are included in the
    system section.
- **`config`** (`bin/config.sh`):
  - `config` (no args) uses dot-fill alignment for all settings and
    colour-codes values (lime = enabled, gray = disabled, cyan = network).
  - `config <key>` help block is framed with a separator line.
  - Help output is sectioned with colour-coded examples.
- **`login`** (`bin/login.sh`):
  - When called interactively (no args), a header shows the active auth
    backend.
  - A brief spinner plays during credential verification.
  - Prompts and result lines are consistently indented.
- **`welcome.sys`**: a black status bar is drawn at the bottom of the
  welcome screen showing the current user and a command hint.

### Fixed

- First-run post-install verification ("Postinstall-Check") no longer
  fails on a clean install. The shipped per-package manifests under
  `/etc/apt/manifest/` are now bootstrapped into `/etc/apt/list/` before
  the check runs, and the verification itself is network-free so an
  offline install reports success when the local state is consistent.
- `apt update` (and `apt -U` / `doctor --repair`) now seed the same
  missing per-package manifests at the start of the run so a freshly
  installed system can be refreshed from the network without first
  hitting "installed package missing local manifest" failures.

### API

- `apt.postinstall()` and `apt.bootstrapinstalled()` API entries on the
  `apt` module for local-only verification and manifest seeding.

## [3.1.0] - 2026-05-10

### Added

- `apt help` / `-h` / `--help` / `?` now prints a structured usage
  block listing every command, its short flag, and which actions
  require admin privileges.
- `halt` and `restart` accept `help` / `-h` / `--help` / `?` and ask
  for an interactive `[y/N]` confirmation by default; pass `-y` /
  `--yes` to keep the previous immediate behaviour.
- `config` with no arguments now lists every configurable key and its
  current value when the `menu` package is not installed, instead of
  printing a generic "invalid input" message.
- `config <key>` shows the current value plus the valid options for that
  key, and `config help` / `-h` / `--help` / `?` print full usage.
- `bash help` / `-h` / `--help` / `?` print usage for the shell launcher
  and `bash setcolor` now validates all three colour names and reports
  unknown values clearly instead of silently writing them to disk.
- The boot welcome prompt accepts `help` / `?` and lists the available
  prompt commands (`bash`, `update`, `restart`, `halt`).
- `login`, `useradd`, `userdel`, and `passwd` now all accept
  `help` / `-h` / `--help` / `?` and use a uniform Usage block.
- `useradd` prompts interactively (masked) for a password when one is
  not supplied on the command line (parity with `passwd`).
- `userdel` now requires an interactive `[y/N]` confirmation before
  deleting an account; pass `-y` / `--yes` to keep the previous
  non-interactive behaviour.

### Changed

- The boot welcome banner artwork (`etc/minux-main/welcome/mnx.nfp`) now
  reads `reminux` instead of `minux` while keeping the original blocky
  pixel-font style; `welcome.sys` shifts the banner left so the wider
  art still fits inside the standard 51-column terminal.
- The boot welcome prompt now routes `restart` / `halt` through
  `/bin/restart.sh` and `/bin/halt.sh`, preserving the same `[y/N]`
  confirmation flow as the shell commands.
- The boot login retry copy now matches the actual control flow:
  retries are counted from the first `login.sh` invocation and the
  message no longer claims that Enter is required before retrying.
- `find` now follows the newer wrapper style: `help/-h/--help/?`,
  `find:`-prefixed error lines, `false` on invalid arguments, and
  inline hints for missing option values and missing paths.
- `service` now follows the newer command style: `help/-h/--help/?`,
  clearer missing-name and unknown-action errors, a hint toward
  `service list`, and color-gated success/failure output.
- `doctor` now accepts `-h` and reports unknown arguments with a proper
  `doctor:`-prefixed error plus inline usage instead of a vague
  `try 'man doctor'` line.
- The core shell now reports the missing command name (`No such program:
  <name>`) instead of a generic line, including multishell tab launches.
- `usermod` now matches the newer wrapper style: `help/-h/--help/?`,
  `usermod:`-prefixed errors, clearer local-vs-network AUTH guidance,
  and specific usage hints for missing actions / usernames / passwords.
- `apt` distinguishes between missing argument, missing admin, and
  unknown command instead of one merged "Invalid input or access
  denied" message; failure paths now return `false` and surface
  red error lines with concrete hints. Removed the always-printed
  `Apt: operation complete.` trailer that ran even after failures.
- `config` and `bash setcolor` now print success/failure feedback
  (green on success, red on error) so users can see whether a setting
  change applied. Failed `minux.setconfig` calls (e.g. denied because
  the user is not admin/owner) surface a friendly hint instead of
  silently noop'ing.
- `login.sh` no longer eats a stray keystroke after empty input, prints
  `Access granted/denied` in green/red, and shows the username on a
  failed attempt. It returns false on failure so `&&` / `||` work.
- `useradd` / `userdel` / `passwd` print colour-coded success and
  failure lines with concrete hints (e.g. "'apt -i auth-client' to
  install the network auth client") and avoid duplicate messages when
  delegating to `usermod`.
- The boot login retry loop dropped its blocking 2-second sleep and now
  shows an attempt counter so users can see the prompt is alive.
- Refreshed `man config`, `man bash`, `man login`, `man useradd`, and
  `man userdel` to document the expanded CLI.
- Bumped project package version to 3.1.0.

## [3.0.2] - 2026-05-08

### Fixed

- Stopped an endless first-run installation verify loop in the boot flow.
- Fixed wrapper failure return values so shell control flow (`&&` / `||`) behaves correctly for `cat`, `head`, `less`, `tail`, `man`, `mktemp`, and `service`.

### Added

- Added manual pages for `bash`, `edit`, `halt`, `lock`, `makeboot`, `newtab`, `restart`, `useradd`, and `userdel`.

### Changed

- Bumped project package version to 3.0.2.
- Added and packaged `CHANGELOG.md` in the release manifest.

## [3.0.1] - 2026-05-08

### Changed

- Updated in-system branding from **Minux** to **ReMinux**.
- Updated installer and APT release metadata handling for the 3.0.1 release path.
- Refreshed manual pages for `apt`, `chat`, `config`, `ls`, `man`, `ping`, `search`, and `usermod`.
