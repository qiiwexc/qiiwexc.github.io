# Agent Instructions

## Project Overview

`qiiwexc` is a Windows utility toolkit that builds these artifacts from PowerShell source:

- `build/qiiwexc.ps1` — a WPF GUI PowerShell app for Windows configuration and diagnostics
- `build/qiiwexc.bat` — a batch launcher that wraps the PS1
- `build/index.html` — the project's GitHub Pages landing page
- `build/autounattend-*.xml` — Windows unattended installation answer files

## Never Do

- Never edit anything under `build/` — it is generated output.
- `d/` and `public/` are live GitHub Pages payloads that end users download and execute — treat
  any change there as a release.
- Do not renumber the numeric filename prefixes casually: they define the bundle order of the
  built script.

## Platform Constraints

The app and the full build are **Windows-only** (WPF, BITS, registry, Windows PowerShell 5.1).
CI runs on `windows-latest`. Source under `src/` and `tools/` targets **Windows PowerShell 5.1**,
not PowerShell 7 — avoid PS7-only syntax such as `&&`/`||` chaining, the ternary operator (`?:`),
the null-coalescing operators (`??`, `??=`), and `Get-Error`. On non-Windows hosts most of the
Pester suite runs, but tests that load WPF assemblies (`src/1-components`,
`Add-Type -AssemblyName PresentationFramework`) or construct CIM types fail — treat those
failures as environmental, not regressions.

## Developer Workflows

| Task                   | Command                                                                  |
| ---------------------- | ------------------------------------------------------------------------ |
| Run tests              | `.\test.bat` (Pester via `tools\test.ps1`)                               |
| Tests with coverage    | `.\test-with-coverage.bat` (what CI runs; fails below the target)        |
| Tests tagged `WIP`     | `.\test-wip.bat`                                                         |
| Run a single test file | `Invoke-Pester -Path 'src\4-functions\Common\Start-Download.Tests.ps1'`  |
| Full build, as CI does | `.\build-ci.bat` (runs `tools\build.ps1 -Full -CI`)                      |
| Dev build + run        | `.\build-dev.bat` (runs `tools\build.ps1 -Dev`)                          |
| Update external deps   | `tools\build.ps1 -Update` (or the nightly `update-dependencies.yml`)     |
| Release                | `.\release.bat` (or the manual `tag.yml` workflow)                       |

- `-Full` builds the HTML page, the answer files, the PS1 and the launcher, and runs the linter.
  Without `-CI` it also runs the tests and the dependency update (`build.bat`,
  `build-and-run.bat`); `-Full -CI` skips both, because CI runs the tests in their own job and
  the update nightly.
- The dependency update rewrites `resources/dependencies.json`. Without `-CI` it opens each
  changelog URL in the browser; with `-CI` it writes them to `$env:CHANGELOG_URLS`, which
  `tools\Invoke-DependencyUpdate.ps1` hands to the nightly workflow.
- `build-dev.bat`, `build-and-run.bat` and `tools\build.ps1 -Run` start the built app, which
  relaunches itself elevated — don't run them unless asked. `build-ci.bat` and the test scripts
  write only to the git-ignored outputs in `build/` and `vm/`.
- `tools\test.ps1` and the linter load the exact Pester and PSScriptAnalyzer versions pinned in
  `resources/dependencies.json` — install them with `install-dependencies.bat`.

## Build Architecture

`tools/build.ps1` orchestrates the build. `tools/build/` contains individual build step functions. `tools/common/` contains shared utilities (logger, progress bar, file I/O) used by both build and test.

### Source-to-Script Bundling

`tools/build/New-PowerShellScript.ps1` concatenates all files under `src/` except `*.Tests.ps1` into a single `build/qiiwexc.ps1`, in `Get-ChildItem -Recurse` order: a directory's own files first, in name order, then its subdirectories, in name order — so `2-ui/Form.ps1` precedes everything in `2-ui/1-Home/`. File ordering is controlled by numeric prefixes on filenames and directories (e.g., `0-init/`, `1-components/`, `0 Parameters.ps1`). Leading numeric prefixes on each path segment are stripped from `#region` names in the output. The build fails if any `{KEY}` placeholder is left unresolved or if the bundled script does not parse.

The answer files are built from `templates/autounattend.xml`, which also carries sections for the development VM only (disk 0 partitioning, a local auto-logon account). `tools/build/New-UnattendedFile.ps1` strips them from the published files, and `tools/build/unattended/Assert-UnattendedFile.ps1` fails the build if any remain, a `{KEY}` placeholder is unresolved, or the XML is not well-formed.

Non-PS1 files in `src/3-configs/` (`.reg`, `.json`, `.conf`, `.ini`, `.xml`) are embedded as string constants named `CONFIG_<UPPERCASED_FILENAME>` using `Set-Variable -Option Constant`.

### Template Substitution

`resources/urls.json` and `resources/dependencies.json` feed into `tools/build/Get-Config.ps1` to produce a `$Config` PSCustomObject. Templates (`templates/home.html`, `templates/autounattend.xml`) use `{KEY}` placeholders replaced at build time. `src/0-init/1 Version.ps1` uses `{PROJECT_VERSION}` which is injected this way.

Downloads are verified by SHA-256 (`Start-DownloadUnzipAndRun -Sha256`). Fixed-version downloads keep a `SHA256_<NAME>` key in `urls.json`; a dependency whose `URL_<NAME>` contains `{VERSION}` keeps a `sha256` field in `dependencies.json`, exposed as `SHA256_<NAME>` and recomputed by the dependency update whenever the version changes (the version bump is dropped if the checksum cannot be computed). The self-updater verifies `qiiwexc.bat` against the release's `SHA256SUMS.txt`.

### Versioning

Locally: `YY.M.D` (from current date). In CI on a tag: parsed from `$Env:GITHUB_REF_NAME` (e.g., `v26.2.18` → `26.2.18`). For reproducible output, pin it explicitly: `tools\build.ps1 -Version 26.2.18`.

## Source Structure (`src/`)

```text
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
- `BeforeAll` dot-sources the production file, `. $PSCommandPath.Replace('.Tests.ps1', '.ps1')`,
  and anything else it needs relative to the test, `. "$PSScriptRoot\..\Common\types.ps1"`, so
  the suite runs from any directory
- `Mock` goes in `BeforeAll`, not `BeforeEach` — re-creating mocks before every test made the
  suite almost twice as slow. `Should -Invoke` still counts per test, and a `Mock` inside an `It`
  overrides it for that test only; keep `BeforeEach` for per-test state
- A mock should behave like the function it replaces: never make a function throw when its whole
  body is a catch-all `try` that doesn't rethrow — `tools/Mocks.Tests.ps1` fails on it
- Some `src/0-init` scripts run as soon as they are loaded (`2 Start elevated.ps1` relaunches
  PowerShell elevated), so their tests pull the functions out through the parser instead of
  dot-sourcing the script
- Pester runs `tools/`, `src/0-init`, `src/1-components`, `src/3-configs` and `src/4-functions`;
  `src/3-configs/Configs.Tests.ps1` checks every JSON and `.reg` config, and that each
  `$CONFIG_*` the code uses is embedded. Coverage is measured on `tools/common`, `tools/build`,
  `src/1-components` and `src/4-functions`
- Tag tests `WIP` to run them in isolation via `.\test-wip.bat`
- Windows-only commands (BITS, CIM, `chkdsk`, `DISM`, `powercfg`, scheduled tasks, Defender) are
  stubbed at the top of `BeforeAll` with simple `function` declarations so Pester can mock them on
  any host — follow that pattern when a test needs to mock a new Windows-only command

## Linting

PSScriptAnalyzer runs on the **built** `build/qiiwexc.ps1` only — `tools/` is not linted — with the settings in `PSScriptAnalyzerSettings.psd1`. Findings are printed but do not fail the build, so read the output. Notable rules: single quotes for constant strings, aligned assignment statements (hashtables included), `-not` instead of `!`, no semicolons as line terminators, opening braces on the same line, 4-space indentation, correct casing, and cmdlets and syntax that Windows PowerShell 5.1 supports.

## CI/CD Workflows

The workflows in `.github/workflows/` share composite actions from `.github/actions/` (`test`, `build`, `deploy`, `release`), referenced as `$/.github/actions/<name>`. Permissions follow least privilege: an empty or read-only default at workflow level, specific grants per job.

- `ci.yml` chains `test → build → deploy → release`; `deploy` and `release` run for tags only. `test` runs `test-with-coverage.bat` and `build` runs `build-ci.bat`. `deploy` publishes an explicit file list (assembled in `.github/actions/deploy/action.yml`) to GitHub Pages — add new site files there — and `release` creates a GitHub Release with `qiiwexc.bat`, `qiiwexc.ps1`, `autounattend-*.xml` and `SHA256SUMS.txt` as assets (via `gh release create`), unless one already exists for the tag.
- A release is cut by pushing a `vYY.M.D` tag: `release.bat` tags `origin/master` from a local checkout (it refuses if `HEAD` differs), and the manual `tag.yml` workflow tags on GitHub and then dispatches `ci.yml` for the tag, since a tag pushed with `GITHUB_TOKEN` triggers no workflows.
- `update-dependencies.yml` checks for updates nightly in a read-only job and hands the changed `dependencies.json` to a separate job that force-pushes the `chore/update-dependencies` branch and opens or updates its PR — only when a versioned download URL, Pester or PSScriptAnalyzer changes — then runs the `test` and `build` actions on it and reports both as commit statuses.
- `zizmor.yml` runs [zizmor](https://docs.zizmor.sh/) security analysis whenever files under `.github/` change.
