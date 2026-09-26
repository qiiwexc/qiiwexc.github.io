# Agent Instructions

This is the single canonical source of guidance for every AI agent working in this repository,
regardless of the platform it runs on - GitHub Copilot (in Visual Studio Code or on GitHub.com)
and Claude Code (in Visual Studio Code or on the web) all follow these same instructions. The
platform-specific entry files (`CLAUDE.md`, `.github/copilot-instructions.md`) only point here.
Apply this guidance on every request - large or small - even when the user does not explicitly
ask for it.

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
- Do not renumber the numeric prefixes of the `src/` directories or the `src/0-init` files
  casually: they define the order the built script runs in.

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
| Visual comparison      | `.\test-visual.bat` (tabs rendered from `HEAD` and the working tree)     |
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
  changelog URL in the browser; with `-CI` it writes them to `$env:CHANGELOG_URLS`, from which
  `tools\Invoke-DependencyUpdate.ps1` writes the nightly pull request's description to
  `build/dependency-update.md`: a table of the versions that moved, the changelog links grouped
  as other sites, GitHub commit comparisons and GitHub releases and tags, and the release notes
  of every release or tag crossed. The notes are third-party text, so `Format-ReleaseNotes`
  defuses mentions and issue references before quoting them, and the workflow hands the file to
  `gh` as `--body-file`.
- `build-dev.bat`, `build-and-run.bat` and `tools\build.ps1 -Run` start the built app, which
  relaunches itself elevated — don't run them unless asked. `build-ci.bat` and the test scripts
  write only to the git-ignored outputs in `build/` and `vm/`.
- `tools\test.ps1` and the linter load the exact Pester and PSScriptAnalyzer versions pinned in
  `resources/dependencies.json` — install them with `install-dependencies.bat`.
- Long command output wastes context: pipe verbose commands through `Select-Object -Last 30`, or
  filter a Pester run down to its failures (`[-]` lines and the summary) when only those matter.

## Skills

`.claude/skills/` holds this repository's procedures, one directory per procedure with a
`SKILL.md` inside. Claude Code discovers and loads them on its own. **Every other platform -
GitHub Copilot included - has no such mechanism, so read the file directly before starting the
matching task.** Each of these is the authority on its procedure; this file does not restate them.

| procedure                                                                      | read it before                                                                    |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| [`repository-review`](.claude/skills/repository-review/SKILL.md)               | reviewing the repository, or one of its areas, end to end                         |
| [`dependency-update-triage`](.claude/skills/dependency-update-triage/SKILL.md) | triaging the nightly dependency update PR or a Dependabot PR, or judging a bump   |
| [`memory-consolidation`](.claude/skills/memory-consolidation/SKILL.md)         | auditing the agent memory directory (Claude Code only; no other platform has one) |

## Build Architecture

`tools/build.ps1` orchestrates the build. `tools/build/` contains individual build step functions. `tools/common/` contains shared utilities (logger, progress bar, file I/O) used by both build and test. The logger and the progress bar there are the app's own (`src/4-functions/App lifecycle`), dot-sourced with no-op stand-ins for the window they would otherwise write to, so the two cannot drift apart.

### Source-to-Script Bundling

`tools/build/New-PowerShellScript.ps1` concatenates all files under `src/` except `*.Tests.ps1` into a single `build/qiiwexc.ps1`, in the order `tools/build/Get-SourceFiles.ps1` spells out: a directory's own files first, then its subdirectories, each level in name order (ordinal, ignoring case, as NTFS lists them). The order matters only where code runs as it loads, so the numeric prefixes that control it are on the top-level directories (`0-init/` … `5-interface/`) and on the files in `0-init/` (`0 Parameters.ps1`, …); everything else defines functions, constants or tab definitions. Leading numeric prefixes on each path segment are stripped from `#region` names in the output. The build fails if any `{KEY}` placeholder is left unresolved or if the bundled script does not parse.

The answer files are built from `templates/autounattend.xml`, which also carries sections for the development VM only (disk 0 partitioning, a local auto-logon account). `tools/build/New-UnattendedFile.ps1` strips them from the published files, and `tools/build/unattended/Assert-UnattendedFile.ps1` fails the build if any remain, a `{KEY}` placeholder is unresolved, or the XML is not well-formed. The template is the output of the [unattend generator](https://schneegans.de/windows/unattend-generator/); the URL in its first comment reproduces it. After regenerating it, run the tests: `New-UnattendedBase` fails if something it rewrites (such as the `RemovePackage.ps1` package list) is gone, and `New-UnattendedFile.Tests.ps1` builds the real template end to end.

Non-PS1 files in `src/3-configs/` (`.reg`, `.json`, `.conf`, `.ini`, `.xml`) are embedded as string constants named `CONFIG_<UPPERCASED_FILENAME>` using `Set-Variable -Option Constant`.

### Template Substitution

`resources/urls.json` and `resources/dependencies.json` feed into `tools/build/Get-Config.ps1` to produce a `$Config` PSCustomObject. Templates (`templates/home.html`, `templates/autounattend.xml`) use `{KEY}` placeholders replaced at build time. `src/0-init/1 Version.ps1` uses `{PROJECT_VERSION}` which is injected this way.

Downloads are verified by SHA-256 (`Start-DownloadUnzipAndRun -Sha256`). Fixed-version downloads keep a `SHA256_<NAME>` key in `urls.json`; a dependency whose `URL_<NAME>` contains `{VERSION}` keeps a `sha256` field in `dependencies.json`, exposed as `SHA256_<NAME>` and recomputed by the dependency update whenever the version changes (the version bump is dropped if the checksum cannot be computed). The self-updater verifies `qiiwexc.bat` against the release's `SHA256SUMS.txt`.

### Versioning

Locally: `YY.M.D` (from current date). In CI on a tag: parsed from `$Env:GITHUB_REF_NAME` (e.g., `v26.2.18` → `26.2.18`). For reproducible output, pin it explicitly: `tools\build.ps1 -Version 26.2.18`.

## Source Structure (`src/`)

```text
0-init/          # App parameters, version, elevation, initialization, UI constants, theme
1-components/    # WPF controls (New-Button, New-CheckBox, New-Card, ...) and New-Tab, which renders a tab
2-ui/            # The window's XAML (Form.ps1) and one definition per tab (Home.ps1, Installs.ps1, ...)
3-configs/       # Embedded config files (app settings, registry exports, ini files)
4-functions/     # Feature logic organized by tab (App lifecycle, Installs, Configuration, etc.)
5-interface/     # Entry point: Show window.ps1 renders the tabs, in order, and shows the window
```

## UI Pattern (tab definitions)

Each tab is data: `src/2-ui/<Tab>.ps1` defines a `TAB_<NAME>` hashtable of cards, and each card lists its items — buttons with their `Action`, their options and an optional centred "Start after download" checkbox (`StartAfterDownload`), and standalone checkboxes. `New-Tab` (`src/1-components/Tab.ps1`) renders a definition through the component functions, which add to the panel they are given and return what they made. It rejects unknown keys, a missing `Action` or `Name` and duplicate names, puts every checkbox into `$CHECKBOXES` under its `Name`, and every button given a `Name` into `$BUTTONS`.

- Placement follows from the definition: a button's options join its "Start after download" group when it has one and sit in the card otherwise, and every button after a card's first item is spaced from what comes before it.
- Handlers read checkboxes at click time (`$CHECKBOXES.StartVentoy.IsChecked`). A checkbox that enables others has `OnClick = { Set-CheckboxState -Control $this -Dependant $CHECKBOXES.<Name> }`.
- Only one async operation runs at a time. `New-Tab` registers every button whose `Action` calls `Start-AsyncOperation` (`Register-AsyncButton`); while an operation runs, all of them are disabled except the one that started it, which turns into its Cancel button until the cancellation is under way. A handler that enables or disables such a button for a reason of its own, such as nothing being selected to apply, goes through `Set-ButtonEnabled $BUTTONS.<Name>`, never `IsEnabled`, so that the state survives an operation.
- An operation reaches the window only through `Invoke-OnDispatcher 'Command-Name' @{ Parameter = $Value }`, which runs that function on the UI thread through a delegate the UI thread's runspace created, so only data crosses threads. Never hand a dispatcher a script block from the async runspace: once the operation is being cancelled, running it waits for that runspace while the operation waits for the UI thread, and the window freezes. `Invoke-OnDispatcher.Tests.ps1` fails on any other code that calls into a dispatcher. The functions that touch the window (`Add-FormLogEntry`, `Set-ProgressBarValue`, `Set-FormIcon`) run only that way.
- `Start-AsyncOperation` copies function bodies into its runspace, not the handler's scope, so an operation gets only what is passed with `-Variables` (and the app-wide variables it injects). The app's enums (`[LogLevel]`, `[IconName]`) resolve there only inside those functions, not in the operation's own script block. `src/2-ui/Tabs.Tests.ps1` fails on a variable that is not passed, on a checkbox or a named button that is read but not defined, or defined but never read, and on a button that starts an operation without being registered.
- A change to the components, the renderer, the definitions' layout or `Form.ps1` that should not change how the window looks is checked with `.\test-visual.bat`: it renders every tab in the light, dark and high contrast themes from `HEAD` and from the working tree, and compares them pixel for pixel (differences land in `build/ui-snapshots/diff`).

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
- To check in a `ParameterFilter` that a parameter was not passed, use
  `-not $PesterBoundParameters.ContainsKey('Name')`: `$Name -eq $Null` reads any variable of that
  name in an outer scope instead, and a parallel worker defines `$WorkingDirectory`
- Some `src/0-init` scripts run as soon as they are loaded (`2 Start elevated.ps1` relaunches
  PowerShell elevated), so their tests pull the functions out through the parser instead of
  dot-sourcing the script
- Pester runs `tools/`, `src/0-init`, `src/1-components`, `src/2-ui`, `src/3-configs` and
  `src/4-functions`; `src/3-configs/Configs.Tests.ps1` checks every JSON and `.reg` config, and
  that each `$CONFIG_*` the code uses is embedded. Coverage is measured on `tools/common`,
  `tools/build`, `src/1-components` and `src/4-functions`
- Tag tests `WIP` to run them in isolation via `.\test-wip.bat`. Tests tagged `Visual` (the
  rendering comparison in `tools/ui`) run only with `-Visual`, via `.\test-visual.bat`, never in
  CI
- Test files run in parallel (`Run.Parallel` in `PesterSettings.ps1`), each in a runspace of its
  own on an MTA thread — except with coverage, which is several times slower in parallel, so CI's
  run stays sequential. A file that builds WPF controls (they need STA) or changes process-wide
  state (environment variables, the current directory, the console encoding) starts with a
  `#pester:no-parallel` comment saying why, and runs in the calling session after the parallel
  batch. The root `Pester.BeforeContainer.ps1` gives every file the strict mode and `Stop` error
  preference of `tools\test.ps1`, which a fresh runspace would not have
- Windows-only commands (BITS, CIM, `chkdsk`, `DISM`, `powercfg`, scheduled tasks, Defender) are
  stubbed at the top of `BeforeAll` with simple `function` declarations so Pester can mock them on
  any host — follow that pattern when a test needs to mock a new Windows-only command

## Linting

PSScriptAnalyzer runs on the **built** `build/qiiwexc.ps1` and on every script under `tools/` (tests included), with the settings in `PSScriptAnalyzerSettings.psd1`. Any finding fails the build, after all of them are printed; `src/` is covered through the bundle, so its findings point at lines of `build/qiiwexc.ps1`. The analyzer sometimes fails with a rule error of its own (`The term 'Get-Command' is not recognized`) rather than a finding, which the build retries. Notable rules: single quotes for constant strings, aligned assignment statements (hashtables included), `-not` instead of `!`, no semicolons as line terminators, opening braces on the same line, 4-space indentation, correct casing, and cmdlets and syntax that Windows PowerShell 5.1 supports.

## CI/CD Workflows

The workflows in `.github/workflows/` share composite actions from `.github/actions/` (`test`, `build`, `deploy`, `release`), referenced as `$/.github/actions/<name>`. Permissions follow least privilege: an empty or read-only default at workflow level, specific grants per job.

- `ci.yml` chains `test → build → deploy → release`; `deploy` and `release` run for tags only. `test` runs `test-with-coverage.bat` and `build` runs `build-ci.bat`. `deploy` publishes an explicit file list (assembled in `.github/actions/deploy/action.yml`) to GitHub Pages — add new site files there — and `release` creates a GitHub Release with `qiiwexc.bat`, `qiiwexc.ps1`, `autounattend-*.xml` and `SHA256SUMS.txt` as assets (via `gh release create`), unless one already exists for the tag.
- A release is cut by pushing a `vYY.M.D` tag: `release.bat` tags `origin/master` from a local checkout (it refuses if `HEAD` differs), and the manual `tag.yml` workflow tags on GitHub and then dispatches `ci.yml` for the tag, since a tag pushed with `GITHUB_TOKEN` triggers no workflows.
- `update-dependencies.yml` checks for updates nightly in a read-only job and hands the changed `dependencies.json`, with the pull request description it wrote, to a separate job that force-pushes the `chore/update-dependencies` branch and opens or updates its PR whenever any version moved, then runs the `test` and `build` actions on it and reports both as commit statuses.
- `zizmor.yml` runs [zizmor](https://docs.zizmor.sh/) security analysis whenever files under `.github/` change.

## Workflow Notes

- **After making code changes, run the tests before handing work off** - the single test files
  that cover the change while iterating, then `.\test.bat` - and `.\build-ci.bat` whenever the
  change reaches the bundle, the page, the answer files or `tools/`. The task is complete only
  when both pass. A dependency or CI change is always the full run.
- After making changes, update any documentation they affect (this `AGENTS.md`, the platform
  entry files, the skills, and inline comments) so the docs stay in sync with the code.
- **Documentation describes the repository as it is now, never as it was.** Do not write - and
  remove where you find - lines whose subject is a past state: "this used to live in X",
  "renamed from Y", "the old behaviour was Z". Git holds the history. Where a past decision still
  constrains the code, state the constraint rather than the change. The one exception is a
  migration that is genuinely still in flight, which the next rule covers.
- **Compatibility shims are temporary, and it is your job to make sure they are.** When a file
  format, registry value, stored setting or path the app reads changes and the code keeps
  reading the old shape - a fallback branch, a legacy key, a clean-up of what an older version
  left behind - mark it in the source with a `MIGRATION:` comment saying what it accepts and what
  has to happen before it can go (usually "every installed copy has self-updated past version
  X"), and then **save a memory recording it**. At the start of a later session, ask the user
  whether that migration can be removed yet. Remove one as soon as the user confirms.
- Never run `git checkout -- <path>` or `git restore <path>` to "tidy up" - it restores the
  working tree from the index and silently destroys every uncommitted edit under that path,
  including ones made earlier in the session. Run `git status`/`git diff` on the path first and
  confirm it holds only changes that should be discarded.
- When moving source files, move their `.Tests.ps1` files with them, and update every
  dot-source path that pointed at the old location.
- `wip/` holds work in progress that is never committed (it is git-ignored): drafts, notes,
  review reports, and the Office Installer executables `Update-FileDependency` reads. Nothing in
  it is part of the codebase and it is outside every check. Do not read through the directory to
  build context; open only the files a task points at by name. It is also where output a task
  asks you to produce belongs (review artifacts, reworked text) unless the user names another
  location.
- **Prose is British English, identifiers are whatever the platform calls them.** Comments,
  documentation and commit messages say "behaviour", "colour", "initialise"; code says `Color`,
  `Foreground`, `Initialize-AppDirectory`, because those are the names WPF and PowerShell use
  (or the `Verb-Noun` convention requires), and a renamed identifier is a bug rather than a style.

## General Guidelines

- Ask before assuming: when there is not enough context to complete a task - missing
  requirements, ambiguous intent, or several viable interpretations - ask the user BEFORE
  starting the implementation instead of guessing.
- Be proactive with suggestions: surface relevant actions, follow-ups or improvements the user
  may not have asked for.
- Be proactive with code quality: when you spot an opportunity to improve the codebase - security
  hardening, structure, naming, performance - make the improvement even if it was not requested.
  Keep such improvements low-risk and scoped to what you are already touching; raise larger or
  riskier refactors with the user first.
- Delegate research-heavy or exploration tasks to subagents where the platform supports them, and
  save useful findings to memory.
- Treat generated artifacts (`build/`, `build/coverage.xml`, the `vm/` images) and everything in
  `.gitignore` as out of scope for reviews, refactors and searches unless explicitly asked.
- When asked to create a file unrelated to the changed files (a summary, a report), save it to
  `wip/` under its own name.

## Implementation Considerations

- When implementing a change, account for security, performance, edge cases and likely failure
  modes. The app runs elevated on other people's machines, so a mistake there is an
  administrator-level mistake.
- Fix minor nearby issues when doing so is low risk and clearly improves the codebase.
- The full test suite and the linter take minutes; if they appear slow, give them time rather
  than cutting them short, or ask the user whether to skip them.
- When a solution behaves unreliably, add logging (`Write-LogDebug` in the app, `Write-LogInfo`
  in `tools/`) before retrying, and analyse the resulting logs to understand the failure before
  attempting further fixes.

## Coding Style

- Follow the conventions of the code around you: one function per file, named after it
  (`Verb-Noun.ps1` with an approved verb); typed variables and parameters; values that do not
  change declared with `Set-Variable -Option Constant Name ([Type]value)`. `Set-Variable` turns its
  value into a string for its `-WhatIf` message, so it fails on an object that cannot be turned into
  one, such as the `Process` that `Start-Process -Wait -PassThru` returns once it has exited: keep
  only the property you need (`.ExitCode`). For the same reason, a function with
  `SupportsShouldProcess` sets none of its constants under `-WhatIf`.
- `Start-Process -Wait` in Windows PowerShell 5.1 takes a second or more, however quickly the
  process exits. Where that adds up (a tool run once per registry key), start it with `-PassThru`
  and call `WaitForExit()` on the process, as `Invoke-RegistryImport` does.
- Keep functions small and single-purpose, and prefer an existing helper in
  `src/4-functions/Common` or `tools/common` over a new local one.
- Do not reference external sources in code comments - issue trackers, screenshots, files in
  `wip/`, or other artifacts that live outside the codebase. They go stale and mean nothing to
  readers without access to them; describe the behaviour or constraint in the comment itself.
- Pin GitHub Actions by full commit SHA with the version in a trailing comment
  (`uses: owner/action@<sha> # vX.Y.Z`); Dependabot keeps them current.
- A `.ps1` file with non-ASCII characters outside comments (Cyrillic strings, emoji) must be
  saved as UTF-8 **with** a byte order mark. Windows PowerShell 5.1 reads a file without one as
  ANSI, where a mangled character such as `’` can end a string early and break the whole file.
  Rewriting a file through an API that writes UTF-8 without a BOM drops it silently, so check the
  first three bytes after editing such a file.
- Apply OWASP-minded security practices, and prefer writing the test first when practical.

## Request Assessment

Where a request would cause a real problem - a security hole, a download the app runs without
verifying it, a system change applied without the user's consent - name the problem
specifically, propose the safer approach, and wait for the user's decision rather than
implementing it silently. Minor concerns and style preferences do not warrant blocking.

## Planning Workflow

Skip planning for trivial changes and implement directly. For anything else, use the platform's
plan mode, researching the codebase first - delegating to parallel subagents where the platform
supports them - and ask the blocking questions during planning rather than leaving them at the
end of the plan.
