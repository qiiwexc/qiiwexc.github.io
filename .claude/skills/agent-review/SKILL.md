---
name: agent-review
description: Review this repository's agent setup and the agents' recent sessions, then ask the user which findings to act on - optionally run the memory-consolidation pass first, check AGENTS.md, CLAUDE.md, the Copilot entry file and every skill against the code as it is, mine past session transcripts for repeated errors, corrections and rediscovered facts worth writing down, and measure what the setup costs in tokens and context window. Use when asked to review, audit or tune the agent instructions, skills or setup, to find what agents keep getting wrong, to learn from past sessions, to cut token usage or context bloat, or whether the agent files are still accurate. Not for auditing the memory directory alone (memory-consolidation) or the code (repository-review).
---

# Reviewing the agent setup and the sessions

The agent files are written one rule at a time, in the middle of other work, and read by
every session whole. Two things go wrong with them, slowly: they drift from the code, so a
session acts on a rule that stopped being true; and they grow, so every session pays for
paragraphs it never needed. Meanwhile the sessions themselves keep tripping over the same
things - a shell that cannot start, a scratch folder that is gone, a fact looked up for the
third time - that nobody wrote down.

This skill finds all three, then **stops and asks** which to fix. It changes nothing before
the user has chosen.

The numbers come from one script, which the examples below call `<stats>`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude\skills\agent-review\scripts\Get-AgentStats.ps1 <command>
```

Its commands are `context`, `paths`, `sessions` and `errors`; the comment at its top says
what each prints. Where there is no Windows PowerShell, `pwsh -NoProfile -File` runs it too.

Steps 2 and 3 read Claude Code's own session transcripts, so they work only where Claude
Code has run on this checkout. Step 1 works on any platform.

## Step 0 - ask about the memory pass

Ask, in one question with the rest of the scope (`AskUserQuestion`):

- whether to run the [`memory-consolidation`](../memory-consolidation/SKILL.md) skill first -
  it is the whole-directory memory audit, and the memory index is part of what every session
  loads;
- how many recent sessions to read. 15 is the default, and there may be fewer: Claude Code
  deletes a transcript once it is older than its retention period (`cleanupPeriodDays`, 30
  days unless the user's settings say otherwise);
- whether any area matters most (a skill, a kind of task, a recurring annoyance).

Run the memory pass first if asked: its promotions into `AGENTS.md` change what Step 1
checks.

## Step 1 - the setup, against the code

What every session loads, and what is read on demand:

```powershell
<stats> context
<stats> paths
```

`context` lists the files; read every one - `CLAUDE.md` and the `AGENTS.md` it imports,
`.github/copilot-instructions.md`, every `SKILL.md` - and check each claim that can be
checked:

- **Paths.** `paths` reports every path the agent files name that does not exist: the target
  of a Markdown link, and a code span that starts with `.\` or with one of the repository's
  top-level entries. It skips what git ignores (a build output is not expected to exist),
  fenced code, a span with a placeholder or a wildcard, and a bare file name, so search for
  those by hand where a rule depends on one.
- **Commands, switches and names.** `paths` cannot tell that a `.bat` script still does what
  the text says, that `tools\build.ps1` still takes a switch (read its `param()` block), or
  that a function, a test file, a workflow or a `$CONFIG_*` constant a rule names still
  exists. Search for each.
- **Rules still match the code.** A rule saying "`Tabs.Tests.ps1` fails on X" is worth a
  look at the test; "the linter runs on Y" is worth a look at `tools\build.ps1`; "the only
  place that does Z" is worth a search for a second one.
- **Contradictions** between `AGENTS.md`, `CLAUDE.md`, the Copilot entry file and a skill.
  The more specific file is not automatically right.
- **Duplication.** A rule stated in `AGENTS.md`, in a skill and in a code comment is three
  copies to keep in step. It belongs in one, with pointers. The entry files only point to
  `AGENTS.md`; a rule repeated in one of them is a finding.
- **History.** `AGENTS.md` forbids lines about a past state ("used to", "renamed from").
  Find them. A `MIGRATION:` comment is the one exception, and each should have a memory
  recording it.
- **Skills.** Each description says when to use the skill and when not, without overlapping
  another's; each body is the authority on its procedure and agrees with the code. The
  Skills table in `AGENTS.md` lists every directory under `.claude/skills/`, and nothing
  else: other platforms find the skills only through it.

## Step 2 - the sessions

```powershell
<stats> sessions 15
<stats> errors 15
```

`sessions` gives each session's start, title, prompts, tool calls, errors, tokens, the
largest context one call was sent, its largest tool results and the short user messages
that may be corrections. `errors` groups every failed tool call by what it said, with the
number of sessions it was met in.

- **Which sessions**: the ones that started last. The session running the script is left
  out by itself; `-Exclude '<id>,<id>'` (the eight characters `sessions` prints, quoted)
  leaves out others - an earlier session of the same review, say.
- **What counts as failed**: a result the harness flagged, and a shell result it did not
  flag that still shows a failure - a PowerShell error record, a command PowerShell does not
  know, a parse error, the Bash tool failing to fork, git refusing. A command in the middle
  of a chain fails without the result being flagged, so a count of the flagged ones alone is
  too low. The signatures are in `Get-FailureSignature` in the script: add one, with a test,
  for a failure a transcript shows and the list misses. A failing test is not a failed call
  and is not counted.
- **"correction?" is a hint.** The messages are picked by a few words ("no", "instead",
  "revert"). Read each before calling it a correction.

Then open the transcripts behind the patterns, never by reading a whole `.jsonl` into
context: one session runs to megabytes. They are in the directory `sessions` names in its
first line, one file per session, one JSON object per line. An entry's `type` is `user` or `assistant` (the other
types are the harness's bookkeeping), and its `message.content` is a string or a list of
blocks: `text`, `tool_use` with a `name` and an `input`, `tool_result` with a `tool_use_id`,
`is_error` and `content`. Select what is needed and cut it short:

```powershell
$Entries = [IO.File]::ReadAllLines('<transcript>') | ForEach-Object { try { ConvertFrom-Json $_ } catch { $Null } }

# What the user typed
$Entries | Where-Object { $_.type -eq 'user' -and $_.PSObject.Properties['origin'] -and $_.origin.kind -eq 'human' } |
    ForEach-Object { "$(@($_.message.content | ForEach-Object { if ($_ -is [String]) { $_ } else { $_.text } }))" } |
    ForEach-Object { $_.Substring(0, [Math]::Min(300, $_.Length)) }

# The commands one tool was given
$Entries | Where-Object { $_.type -eq 'assistant' } | ForEach-Object { $_.message.content } |
    Where-Object { $_.type -eq 'tool_use' -and $_.name -eq 'PowerShell' } |
    ForEach-Object { $_.input.command.Substring(0, [Math]::Min(120, $_.input.command.Length)) }
```

Look for:

- **Repeated failures** - the same error across sessions: a shell that cannot start, a
  write into a scratch folder that is gone, a command run with a switch it does not have, a
  here-string that does not parse. Each is a rule or a memory missing, or one written where
  it is not read.
- **Corrections** - the user saying no, stop, instead, why did you. What the agent did, and
  what instruction would have prevented it.
- **Rediscovery** - the same file read, the same data shape probed, the same question
  answered in several sessions. A fact found three times belongs in a doc, a skill or a
  memory.
- **Questions asked that the instructions answer**, and decisions taken unasked that the
  user then reversed.
- **Skills not used** where they applied, or used where they did not: a description to
  sharpen.

## Step 3 - tokens and the context window

From the same numbers:

- **The fixed cost.** Everything `context` lists as loaded at the start of every session is
  paid on every turn of every session (cached, but it still fills the window). Rank it.
  Candidates to cut: detail that only one kind of task needs (move it to a skill or a file
  that `AGENTS.md` points at, read on demand), repetition, long examples, history, prose
  that restates what the code says, and `MEMORY.md` index lines that are paragraphs rather
  than one-line hooks.
- **What lies outside the repository.** `context` also lists the user's own
  `~/.claude/CLAUDE.md` and the skills under `~/.claude/skills`, which every session on the
  machine is shown as well. Report what they cost. They are the user's to change, not the
  repository's, and the harness's own prompt and built-in tools are beyond the script
  altogether.
- **The per-session cost.** The largest tool results: a whole file read where a range would
  do, a test run or a build not piped through `Select-Object -Last 30`, a JSON dump not
  narrowed. A pattern across sessions is a rule to add or a script to write.
- **The context window.** A session whose peak context nears the model's window is one that
  gets summarised and loses detail; one that keeps rereading the same large files is a
  candidate for a skill holding what it needs.

Estimate each proposed cut in tokens, so the user can weigh it.

## Step 4 - the findings, then the question

Write the findings down before asking - a short ranked list in the session, and the whole
of it in `wip/agent-review-<YYYY-MM-DD>.md` when it is long. Each finding:

- what is wrong or what it costs, with the evidence (file and line, or the sessions it came
  up in, and how often);
- the change proposed, and where (which file, a new skill, a script, a memory);
- its size, and the tokens it saves where it is a cut.

Then ask (`AskUserQuestion`, `multiSelect`) which to make - grouped so one question covers
related findings, the recommended ones first. Make only the ones chosen, each where it
belongs. Step 4 of `memory-consolidation` draws the line and applies here unchanged:

| what was found                                              | where it goes                             |
| ----------------------------------------------------------- | ----------------------------------------- |
| a rule about the code, the build, the tests, CI or workflow | `AGENTS.md`                               |
| something true only while doing one procedure               | that skill's `SKILL.md`                   |
| a constraint that only makes sense next to the code         | a comment in that code                    |
| a quirk of this machine, the harness or the sandbox         | a memory, never an always-loaded file     |
| a check that keeps being made by hand                       | a script, or a command of this skill's    |

What the user wants kept for later stays in the report in `wip/`.

After the changes, the gate in the Workflow Notes of `AGENTS.md`: `.\test.bat`, and
`.\build-ci.bat` when a change reached `tools/` or a skill's script. Nothing tests the
Markdown of the agent files, so after a change to them run `<stats> paths` again. Then the
[`commit`](../commit/SKILL.md) question.

## What not to do

- **Change nothing before the user has chosen.** This is a review first.
- **Do not cut a rule because it looks long.** Check whether sessions needed it: a rule
  that prevented an administrator-level mistake on a user's machine earns its tokens.
- **Do not paste transcript text into tracked files** - findings and counts only. A
  transcript can also hold a secret a session printed, such as the token in `.env`: report
  that it is there, never its value, in `wip/` as much as anywhere.
- **Do not move a rule out of the always-loaded files into a file nobody is told to read.**
  A pointer in `AGENTS.md`, with the moment to read it, goes with every move.
- **Do not promote a machine or harness quirk into `AGENTS.md`.** Every session on every
  platform would pay for it in full, where a memory costs one index line.
