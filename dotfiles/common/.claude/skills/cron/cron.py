#!/usr/bin/env python3
"""cron — sandboxed scheduled jobs (overnight protocols). Deterministic backend.

Manages systemd user timers that run a protocol inside a kernel sandbox + an isolated
git worktree: a job writes only its worktree (committed to a per-run branch), reads
everything except secrets, and cannot touch its own controls. The control plane (units,
manifests, journal) lives outside the cage. Spec: iris/docs/specs/2026-05-31-sandboxed-cron-skill.md

Stdlib only. Linux/systemd backend. macOS (launchd+Seatbelt) is a future backend.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

HOME = Path.home()
CTRL = HOME / ".local/share/cron"
WT = CTRL / "wt"
LOGS = CTRL / "logs"
DIGEST = CTRL / "digest.md"
UNIT_DIR = HOME / ".config/systemd/user"
CLAUDE = "/usr/bin/claude"
PY = "/usr/bin/python3"
SELF = Path(__file__).resolve()

# Secret locations blocked from every job (kernel-level, InaccessiblePaths). A job can
# re-permit one it legitimately needs via `allow_read:`. `.env` files are scattered and
# not glob-blockable in systemd — this is the known-paths deny-list, not a guarantee.
SECRET_PATHS = [
    "~/.ssh", "~/.aws", "~/.gnupg", "~/.config/gh", "~/.config/gcloud", "~/.netrc",
    "~/.kube", "~/.docker/config.json", "~/.npmrc", "~/.pypirc", "~/.git-credentials",
    "~/.config/op", "~/.config/anthropic",
]

DOW = {"mon": "Mon", "tue": "Tue", "wed": "Wed", "thu": "Thu", "fri": "Fri",
       "sat": "Sat", "sun": "Sun"}


@dataclass
class Job:
    name: str
    project: Path
    schedule: str
    run: str = "claude"
    body: str = ""
    worktree: bool = True
    writable: list[str] = field(default_factory=list)
    allow_read: list[str] = field(default_factory=list)
    catchup: str = "spread"  # spread | once | skip
    retain: int = 14
    enabled: bool = True
    manifest: Path | None = None

    @property
    def unit(self) -> str:
        proj = re.sub(r"[^a-zA-Z0-9_-]", "-", self.project.name)
        return f"cron-{proj}-{self.name}"


# ── helpers ──────────────────────────────────────────────────────────────────────

def _expand(p: str) -> str:
    return str(Path(p).expanduser())


def sh(cmd: list[str], cwd: Path | None = None, check: bool = True) -> int:
    r = subprocess.run(cmd, cwd=str(cwd) if cwd else None, check=False)
    if check and r.returncode != 0:
        raise SystemExit(f"command failed ({r.returncode}): {' '.join(cmd)}")
    return r.returncode


def sh_out(cmd: list[str], cwd: Path | None = None) -> str:
    return subprocess.run(cmd, cwd=str(cwd) if cwd else None, check=False,
                          capture_output=True, text=True).stdout


# ── manifest ───────────────────────────────────────────────────────────────────

def _coerce(v: str) -> object:
    v = v.strip()
    if v.lower() in ("true", "false"):
        return v.lower() == "true"
    if v.startswith("[") and v.endswith("]"):
        inner = v[1:-1].strip()
        return [x.strip().strip("'\"") for x in inner.split(",") if x.strip()] if inner else []
    if re.fullmatch(r"-?\d+", v):
        return int(v)
    return v.strip("'\"")


def strip_frontmatter(text: str) -> str:
    if text.startswith("---"):
        parts = text.split("---", 2)
        if len(parts) == 3:
            return parts[2].lstrip("\n")
    return text


def parse_manifest(path: Path) -> Job:
    text = path.read_text()
    if not text.startswith("---"):
        raise SystemExit(f"{path}: manifest must start with a --- frontmatter block")
    _, fm, body = text.split("---", 2)
    cfg: dict[str, object] = {}
    for line in fm.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, _, val = line.partition(":")
        cfg[key.strip()] = _coerce(val)
    project = Path(str(cfg.get("project", path.parent.parent))).expanduser().resolve()
    return Job(
        name=str(cfg.get("name", path.stem)),
        project=project,
        schedule=str(cfg.get("schedule", "daily 03:00")),
        run=str(cfg.get("run", "claude")),
        body=body.lstrip("\n"),
        worktree=bool(cfg.get("worktree", True)),
        writable=list(cfg.get("writable", []) or []),  # type: ignore[arg-type]
        allow_read=list(cfg.get("allow_read", []) or []),  # type: ignore[arg-type]
        catchup=str(cfg.get("catchup", "spread")),
        retain=int(cfg.get("retain", 14)),  # type: ignore[arg-type]
        enabled=bool(cfg.get("enabled", True)),
        manifest=path.resolve(),
    )


# ── schedule → systemd OnCalendar ─────────────────────────────────────────────

def parse_time(t: str) -> str:
    t = t.strip().lower().replace(" ", "")
    ampm = None
    if t.endswith("am"):
        ampm, t = "am", t[:-2]
    elif t.endswith("pm"):
        ampm, t = "pm", t[:-2]
    if ":" in t:
        hh, mm = t.split(":", 1)
        h, m = int(hh), int(mm)
    else:
        h, m = int(t), 0
    if ampm == "pm" and h < 12:
        h += 12
    if ampm == "am" and h == 12:
        h = 0
    return f"{h:02d}:{m:02d}:00"


def parse_schedule(s: str) -> str:
    s = s.strip()
    if s.lower().startswith("oncalendar="):
        return s.split("=", 1)[1].strip()
    low = s.lower()
    if low == "hourly":
        return "hourly"
    if low == "daily":
        return "*-*-* 03:00:00"
    m = re.match(r"daily\s+(.+)", low)
    if m:
        return f"*-*-* {parse_time(m.group(1))}"
    m = re.match(r"every\s+(\w+)\s*(.*)", low)
    if m and m.group(1)[:3] in DOW:
        t = parse_time(m.group(2)) if m.group(2).strip() else "09:00:00"
        return f"{DOW[m.group(1)[:3]]} *-*-* {t}"
    return s  # assume a raw OnCalendar expression


# ── systemd unit rendering ─────────────────────────────────────────────────────

def render_service(job: Job) -> str:
    rw = [str(WT), str(LOGS), str(job.project / ".git"), str(HOME / ".claude")]
    rw += [_expand(p) for p in job.writable]
    allow = {_expand(a) for a in job.allow_read}
    blocked = " ".join("-" + _expand(p) for p in SECRET_PATHS if _expand(p) not in allow)
    log = LOGS / f"{job.name}.log"
    return f"""[Unit]
Description=cron job: {job.name} ({job.project.name})

[Service]
Type=oneshot
Environment=PATH=/usr/local/bin:/usr/bin:/bin:{HOME}/.local/bin
WorkingDirectory={WT}
ExecStart={PY} {SELF} __run__ {job.manifest}
StandardOutput=append:{log}
StandardError=append:{log}
TimeoutStartSec=3600

# write-cage: reads everything except secrets; writes only worktree + own .git + claude state
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths={' '.join(rw)}
InaccessiblePaths={blocked}
PrivateTmp=true
NoNewPrivileges=true
"""


def render_timer(job: Job) -> str:
    oncal = parse_schedule(job.schedule)
    persistent = "false" if job.catchup == "skip" else "true"
    delay = "\nRandomizedDelaySec=300" if job.catchup == "spread" else ""
    return f"""[Unit]
Description=cron timer: {job.name} ({job.project.name})

[Timer]
OnCalendar={oncal}
Persistent={persistent}{delay}

[Install]
WantedBy=timers.target
"""


# ── commands ────────────────────────────────────────────────────────────────────

def cmd_install(manifest: Path) -> None:
    job = parse_manifest(manifest)
    UNIT_DIR.mkdir(parents=True, exist_ok=True)
    (UNIT_DIR / f"{job.unit}.service").write_text(render_service(job))
    (UNIT_DIR / f"{job.unit}.timer").write_text(render_timer(job))
    sh(["systemctl", "--user", "daemon-reload"])
    if job.enabled:
        sh(["systemctl", "--user", "enable", "--now", f"{job.unit}.timer"])
    else:
        sh(["systemctl", "--user", "disable", "--now", f"{job.unit}.timer"], check=False)
    print(f"installed {job.unit}  ·  OnCalendar={parse_schedule(job.schedule)}  ·  enabled={job.enabled}")


def _run_inner(manifest: Path) -> int:
    """The sandboxed executor (called by the unit's ExecStart). Worktree → run → commit → prune."""
    job = parse_manifest(manifest)
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")  # noqa: DTZ005 — local stamp, not a workflow
    branch = f"cron/{job.name}/{ts}"
    wt = WT / job.unit
    print(f"[cron] {job.name} start {ts} → {branch}")
    if job.worktree:
        sh(["git", "-C", str(job.project), "worktree", "remove", "--force", str(wt)], check=False)
        sh(["git", "-C", str(job.project), "worktree", "add", "--force", "-b", branch, str(wt), "HEAD"])
        workdir = wt
    else:
        workdir = job.project
    if job.run == "claude":
        rc = sh([CLAUDE, "-p", strip_frontmatter(job.body), "--dangerously-skip-permissions"],
                cwd=workdir, check=False)
    else:
        rc = sh(["/bin/sh", "-c", job.body], cwd=workdir, check=False)
    if job.worktree:
        sh(["git", "-C", str(wt), "add", "-A"], check=False)
        if sh_out(["git", "-C", str(wt), "status", "--porcelain"]).strip():
            committer = ["gitenv"] if shutil.which("gitenv") else []
            # --no-gpg-sign: cron commits are unsigned — signing needs ~/.gnupg, which the cage blocks.
            rc_c = sh([*committer, "git", "-C", str(wt), "-c", "commit.gpgsign=false",
                       "commit", "--no-gpg-sign", "-m", f"cron {job.name} {ts}"], check=False)
            print(f"[cron] {job.name} committed → {branch}" if rc_c == 0
                  else f"[cron] {job.name} COMMIT FAILED rc={rc_c} (see log)")
        else:
            print(f"[cron] {job.name} no changes")
        sh(["git", "-C", str(job.project), "worktree", "remove", "--force", str(wt)], check=False)
        prune_job(job)
    print(f"[cron] {job.name} done rc={rc}")
    return rc


def prune_job(job: Job) -> None:
    """Auto-prune: keep the last `retain` per-run branches, drop the rest; prune worktrees + log."""
    out = sh_out(["git", "-C", str(job.project), "branch", "--list", f"cron/{job.name}/*"])
    branches = sorted(b.strip().lstrip("*+ ").strip() for b in out.splitlines() if b.strip())
    stale = branches[:-job.retain] if job.retain > 0 and len(branches) > job.retain else []
    for b in stale:
        sh(["git", "-C", str(job.project), "branch", "-D", b], check=False)
    if stale:
        print(f"[cron] {job.name} pruned {len(stale)} old branch(es), kept {job.retain}")
    sh(["git", "-C", str(job.project), "worktree", "prune"], check=False)
    log = LOGS / f"{job.name}.log"
    if log.exists() and log.stat().st_size > 1_000_000:
        tail = log.read_text(errors="ignore").splitlines()[-2000:]
        log.write_text("\n".join(tail) + "\n")


def _find_unit(name: str) -> str:
    if name.startswith("cron-"):
        return name if name.endswith(".timer") else f"{name}.timer"
    matches = sorted(p.stem for p in UNIT_DIR.glob(f"cron-*-{name}.timer"))
    if not matches:
        raise SystemExit(f"no managed job named '{name}'")
    if len(matches) > 1:
        raise SystemExit(f"ambiguous '{name}' — matches: {', '.join(matches)} (use full unit name)")
    return f"{matches[0]}.timer"


def cmd_list() -> None:
    timers = sorted(UNIT_DIR.glob("cron-*.timer"))
    if not timers:
        print("no cron jobs installed.")
        return
    print(f"{'JOB':40} {'ENABLED':9} {'NEXT'}")
    nxt = sh_out(["systemctl", "--user", "list-timers", "--all", "--no-pager", "cron-*"])
    for t in timers:
        unit = t.stem
        en = sh_out(["systemctl", "--user", "is-enabled", f"{unit}.timer"]).strip() or "?"
        when = next((ln.split("  ")[0].strip() for ln in nxt.splitlines() if unit in ln), "")
        print(f"{unit:40} {en:9} {when}")


def cmd_enable(name: str) -> None:
    sh(["systemctl", "--user", "enable", "--now", _find_unit(name)])


def cmd_disable(name: str) -> None:
    sh(["systemctl", "--user", "disable", "--now", _find_unit(name)], check=False)


def cmd_run(name: str) -> None:
    """Trigger a run NOW — through systemd, so it's sandboxed exactly like a scheduled run."""
    unit = _find_unit(name).replace(".timer", ".service")
    sh(["systemctl", "--user", "start", "--no-block", unit])
    print(f"started {unit} (sandboxed). logs: cron logs {name}")


def cmd_logs(name: str) -> None:
    unit = _find_unit(name).replace(".timer", "")
    print(sh_out(["journalctl", "--user", "-u", f"{unit}.service", "-n", "40", "--no-pager"]))


def _manifest_for_unit(unit: str) -> Path:
    svc = (UNIT_DIR / f"{unit}.service").read_text()
    m = re.search(r"__run__\s+(\S+)", svc)
    if not m:
        raise SystemExit(f"cannot find manifest for {unit}")
    return Path(m.group(1))


def cmd_prune(name: str) -> None:
    units = ([t.stem for t in sorted(UNIT_DIR.glob("cron-*.timer"))]
             if name == "--all" else [_find_unit(name).replace(".timer", "")])
    for unit in units:
        try:
            prune_job(parse_manifest(_manifest_for_unit(unit)))
        except SystemExit as exc:
            print(f"skip {unit}: {exc}")


def cmd_digest() -> None:
    stamp = datetime.now().strftime("%Y-%m-%d %H:%M")  # noqa: DTZ005
    lines = [f"# cron digest — {stamp}"]
    for t in sorted(UNIT_DIR.glob("cron-*.timer")):
        unit = t.stem
        res = sh_out(["systemctl", "--user", "show", f"{unit}.service",
                      "-p", "Result", "-p", "ExecMainStatus",
                      "-p", "ExecMainExitTimestamp"]).strip().replace("\n", "  ")
        lines.append(f"\n## {unit}\n{res or '(never run)'}")
        try:
            job = parse_manifest(_manifest_for_unit(unit))
            raw = sh_out(["git", "-C", str(job.project), "branch", "--list", f"cron/{job.name}/*"])
            recent = sorted(b.strip().lstrip("*+ ") for b in raw.splitlines() if b.strip())[-3:]
            for b in recent:
                subj = sh_out(["git", "-C", str(job.project), "log", "-1", "--format=%ci %s", b]).strip()
                lines.append(f"  - {b}: {subj}")
        except SystemExit:
            pass
    DIGEST.parent.mkdir(parents=True, exist_ok=True)
    DIGEST.write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
    print(f"\n→ {DIGEST}")


def cmd_remove(name: str) -> None:
    unit = _find_unit(name).replace(".timer", "")
    sh(["systemctl", "--user", "disable", "--now", f"{unit}.timer"], check=False)
    for ext in (".service", ".timer"):
        p = UNIT_DIR / f"{unit}{ext}"
        if p.exists():
            p.unlink()
    sh(["systemctl", "--user", "daemon-reload"])
    print(f"removed {unit} (manifest kept)")


def cmd_adopt_iris() -> None:
    proj = HOME / "Projects/iris"
    manifest = proj / ".cron" / "iris-sweep.md"
    manifest.parent.mkdir(parents=True, exist_ok=True)
    body = strip_frontmatter((proj / ".claude/commands/iris-sweep.md").read_text())
    manifest.write_text(
        "---\n"
        "name: iris-sweep\n"
        f"project: {proj}\n"
        "schedule: daily 09:00\n"
        "run: claude\n"
        "worktree: true\n"
        "catchup: spread\n"
        "retain: 14\n"
        "enabled: true\n"
        "---\n" + body
    )
    sh(["systemctl", "--user", "disable", "--now", "iris-sweep.timer"], check=False)
    for u in ("iris-sweep.service", "iris-sweep.timer"):
        p = UNIT_DIR / u
        if p.exists():
            p.unlink()
    sh(["systemctl", "--user", "daemon-reload"])
    cmd_install(manifest)
    print(f"adopted iris-sweep → manifest {manifest}")


def main() -> None:
    ap = argparse.ArgumentParser(prog="cron", description="sandboxed scheduled jobs")
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name in ("install", "__run__"):
        p = sub.add_parser(name)
        p.add_argument("manifest", type=Path)
    for name in ("enable", "disable", "run", "logs", "prune", "remove"):
        p = sub.add_parser(name)
        p.add_argument("name")
    sub.add_parser("list")
    sub.add_parser("digest")
    sub.add_parser("adopt-iris")
    args = ap.parse_args()

    if sys.platform != "linux":
        raise SystemExit(
            "cron: only the Linux/systemd backend is implemented; macOS (launchd + "
            "Seatbelt) is a planned backend. The manifest format is already portable."
        )

    if args.cmd == "install":
        cmd_install(args.manifest)
    elif args.cmd == "__run__":
        raise SystemExit(_run_inner(args.manifest))
    elif args.cmd == "list":
        cmd_list()
    elif args.cmd == "enable":
        cmd_enable(args.name)
    elif args.cmd == "disable":
        cmd_disable(args.name)
    elif args.cmd == "run":
        cmd_run(args.name)
    elif args.cmd == "logs":
        cmd_logs(args.name)
    elif args.cmd == "prune":
        cmd_prune(args.name)
    elif args.cmd == "digest":
        cmd_digest()
    elif args.cmd == "remove":
        cmd_remove(args.name)
    elif args.cmd == "adopt-iris":
        cmd_adopt_iris()


if __name__ == "__main__":
    main()
