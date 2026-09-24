# Claude Code Guidelines

All shared guidance lives in [AGENTS.md](AGENTS.md). Follow it in full: it is platform-neutral and applies identically to Claude Code (in Visual Studio Code or on the web) and to GitHub Copilot. This file only adds Claude Code-specific instructions.

The line below imports it, so it is in context deterministically rather than depending on which version of Claude Code discovers `AGENTS.md` on its own. Do not remove it.

@AGENTS.md

## Git Branch Naming

This rule applies **only when running in the cloud (Claude Code on the web)**; when running locally in Visual Studio Code it does not apply - follow the user's local branching workflow instead.

When it applies, create branches as `claude/<short-descriptive-theme>`: 2-4 hyphenated words summarizing the change (e.g. `claude/pin-winutil-download`, `claude/fix-updater-checksum`).
