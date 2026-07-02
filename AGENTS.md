# Agent Instructions

All project instructions for AI coding agents — architecture, build, test and linting
conventions, platform constraints, and things that must never be changed — live in
[`.github/copilot-instructions.md`](.github/copilot-instructions.md). Read that file in full
before making changes. The most load-bearing rules from it are repeated below so they aren't
missed by an agent that only reads this entry file.

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
