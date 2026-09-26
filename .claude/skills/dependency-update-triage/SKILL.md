---
name: dependency-update-triage
description: Work out what a dependency update pull request actually changes and whether it can be merged - read the PR, its release notes and its CI through the GitHub API, find the breaking changes, deprecations and upstream changes hiding in every version it crosses, check that each new download is still the upstream project's own file, name what this repository now has to change or could adopt, run the full gate, and write a merge/hold verdict. Use for the nightly "Update dependencies" pull request, any Dependabot GitHub Actions PR, and whenever asked whether an update is safe, what a bump changes, why a dependency PR is failing, or whether a new release of a tool the app runs brings anything worth adopting. Not for adding or removing a dependency by hand.
---

# Triaging a dependency update PR

These PRs open themselves, and the failure mode is not merging a bad one - it is merging
all of them unread, so the release that quietly renamed a parameter the app passes goes in
with the four that changed nothing, and the feature that would have deleted a workaround
here is never noticed. Triage produces two lists: what could break, and what is worth
having.

This repository adds a third concern. Several of its dependencies are programs the app
downloads and **runs elevated on other people's machines**, so a version bump is also a
supply-chain event: the question is not only "does it still work" but "is this still the
file the upstream project published".

**The answer is always one of three: merge, hold, or needs a change first.** A triage
that ends without one of those has not finished.

## Where these PRs come from

**The nightly PR.** `.github/workflows/update-dependencies.yml` runs
`tools\Invoke-DependencyUpdate.ps1`, which checks every entry in
`resources/dependencies.json`. It opens or updates a pull request whenever any version
moved, including those that change nothing built (`Version record only`). There is one
standing PR from `chore/update-dependencies`, titled
`Update dependencies (yyyy.MM.dd)`. Each night's run starts from master and force-pushes
over it. The PR changes `resources/dependencies.json` and nothing else. The `test` and
`build` jobs report back as commit statuses.

**Dependabot.** `.github/dependabot.yml` watches GitHub Actions only. It has one entry
per directory: the root, for the workflows, and each composite action under
`.github/actions/`. It groups patch and minor bumps per directory as
`github-actions-patch-updates`, leaves majors on their own, and waits out a 7-day cooldown.
The same action used in two directories arrives as two PRs (#54 and #55 moved
`actions/cache` in `build` and in `test` on the same day).

Because the nightly PR is force-pushed, **write down `head.sha` when you start and check
it again before the verdict**. A triage of last night's head is a triage of a different
PR.

## Step 0 - reading GitHub

The repository is public, so no token is needed to read it. Use the best access the
session has: the GitHub MCP tools if they are connected, `gh` if it is installed,
otherwise the REST API anonymously. The anonymous API allows 60 requests an hour per
address, and a triage takes about ten, so check the budget before starting:

```powershell
$H = @{ 'User-Agent' = 'qiiwexc' }
$Api = 'https://api.github.com/repos/qiiwexc/qiiwexc.github.io'
(Invoke-RestMethod 'https://api.github.com/rate_limit' -Headers $H).rate.remaining
```

Workflow job logs need authentication even on a public repository; check-run
annotations do not, and they carry the failing lines (Step 6).

The diff is always available through git, whatever else is not:

```powershell
git fetch origin refs/pull/<n>/head:refs/pr/<n>
git diff master...refs/pr/<n> --stat
git update-ref -d refs/pr/<n>     # when done
```

## Step 1 - read the PR

```powershell
$Pr = Invoke-RestMethod "$Api/pulls/<n>" -Headers $H
$Pr | Select-Object state, merged, mergeable_state, changed_files, @{ n = 'head'; e = { $_.head.sha } }
$Pr.body | Set-Content "wip\pr<n>.md" -Encoding UTF8
```

That one call is most of the triage: the body already quotes the release notes.

- **A nightly body** is Markdown written by `New-DependencyUpdateDescription`. It has the
  table, with one row per version that moved and a `Changes` column of `Download URL`,
  `CI tool` or `Version record only`. Then comes `## Links`, grouped as other sites,
  GitHub commit comparisons and GitHub releases and tags. Last is `## Release notes`: one
  `<details>` block per dependency, newest release first, with mentions and issue
  references defused. It runs to tens of thousands of characters (29,443 for #65), so save
  it and read the table and the links first, then the notes one dependency at a time.
  GitHub caps a body at 65,536 characters. Notes that did not fit are listed at the end
  under *The notes for these versions did not fit in the description* - fetch those.
- **A Dependabot body** quotes each action's release notes and commit list in HTML
  `<details>` blocks, and cuts long ones with `... (truncated)`.

What moved is the patch, and on these PRs it is small - there is no lockfile to wade
through:

```powershell
Invoke-RestMethod "$Api/pulls/<n>/files" -Headers $H | ForEach-Object { $_.filename; $_.patch }
```

## Step 2 - build the table of what moved

One row per dependency: **name, from → to, and what it is to this repository.** The last
column decides how hard to look, and it is not the same question as how big the jump is:

| what it is                                                        | where it reaches                                                 | how hard to look                                             |
| ----------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------ |
| a **pinned download** (below)                                     | run elevated on users' machines, from the next release on        | hardest: every check in Step 5's first bullet                |
| a **CI tool**: Pester, PSScriptAnalyzer                           | the gate itself                                                  | the gate will tell you; read for new rules and mock changes  |
| a **live tool**: O&O ShutUp10, SDI                                | users already have the new version, whatever this PR does        | the PR is a notice, not a gate: check what the app passes it |
| a **generator**: Unattend Generator                               | `templates/autounattend.xml`, once it is regenerated             | whether to regenerate                                        |
| a **record**: SystemRescue, TronScript, Windows, Office Installer | a link, or a file updated by hand                                | a glance                                                     |
| a **GitHub Action**                                               | CI, and for the deploy and release actions only the next release | Step 5's SHA rule                                            |

A **pinned download** is fetched from a versioned URL and checked against a recorded
checksum. `resources/urls.json` is the authority on which dependencies these are: the key
is `URL_` plus the dependency's name upper-cased, with spaces and hyphens turned into
underscores (`Microsoft Activation Scripts` → `URL_MICROSOFT_ACTIVATION_SCRIPTS`), and a
key that contains `{VERSION}` makes that dependency a pinned download, with a `sha256`
next to its version in `dependencies.json`. A **live tool** is fetched at click time from
a URL without a version, so it is whatever the upstream serves that day.

## Step 3 - read every version the PR crosses, not just the target

A bump from 2026.07.11 to 2026.08.24 may be three releases, and the renamed parameter is
as likely to be in the middle one. Sources, in the order to try them:

1. **The PR body from Step 1.** For a GitHub release dependency the nightly quotes every
   release crossed, usually the whole job.
2. **The upstream's releases**, when the body cut them or never had them:

   ```powershell
   Invoke-RestMethod 'https://api.github.com/repos/<owner>/<repo>/releases?per_page=20' -Headers $H |
       Select-Object tag_name, published_at, prerelease
   (Invoke-RestMethod 'https://api.github.com/repos/<owner>/<repo>/releases/tags/<tag>' -Headers $H).body
   ```

   The nightly only looks at a repository's **five most recent releases**
   (`Select-Releases`). A jump across more than five links the latest release alone, so
   its notes are the only ones in the body - fetch the rest yourself.
3. **The links section** for everything else: a commit comparison for `commits`
   dependencies (Unattend Generator), a tag comparison for `tags` ones, and the changelog
   page for `URL` dependencies (O&O ShutUp10, SDI, CPU-Z), which has no notes in the body.

Read for five things and nothing else. The first four are **removals, changed defaults,
new deprecations, and renamed parameters or settings the app passes**. The fifth applies
to anything the app runs elevated: **new downloads or network calls, and a change in where
the project publishes its files.**

## Step 4 - sort every row into one of three buckets

**Blocking** - it will fail the gate or the build, or the download is no longer
trustworthy (Step 5). Say which, and why.

**Needs a change first** - it works, but something here is now wrong: a deprecated
parameter still passed, a setting ID the preset still uses, an embedded config exported by
an older version. Name the file. On the nightly PR that change goes to master as its own
commit, never onto `chore/update-dependencies`, which the next run force-pushes away.

**Worth adopting** - the release brought something this repository has an actual use
for. Two rules keep this honest:

- **It must name the file it would change.** "Win11Debloat added new settings" is not a
  finding. "Win11Debloat's new \<setting\> would replace the \<tweak\> that
  `Personalization.reg` applies by hand" is.
- **Read the code before writing it down.** Release notes are marketing copy for a
  change, not its contract. For a script dependency, read the script at the new tag.
  For a switch, find where it is parsed. A recommendation resting on one changelog
  sentence goes in the report as "worth a look, unverified", or not at all.

An adoption never rides along in the dependency PR. It is a separate change after the
bump is merged, so the bump stays revertible.

## Step 5 - the tripwires this repository has

Generic advice misses all of these. Check each one that applies.

- **A pinned download must still be the upstream project's own file.** For every
  `Download URL` row:
  - The `sha256` moved together with the version. The nightly keeps the old version when
    it cannot compute a checksum, so a new version with an unchanged checksum is an updater
    bug.
  - The URL, with the version filled in, points at the project's own release (its GitHub
    release asset, its repository at the tag, or its own site), never a mirror.
  - The checksum is right. Compute it yourself and compare it with the PR:

    ```powershell
    $File = "$env:TEMP\triage-download"
    Invoke-WebRequest '<URL with the version filled in>' -OutFile $File -UseBasicParsing
    (Get-FileHash $File -Algorithm SHA256).Hash.ToLower()
    ```

  - An executable was signed by the same publisher as before. Run
    `Get-AuthenticodeSignature` on the new file and on the previous version's, and treat a
    new or missing signer where there was one as a hold until explained.
  - A script (WinUtil's `winutil.ps1`, MAS's `MAS_AIO.cmd`, Win11Debloat's source archive)
    is read in the notes for new downloads, and checked against what the app hands it.
    `Start-Activator.ps1` passes MAS `-el`, `/HWID` and `/Ohook`, and fetches it from
    `MAS/All-In-One-Version-KL/MAS_AIO.cmd` at the release tag. `Start-WinUtil.ps1` relies
    on WinUtil not relaunching itself when already elevated. `Start-WindowsDebloat.ps1`
    runs `Win11Debloat.ps1` from the archive's single top folder with `-SkipExplorerRestart`,
    `-Sysprep`, `-RunSavedSettings`, `-RemoveApps`, `-Apps` and `-Silent`, and writes its
    `Config\LastUsedSettings.json` from `src/3-configs/Windows/Tools/Debloat preset *.json`
    and `Debloat app list base.json`: a renamed parameter, or a setting or app ID the tool
    no longer knows (it skips those silently), is a change needed first.

  A pinned file that moves inside its upstream repository fails the checksum download.
  The nightly then keeps the old version with a warning in the workflow log, so **a
  pinned dependency that has stopped updating is itself a finding** - compare its version
  with the upstream's latest release.

- **A live tool has already changed under the app.** O&O ShutUp10 is fetched from a URL
  without a version at click time, so a new release is in effect for users the day it is
  published, and a fix it needs goes to master at once, whatever happens to the PR.
  `OOShutUp10.cfg` names the version that exported it in its header (`V3.5.1130`), and a
  new release may need it exported again.
- **The CI tools are loaded at their exact pinned versions.** `tools\test.ps1` and the
  linter load the versions in `dependencies.json`, so on the PR head run
  `install-dependencies.bat` before the gate, or it fails to load them. A PSScriptAnalyzer
  release that adds or tightens a rule fails the build on code nobody touched. The linter
  prints every finding before failing. The answer is to fix the code, or to add a
  documented exclusion in `PSScriptAnalyzerSettings.psd1` where the rule is wrong for this
  codebase. Never quietly pin the tool back.
- **A PSScriptAnalyzer release can end the one-rule-per-call linting.** `Invoke-Linter` runs
  each rule on its own because concurrent command lookups race on Windows PowerShell 5.1
  (upstream: PowerShell/PSScriptAnalyzer#2206, open as of 2026-09-26). When a release's notes
  say the lookups are serialised, name it as something to adopt: one call per path again,
  verified by linting in ten fresh processes without a single rule error.
- **Actions are pinned by full SHA**, as `uses: owner/action@<sha> # vX.Y.Z`. Check that
  the trailing comment moved with the SHA, and that the SHA is the tag's commit:

  ```powershell
  $Ref = Invoke-RestMethod 'https://api.github.com/repos/<owner>/<action>/git/ref/tags/<tag>' -Headers $H
  if ($Ref.object.type -eq 'tag') { $Ref = Invoke-RestMethod $Ref.object.url -Headers $H }
  $Ref.object.sha
  ```

  Merge the PRs that move the same action in different directories together, so the pins
  do not drift apart. A change under `.github/` also runs zizmor; its check is part of the
  CI state.
- **Merging is not releasing.** Pinned URLs and checksums are built into `qiiwexc.ps1`,
  so a merged pin reaches users only at the next `vYY.M.D` tag, and the deploy and release
  actions first run then too. Say in the verdict whether the bump is worth a release of its
  own. Live tools work the other way round: they reach users with no release at all.

## Step 6 - read CI, then run the gate

**Read what CI has already said** before reproducing anything:

```powershell
(Invoke-RestMethod "$Api/commits/<head.sha>/status" -Headers $H).statuses | Select-Object context, state, description
(Invoke-RestMethod "$Api/commits/<head.sha>/check-runs" -Headers $H).check_runs | Select-Object id, name, conclusion
Invoke-RestMethod "$Api/check-runs/<id>/annotations" -Headers $H | Select-Object path, start_line, message
```

The statuses are the nightly workflow's `test` and `build`. The check runs are `ci.yml`
on the pull request (`deploy` and `release` are skipped there, as they run for tags only),
CodeQL, and zizmor when `.github/` changed. A combined state of `pending` with an empty
`statuses` list means nothing reported, not that something is still running.

**To run the gate yourself**, the PR has to be in the working tree:

```powershell
git status --short                       # first: whose changes are about to come along
git fetch origin refs/pull/<n>/head:refs/pr/<n>
git switch --detach refs/pr/<n>
.\install-dependencies.bat               # when Pester or PSScriptAnalyzer moved
.\test.bat
.\build-ci.bat
git switch master; git update-ref -d refs/pr/<n>
```

A dependency change is **always the full run** (`AGENTS.md`), never a single test file.
Read that first `git status`. The nightly PR touches only `dependencies.json`, so the
switch carries any other uncommitted work along, and the gate then runs over the bump
plus that work. Uncommitted changes to `dependencies.json` itself make the switch refuse.

The gate does not exercise an action bump; CI on the PR does. `build.ps1 -CI` does not
download the pinned files either - Step 5's checksum check is what does.

## Step 7 - the verdict

Report in this shape, short enough to read on one screen:

1. **One line per bump**: name, from → to, and the one-clause reason it is fine or is not.
2. **The verdict**: merge / hold until \<date or condition\> / needs \<change\> first - and
   for a pinned download, whether it is worth a release.
3. **Needs a change** and **worth adopting**, if anything: what, where, and how big.
   Each is a follow-up, never folded into this PR.

Say plainly which release notes you could not find or read. "Nothing in the notes" and
"could not read the notes" are different answers, and only one of them supports a merge.

Merging and commenting on the PR are the user's to do. Offer them; never do either on
your own initiative, even after a clean verdict, and even when an earlier PR in the same
session was approved.

## A worked example - PR #65

`Invoke-RestMethod "$Api/pulls/65"` returned a 29,443-character body opening with this
table, and `changed_files: 1` - `resources/dependencies.json`, four lines each way:

| dependency         | from → to               | changes             | what it is                                    |
| ------------------ | ----------------------- | ------------------- | --------------------------------------------- |
| Unattend Generator | `781fde5` → `538f930`   | Version record only | the generator of `templates/autounattend.xml` |
| Win11Debloat       | 2026.07.11 → 2026.08.24 | Version record only | a live tool at the time (pinned since)        |
| OOShutUp10         | 3.4 → 3.5               | Version record only | a live tool with an embedded config           |
| Pester             | 6.1.0 → 6.2.0           | CI tool             | a CI tool                                     |

Pester is the only row that changes what CI checks; the gate is its whole test, and `ci.yml`'s `test` and `build`
check runs were green. The other three rows say "Version record only", yet two of them
needed work:

- **Win11Debloat 2026.08.24** deprecated `NoRestartExplorer` in favour of
  `SkipExplorerRestart`, in a note at the top of its release. `Start-WindowsDebloat.ps1`
  passed `-NoRestartExplorer`. Win11Debloat was fetched live then, so users already had
  the new version, and the fix could not wait for the merge: it went to master as part of
  `01379ab`. Pinned, the same release would arrive as a `Download URL` row, and the rename
  would be a change needed before merging.
- **O&O ShutUp10 3.5** has no notes in the body (its changelog is on another site, in the
  links). The embedded `OOShutUp10.cfg` had been exported by V3.4.1124, and was exported
  again with V3.5.1130 in `e0b4cea`.

The Unattend Generator row changes nothing built until the template is regenerated from
the URL in its first comment, so it is a decision rather than a risk. The PR itself was
merged as it was: its only change is the version record, and the work it announced went
to master in commits of its own. No row was a pinned download, so the bump needed no
release.

## Quick reference

| step                       | call                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------ |
| request budget             | `(Invoke-RestMethod https://api.github.com/rate_limit -Headers $H).rate.remaining`               |
| the PR and its notes       | `Invoke-RestMethod "$Api/pulls/<n>"` - save `.body` to `wip\`                                    |
| what moved                 | `Invoke-RestMethod "$Api/pulls/<n>/files"` - the `patch` of each file                            |
| an upstream's releases     | `…/repos/<owner>/<repo>/releases?per_page=20`, then `…/releases/tags/<tag>`                      |
| is a pinned file genuine   | download it, `Get-FileHash -Algorithm SHA256`, `Get-AuthenticodeSignature`                       |
| is an action's SHA its tag | `…/repos/<owner>/<action>/git/ref/tags/<tag>`                                                    |
| CI state                   | `"$Api/commits/<sha>/status"` and `"$Api/commits/<sha>/check-runs"`                              |
| why CI failed              | `"$Api/check-runs/<id>/annotations"`                                                             |
| the gate                   | on the fetched PR ref: `install-dependencies.bat` if a CI tool moved, `test.bat`, `build-ci.bat` |
| merge or comment           | the user's - offer, never do                                                                     |

## Common mistakes

- **Taking "Version record only" as "nothing to do".** It means nothing built changes. A
  live tool's release is already in users' hands, and two of #65's three such rows needed
  a commit.
- **Reading only the target version's notes.** The PR crosses every release in between,
  and past five releases the body only has the latest.
- **Trusting the checksum because the updater computed it.** The updater proves the
  file did not change between its download and the user's. It does not prove the file is
  the upstream's. That is what the URL and signature checks are for.
- **Recommending an adoption from a changelog sentence.** Read the script or the switch
  first, or say in the report that you did not.
- **Fixing things on `chore/update-dependencies`.** The next nightly run force-pushes over
  it. Fixes go to master.
- **Judging a force-pushed PR by a stale head.** Check `head.sha` again before the
  verdict.
- **Merging one directory's action bump without its siblings.** The pins drift apart.
- **Calling a merged pin shipped.** It ships at the next release; say whether one is
  warranted.
- **Pinning a CI tool back to silence a new linter rule.** Fix the code, or document the
  exclusion.
- **Merging or commenting without asking.** Both are outward-facing, and neither is
  implied by "triage this PR".
