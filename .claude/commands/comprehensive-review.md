# Comprehensive Codebase Review

Perform a comprehensive, end-to-end review of this repository and produce a single prioritized report. This is a review-only task: do not change any code, but DO run builds, tests, and linters to verify your findings empirically rather than relying on reading alone.

## Project context

`qiiwexc` is a Windows utility toolkit written in PowerShell. The build (`tools/build.ps1`) bundles everything under `src/` into a single `build/qiiwexc.ps1` WPF GUI app, plus a `qiiwexc.bat` launcher, a GitHub Pages landing page, and `autounattend-*.xml` answer files. Read `.github/copilot-instructions.md` first for architecture, build, and testing conventions. Tests use Pester, linting uses PSScriptAnalyzer (on the built artifact), and CI/CD runs through reusable GitHub Actions workflows in `.github/workflows/`.

## Scope

Review every part of the repository, including but not limited to:

- **Application code**: `src/` (init, UI components, layouts, embedded configs, feature functions, entry point)
- **Build and release tooling**: `tools/`, `*.bat` entry scripts, `templates/`, `resources/`
- **Tests**: all `*.Tests.ps1` files, `PesterSettings.ps1`, coverage configuration
- **CI/CD**: `.github/workflows/` (ci, tag, automerge, update-dependencies), `.github/actions/` composite actions, `dependabot.yml`
- **Configuration**: `PSScriptAnalyzerSettings.psd1`, `.editorconfig`, `.vscode/`, `.env.example`, `.gitignore`, `resources/urls.json`, `resources/dependencies.json`
- **Distributed artifacts**: `d/` and `public/` (the GitHub Pages payload users actually download and execute)
- **Documentation**: `templates/home.html` landing page content, LICENSE, any READMEs
- **AI documentation**: `.github/copilot-instructions.md` and any other AI/agent instruction files

## Review areas

For each area below, report concrete findings with evidence — not generic advice.

### 1. Security and vulnerabilities
- This app downloads and executes remote content on end-user machines (e.g., `irm | iex`-style bootstrapping via `qiiwexc.bat`, installer downloads from URLs in `resources/urls.json`). Assess the trust chain end to end: HTTPS enforcement, integrity verification (hashes/signatures or lack thereof), TLS settings, and what happens if a hosted URL or the Pages site is compromised.
- Elevation handling in `src/0-init/2 Start elevated.ps1` and any registry/system modifications in `src/3-configs/` and `src/4-functions/`.
- Injection risks in template substitution (`{KEY}` placeholders), string-embedded configs, and `Invoke-Expression`/dynamic code use anywhere.
- CI/CD security: workflow permissions (least privilege claimed — verify it), secret handling, `GITHUB_TOKEN` usage, third-party action pinning (SHA vs tag), automerge workflow abuse potential, supply-chain exposure in `update-dependencies`.
- Run `Get-ChildItem -Recurse` for stray secrets, and check `.env.example`/`.gitignore` hygiene.

### 2. Code quality and maintainability
- Consistency with the documented conventions (single quotes, aligned assignments, numeric filename prefixes controlling bundle order).
- The `$script:LayoutContext` mutable-global UI pattern: fragility, coupling, and whether the ordering-by-filename build scheme has failure modes (e.g., renamed files silently changing behavior).
- Duplication across `src/4-functions/` feature areas and across `tools/`; dead code; overly long functions; error-prone string manipulation in the bundler (`New-PowerShellScript.ps1`).
- PSScriptAnalyzer is run only on the built output — assess what that misses on source and test files; run it against `src/` and `tools/` yourself and report deltas.

### 3. Tests: coverage and effectiveness
- Run `.\test.bat` (or the Pester equivalent on this platform) and `.\test-with-coverage.bat` if feasible; report pass/fail and coverage numbers.
- Coverage gaps: which of `src/0-init`, `src/2-ui`, `src/5-interface`, and `tools/build.ps1` itself are untested, and which untested paths are riskiest (elevation, downloads, registry writes).
- Test quality: are assertions meaningful or tautological? Do tests verify behavior or implementation details? Is the `BeforeAll` dot-sourcing pattern hiding load-order bugs that only appear in the bundled artifact?
- Mocking of network/filesystem/registry side effects — can the suite run safely and deterministically in CI?

### 4. CI/CD pipeline efficiency and reliability
- Trace the `test → build → deploy → release` chain in `ci.yml` for correctness, race conditions, and failure handling. Verify tag-only gating for deploy/release.
- Caching opportunities, redundant work, runner choice, and total pipeline time.
- The versioning scheme (`YY.M.D` locally vs tag-parsed in CI): drift risks and reproducibility.
- `automerge.yml` and `update-dependencies.yml`: what merges without human review, and is that safe given findings in area 1?

### 5. Configuration management
- `resources/urls.json` / `resources/dependencies.json`: staleness, dead URLs (spot-check a sample), HTTP-vs-HTTPS, and whether the dependency-update tooling validates what it fetches.
- Duplication or contradiction between `.editorconfig`, `PSScriptAnalyzerSettings.psd1`, and `.vscode/` settings.
- Environment-specific assumptions (Windows-only `.bat` entry points vs cross-platform CI needs).

### 6. Documentation clarity and completeness
- There is no top-level README — assess the impact for contributors and end users, and what the GitHub Pages landing page (`templates/home.html`) does and doesn't explain (especially the security implications of running the tool).
- Whether build/test instructions actually work as documented; LICENSE appropriateness; missing CONTRIBUTING/SECURITY policy given the app's nature.

### 7. AI documentation accuracy, usefulness, and token efficiency
- Verify every factual claim in `.github/copilot-instructions.md` against the current code (file paths, commands, conventions, workflow chain). Flag anything stale or wrong — wrong AI docs are worse than none.
- Assess token efficiency: is anything redundant, derivable from the code cheaply, or missing that an agent repeatedly needs (e.g., how to run a single test, platform constraints, things an agent must never do)?
- Note the absence or presence of `CLAUDE.md`/`AGENTS.md` and whether instructions are discoverable by non-Copilot agents.

### 8. Best practices and industry standards
- PowerShell idioms: approved verbs, `Set-StrictMode`, comment-based help, parameter validation, pipeline support where it matters.
- GitHub Actions hardening best practices; semantic versioning vs the date-based scheme; release asset integrity (checksums in release notes?).

### 9. Performance and scalability
- App startup time implications of the single-file bundle; synchronous downloads blocking the UI thread; progress reporting.
- Build-time performance of the concatenation/templating steps as `src/` grows.

### 10. Error handling and logging
- Consistency of `try/catch`/`-ErrorAction` use; whether failures during downloads, elevation, or registry edits surface to the user or fail silently; logger usage in `tools/common/` vs ad-hoc `Write-Host`.
- What a user sees when something goes wrong mid-operation, and whether partial system changes are left behind.

### 11. Dependency management
- How external tool versions in `resources/dependencies.json` are discovered, compared (`Compare-Dependencies.ps1`), and updated; failure modes of scraping-based update checks; Dependabot coverage of Actions.

### 12. Accessibility, internationalization, UX
- WPF UI: keyboard navigation, contrast/theming (`src/0-init/5 Theme.ps1`), DPI scaling, screen-reader friendliness.
- Hardcoded English vs the existence of Russian/English autounattend variants; whether the landing page is accessible (semantic HTML, alt text).
- UX of destructive operations: confirmations, undo-ability, clarity of what each button will change on the system.

### 13. Anything else
Report anything significant you find outside these categories rather than forcing it into one.

## Method

1. Read `.github/copilot-instructions.md`, then survey the tree before reading files in depth.
2. Use subagents to fan out across review areas in parallel where helpful; consolidate into one report.
3. Run tests and linters where the environment allows; if a check can't run (e.g., Windows-only), say so explicitly instead of guessing.
4. Verify before reporting: every finding must cite `file:line` (or a workflow/job name) and, where applicable, the command output that demonstrates it.

## Output format

Produce a single report (`REVIEW.md` is acceptable as a scratch deliverable, but do not commit it unless asked) with:

1. **Executive summary** — overall health in a short paragraph, plus the top 5 issues.
2. **Findings by area** — for each area above: findings with severity (Critical / High / Medium / Low), evidence (`file:line` + explanation), and a concrete recommended fix with rough effort (S/M/L).
3. **Prioritized action plan** — ordered list of the highest-value fixes, grouped into "do now", "do soon", "nice to have".
4. **Positive notes** — practices worth keeping, so good patterns aren't accidentally refactored away.

Be honest about severity: do not inflate cosmetic issues, and do not soften genuine security problems in a tool that runs elevated code from the internet on end-user machines.
