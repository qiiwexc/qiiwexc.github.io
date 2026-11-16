# The build

`tools/build.ps1` orchestrates the build. `tools/build/` contains individual build step
functions. `tools/common/` contains shared utilities (logger, progress bar, file I/O) used by
both build and test. The logger and the progress bar there are the app's own
(`src/4-functions/App lifecycle`), dot-sourced with no-op stand-ins for the window they would
otherwise write to, so the two cannot drift apart.

## Source-to-script bundling

`tools/build/New-PowerShellScript.ps1` concatenates all files under `src/` except
`*.Tests.ps1` into a single `build/qiiwexc.ps1`, in the order `tools/build/Get-SourceFiles.ps1`
spells out: a directory's own files first, then its subdirectories, each level in name order
(ordinal, ignoring case, as NTFS lists them). The order matters only where code runs as it
loads, so the numeric prefixes that control it are on the top-level directories (`0-init/` …
`5-interface/`) and on the files in `0-init/` (`0 Parameters.ps1`, …); everything else defines
functions, constants or tab definitions. Leading numeric prefixes on each path segment are
stripped from `#region` names in the output. The build fails if any `{KEY}` placeholder is left
unresolved or if the bundled script does not parse.

Every non-PS1 file in `src/3-configs/` (`.reg`, `.json`, `.ini`, `.cfg`, `.conf`) is embedded
as string constants named `CONFIG_<UPPERCASED_FILENAME>` using `Set-Variable -Option Constant`.

## The answer files

The answer files are built from `templates/autounattend.xml`, which also carries sections for
the development VM only (disk 0 partitioning, a local auto-logon account).
`tools/build/New-UnattendedFile.ps1` strips them from the published files, and
`tools/build/unattended/Assert-UnattendedFile.ps1` fails the build if any remain, a `{KEY}`
placeholder is unresolved, or the XML is not well-formed. The template is the output of the
[unattend generator](https://schneegans.de/windows/unattend-generator/); the URL in its first
comment reproduces it. After regenerating it, run the tests: `New-UnattendedBase` fails if
something it rewrites (such as the `RemovePackage.ps1` package list) is gone, and
`New-UnattendedFile.Tests.ps1` builds the real template end to end.

## Template substitution

`resources/urls.json` and `resources/dependencies.json` feed into `tools/build/Get-Config.ps1`
to produce a `$Config` PSCustomObject. Templates (`templates/home.html`,
`templates/autounattend.xml`) use `{KEY}` placeholders replaced at build time.
`src/0-init/1 Version.ps1` uses `{PROJECT_VERSION}` which is injected this way.

Downloads are verified by SHA-256 (`Start-DownloadUnzipAndRun -Sha256`). Fixed-version
downloads keep a `SHA256_<NAME>` key in `urls.json`; a dependency whose `URL_<NAME>` contains
`{VERSION}` keeps a `sha256` field in `dependencies.json`, exposed as `SHA256_<NAME>` and
recomputed by the [dependency update](dependency-update.md) whenever the version changes. The
self-updater verifies `qiiwexc.bat` against the release's `SHA256SUMS.txt`. Two downloads are
exceptions:

- **Ninite** builds its installer for each selection of apps, so there is no checksum to pin.
  `-Signer` checks its Authenticode signature instead: valid, and from a certificate whose
  common name is `SIGNER_NINITE` in `urls.json`. It checks the name rather than the thumbprint,
  so a renewed certificate still passes.
- **Snappy Driver Installer** runs unverified. `URL_SDI` is the only archive its publisher
  offers. Its name has no version, it is replaced with each release, and the executables in it
  are unsigned, so there is neither a checksum to pin nor a signature to check. Its version is
  read from its changelog, `https://sdi.com.ru/Changelog.txt`, only to keep a record of it.

## Versioning

Locally: `YY.M.D` (from current date). In CI on a tag: parsed from `$Env:GITHUB_REF_NAME`
(e.g., `v26.2.18` → `26.2.18`). For reproducible output, pin it explicitly:
`tools\build.ps1 -Version 26.2.18`.

## The linter

`tools/build/Invoke-Linter.ps1` runs PSScriptAnalyzer one rule per call, and the comment at its
top says why: keep it that way until a PSScriptAnalyzer release serialises its command lookups.
It also fails on a rule name in `PSScriptAnalyzerSettings.psd1` that the analyzer does not have,
which the analyzer itself would silently ignore.
