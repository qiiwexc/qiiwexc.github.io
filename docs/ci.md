# CI/CD and releases

The workflows in `.github/workflows/` share composite actions from `.github/actions/` (`test`,
`build`, `deploy`, `release`), referenced as `$/.github/actions/<name>`. Permissions follow
least privilege: an empty or read-only default at workflow level, specific grants per job.
Actions are pinned by full commit SHA with the version in a trailing comment
(`uses: owner/action@<sha> # vX.Y.Z`); Dependabot keeps them current.

- `ci.yml` chains `test → build → deploy → release`; `deploy` and `release` run for tags only.
  `test` runs `test-with-coverage.bat` and `build` runs `build-ci.bat`. `deploy` first fails
  unless the tagged commit is on master, then publishes an explicit file list (assembled in
  `.github/actions/deploy/action.yml`) to GitHub Pages — add new site files there — and
  `release` creates a GitHub Release with `qiiwexc.bat`, `qiiwexc.ps1`, `autounattend-*.xml` and
  `SHA256SUMS.txt` as assets (via `gh release create`), unless one already exists for the tag.
- A release is cut by pushing a `vYY.M.D` tag: `release.bat` tags `origin/master` from a local
  checkout (it refuses if `HEAD` differs), and the manual `tag.yml` workflow, which refuses to
  run from any branch but master, tags on GitHub and then dispatches `ci.yml` for the tag, since
  a tag pushed with `GITHUB_TOKEN` triggers no workflows. Both refuse a day's second tag; see
  [A bad release](#a-bad-release).
- `update-dependencies.yml` runs the dependency update nightly and opens its pull request, which
  `ci.yml` skips: [dependency-update.md](dependency-update.md) describes both.
- `zizmor.yml` runs [zizmor](https://docs.zizmor.sh/) security analysis whenever files under
  `.github/` change.

## A bad release

Installed copies update to the release `releases/latest` points at, and only to a higher
version than their own, so a broken release cannot be withdrawn from the copies that already
took it, only superseded. In order:

1. **Stop it spreading.** Mark the release as a pre-release
   (`gh release edit v<bad> --prerelease`, or in the web UI). `releases/latest` then points at
   the previous release, which every download link, the launcher and the updater follow, and
   older copies, which ask the API for the newest release, skip a pre-release too. Check that
   `https://github.com/qiiwexc/qiiwexc.github.io/releases/latest` shows the previous release; if
   not, `gh release edit v<previous> --latest`.
2. **Restore the site.** Pages still serves the bad tag's files: the page, the answer files it
   offers and `qiiwexc.bat` at its root. Run `ci.yml` for the previous tag
   (`gh workflow run ci.yml --ref v<previous>`, or "Run workflow" with the tag selected): its
   `deploy` publishes that tag's site, and `release` is skipped, as the release exists.
3. **Supersede it.** Release a version higher than the bad one: the fix from master, or, to roll
   back, the last good commit, which is on master and so passes `deploy`'s check. On a later day,
   `release.bat` or `tag.yml` does it (for the fix). On the same day the day's tag exists, so tag
   by hand with a fourth part, which the build takes as the version and `[Version]` orders
   between that day's release and the next day's:

   ```powershell
   git fetch origin
   git tag -a v26.11.15.1 -m 'Release v26.11.15.1' origin/master   # or the last good commit
   git push origin refs/tags/v26.11.15.1
   ```

   A tag pushed with your own credentials starts `ci.yml` by itself.

Leave the bad release as a pre-release, or delete it (`gh release delete v<bad>` keeps the tag).
