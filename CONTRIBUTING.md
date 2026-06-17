# Contributing to ReMinux

Thank you for taking the time to contribute! The guidelines below keep the codebase consistent and the review process smooth.

---

## Getting started

1. **Fork** the repository and create a branch from `main`:

   ```bash
   git checkout -b feature/my-improvement
   ```

2. Make your changes (see the coding conventions below).
3. Run the syntax checker on every changed Lua file:

   ```bash
   luac5.1 -p path/to/file.lua
   ```

   Install with `sudo apt-get install lua5.1` if it is not available.
4. When you have CraftOS-PC available locally, run the runtime smoke test:

   ```bash
   CRAFTOS_PC_BIN=/path/to/craftos-pc/squashfs-root/AppRun ./.github/scripts/run-craftos-smoke.bash
   ```

   This helper currently assumes a Unix-like shell with `python3` and `timeout` available, plus a Linux/AppImage-style CraftOS-PC extraction layout. On other platforms, point `CRAFTOS_PC_BIN` at the equivalent CraftOS-PC executable and ensure those helper tools are available first.
5. Open a pull request against `main`.

---

## Code conventions

### Language and style

- **All code, comments, commit messages, and documentation must be in English.**
- Lua 5.1 (the version embedded in CC: Tweaked) is the target language.
- Use `local` for every variable that does not need to be global. Never pollute `_G` from a script unless intentionally registering a system-wide value.
- Follow **DRY** (Don't Repeat Yourself): extract repeated logic into local helper functions.
- Prefer **OOP** where a stateful entity is involved (see `etc/api/apt` for the `AptManager` class pattern).

### Naming

| Kind                   | Convention    | Example                           |
| ---------------------- | ------------- | --------------------------------- |
| Local variables        | `camelCase`   | `lineCount`, `authType`           |
| Constants              | `UPPER_SNAKE` | `AUTH_DIR`, `NO_USER`             |
| Functions (module API) | `camelCase`   | `readLines`, `buildFromDirectory` |
| Classes                | `PascalCase`  | `AptManager`                      |

### File structure

- Scripts under `bin/` are user-executable command wrappers. They should be thin: validate input, call the appropriate API function, print the result.
- APIs under `etc/api/` contain the actual logic. Keep scripts and logic separated.
- Manual pages live in `etc/man/<name>.man` and are plain text.

### Error handling

- Validate all function arguments with `expect()` in public API functions.
- Return `false` (or an error code) on failure — do not `error()` from top-level scripts.
- Print user-readable messages for failures, not raw error strings.

---

## Pull request checklist

- [ ] All changed Lua files pass `luac5.1 -p`
- [ ] CraftOS-PC smoke test passes when the runtime or boot flow changes
- [ ] No new global variable leaks in `bin/` scripts
- [ ] Manual page added or updated if a command changed
- [ ] Commit messages are in the imperative mood ("Add …", "Fix …", "Remove …")
- [ ] PR description explains *what* changed and *why*

---

## Reporting bugs

Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) template. Please include:

- CC: Tweaked version
- ReMinux version (`cat /etc/apt/list/minux-main.db | grep version`)
- Steps to reproduce
- Expected vs actual behaviour
- Any log output from `/var/log/minux.txt` (enable with `config debug logging`)

---

## Feature requests

Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) template.
