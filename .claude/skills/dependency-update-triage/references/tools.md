# What the app hands each tool

The tool-specific checks of [the triage](../SKILL.md)'s Step 5. Read the section of each
dependency that moved; one that did not move needs none of this.

## The scripts the app runs

A script (WinUtil's `winutil.ps1`, MAS's `MAS_AIO.cmd`, Win11Debloat's release archive) is read
in the notes for new downloads, and checked against what the app hands it:

- `Start-Activator.ps1` passes MAS `-el`, `/HWID` and `/Ohook`, and fetches it from
  `MAS/All-In-One-Version-KL/MAS_AIO.cmd` at the release tag.
- `Start-WinUtil.ps1` relies on WinUtil not relaunching itself when already elevated.
- `Start-WindowsDebloat.ps1` downloads the release's `Win11Debloat.zip` (its `SHA256SUMS` and
  GitHub's asset `digest` both give the checksum to compare with), runs `Win11Debloat.ps1` from
  the archive's single top folder with `-SkipExplorerRestart`, `-Sysprep`, `-RunSavedSettings`,
  `-RemoveApps`, `-Apps` and `-Silent`, and writes `LastUsedSettings.json` into
  `%LOCALAPPDATA%\Win11Debloat`, where the tool reads it, from
  `src/3-configs/Windows/Tools/Debloat preset *.json`; with the personalization preset it also
  passes the app IDs in `Debloat app list.json`, which the answer files' app removal list is
  built from too.

A renamed parameter, a moved settings file, or a setting or app ID the tool no longer knows (it
skips those silently) is a change needed first: compare the presets' names with
`Config/Features.json` and the app list with `Config/Apps.json` at the new tag.

## O&O ShutUp10's embedded configs

`OOShutUp10 base.cfg` and `OOShutUp10 personalization.cfg` (the one the "+ Personalization
settings" checkbox picks) name the version that exported them in their headers (`V3.7.1143`).
ShutUp10 is a pinned download, so exporting both configs again with the new version is a change
needed first, and they reach users together with it at the next release. Its version is the full
build number the homepage prints, because the versioned file's URL needs it, and the file is
O&O's own winget package, the same bytes as the unversioned `OOSU10.exe` of that build.

## Snappy Driver Installer

A live tool: `sdi.zip` holds `SDI_auto.bat`, which the app runs and which starts
`SDI_x64_R<release>.exe`, or `SDI_R<release>.exe` on 32-bit Windows - the process names
`Test-SdiIsRunning` matches. Every switch in `sdi.cfg` must still be listed in the archive's
`command-line.htm`, and `-theme:` must name a file under `Tools/SDI/themes/`.

## PSScriptAnalyzer and the one-rule-per-call linting

`Invoke-Linter` runs each rule on its own because concurrent command lookups race on Windows
PowerShell 5.1 (upstream: PowerShell/PSScriptAnalyzer#2206, open as of 2026-09-26). When a
release's notes say the lookups are serialised, name it as something to adopt: one call per path
again, verified by linting in ten fresh processes without a single rule error.
