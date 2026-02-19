# Copilot Instructions

## Project Overview

`qiiwexc` is a Windows utility toolkit that builds three artifacts from PowerShell source:

- `build/qiiwexc.ps1` — a WPF GUI PowerShell app for Windows configuration and diagnostics
- `build/qiiwexc.bat` — a batch launcher that wraps the PS1
- `build/index.html` — the project's GitHub Pages landing page
- `build/autounattend-*.xml` — Windows unattended installation answer files

## Developer Workflows

| Task                  | Command                                             |
| --------------------- | --------------------------------------------------- |
| Dev build + run       | `.\build-dev.bat` (runs `tools\build.ps1 -Dev`)     |
| Run tests             | `.\test.bat` (Pester)                               |
| Full build (CI-style) | `.\build-ci.bat` (runs `tools\build.ps1 -Full -CI`) |
| Tests with coverage   | `.\test-with-coverage.bat`                          |
| Update external deps  | `.\update-dependencies.bat`                         |

`-Full` implies: tests, dependency update check, HTML, autounattend, PS1, lint, and batch.
**Always pass `-CI` in CI/CD** — without it, `Update-Dependencies` opens browser tabs instead of writing to `$env:CHANGELOG_URLS`.

## Build Architecture

`tools/build.ps1` orchestrates the build. `tools/build/` contains individual build step functions. `tools/common/` contains shared utilities (logger, progress bar, file I/O) used by both build and test.

### Source-to-Script Bundling

`tools/build/New-PowerShellScript.ps1` concatenates all files under `src/` recursively (sorted, `*.Tests.ps1` excluded) into a single `build/qiiwexc.ps1`. File ordering is controlled by numeric prefixes on filenames and directories (e.g., `0-init/`, `1-components/`, `0 Parameters.ps1`). These prefixes are stripped from `#region` names in the output.

Non-PS1 files in `src/3-configs/` (`.reg`, `.json`, `.conf`, `.ini`, `.xml`) are embedded as string constants named `CONFIG_<UPPERCASED_FILENAME>` using `Set-Variable -Option Constant`.

### Template Substitution

`resources/urls.json` and `resources/dependencies.json` feed into `tools/build/Get-Config.ps1` to produce a `$Config` PSCustomObject. Templates (`templates/home.html`, `templates/autounattend.xml`) use `{KEY}` placeholders replaced at build time. `src/0-init/1 Version.ps1` uses `{PROJECT_VERSION}` which is injected this way.

### Versioning

Locally: `YY.M.D` (from current date). In CI on a tag push: parsed from `$Env:GITHUB_REF_NAME` (e.g., `v26.2.18` → `26.2.18`).

## Source Structure (`src/`)

```
0-init/          # App parameters, version, elevation, initialization, UI constants, theme
1-components/    # Reusable WPF controls: New-Button, New-CheckBox, New-Label, New-Card, etc.
2-ui/            # Form XAML + tab page layouts (Form.ps1 is the main WPF window)
3-configs/       # Embedded config files (app settings, registry exports, ini files)
4-functions/     # Feature logic organized by tab (App lifecycle, Installs, Configuration, etc.)
5-interface/     # Entry point: Show window.ps1
```

## UI Pattern (`$script:LayoutContext`)

All component functions (`New-Button`, `New-CheckBox`, etc.) read and mutate `$script:LayoutContext` — a hashtable tracking `CurrentGroup`, `CurrentTab`, `PreviousButton`, `PreviousLabelOrCheckbox`, and `CenteredCheckboxGroup`. Adding a UI element appends it to `$script:LayoutContext.CurrentGroup.Children`. Tests must initialize this context in `BeforeEach`.

## Testing Conventions

- Test files live alongside source: `Foo.ps1` + `Foo.Tests.ps1`
- `BeforeAll` dot-sources the production file: `. $PSCommandPath.Replace('.Tests.ps1', '.ps1')`
- Pester runs cover `tools/common`, `tools/build`, `src/1-components`, `src/4-functions`
- Tag tests `WIP` to run them in isolation via `.\test-wip.bat`

## Linting

PSScriptAnalyzer runs on the **built** `build/qiiwexc.ps1`, not on source files. Settings in `PSScriptAnalyzerSettings.psd1`. Notable enforced rules: use single quotes for constant strings, align assignment statements, no semicolons as line terminators, no double quotes for constant strings.

## CI/CD Workflows

Reusable workflows in `.github/workflows/`. `ci.yml` chains: `test → build → deploy (tags only) → release`. Permissions follow least-privilege: empty `{}` at workflow level, specific grants per job. The `deploy` job publishes to GitHub Pages; `release` creates a GitHub Release with `qiiwexc.bat`, `qiiwexc.ps1`, and `autounattend-*.xml` as assets.
