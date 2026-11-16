# The dependency update

`tools\build.ps1 -Update` checks every entry in `resources/dependencies.json` for a newer
version and rewrites the file. A local full build (`build.bat`, `build-and-run.bat`) runs it
too; the nightly `update-dependencies.yml` runs it with `-CI` and turns what moved into a pull
request. This file says how the update decides. How to judge the pull request it opens is the
[`dependency-update-triage`](../.claude/skills/dependency-update-triage/SKILL.md) skill.

## What a run writes

Without `-CI` the update opens each changelog URL in the browser; with `-CI` it writes them to
`$env:CHANGELOG_URLS`, from which `tools\Invoke-DependencyUpdate.ps1` writes the nightly pull
request's description to `build/dependency-update.md`: a table of the versions that moved, the
changelog links grouped as other sites, GitHub commit comparisons and GitHub releases and tags,
and the release notes of every release or tag crossed. The notes are third-party text, so
`Format-ReleaseNotes` defuses mentions and issue references before quoting them, and the
workflow hands the file to `gh` as `--body-file`.

A dependency whose `URL_<NAME>` in `resources/urls.json` contains `{VERSION}` keeps a `sha256`
field, recomputed whenever the version changes; the version bump is dropped if the checksum
cannot be computed.

## Which dependencies open the pull request

Every entry in `dependencies.json` sets `opensPullRequest`, and the nightly opens its pull
request only when a dependency set to `true` moved; other bumps ride along in it. It is `true`
where a new version can need a change here: a `{VERSION}` download with its `sha256`, a CI tool,
the Windows links in `urls.json`, and O&O ShutUp10, whose exported configs the app embeds. It is
`false` for the `File` dependencies, which only a local run with their files in `wip/` updates,
for what the app only links to or fetches unversioned (SystemRescue, TronScript, SDI), and for
the Unattend Generator, which `templates/autounattend.xml` is regenerated from by hand.
`Compare-Dependencies` fails on a dependency that moved without a boolean there, and a test
checks every entry.

## Report-only dependencies

A dependency with `reportOnly` set to `true` is checked like any other, and its links are kept,
but `Update-Dependencies` puts its recorded version back: that version records what a file here
was made from, so it changes with the file, by hand. The Unattend Generator is one. Its version
is the commit `templates/autounattend.xml` was generated from, the `<Hash>` in the template's
`Extensions`, and a test fails when the two differ, so the commit that regenerates the template
updates the record too. A newer upstream commit therefore never opens a pull request, nor adds a
row to one; a pull request opened for another dependency lists it under *Not applied*, with a
comparison from the commit in use to the upstream's latest. A local run opens that comparison
in the browser every time, until the template is regenerated.

## The quarantine

A dependency set to `true` also waits out a 7-day quarantine: a new version is applied only 7
days after the update first saw it (`Get-QuarantineEnd`), and until then the recorded version
stays. `build/dependency-quarantine.json` keeps, per dependency, the versions seen since the
recorded one, each with the time it was first seen; `Resolve-QuarantinedVersion` applies the
newest one out of quarantine and cuts the changelog links to it.

A latest version seen before, the recorded one included, means the versions recorded after it
were withdrawn: they are dropped, with a warning, so none can come out of quarantine once a newer
one shows up. That is why a check that cannot tell (a page that does not load or no longer
matches, an empty list of releases, tags or commits) throws instead of leaving the version as it
is: the failure is logged and the waits stand.

A local run keeps its own copy of the state file, and the nightly restores the previous run's
from a workflow artifact. Losing the file only restarts the waits. The pull request's table gains
a Pending column when a dependency it updates has a newer version still waiting, and a dependency
with only waiting versions is listed under it, each version with the date its quarantine ends.

## Warnings

In the nightly, every warning of the update (a dependency that could not be checked, a version
kept back because its checksum could not be computed, a version taken as withdrawn) becomes an
annotation of the run (`Write-WorkflowAnnotation`), and so does the reason no quarantine state
could be restored: annotations can be read without a token, the job log cannot. A normal night
raises none, so the expected skips, such as the `File` dependencies' missing files, log as
information.

## The workflow

`update-dependencies.yml` checks for updates in a read-only job, which first restores the
quarantine state from this workflow's previous run on master (the only runs it trusts for it)
and afterwards keeps the new one as the `dependency-quarantine` artifact for 30 days. It hands
the changed `dependencies.json`, with the pull request description it wrote, to a separate job
that force-pushes the `chore/update-dependencies` branch and opens or updates its pull request
whenever a dependency whose `opensPullRequest` is `true` moved, then runs the `test` and `build`
actions on the commit it pushed (by SHA, not the branch, which a later push could move) and
reports both on that commit as commit statuses, which stand in for `ci.yml`'s checks of those
names.

`ci.yml` skips any pull request that changes only `dependencies.json`, because GitHub holds the
runs that `github-actions[bot]` triggers until someone approves them, and on `pull_request` a
branch filter matches the base branch, not the head. Only the nightly workflow checks that pull
request, so after a fix on master, run it again rather than updating the branch from the pull
request's page, which leaves a head nothing has checked.
