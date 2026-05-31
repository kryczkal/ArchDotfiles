#!/usr/bin/env python3
"""Plain-assert tests for the cron engine's pure functions (no pytest dep)."""

import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import cron  # noqa: E402


def _job(txt: str) -> "cron.Job":
    with tempfile.TemporaryDirectory() as d:
        p = Path(d) / "m.md"
        p.write_text(txt)
        return cron.parse_manifest(p)


def test_parse_time():
    assert cron.parse_time("3am") == "03:00:00"
    assert cron.parse_time("9pm") == "21:00:00"
    assert cron.parse_time("14:30") == "14:30:00"
    assert cron.parse_time("12am") == "00:00:00"
    assert cron.parse_time("12pm") == "12:00:00"


def test_parse_schedule():
    assert cron.parse_schedule("daily 3am") == "*-*-* 03:00:00"
    assert cron.parse_schedule("daily") == "*-*-* 03:00:00"
    assert cron.parse_schedule("every Mon 9am") == "Mon *-*-* 09:00:00"
    assert cron.parse_schedule("hourly") == "hourly"
    assert cron.parse_schedule("OnCalendar=*-*-* 02:00:00") == "*-*-* 02:00:00"


def test_parse_manifest():
    j = _job(
        "---\nname: datamine\nproject: /home/wookie/Projects/rizz\n"
        "schedule: daily 2am\nrun: claude\nallow_read: [~/.config/gh]\nretain: 7\n"
        "---\nMine the web for X.\n"
    )
    assert j.name == "datamine"
    assert j.schedule == "daily 2am"
    assert j.allow_read == ["~/.config/gh"]
    assert j.retain == 7
    assert j.body.strip() == "Mine the web for X."
    assert j.unit == "cron-rizz-datamine"


def test_render_service_sandbox():
    j = _job(
        "---\nname: j\nproject: /home/wookie/Projects/rizz\n"
        "schedule: daily 2am\nallow_read: [~/.gnupg]\n---\ndo it\n"
    )
    s = cron.render_service(j)
    assert "ProtectSystem=strict" in s
    assert "ProtectHome=read-only" in s
    assert "NoNewPrivileges=true" in s
    assert "PrivateTmp=true" in s
    assert "/.ssh" in s                  # secret blocked
    assert "/.gnupg" not in s            # allow_read removed it from the deny-list
    assert "/Projects/rizz/.git" in s    # can commit to its own branch
    assert "InaccessiblePaths=" in s


def test_render_timer():
    j = _job(
        "---\nname: j\nproject: /home/wookie/Projects/rizz\n"
        "schedule: daily 2am\ncatchup: spread\n---\nx\n"
    )
    t = cron.render_timer(j)
    assert "Persistent=true" in t
    assert "RandomizedDelaySec=300" in t
    assert "OnCalendar=*-*-* 02:00:00" in t


TESTS = [test_parse_time, test_parse_schedule, test_parse_manifest,
         test_render_service_sandbox, test_render_timer]

if __name__ == "__main__":
    fails = 0
    for t in TESTS:
        try:
            t()
            print(f"PASS {t.__name__}")
        except AssertionError as e:
            fails += 1
            print(f"FAIL {t.__name__}: {e}")
    print(f"\n{len(TESTS) - fails}/{len(TESTS)} passed")
    sys.exit(1 if fails else 0)
