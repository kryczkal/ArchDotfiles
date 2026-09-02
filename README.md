# ArchDotfiles

Two jobs: (a) fresh Arch install to a working river desktop in one command,
(b) one set of configs shared across machines, edited in place.

```bash
git clone git@github.com:kryczkal/ArchDotfiles.git ~/ArchDotfiles
~/ArchDotfiles/install          # idempotent, re-run any time
~/ArchDotfiles/install --keys   # once: ssh key
```

## Layout

| path | what |
|---|---|
| `install` | the whole bootstrap, ~70 lines, no prompts |
| `pkgs/*.txt` | package lists. `base`, `desktop`, `aur`, `host-<hostname>` |
| `etc/` | system files, copied to `/etc` verbatim |
| `home/common/` | stow package, everything shared |
| `home/host-<hostname>/` | stow package, per-machine overrides (monitors, waybar tweaks) |
| `docs/` | design notes |

## Rules

- A config file is managed iff it is a symlink into this repo. Editing it edits the repo.
- Packages are data. `install` runs `pacman -S --needed` on the lists, nothing else.
- Per-host differences go in `home/host-<hostname>/` and `pkgs/host-<hostname>.txt`, never in `common`.
- Shell options live in `~/.config/shell/`. `.zshrc` and `.zprofile` are loaders.
- Machine-local secrets go in `~/.config/shell/local.sh` (gitignored).

## Daily

```bash
dots status | diff | log    # git in the repo from anywhere
dots sync                   # stage, commit with summary, push
dots drift                  # config on this machine the repo does not own
dots pkgs                   # explicitly installed packages missing from pkgs/
```

Add app-generated state to `home/.driftignore` / `etc/.driftignore` so `dots drift` stays quiet.
