---
name: memory-consolidation
description: Audit the whole file-based memory directory for this project - read every memory, check each one against the repository as it is today, prune what is no longer true, fix drift, reconcile memories that contradict each other, promote durable rules into AGENTS.md or a skill, and resync MEMORY.md. Use whenever the user asks to review, audit, clean up, consolidate, prune or reorganise memories, asks whether the memories are still accurate or still relevant, asks whether something should live in the agent instructions instead of memory, or asks what has gone stale - and also when a large refactor has just moved or deleted things memories point at, since that is exactly when they rot. This is the whole-directory pass; writing one new memory during ordinary work needs no skill.
---

# Consolidating the project memory

Memories are written one at a time, in the middle of other work, and then never
read again as a set. That is what makes them rot: a memory records what was true
on the day it was written, the code moves on, and nothing tells the memory. A
memory that is quietly wrong is worse than no memory, because it is loaded into
context with the same authority as a correct one and an agent will act on it.

This pass is the maintenance the writing step never does. It is a **read,
verify, and reconcile** job, not a rewriting-for-style job: leave prose alone
unless it is wrong, out of date, or in the wrong place.

## Where the memories are

The memory directory is named in the system prompt for the session
(`%USERPROFILE%\.claude\projects\<slug>\memory\`). If it is not, list
`%USERPROFILE%\.claude\projects\` and match the slug to the repository path. It
holds one `.md` file per memory plus `MEMORY.md`, the index that is loaded into
every session.

Read the repository's own instruction files first - `AGENTS.md`, `CLAUDE.md` and
the `SKILL.md` of every skill under `.claude/skills/` - because the promotion
decision below is entirely about the boundary between those files and memory,
and you cannot judge it without knowing what they already say.

## Step 1 - read every memory, all of it

Read them all, in batches of about ten so no single output is enormous:

```powershell
foreach ($f in 'a-file', 'b-file', 'c-file') { "##### $f"; Get-Content "<memory-dir>\$f.md" -Raw -Encoding UTF8 }
```

Do not sample and do not judge from `MEMORY.md`'s one-line hooks - the hooks are
themselves a thing that drifts, and half the findings in this pass come from a
memory whose body says something its hook does not.

## Step 2 - check each memory against the repository

A memory is a claim about a codebase, so almost every one of them is checkable.
Anything a memory names is a probe:

| The memory names                               | Check                                                  |
| ---------------------------------------------- | ------------------------------------------------------ |
| a file or directory                            | `Test-Path` it                                         |
| a function, `$CONFIG_*` constant or config key | search for it                                          |
| a `.bat` script or a `tools\build.ps1` switch  | read the script, or the `param()` block of `build.ps1` |
| a behaviour of the code                        | read the code, or run the test that covers it          |
| a review finding and its status                | the report in `wip/`, and the code the finding cites   |
| a decision "the user confirmed"                | leave it - only the user can retire that               |

Two failure shapes are worth naming, because they are the common ones:

- **The subject was deleted.** A memory explaining a pitfall of a function that
  no longer exists is not a stale detail, it is a memory with nothing left to be
  about. Prune it.
- **A path moved.** Refactors relocate the files memories cite, and the numeric
  prefixes in `src/` get renumbered. The memory is still true; the address is
  not. Fix the address.

## Step 3 - read the memories against each other

Individually-correct memories can still be collectively wrong.

- **Contradictions.** When two memories disagree, the later one has usually
  earned it - it was often written _because_ the earlier theory was disproved.
  Trim the earlier one to what survived and point it at the later one, rather
  than leaving two accounts for a future reader to pick between.
- **Duplicates and near-duplicates.** Merge into whichever is the better
  written, keeping any detail the other one had alone.
- **Sagas.** Several memories from one long debugging session are fine if each
  answers a different question, and a problem if they are chapters. Chapters
  should be one memory.
- **`[[links]]`.** A link to a memory that does not exist yet is deliberate - it
  marks something worth writing. A link to a memory _this pass just pruned_ is
  a dead end: remove it, and take the sentence around it with it if that is all
  the sentence was for.

## Step 4 - decide what belongs in the repository instead

This is the judgement call the pass exists for, and it is not "is this
important". Both are loaded; they are loaded differently, and that is what
decides.

**`AGENTS.md` is loaded in full, every session, for every agent on every
platform.** So it earns things that are:

- a rule an agent must obey while writing code here, where breaking it produces
  a bug that review would not obviously catch;
- true independently of how it was discovered;
- statable in a sentence or two.

**Memory loads one index line per memory, and the body only when it turns out to
be relevant.** So it keeps things that are:

- diagnostic - how a failure presents, how it was traced, what was ruled out;
- situational - operational limits, live-run history, progress through a
  multi-session piece of work, decisions and their reasoning;
- about the environment or the harness rather than about the code.

That last one is worth stating plainly, because the instinct runs the other way:
**do not promote harness and sandbox quirks into `CLAUDE.md` or `AGENTS.md`.**
Something like "the Bash tool cannot fork on this machine, use PowerShell" is
genuinely useful, and moving it into an always-loaded file makes every session
pay for it in full when memory was already charging a single line. Promoting it
costs tokens rather than saving them.

Where a promotion goes:

- `AGENTS.md` - anything about the code, the build, the tests or CI, plus
  workflow and safety rules;
- a skill's `SKILL.md` - anything true only while doing that one procedure;
- a code comment, when the constraint only makes sense next to the code it
  constrains (a regex that must keep matching a legacy form, a bundle order
  that is load-bearing).

**Promoting does not mean deleting the memory.** Move the _rule_, and leave
behind the root cause, the reproduction, and how it was found - the things a
one-line rule cannot carry - with a closing pointer so a reader knows the rule
has an official home:

> **Where the rule lives now:** the constraint itself is written into
> `AGENTS.md` (the "…" bullet). What is kept here is the root cause and how it
> was found.

## Step 5 - apply the changes

Prune when the evidence is concrete - the file, command or behaviour the memory
is about is provably gone. Say so in the report; do not ask first, since the
check is the argument.

Ask the user when it is a judgement call: a memory that is superseded but still
carries residual value, a merge that would lose a distinction someone chose
deliberately, or anything recording a decision the user made. Deleting a memory
throws away context nothing else holds, so the bar for "obviously" is high.

Then bring `MEMORY.md` back in step: one line per memory, `- [Title](file.md) —
hook`, nothing else in the file. Re-read the hooks against the bodies you now
know - a hook that describes a memory's _old_ content is the same failure as a
stale memory, one level up. Add lines for anything new, drop lines for anything
pruned, and confirm the counts match:

```powershell
(Get-ChildItem '<memory-dir>' -Filter *.md | Where-Object Name -ne 'MEMORY.md').Count
(Get-Content '<memory-dir>\MEMORY.md' -Encoding UTF8 | Where-Object { $_ -match '^- \[' }).Count
```

If a write fails with a read-only filesystem error, that is the sandbox rather
than a permissions problem with the directory - rerun that command with the
sandbox disabled.

## Step 6 - report

Short and concrete. For each memory you touched, one line: what you did and what
made it necessary. Group as **pruned / updated / merged / promoted**, and end
with anything you left alone but are unsure about, so the user can overrule you.
Say how many memories you read - a consolidation pass that only mentions the
five it changed reads as if it only looked at five.

## Staying in scope

The pass improves the memories' accuracy and their placement. It is not a
rewrite: do not restyle prose that is merely unfashionable, do not compress
memories that are long because the subject is, and do not add new memories about
the work you are doing right now. If the audit turns up something wrong in the
repository itself - a doc contradicting the code, a comment describing a deleted
function - fix it when it is a line or two and mention it, and raise it rather
than fixing it when it is bigger than that.
