# Tests

The suite is Pester, at the version pinned in `resources/dependencies.json`, run by
`tools\test.ps1` with the settings in `PesterSettings.ps1` (the commands are in `AGENTS.md`).

## A test file

- Test files live alongside source: `Foo.ps1` + `Foo.Tests.ps1`.
- `BeforeAll` dot-sources the production file, `. $PSCommandPath.Replace('.Tests.ps1', '.ps1')`,
  and anything else it needs relative to the test, `. "$PSScriptRoot\..\Common\types.ps1"`, so
  the suite runs from any directory.
- Some `src/0-init` scripts run as soon as they are loaded (`2 Start elevated.ps1` relaunches
  PowerShell elevated), so their tests pull the functions out through the parser instead of
  dot-sourcing the script.
- Windows-only commands (BITS, CIM, `chkdsk`, `DISM`, `powercfg`, scheduled tasks, Defender,
  System Restore, the DNS client) are stubbed at the top of `BeforeAll` with simple `function` declarations so Pester
  can mock them on any host — follow that pattern when a test needs to mock a new Windows-only
  command.

## Mocks

- `Mock` goes in `BeforeAll`, not `BeforeEach` — re-creating mocks before every test made the
  suite almost twice as slow. `Should -Invoke` still counts per test, and a `Mock` inside an `It`
  overrides it for that test only; keep `BeforeEach` for per-test state.
- A mock should behave like the function it replaces: never make a function throw when its whole
  body is a catch-all `try` that doesn't rethrow — `tools/Mocks.Tests.ps1` fails on it.
- Mock only what reaches outside the test - the registry, processes, the network, files outside
  `TestDrive:`, the window, the logger - or the app's own function that does, such as
  `Import-RegistryConfiguration`. Run pure helpers (`Add-SysPrepConfig`, `Merge-JsonObject`) for
  real: mocked, they leave the test checking how the function is built rather than what it does.
  Assert on what crosses that boundary (the keys an import is given, the file written, a process's
  arguments) and on what the user is told, rather than on how often a helper ran.
- To check in a `ParameterFilter` that a parameter was not passed, use
  `-not $PesterBoundParameters.ContainsKey('Name')`: `$Name -eq $Null` reads any variable of that
  name in an outer scope instead, and a parallel worker defines `$WorkingDirectory`.

## What runs, and how

- Pester runs `tools/`, `.claude/skills/`, `src/0-init`, `src/1-components`, `src/2-ui`,
  `src/3-configs` and `src/4-functions`. `src/3-configs/Configs.Tests.ps1` checks every JSON and
  `.reg` config, and that each `$CONFIG_*` the code uses is embedded. `tools/Bundle.Tests.ps1`
  checks that every command the bundle calls is one of its functions, a cmdlet of Windows
  PowerShell's core modules or on its list of Windows commands - which takes a new one only when
  every supported Windows has it, or the code checks for it first - and that nothing passes
  arguments to a function that takes none.
- Coverage is measured on `tools/common`, `tools/build`, `src/1-components` and
  `src/4-functions`, against the 90% target in `PesterSettings.ps1`.
- Tag tests `WIP` to run them in isolation via `.\test-wip.bat`. Tests tagged `Visual` (the
  rendering comparison in `tools/ui`) run only with `-Visual`, via `.\test-visual.bat`, never in
  CI.
- Test files run in parallel (`Run.Parallel` in `PesterSettings.ps1`), each in a runspace of its
  own on an MTA thread — except with coverage, which is several times slower in parallel, so CI's
  run stays sequential. A file that builds WPF controls (they need STA) or changes process-wide
  state (environment variables, the current directory, the console encoding) starts with a
  `#pester:no-parallel` comment saying why, and runs in the calling session after the parallel
  batch. The root `Pester.BeforeContainer.ps1` gives every file the strict mode and `Stop` error
  preference of `tools\test.ps1`, which a fresh runspace would not have.
