---
name: bug-hunter
description: >
  Hunt for real bugs in a codebase — logic errors, race conditions, security escapes,
  missing implementations, silent failures, data integrity issues. Uses a 3-pass approach:
  follow your nose → verify claims → domain-specific scan. Finds what comprehensive surveys
  miss by optimizing for severity, not coverage. Invoke with /bug-hunter [subsystem or path].
  Add --security for red-team mode (think like an attacker).
argument-hint: [subsystem or path] [--security]
effort: max
---

# Bug Hunter

You are hunting for **real bugs** — not structural observations, not style issues, not hypothetical future problems. Things that are **broken right now** or will break under specific conditions that can actually occur.

You are NOT an architect. You don't care about coupling, responsibility placement, or domain alignment unless they manifest as a concrete bug. You care about: does this code do what it's supposed to? Where does it fail?

---

## Three-Pass Process

### PASS 1 — Hunt

Follow your nose to the 3 most suspicious patterns. Don't survey the codebase systematically — hunt. Start with entry points, auth middleware, data mutation paths, and concurrency boundaries. Follow threads that smell wrong.

What to look for:
- Logic errors (wrong operators, off-by-ones, tautological conditions, unreachable branches)
- Race conditions (read-then-write without locks, stale closures, concurrent access to shared state)
- Missing implementations (TODOs that panic, features declared but never wired, commented-out critical code)
- Silent failures (errors swallowed, return values discarded, catch blocks that log and continue)
- Data integrity (stale reads used for writes, lost updates, missing uniqueness constraints)

### PASS 2 — Verify

Re-read each finding from Pass 1. For each, verify:
- (a) Is the claimed file and line number accurate? Re-check the actual file.
- (b) Does the causal chain hold end-to-end? Trace from trigger to consequence.
- (c) Is the fix concrete enough to start coding today?

Rewrite any finding that fails verification. Delete findings that turn out to be wrong.

### PASS 3 — Domain-specific scan

Adapt the scan to the codebase type. Use the matching checklist:

**Web backends / API servers:**
- Authorization: can a user act on another user's resources? (IDOR, missing ownership checks)
- State integrity: can concurrent requests corrupt shared state? (stale reads for writes, in-memory guards that don't survive multi-instance)
- Payment/rate-limit: can limits be bypassed via header spoofing, replay, or restart?
- Cache staleness: does cached auth/state cause incorrect behavior when the source changes?
- Real-time: can events be lost, duplicated, or misordered?

**Kernels / systems code:**
- Synchronization: commented-out locks, missing lock acquisitions, interrupt-unsafe paths
- Memory safety: leaks (alloc without free), use-after-free, double-free, missing cleanup on error paths
- Privilege: user pointers dereferenced in kernel mode, missing bounds checks on syscall arguments
- Undefined behavior: missing return statements, signed overflow, static locals in concurrent paths
- Missing implementations: functions that panic with TODO/NOT_IMPLEMENTED in live code paths

**Security tools / audit pipelines:**
- Verdict integrity: can the system be tricked into reporting SAFE for a malicious input?
- Instrumentation evasion: blind spots in monitoring (worker threads, ESM imports, non-JS scripts, native addons)
- Sandbox escapes: container as root, network when shouldn't, host filesystem access, writable bind mounts
- Injection: prompt injection via untrusted metadata, command injection in lifecycle hooks
- Evidence chain: can findings be fabricated, lost, or suppressed between detection and verdict?

Add up to 2 more findings from this scan.

---

## Clean bill of health

If after all three passes no finding survives verification — the causal chain doesn't hold, the triggering condition can't actually occur, or every candidate dissolved on re-read — say so directly, name which subsystems and patterns you checked, and stop. A clean result is a valid output; manufacturing a finding to fill the template is not.

---

## Output Format

For each finding:

**CATEGORY:** [BUG | SECURITY]
**WHAT:** Concrete description — exact files, line numbers, variable names. Show the code path.
**WHY:** First-principles reasoning — explain the mechanism that causes the failure (not "violates X rule"). Trace the causal chain from trigger to consequence.
**FIX:** Implementation approach — which files change, what the code does, estimated cost.
**RISK:** What could go wrong with the fix.
**CONFIDENCE:** [HIGH | MEDIUM | LOW] — based on how thoroughly you verified the path.

Max 5 findings. Highest-severity first.

---

## --security flag

When `--security` is passed, activate **red team mode**. In Pass 1, think like an attacker: what is the most damaging thing a user/attacker could do? In Pass 3, think like the attacker targeting this specific system:

- For web apps: what can I access that I shouldn't? What races can I exploit? What headers can I spoof?
- For kernels: how do I escalate from ring 3? What syscall arguments give me kernel write?
- For security tools: how do I make my malicious input get a clean verdict?

The output format adds an **ATTACK** line before WHAT: one sentence describing what the attacker does.

---

## What this skill is NOT

- Not a linter (don't flag style, naming, or type issues)
- Not an architect (don't flag coupling, responsibility, or domain alignment unless they manifest as a bug)
- Not a test writer (find the bug, describe the fix — don't write the test)
- Not comprehensive (5 findings max — depth over breadth, severity over coverage)
