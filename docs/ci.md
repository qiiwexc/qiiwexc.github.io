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
  a tag pushed with `GITHUB_TOKEN` triggers no workflows.
- `update-dependencies.yml` runs the dependency update nightly and opens its pull request, which
  `ci.yml` skips: [dependency-update.md](dependency-update.md) describes both.
- `zizmor.yml` runs [zizmor](https://docs.zizmor.sh/) security analysis whenever files under
  `.github/` change.
