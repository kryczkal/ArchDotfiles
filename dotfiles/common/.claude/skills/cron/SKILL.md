---
name: cron
description: Set up and manage sandboxed, scheduled "overnight protocol" jobs across projects — datamining, overnight code-quality sweeps, the iris daily sweep. Each job is kernel-confined to write only its own git worktree, reads everything except secrets, and its control plane sits outside the cage (injection-resilient). Trigger on "/cron", "schedule an overnight job", "run X nightly", "datamine while I sleep", "manage cron jobs". Linux/systemd now; macOS (launchd+Seatbelt) planned.
---

# cron — sandboxed scheduled jobs

Local, recurring, structurally-sandboxed jobs for unattended overnight work. The engine is `~/.claude/skills/cron/cron.py` (run with `/usr/bin/python3`) — it does the deterministic plumbing (manifest → systemd unit, worktree, commit, prune, digest). You are the conversational layer.

This is **not** the `schedule` skill (cloud/remote — can't see local files) or `loop` (in-session). These run locally via **systemd user timers + a kernel sandbox**.

## How a job works (explain when relevant)

- A job is a git-tracked manifest `<project>/.cron/<name>.md`: YAML frontmatter (schedule, run, sandbox) + body (a Claude protocol prompt, or a shell command).
- Each run: a fresh git **worktree** at HEAD on branch `cron/<name>/<timestamp>` → run the protocol there → commit (unsigned) → **auto-prune** to `retain` branches. **The live working tree is never touched.** Review/merge the branch later; `/cron digest` aggregates results from those branches + the systemd journal (unforgeable run facts).
- **The cage** (kernel-enforced via systemd): writes only its worktree + that repo's `.git` + `~/.claude`; reads everything **except** secrets (`~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.config/gh`, `~/.netrc`, …); the control plane (units, manifests, journal) is unwritable by the job → a prompt-injected job can wreck its own throwaway branch at worst.

## Commands

Set `PY=/usr/bin/python3` and `CRON=~/.claude/skills/cron/cron.py`, then shell out:

- **new** — author a job. Establish: which project, the schedule (`daily 3am` / `every Mon 9am` / raw `OnCalendar=…`), and the protocol (a Claude prompt, or `run: shell` + a command). Write `<project>/.cron/<name>.md` (frontmatter + body), then `$PY $CRON install <path>`.
- **list** — `$PY $CRON list`
- **run `<name>`** — `$PY $CRON run <name>` (triggers now, fully sandboxed) then `$PY $CRON logs <name>`
- **enable / disable / remove `<name>`** — `$PY $CRON {enable|disable|remove} <name>`
- **logs `<name>`** — `$PY $CRON logs <name>`
- **digest** — `$PY $CRON digest` (morning review across all jobs)
- **prune `<name>`|`--all`** — `$PY $CRON prune <name>` (also runs automatically after every job)
- **adopt-iris** — `$PY $CRON adopt-iris` (migrate the hand-built iris-sweep into a managed job)

## Manifest fields

`name`, `project`, `schedule`, `run` (`claude`|`shell`), `worktree` (default `true`), `writable` (extra dirs, rare), `allow_read` (re-permit a blocked secret a job legitimately needs, e.g. `~/.config/gh` for `gh`), `catchup` (`spread`|`once`|`skip`), `retain` (default 14), `enabled` (default `true`).

## When creating a job

1. Confirm project + schedule + the one protocol it should run.
2. Write the manifest. For a Claude job, the body is the protocol prompt — it runs with **cwd = the worktree**, so use **relative paths** to write results into the repo (they land on the branch). The body's first line must not be `---` (frontmatter is stripped before `claude -p`).
3. `install`, then offer a test `run` + show `logs`.
4. Remind the user: results appear on `cron/<name>/*` branches and in `/cron digest`, never in their live checkout — they merge what they want.
