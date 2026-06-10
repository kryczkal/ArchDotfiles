# Spec: Consolidate dispersed shell/config options under stow

**Date:** 2026-06-10
**Status:** approved-pending-review

## 1. Goal

Make ArchDotfiles the single source of truth for every hand-edited option: shell
options move into topical files under `~/.config/shell/` with thin, stowed rc
files as loaders, and the few unmanaged hand-edited files worth keeping are
adopted into the repo. Out of scope: replacing oh-my-zsh, managing bash,
adopting app-generated state (btop/htop/GTK/dconf/…), and the tmux plugin
install story (flagged in §8, not fixed here).

## 2. Background (why this exists)

The repo already contains the intended design — `dotfiles/common/.config/shell/
{aliases,env}.sh` with headers saying "edit this instead of rc files" — but the
live `~/.zshrc` / `~/.zprofile` / `~/.p10k.zsh` were never brought into the
repo and never source those files. Result: two copies of the aliases (repo copy
dead and stale, live copy unmanaged), PATH/env options accumulated in
`~/.zprofile`, and a `source ~/.zprofile` hack in `.zshrc:84` that double-runs
everything in login shells. The repo copy of `aliases.sh` still carries the
global `-h`/`--help` aliases in the unsafe (pre-omz) position — the exact cause
of the 2026-06-10 `diagnostics.zsh:134 parse error near '>&'` bug: global
aliases expand at parse time, and in login shells `.zprofile` runs before
oh-my-zsh sources its libs, so `[[ -h "$file" ]]` inside any omz lib became a
pipe inside `[[ ]]`.

## 3. Architecture

```
                    ArchDotfiles (repo, source of truth)
                    ────────────────────────────────────
dotfiles/common/.zshrc ─────────────stow──→ ~/.zshrc          (thin loader)
dotfiles/common/.zprofile ──────────stow──→ ~/.zprofile       (thin loader)
dotfiles/common/.p10k.zsh ──────────stow──→ ~/.p10k.zsh
dotfiles/common/.config/shell/ ─────stow──→ ~/.config/shell/  (folded dir link)
    ├── env.sh        exports (MANPAGER, ANDROID_HOME, CLAUDE_*, …)
    ├── path.sh       PATH entries, deduped via typeset -U
    ├── aliases.sh    plain aliases (ls/l/cat/paru/.)
    ├── functions.sh  dots / dots-commit helpers
    ├── local.sh      machine-local overrides — GITIGNORED, optional
    └── zsh/
        └── bat-help.zsh   global -h/--help aliases (parse-time hazard:
                           must load AFTER omz; zsh-only)
dotfiles/common/.config/mimeapps.list ─stow─→ ~/.config/mimeapps.list
dotfiles/common/.local/bin/{wifi-reset,gitenv} ─stow─→ ~/.local/bin/…

Load order:
  login shell:     .zprofile → env.sh + path.sh        (river/way-displays see env)
  every interactive: .zshrc → fpath additions → omz (theme set here) →
                     env.sh + path.sh (idempotent re-source) → aliases.sh →
                     functions.sh → p10k → zsh/bat-help.zsh → local.sh (if exists)
```

Double-sourcing env/path in login shells is intentional and harmless: exports
are idempotent and `typeset -U path` dedupes. This replaces the
`source ~/.zprofile` hack and fixes non-login shells without it.

## 4. User-confirmed decisions

| Decision | Choice |
|---|---|
| Scope | Full audit: shell config + review all unmanaged configs, adopt/ignore each |
| Layout | Topical files in `~/.config/shell/`, rc files are thin stowed loaders |
| Machine-local options | Yes — `local.sh` hook, gitignored |
| Bash | Zsh-only; `~/.bashrc` stays unmanaged; drop bash claims from headers |
| Drift workflow | Make committing trivial: `dots-commit` helper (add/commit/push, generated message) |
| oh-my-zsh | Keep. Structure cleanup only, no framework change |
| Stow conflict policy | **Repo wins**: drop `--adopt`; back up conflicting target to `*.pre-stow`, then link |
| Adopt (borderline list) | `mimeapps.list` only. NOT adopted: `.gitconfig`, GTK settings, btop/htop |

Adopts decided by audit (not in the borderline question, flagged for review at
implementation): `~/.local/bin/wifi-reset` and `~/.local/bin/gitenv` — both
hand-written scripts that would be lost on reinstall (same class as `cwt`,
which already lives in the repo). `cursor-session` is an ELF binary, not
adopted. If you disagree, strike them from §6.

## 5. Technical decisions

Each was chosen against two rejected alternatives.

**T1 — Where stowed rc files live: `common` package top-level.**
Alternatives: (b) a separate `zsh` stow package — finer granularity nobody
needs, one more package name in `stow.bash`; (c) `ZDOTDIR=~/.config/zsh`
relocation — prettiest `$HOME`, but breaks the omz installer's assumptions and
every tool that appends to `~/.zshrc`. `common` already holds top-level
dotfiles (`.agents`), so (a) follows precedent.

**T2 — Login vs non-login env: dual-source with idempotence.**
`.zprofile` sources `env.sh` + `path.sh` (login shells; river session needs
env before any rc runs). `.zshrc` sources them again for non-login shells.
`path.sh` opens with `typeset -U path PATH` so re-sourcing never duplicates
entries. Alternatives: (b) keep the `source ~/.zprofile` hack — re-runs
*everything* including aliases and is the current duplication bug; (c) put env
in `.zshenv` — runs for every zsh including scripts, pollutes non-interactive
shells, against zsh best practice.

**T3 — Global `-h`/`--help` aliases: dedicated `shell/zsh/bat-help.zsh`, sourced last.**
The file carries a comment block explaining the parse-time hazard (today's
bug). Alternatives: (b) inline at end of `.zshrc` — works (it's where the
hotfix lives now) but the hazard documentation belongs with the hazard, and
the loader stays generic; (c) replace with bat's `help()` wrapper function —
fully safe but changes muscle memory (`help cmd` vs `cmd --help`); user keeps
current UX. Residual risk stays: any function file zsh parses *later*
(autoloaded completions containing `[[ -h … ]]`) can still trip — accepted,
documented in the file.

**T4 — `local.sh` placement: inside the folded symlink dir, gitignored.**
`~/.config/shell` is one folded symlink into the repo, so `local.sh` physically
lands in the repo working tree; a `.gitignore` entry
(`dotfiles/common/.config/shell/local.sh`) keeps it out of git. Alternatives:
(b) `stow --no-folding` so `~/.config/shell` is a real dir — per-file symlinks
everywhere, noisier; (c) `~/.zshrc.local` in `$HOME` — yet another unmanaged
top-level dotfile, the thing this spec removes. Secrets rule: the repo is
public (github.com/kryczkal/ArchDotfiles) — secrets and machine-quirks go in
`local.sh`, never in tracked files.

**T5 — Bootstrap "repo wins" mechanics.**
`zsh.bash`: run the omz installer with `RUNZSH=no CHSH=no KEEP_ZSHRC=yes` (it
currently re-prompts and writes its own `.zshrc`, which under the old `--adopt`
flow would get absorbed into the repo, silently replacing the curated one).
`chsh` stays as the module's own prompt. `powerlevel10k.bash`: delete the
`sed -i ZSH_THEME` block — the theme is set in the repo `.zshrc`; keep the
clone. `stow.bash`: replace `--adopt` with a pre-flight: `stow -n` to list
conflicts, move each conflicting real file to `<name>.pre-stow`, then `stow`.
Helper `backup_stow_conflicts()` goes in `lib/utils.bash`. Alternatives:
(b) keep `--adopt` + manual diff review — exactly the silent-clobber scenario
the user rejected; (c) `stow --override` — only resolves stow-vs-stow
ownership, not real-file conflicts.

**T6 — `dots` helpers in `shell/functions.sh`.**
`dots` = `git -C ~/ArchDotfiles "$@"` (so `dots status`, `dots diff` work).
`dots-commit` = `dots add -A && dots commit -m "chore(sync): $(hostname): <N
files: top-level summary>" && dots push`. Message is generated from `git
status --porcelain` top-level paths. No commit trailers. Alternatives:
(b) prompt-segment dirty indicator — user chose commit-helper over nagging;
(c) auto-commit cron — commits garbage mid-experiment, rejected.

**T7 — Live-machine migration is move-then-stow, file by file** (§7).
Alternative: stow `--adopt` to pull live files in — rejected per repo-wins
(and it would overwrite the *new* curated content with the old live files).

## 6. Changes

| File | Change |
|---|---|
| `dotfiles/common/.zshrc` | NEW — thin loader: instant prompt, `fpath+=(~/.local/share/zsh/site-functions)`, omz init (`plugins=(git)`, theme), source shell/{env,path,aliases,functions}.sh, p10k, zsh/bat-help.zsh, local.sh. Replaces live `~/.zshrc` (omz template boilerplate dropped) |
| `dotfiles/common/.zprofile` | NEW — sources shell/env.sh + shell/path.sh only |
| `dotfiles/common/.p10k.zsh` | NEW — adopted verbatim from `~/.p10k.zsh` |
| `dotfiles/common/.config/shell/env.sh` | REWRITE — merge live `.zprofile` env: MANPAGER, MANROFFOPT, ANDROID_HOME, CLAUDE_CODE_MAX_OUTPUT_TOKENS; drop bash claim from header |
| `dotfiles/common/.config/shell/path.sh` | NEW — `typeset -U path PATH`; entries: `~/.local/bin`, `~/.cargo/bin`, JetBrains Toolbox scripts, `$ANDROID_HOME/{cmdline-tools/latest/bin,platform-tools}` |
| `dotfiles/common/.config/shell/aliases.sh` | REWRITE — resolve drift (live wins): `cat="bat -p"`, add `paru --color=always`; keep `ls`/`l`/`.`; REMOVE global -h/--help (move to zsh/bat-help.zsh) |
| `dotfiles/common/.config/shell/functions.sh` | NEW — `dots`, `dots-commit` |
| `dotfiles/common/.config/shell/zsh/bat-help.zsh` | NEW — global -h/--help aliases + hazard comment (must load after omz) |
| `dotfiles/common/.config/mimeapps.list` | NEW — adopted from `~/.config/mimeapps.list` |
| `dotfiles/common/.local/bin/wifi-reset` | NEW — adopted from `~/.local/bin/wifi-reset` (flagged §4) |
| `dotfiles/common/.local/bin/gitenv` | NEW — adopted from `~/.local/bin/gitenv` (flagged §4) |
| `.gitignore` | ADD `dotfiles/common/.config/shell/local.sh` |
| `modules/02-shell/zsh.bash` | omz installer: `RUNZSH=no CHSH=no KEEP_ZSHRC=yes` |
| `modules/02-shell/powerlevel10k.bash` | DELETE the `sed ZSH_THEME` block + `try_backup_file` of `.zshrc` |
| `modules/02-shell/aliases.bash` | Update messages: sourcing is automatic now, no manual step |
| `modules/99-finalize/stow.bash` | Drop `--adopt`; pre-flight conflict backup to `*.pre-stow` via new helper |
| `lib/utils.bash` | ADD `backup_stow_conflicts <package>` |
| `dotfiles/desktop/.config/waybar/{config,style.css}.bck` | `git rm` — tracked backup junk |
| `~/.config/.tmux.conf` | DELETE (stale pre-stow duplicate; differs from managed tmux.conf — eyeball diff first) |
| `~/.config/nvim.bck.bck` | DELETE |
| `README.md` | Update stow-packages section: shell files now managed; document `dots-commit` and `local.sh` |

Live-file deletions after stow succeeds (migration §7): `~/.zshrc`,
`~/.zprofile`, `~/.p10k.zsh`, `~/.config/mimeapps.list`,
`~/.local/bin/{wifi-reset,gitenv}` (each replaced by symlink).

## 7. Migration (this laptop)

1. Build all repo files (§6), commit.
2. Eyeball `diff ~/.config/.tmux.conf` vs managed tmux.conf; delete straggler + `nvim.bck.bck`.
3. Move live originals aside: `for f in .zshrc .zprofile .p10k.zsh; do mv ~/$f ~/$f.pre-stow; done`; same for `mimeapps.list`, `wifi-reset`, `gitenv`.
4. `cd ~/ArchDotfiles/dotfiles && stow -t ~ common` (also restow `laptop`).
5. Run test suite (§9). On pass, delete `*.pre-stow` files.
6. Desktop machine: next visit, run steps 3–5 there (its live files may have their own drift — diff `*.pre-stow` against repo before deleting).

## 8. Flagged, out of scope

- tmux plugins dir is gitignored and nothing in bootstrap clones catppuccin —
  fresh machine gets bare tmux styling. Needs a TPM bootstrap or a clone module.
- `~/.bashrc` stays unmanaged (zsh-only decision).
- `.gitconfig` explicitly not adopted (user choice).

## 9. Tests

1. `zsh -lic exit 2>&1` produces no output → no parse error, no p10k instant-prompt warning.
2. `zsh -lic 'alias -- -h; alias -- --help'` → both global aliases defined.
3. `zsh -lic 'print -l $path | sort | uniq -d'` → empty (no PATH duplicates in login shell); same for `zsh -ic`.
4. `zsh -ic 'alias cat ls paru; whence -w dots dots-commit'` → live values match repo files; functions defined.
5. `readlink ~/.zshrc ~/.zprofile ~/.p10k.zsh ~/.config/mimeapps.list ~/.local/bin/wifi-reset` → all point into ArchDotfiles.
6. `stow -n -t ~ common laptop` after migration → zero conflicts, zero planned ops.
7. `touch ~/.config/shell/local.sh && dots status` → local.sh not listed (gitignored).
8. `dots-commit` with a dirty repo → single commit, generated message, no trailers, pushed.
9. Fresh-machine sim (arch container): run `02-shell` then `99-finalize` modules → final `~/.zshrc` is the repo symlink; any pre-existing file got `*.pre-stow`d, not adopted.
10. `xdg-mime query default text/html` unchanged before/after mimeapps adoption.
