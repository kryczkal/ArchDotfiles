# ArchDotfiles

Two jobs: (a) fresh Arch install to a working river desktop in one command,
(b) one set of configs shared across machines, edited in place.

```bash
git clone git@github.com:kryczkal/ArchDotfiles.git ~/ArchDotfiles
~/ArchDotfiles/install          # idempotent, re-run any time
~/ArchDotfiles/install --keys   # once: ssh key
~/ArchDotfiles/drift            # what this machine has that the repo does not, and the reverse
```

## Layout

| path | what |
|---|---|
| `install` | the whole bootstrap, ~70 lines, no prompts |
| `drift` | config and packages the repo does not own, shipped files not linked |
| `pkgs/*.txt` | package lists. `base`, `desktop`, `aur`, `host-<hostname>` |
| `etc/` | system files, copied to `/etc` verbatim |
| `home/common/` | stow package, everything shared |
| `home/host-<hostname>/` | stow package, per-machine files (hardware scripts, monitors) |
| `home/seed/` | copied once, never overwritten: files apps rewrite themselves (mimeapps.list) |
| `docs/backlog.md` | open items |

## Rules

- A config file is managed iff it is a symlink into this repo. Editing it edits the repo.
- Packages are data. `install` runs `pacman -S --needed` on the lists, nothing else.
  Laptop-only packages (tlp) and hardware go in `pkgs/host-<hostname>.txt`.
- Per-host differences go in `home/host-<hostname>/` and `pkgs/host-<hostname>.txt`, never in `common`.
- Shell options live in `~/.config/shell/`. `.zshenv` and `.zshrc` only `source`.
- Machine-local secrets and paths go in `~/.config/shell/local.sh` (gitignored).
- App state stays where the app puts it. `drift` lists it once; then it goes in `home/.driftignore`.

## Daily

Edit the file in place. Then plain git in the repo: status, commit, push here, pull on the other machine.
