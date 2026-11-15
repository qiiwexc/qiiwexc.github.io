---
name: commit
description: Offer to commit once a change is done and the tests and the build pass, and - when the user says yes - commit it as a series of thematic Conventional Commits, splitting a file whose changes belong to different commits hunk by hunk or line by line. Use at the end of every implementation task, after the gate in AGENTS.md passes, to ask whether to commit, and whenever asked to commit, to split changes into commits, to stage part of a file, or to write commit messages. Not for pushing, opening pull requests, tagging a release or rewriting history that is already pushed.
---

# Committing a change

A finished change ends with a question, not a commit: **ask the user whether to commit**,
once the gate in the Workflow Notes of `AGENTS.md` has passed (`.\test.bat`, and
`.\build-ci.bat` where the change calls for it). Commit only on a yes, and only what they
agreed to. Approval for one commit is not approval for the next session's.

When the answer is yes, the change goes in as several small commits, each about one thing,
rather than one commit of everything the session touched. A reader of `git log` should be
able to revert the debloat preset fix without reverting the window layout change that
happened to be written the same afternoon.

## Step 1 - see everything that would be committed

```powershell
git status --short
git diff --stat
git diff --cached --stat     # something may already be staged - a `git mv` stages a rename
```

Sort what is there into two piles before anything else:

- **This session's work** - what you changed, and only that.
- **Everything else** - the user's own uncommitted work, which was in the tree when the
  session started (the session's opening git status shows it), and edits another tool or
  person made since. **Never commit it unasked.** Name it in the question and let the user
  say whether it goes in, and in which commit.

Untracked files need a decision each: new source files, tests and docs go in; scratch
output never does. `build/`, `wip/` and the `vm/` images are git-ignored and stay out.

**`d/` and `public/` are what GitHub Pages serves**: users download and run those files.
A commit that touches either is a release of that file once it is pushed, so say so in the
question.

## Step 2 - plan the commits, then ask

Group the changes by theme - one feature, one fix, one refactor, one docs change that
stands on its own - not by file and not by directory. Then put the plan to the user in the
same question that asks whether to commit (`AskUserQuestion` where the platform has it):

```text
1. fix(app): write the debloat preset where Win11Debloat reads it
   - Start-WindowsDebloat.ps1 and its tests, dependency-update-triage/SKILL.md (one hunk)
2. feat(configs): list the new Win11Debloat settings in both presets
   - Debloat preset base.json, Debloat preset personalization.json
3. docs(agents): say that the linter covers the skills' scripts
   - AGENTS.md (two hunks)
Not included: tools/build.ps1, PesterSettings.ps1 (uncommitted before this session)
```

Offer the obvious alternatives as options - the plan as shown, one commit of everything,
or not now - and let the user edit the grouping. A file listed under two commits is said
to be split, with which part goes where.

## Step 3 - the message

[Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <summary>

<body: what changed and why, wrapped at 72 columns>

<the attribution lines the harness gives, if any>
```

- **type** - `feat` (something new a person can use), `fix` (a bug), `refactor` (no change
  in behaviour), `perf`, `test` (tests alone), `docs` (documentation alone, agent
  instructions and skills included), `build` (the build and test tooling), `ci` (workflows
  and actions), `chore` (anything else: a dependency record, a config tidy). A change with
  tests and docs beside its code takes the code's type.
- **scope** - the part of the repository the commit is for:

  | scope      | what it covers                                                                  |
  | ---------- | ------------------------------------------------------------------------------- |
  | `app`      | the app under `src/`: components, tabs, feature logic                           |
  | `configs`  | the embedded configs in `src/3-configs`, which are applied to users' machines   |
  | `unattend` | the answer files: `templates/autounattend.xml`, `tools/build/unattended`        |
  | `page`     | the landing page and the Pages payload: `templates/home.html`, `public/`, `d/`  |
  | `tools`    | `tools/`, the `.bat` entry points, the Pester and linter settings               |
  | `deps`     | `resources/dependencies.json`, and the pinned URLs and checksums in `urls.json` |
  | `vm`       | the development VM scripts                                                      |
  | `skills`   | `.claude/skills/`                                                               |
  | `agents`   | `AGENTS.md`, `CLAUDE.md`, the Copilot entry file                                |

  A commit spanning two names the one it is for, or leaves the scope out. Leave it out too
  where it would repeat the type: `ci: ...`, not `ci(ci): ...`.
- **summary** - imperative, lower case after the colon, no full stop, at most ~72
  characters: `feat(app): offer the personalization settings for O&O ShutUp10`.
- **body** - British English, as all prose here. Say why, and anything a reader of the diff
  would not see: a decision, a constraint, what was left out on purpose.
- A breaking change - a parameter the app no longer takes, a stored setting or file an
  installed copy can no longer read - gets `!` after the scope and a `BREAKING CHANGE:`
  footer saying what to do. Where the code keeps reading the old shape, that is a
  `MIGRATION:` shim, which `AGENTS.md` covers, and not a breaking change.
- End with the attribution lines the harness's instructions give for commits, exactly as
  given. Do not invent any.
- The pull requests the nightly update and Dependabot open title themselves
  `chore(deps): ...`. A squash merge keeps the title: leave it as it is.

**Pass the message through a file**, one per commit: write it with the file-writing tool
into the session's scratch directory, or into `wip/`, as UTF-8 without a byte order mark.

```powershell
git commit -F '<scratch>\message-1.txt'
```

Not as `-m` pieces, where a backtick or a `$` in the message is the shell's to expand. Not
on standard input either: in Windows PowerShell a here-string after `git commit -F -`
reaches git as arguments, which it takes for paths, and nothing is committed. And not
through `Set-Content -Encoding utf8` or `>`, which put a byte order mark in front of the
summary, where git keeps it.

## Step 4 - stage one commit at a time

Stage exactly one planned commit, check it, commit it, then the next. Start each from an
empty index: `git diff --cached --stat` should list only what that commit is for.

**Never `git add` and `git commit` in one command.** Staging, the look at
`git diff --cached --stat` and the commit are three calls: chained, the commit takes
whatever the index already held - a rename `git mv` staged, the last commit's leftovers -
before anyone has seen it. `git commit -a` is the same mistake in one word: it stages every
tracked change on the way.

**Whole files** - `git add -- <path>...`. A deleted file is `git rm --cached -- <path>` (or
`git add` on the deletion); a move done without `git mv` is a deletion plus an addition,
which git pairs as a rename by itself once both are staged.

**Part of a file, hunk by hunk.** `git add -p` is interactive, and interactive commands do
not work here. `scripts/Add-GitHunk.ps1` does the same from the command line, run from the
repository's root. The examples below call it `<hunk>`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude\skills\commit\scripts\Add-GitHunk.ps1 <command>
```

```powershell
<hunk> list <path>           # the file's hunks, numbered
<hunk> stage <path> 1 3 4    # stage those
```

`list` prints each hunk of `git diff` for the file under its number; `stage` builds a patch
of the chosen ones and applies it to the index with `git apply --cached`, leaving the
working tree untouched. The hunks that are left are renumbered, so `list` again before the
next `stage`. A hunk that fails to apply means the index already holds part of it - check
`git diff --cached -- <path>`. Where there is no Windows PowerShell, `pwsh -NoProfile -File`
runs the script too.

**Part of a hunk, line by line.** When one hunk mixes two themes - two edits a line apart -
stage the file's exact intermediate content instead: a copy of the file that has only this
commit's lines, which the script stores and points the index at.

```powershell
Copy-Item -LiteralPath <path> '<scratch>\staged'    # the working file...
#  ...take out of the copy what belongs to later commits (the editing tool)
<hunk> content <path> '<scratch>\staged'
```

The copy is what `<path>` holds once this commit is made: everything already committed or
staged, plus this commit's lines, without the later ones. It works for a new file as well.
The working tree keeps every change; only the index holds the intermediate version.

**Check before committing:** `git diff --cached` must read as one coherent change, and
`git diff` must hold everything still to come. A commit should leave the tree passing on
its own: where splitting would leave one that cannot - a function and its only caller, a
tab definition and the handler it names - keep them in one commit.

## Step 5 - after the last commit

```powershell
git status --short        # only what was left out on purpose
git log --oneline -<n>    # the commits, in order
```

Report the commits made and anything left uncommitted, and why. **Do not push** unless the
user asks: a push is outward-facing, and a pushed `vYY.M.D` tag is a release. Where the
session runs on the default branch, follow the user's local workflow - this repository's
own changes are committed on `master` - and in a cloud session the branch rule in
`CLAUDE.md`.

## Common mistakes

- **Committing the user's own work** because it was in `git status`. Sort first.
- **One commit per file**, or one per directory. Commits are themes.
- **A file in two commits staged whole into the first.** Split it, by hunk or by line.
- **`git add` chained with `git commit`**, which commits what was staged before it unseen.
  Three calls, as Step 4 says. A commit that swept a file in is undone with
  `git reset --soft HEAD~1`, which keeps both the index and the working tree.
- **Running `git checkout -- <path>` or `git restore <path>` to undo a staging slip.** That
  rewrites the working tree, and `AGENTS.md` forbids it. `git restore --staged <path>` (or
  `git reset -- <path>`) unstages and leaves the file alone.
- **`git add -N`** to make a new file visible: it breaks `git stash` and the user's
  autostashing pull. Stage new files for real, in their commit.
- **A message file left in the repository.** One written outside the scratch directory and
  `wip/` shows up as an untracked file in the next commit's status.
- **Committing without asking**, or pushing because the commit went well.
