---
name: repository-review
description: Run a thorough end-to-end review of this repository and write a ranked findings report - app source, build tooling, tests, CI/CD, configuration, documentation, agent instructions, external dependencies and the published GitHub Pages payload, judged on security, architecture, reliability, performance, maintainability, style, testing, accessibility, best practices and docs. Use whenever the user asks for a repository or codebase review, audit, health check, "what's wrong with this project", "look over everything", "what would you improve", a second opinion on the state of the code, or a review of one of those areas on its own. Start it by asking whether they have areas they want looked at especially closely. Not for reviewing a diff, a branch or a pull request - that is /code-review.
---

# Reviewing the whole repository

This is a read-and-report task. **Change nothing.** The value is in an accurate,
locatable, honestly-hedged list of findings the user can act on at their own
pace; a review that quietly fixes things as it goes leaves them unable to tell
what was wrong from what was opinion.

Work as a single agent, sequentially: breadth first across every area below,
then depth wherever it looked worst. Reviewing is not a fan-out job - a finding
is only worth reporting if the agent reporting it has actually traced it, and
findings that arrive as a subagent's summary cannot be re-interrogated when they
turn out to hinge on a detail.

## Step 1 - ask what to look at closely

Before reading anything, ask the user whether there is anything they want extra
attention on. The review covers everything either way; this only decides where
the deeper half of the effort goes, and the user usually has something in mind
that no amount of reading would reveal - a part they distrust, a cost they want
down, a change they are contemplating.

Use `AskUserQuestion`, multi-select, with concrete options drawn from the areas
below, and make "nothing in particular - cover everything evenly" the first
option so it is a cheap answer rather than a demand. Skip this step entirely if
they already named their interests when invoking the skill.

Whatever they name gets its own section in the report with more depth than the
rest - not a different standard of evidence, just more of the budget.

## Step 2 - read the standard before judging against it

Read `AGENTS.md` in full first - `.github/copilot-instructions.md` only points
to it. It is what the code is measured against, and it is itself under review: a
rule nothing follows is either a finding about the code or a finding about the
rule.

## Ground rules

- **Findings of every size are wanted**, from "this can brick a user's Windows
  install" down to "this comment says `Unistall`". Do not filter by importance -
  rank instead.
- **Every finding names a file and, where it makes sense, a line**, and quotes
  the smallest excerpt that makes the problem visible. A finding nobody can
  locate is not a finding. Point at `src/` and `tools/`, never at
  `build/qiiwexc.ps1` - the bundle is generated, and a finding there must be
  traced back to the source file it came from.
- **Say how sure you are.** Separate "I read the code and this is wrong" from
  "this smells and is worth a look". If verifying would need something you do
  not have - a real Windows install to run the app on, a VM, a GitHub token, a
  live download URL - say so, and say what you would need. A confident wrong
  finding costs more than a hedged right one.
- **Verify before you claim.** Run the tests, run the linter, grep for the
  second caller, open the config file. Never report a fault you have not
  reproduced or traced. Safe to run:
  - `.\test.bat` or `.\test-with-coverage.bat` - the Pester suite, with the
    coverage target enforced by the latter.
  - `Invoke-Pester -Path '<file>.Tests.ps1'` for a single file.
  - `.\build-ci.bat` - the full build without the dependency update; writes
    only to the git-ignored `build/` and `vm/` outputs, and runs
    PSScriptAnalyzer on the bundle.
- **Never run** anything that changes the machine, the repository or the
  outside world: the built app itself (`build-dev.bat`, `build-and-run.bat`,
  `tools\build.ps1 -Run`, `build\qiiwexc.bat`) - it elevates and reconfigures
  Windows; `tools\build.ps1 -Update` or `-Full` without `-CI`, which rewrite
  `resources/dependencies.json` and open browser tabs; `release.bat`, which
  tags and pushes; `install-dependencies.bat`, which installs modules; and the
  `vm\` scripts.
- **Platform.** Everything targets Windows PowerShell 5.1. If you are on
  another host, or running under PowerShell 7, say so in the report, and treat
  WPF- and CIM-dependent test failures as environmental, per `AGENTS.md`.
- **Out of scope:** `build/` (generated), `.env`, the VM images and generated
  files under `vm/`, and `wip/`, which is the local scratch directory for
  downloaded dependency files and drafts. Do not read through `wip/` to build
  context; open only files the user names.
- **No secrets in the report.** If a token or credential is committed - `.env`
  is supposed to hold the only one, `GITHUB_TOKEN` - report _that a file at path
  X carries one_, never its value.
- Prefer breadth first, then depth. Cover every area at least shallowly before
  spending the rest of the budget on the worst of it.

## Areas to cover

Every one of these, and anything else you notice - the list is a floor, not a
ceiling.

- **App source** - everything under `src/`: `0-init` (parameters, elevation,
  theme), the WPF components and the tab renderer in `1-components`, the
  window's XAML and the tab definitions in `2-ui`, the embedded configs in
  `3-configs` (registry exports, browser preferences, ini files - these are
  applied to users' machines), the feature logic in `4-functions`, and the
  entry point in `5-interface`, which renders the tabs. Read the bundle order
  as part of the code: a function used before the file that defines it is
  bundled is a bug.
- **Build tooling** - `tools/build.ps1`, `tools/build/` (bundling, template
  substitution, autounattend generation, dependency updates) and
  `tools/common/`.
- **Tests** - the `*.Tests.ps1` suites next to each source file, the stubs for
  Windows-only commands, `PesterSettings.ps1`, `tools/test.ps1`, what is and is
  not covered (the Pester run skips `src/2-ui` and `src/5-interface` entirely,
  and measures no coverage for `src/0-init` and `src/3-configs` - is that
  right?).
- **CI/CD** - `.github/workflows/`, `.github/actions/`, `.github/dependabot.yml`,
  the tag, deploy and release paths, and the nightly dependency update.
- **Configuration** - `PSScriptAnalyzerSettings.psd1`, `PesterSettings.ps1`,
  `.editorconfig`, `.gitignore`, `.env.example`, `.vscode/tasks.json`, and the
  `*.bat` entry points at the root.
- **Templates and resources** - `templates/home.html`,
  `templates/autounattend.xml`, `resources/urls.json`,
  `resources/dependencies.json`, `resources/App associations.xml`.
- **Published payload** - `d/` and `public/`, which GitHub Pages serves and end
  users download and execute, plus what the deploy action copies next to them.
  `public/Office_Installer.zip` is a binary: say what it would take to verify
  it rather than guessing at its contents.
- **Documentation** - `AGENTS.md`, `.github/copilot-instructions.md`, and the
  comments in the source. There is no `README.md`; whether there should be is
  itself a question for the report.
- **Agent instructions** - the same two files read as instructions rather than
  as prose, plus `.claude/` (skills, settings, hooks).
- **External dependencies** - the third-party tools the app downloads and runs
  (`resources/dependencies.json`, `resources/urls.json`), the Pester and
  PSScriptAnalyzer versions, and the pinned GitHub Actions: what is pinned,
  stale, unmaintained or risky, and whether the update tooling does what it
  claims.
- **Distribution** - how the app reaches a user (the landing page, the `.bat`
  launcher wrapping the `.ps1`, the self-updater in
  `src/4-functions/App lifecycle/Updater.ps1`, the GitHub Release assets, the
  `fetch-autounattend-*.bat` helpers), and what happens when a release is bad.

## Topics to look for

Also a floor, not a ceiling:

- **Security** - this is an elevated script users download and run, which then
  downloads and runs more executables. Look hard at download integrity (hashes,
  signatures, HTTPS), what runs elevated, command and path injection, Defender
  and antivirus interaction, registry and policy changes, the self-update path,
  the GitHub token in the build tooling, workflow permissions and supply chain
  (zizmor already covers `.github/`; check what it does not). Tooling from
  third parties that is intentionally dual-use (activators, debloaters) is part
  of the product - report on how it is fetched and run, not on whether it
  should exist.
- **Architecture** - module boundaries, the tab definitions and their renderer
  (`New-Tab`, the `$CHECKBOXES` lookup), the concatenation-by-filename bundle, whether the split between
  `src/` and `tools/` (and the near-duplicates between them, such as the two
  `Logger`/`Progressbar` implementations) still earns its keep.
- **Reliability** - failure modes on a real user's machine: no network, slow
  network, antivirus quarantining a download, non-English Windows, non-admin
  accounts, older Windows 10 builds, partial failure midway through a
  configuration run, anything that silently does nothing, UI freezes from work
  on the dispatcher thread.
- **Reversibility** - which of the configuration and debloat actions can a user
  undo, and does the app tell them before it does something they cannot.
- **Performance** - startup time of the bundled script, work on the UI thread,
  the build, the test suite.
- **Maintainability** - duplication, separation of concerns, file and function
  size, dead code, abstractions that earn their keep and abstractions that do
  not.
- **Style and consistency** - naming, structure, whether the codebase reads as
  one author. PSScriptAnalyzer owns what it enforces; report only what it does
  not, and whether its rule set is the right one.
- **Testing** - coverage in the sense of "is the risky part tested", not the
  percentage; test quality, brittleness, over-mocking that leaves nothing real
  under test, missing edge cases, tests that assert the implementation rather
  than the behaviour.
- **Tooling** - the development and build toolchain: what is missing, what is
  redundant, what could be replaced by something better.
- **Best practices** - for Windows PowerShell 5.1 (including PS7-only syntax
  that slipped in), Pester (the version pinned in
  `resources/dependencies.json`), PSScriptAnalyzer, WPF from PowerShell, BITS,
  Windows unattended setup, batch scripting, GitHub Actions and GitHub Pages.
- **Accessibility** - the WPF window and the landing page are real UI: keyboard
  paths, focus order, `AutomationProperties` names for screen readers,
  contrast in both themes, DPI scaling and text scaling.
- **Localisation** - the app configures English and Russian Windows installs
  (the autounattend variants, Office and app configs): check that anything
  keyed on a language, locale, user or group name still works on the other
  one.
- **Documentation quality** - accuracy first (a wrong doc is worse than none),
  then completeness, then length. Check specifically that the documentation
  describes the repository as it is now rather than as it was - commands that
  no longer exist, directories that moved, workflows that were renamed - and
  that `.github/copilot-instructions.md` still only points to `AGENTS.md`
  rather than repeating it.
- **Agent efficiency** - the instruction files are loaded in full every session,
  so staleness, verbosity and redundancy between them cost real tokens on every
  request. Which parts are load-bearing - things an agent would get wrong
  without them - and which would be inferred anyway? Does anything ask for
  output nobody reads? The same question applies to source comments, and to the
  harness setup outside the repository.

## Output

Write the report to `wip/repository-review-<YYYY-MM-DD>.md`, alongside the
other local scratch output. Nothing else is created or changed, apart from what
the verification commands above write to `build/`.

Structure it as:

1. **Summary** - what shape the repository is in, in a few paragraphs. Say
   plainly what is healthy as well as what is not; a review that lists only
   faults misrepresents the codebase and makes the faults harder to weigh.
2. **Findings**, grouped by area, each ranked **critical / high / medium / low /
   nit**, each carrying: what it is, where (`path:line`), why it matters, what to
   do about it, and how confident you are.
3. **The areas the user asked to look at closely**, one section each, if they
   named any.
4. **General recommendations** - things that did not fit a finding. Architecture
   and setup ideas, tools worth adopting or dropping, better ways to work with
   agents here. Say what each would cost as well as what it would buy.
5. **What was not covered** - anything skipped, budget-limited or unverifiable,
   so the gaps are known rather than assumed absent.

Then in chat: the count of findings by rank, the three you would fix first, and
anything you want a decision on before it could be acted on.
