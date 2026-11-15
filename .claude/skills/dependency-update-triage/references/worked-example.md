# A worked example - PR #65

The steps of [the triage](../SKILL.md), walked through one nightly pull request. Two of its
dependencies have changed kind since: Win11Debloat and O&O ShutUp10 were fetched live then, and
are pinned downloads now, so the same releases would arrive as `Download URL` rows today.

`Invoke-RestMethod "$Api/pulls/65"` returned a 29,443-character body opening with this
table, and `changed_files: 1` - `resources/dependencies.json`, four lines each way:

| dependency         | from → to               | changes             | what it is                                    |
| ------------------ | ----------------------- | ------------------- | --------------------------------------------- |
| Unattend Generator | `781fde5` → `538f930`   | Version record only | the generator of `templates/autounattend.xml` |
| Win11Debloat       | 2026.07.11 → 2026.08.24 | Version record only | a live tool                                   |
| OOShutUp10         | 3.4 → 3.5               | Version record only | a live tool, with an embedded config          |
| Pester             | 6.1.0 → 6.2.0           | CI tool             | a CI tool                                     |

Pester is the only row that changes what CI checks; the gate is its whole test, and the
`test` and `build` checks were green. The other three rows say "Version record only", yet
two of them needed work:

- **Win11Debloat 2026.08.24** deprecated `NoRestartExplorer` in favour of
  `SkipExplorerRestart`, in a note at the top of its release. `Start-WindowsDebloat.ps1`
  passed `-NoRestartExplorer`. As a live tool, users already had the new version, and the
  fix could not wait for the merge: it went to master as part of `01379ab`. As a pinned
  download, the rename would be a change needed before merging.
- **O&O ShutUp10 3.5** has no notes in the body (its changelog is on another site, in the
  links). The embedded ShutUp10 config had been exported by V3.4.1124, and was exported
  again with V3.5.1130 in `e0b4cea`.

The Unattend Generator row changes nothing built until the template is regenerated from
the URL in its first comment, so it is a decision rather than a risk. The PR itself was
merged as it was: its only change is the version record, and the work it announced went
to master in commits of its own. No row was a pinned download, so the bump needed no
release.
