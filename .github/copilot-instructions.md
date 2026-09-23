# Copilot Instructions

## Project Overview

`qiiwexc` is a Windows utility toolkit that builds these artifacts from PowerShell source:

- `build/qiiwexc.ps1` — a WPF GUI PowerShell app for Windows configuration and diagnostics
- `build/qiiwexc.bat` — a batch launcher that wraps the PS1
- `build/index.html` — the project's GitHub Pages landing page
- `build/autounattend-*.xml` — Windows unattended installation answer files

## Developer Workflows

| Task                   | Command                                                                       |
| ---------------------- | ----------------------------------------------------------------------------- |
| Dev build + run        | `.\build-dev.bat` (runs `tools\build.ps1 -Dev`)                               |
| Run tests              | `.\test.bat` (Pester via `tools\test.ps1`)                                    |
| Full build (CI-style)  | `.\build-ci.bat` (runs `tools\build.ps1 -Full -CI`)                           |
| Tests with coverage    | `.\test-with-coverage.bat` (fails when coverage is below the target)          |
| Run a single test file | `Invoke-Pester -Path 'src\4-functions\Common\Start-Download.Tests.ps1'`       |
| Update external deps   | `tools\build.ps1 -Update` (or the nightly `update-dependencies.yml` workflow) |

`-Full` implies: tests, dependency update check, HTML, autounattend, PS1, lint, and batch.
`tools\test.ps1` and the linter load the exact Pester and PSScriptAnalyzer versions pinned in `resources/dependencies.json` — install them with `install-dependencies.bat`.
**Always pass `-CI` in CI/CD** — without it, `Update-Dependencies` opens browser tabs instead of writing to `$env:CHANGELOG_URLS`.

## Build Architecture

`tools/build.ps1` orchestrates the build. `tools/build/` contains individual build step functions. `tools/common/` contains shared utilities (logger, progress bar, file I/O) used by both build and test.

### Source-to-Script Bundling

`tools/build/New-PowerShellScript.ps1` concatenates all files under `src/` recursively (in `Get-ChildItem` enumeration order — alphabetical per directory — with `*.Tests.ps1` excluded) into a single `build/qiiwexc.ps1`. File ordering is controlled by numeric prefixes on filenames and directories (e.g., `0-init/`, `1-components/`, `0 Parameters.ps1`). Leading numeric prefixes on each path segment are stripped from `#region` names in the output. The build fails if any `{KEY}` placeholder is left unresolved or if the bundled script does not parse.

The answer files are built from `templates/autounattend.xml`, which also carries sections for the development VM only (disk 0 partitioning, a local auto-logon account). `tools/build/New-UnattendedFile.ps1` strips them from the published files, and `tools/build/unattended/Assert-UnattendedFile.ps1` fails the build if any remain, a `{KEY}` placeholder is unresolved, or the XML is not well-formed.

Non-PS1 files in `src/3-configs/` (`.reg`, `.json`, `.conf`, `.ini`, `.xml`) are embedded as string constants named `CONFIG_<UPPERCASED_FILENAME>` using `Set-Variable -Option Constant`.

### Template Substitution

`resources/urls.json` and `resources/dependencies.json` feed into `tools/build/Get-Config.ps1` to produce a `$Config` PSCustomObject. Templates (`templates/home.html`, `templates/autounattend.xml`) use `{KEY}` placeholders replaced at build time. `src/0-init/1 Version.ps1` uses `{PROJECT_VERSION}` which is injected this way.

Downloads are verified by SHA-256 (`Start-DownloadUnzipAndRun -Sha256`). Fixed-version downloads keep a `SHA256_<NAME>` key in `urls.json`; a dependency whose `URL_<NAME>` contains `{VERSION}` keeps a `sha256` field in `dependencies.json`, exposed as `SHA256_<NAME>` and recomputed by the dependency update whenever the version changes (the version bump is dropped if the checksum cannot be computed). The self-updater verifies `qiiwexc.bat` against the release's `SHA256SUMS.txt`.

### Versioning

Locally: `YY.M.D` (from current date). In CI on a tag push: parsed from `$Env:GITHUB_REF_NAME` (e.g., `v26.2.18` → `26.2.18`). For reproducible output, pin it explicitly: `tools\build.ps1 -Version 26.2.18`.

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
- Windows-only commands (BITS, CIM, `chkdsk`, `DISM`, `powercfg`, scheduled tasks, Defender) are
  stubbed at the top of `BeforeAll` with simple `function` declarations so Pester can mock them on
  any host — follow that pattern when a test needs to mock a new Windows-only command

## Platform Constraints

The app and the full build are **Windows-only** (WPF, BITS, registry, Windows PowerShell 5.1).
CI runs on `windows-latest`. Source under `src/` and `tools/` targets **Windows PowerShell 5.1**,
not PowerShell 7 — avoid PS7-only syntax such as `&&`/`||` chaining, the ternary operator (`?:`),
the null-coalescing operators (`??`, `??=`), and `Get-Error`. On non-Windows hosts most of the
Pester suite runs, but tests that load WPF assemblies (`src/1-components`,
`Add-Type -AssemblyName PresentationFramework`) or construct CIM types fail — treat those
failures as environmental, not regressions.

## Never Do

- Never edit anything under `build/` — it is generated output
- `d/` and `public/` are live GitHub Pages payloads that end users download and execute — treat
  any change there as a release
- Do not renumber the numeric filename prefixes casually: they define the bundle order of the
  built script

## Linting

PSScriptAnalyzer runs on the **built** `build/qiiwexc.ps1`, not on source files. Settings in `PSScriptAnalyzerSettings.psd1`. Notable enforced rules: use single quotes for constant strings, align assignment statements, no semicolons as line terminators, no double quotes for constant strings.

## CI/CD Workflows

Reusable workflows in `.github/workflows/`. `ci.yml` chains: `test → build → deploy (tags only) → release`. Permissions follow least-privilege: empty `{}` at workflow level, specific grants per job. The `deploy` job publishes an explicit file list (assembled in `.github/actions/deploy/action.yml`) to GitHub Pages — add new site files there; `release` creates a GitHub Release with `qiiwexc.bat`, `qiiwexc.ps1`, `autounattend-*.xml` and `SHA256SUMS.txt` as assets (via `gh release create`). `update-dependencies.yml` checks for updates in a read-only job and hands the changed `dependencies.json` to a separate job that force-pushes the `chore/update-dependencies` branch and opens or updates its PR — only when a versioned download URL, Pester or PSScriptAnalyzer changes. `zizmor.yml` runs [zizmor](https://docs.zizmor.sh/) security analysis whenever files under `.github/` change.
