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

| Task                   | Command                                                                 |
| ---------------------- | ----------------------------------------------------------------------- |
| Run tests              | `.\test.bat` (Pester via `tools\test.ps1`)                              |
| Tests with coverage    | `.\test-with-coverage.bat` (what CI runs; fails below the target)       |
| Tests tagged `WIP`     | `.\test-wip.bat`                                                        |
| Visual comparison      | `.\test-visual.bat` (tabs rendered from `HEAD` and the working tree)    |
| Run a single test file | `Invoke-Pester -Path 'src\4-functions\Common\Start-Download.Tests.ps1'` |
| Full build, as CI does | `.\build-ci.bat` (runs `tools\build.ps1 -Full -CI`)                     |
| Dev build + run        | `.\build-dev.bat` (runs `tools\build.ps1 -Dev`)                         |
| Update external deps   | `tools\build.ps1 -Update` (or the nightly `update-dependencies.yml`)    |
| Release                | `.\release.bat` (or the manual `tag.yml` workflow)                      |

- `-Full` builds the HTML page, the answer files, the PS1 and the launcher, and runs the linter.
  Without `-CI` it also runs the tests and the dependency update (`build.bat`,
  `build-and-run.bat`); `-Full -CI` skips both, because CI runs the tests in their own job and
  the update nightly.
- The dependency update rewrites `resources/dependencies.json` by rules of its own: which
  dependencies open the nightly pull request, a 7-day quarantine before a new version is
  applied, and warnings raised as annotations of the run
  ([`dependency-update`](docs/dependency-update.md)).
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
| [`commit`](.claude/skills/commit/SKILL.md)                                     | asking whether to commit a finished change, and committing it in thematic commits |
| [`repository-review`](.claude/skills/repository-review/SKILL.md)               | reviewing the repository, or one of its areas, end to end                         |
| [`dependency-update-triage`](.claude/skills/dependency-update-triage/SKILL.md) | triaging the nightly dependency update PR or a Dependabot PR, or judging a bump   |
| [`memory-consolidation`](.claude/skills/memory-consolidation/SKILL.md)         | auditing the agent memory directory (Claude Code only; no other platform has one) |
| [`agent-review`](.claude/skills/agent-review/SKILL.md)                         | reviewing the agent setup and past sessions for drift, repeated errors and cost   |

A script a skill needs lives in the skill's directory, under `scripts/`, as one self-contained
file with its tests beside it. The test run and the linter cover `.claude/skills/` as they do
`tools/`.

## Docs

`docs/` holds what only one kind of change needs, so that not every session pays for it. No
platform loads these files on its own: **read the matching one before starting such a change.**
Each is the authority on its area; this file keeps only what every session needs.

| doc                                              | read it before changing                                                                                                         |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| [`build`](docs/build.md)                         | the build: `tools/build.ps1`, `tools/build/`, `tools/common/`, the templates, the linter, the version                           |
| [`ui`](docs/ui.md)                               | a tab, a component, `Form.ps1`, or a handler that starts an operation, touches the window or opens a page or a browser          |
| [`ci`](docs/ci.md)                               | anything under `.github/`, the files the site publishes, or how a release is cut                                                |
| [`dependency-update`](docs/dependency-update.md) | the dependency update (`tools/Invoke-DependencyUpdate.ps1`, `tools/build/updates/`), its workflow, `dependencies.json`'s fields |

## Build Architecture

`tools/build.ps1` runs the build steps in `tools/build/`; `tools/common/` holds what the build
and the tests share. The build bundles every file under `src/` except the tests into
`build/qiiwexc.ps1`, embeds every non-PS1 file in `src/3-configs/` as a string constant
`CONFIG_<UPPERCASED_FILENAME>`, and fills the `{KEY}` placeholders of the source and the
templates from `resources/urls.json` and `resources/dependencies.json`. Every download the app
runs is verified by SHA-256 against a `SHA256_<NAME>` key, except Ninite's installer, built per
request and checked by its publisher's signature instead, and Snappy Driver Installer, which
offers neither ([`build`](docs/build.md)).

## Source Structure (`src/`)

```text
0-init/          # App parameters, version, elevation, initialization, UI constants, theme
1-components/    # WPF controls (New-Button, New-CheckBox, New-Card, ...) and New-Tab, which renders a tab
2-ui/            # The window's XAML (Form.ps1) and one definition per tab (Home.ps1, Installs.ps1, ...)
3-configs/       # Embedded config files (app settings, registry exports, ini files)
4-functions/     # Feature logic organized by tab (App lifecycle, Installs, Configuration, etc.)
5-interface/     # Entry point: Show window.ps1 renders the tabs, in order, and shows the window
```

Each tab is data: `src/2-ui/<Tab>.ps1` defines a `TAB_<NAME>` hashtable of cards that `New-Tab`
renders. An operation a button starts with `Start-AsyncOperation` runs off the UI thread, one at
a time, and reaches the window only through `Invoke-OnDispatcher` ([`ui`](docs/ui.md)).

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
- Pester runs `tools/`, `.claude/skills/`, `src/0-init`, `src/1-components`, `src/2-ui`,
  `src/3-configs` and `src/4-functions`; `src/3-configs/Configs.Tests.ps1` checks every JSON and
  `.reg` config, and that each `$CONFIG_*` the code uses is embedded. Coverage is measured on
  `tools/common`, `tools/build`, `src/1-components` and `src/4-functions`
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

PSScriptAnalyzer runs on the **built** `build/qiiwexc.ps1` and on every script under `tools/`
and `.claude/skills/` (tests included), with the settings in `PSScriptAnalyzerSettings.psd1`.
Any finding fails the build, after all of them are printed; `src/` is covered through the
bundle, so its findings point at lines of `build/qiiwexc.ps1`. Notable rules: single quotes for
constant strings, aligned assignment statements (hashtables included), `-not` instead of `!`, no
semicolons as line terminators, opening braces on the same line, 4-space indentation, correct
casing, and cmdlets and syntax that Windows PowerShell 5.1 supports.

## Workflow Notes

- **After making code changes, run the tests before handing work off** - the single test files
  that cover the change while iterating, then `.\test.bat` - and `.\build-ci.bat` whenever the
  change reaches the bundle, the page, the answer files, `tools/` or a skill's script. The task
  is complete only when both pass. A dependency or CI change is always the full run.
- **Then ask the user whether to commit**, and commit only on a yes, through the
  [`commit`](.claude/skills/commit/SKILL.md) skill: thematic Conventional Commits, a file split
  between commits where its changes belong to more than one.
- After making changes, update any documentation they affect (this `AGENTS.md`, the docs under
  `docs/`, the platform entry files, the skills, and inline comments) so the docs stay in sync
  with the code. Detail that only one kind of change needs goes into its doc under `docs/`, not
  here; a new doc gets its row in the Docs table, with the moment to read it.
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
