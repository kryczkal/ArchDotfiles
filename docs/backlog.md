# Backlog

## Open
- **Adopt hand-edited app configs into home/common** (found by `drift` on PipeKiller, 2026-09-02):
  btop, htop, gh, gtk-3.0, gtk-4.0, mpv, flameshot, nextdns, `.config/git/ignore`.
  One at a time: `git mv` into home/common, restow, check the app still reads it.
- **nvim**: LazyVim with 9 language extras; decide extras on demand vs trimmed, and whether
  `lazy-lock.json` is tracked (it appeared on the Dell after first `nvim`, 2026-09-02).
- **tmux theme**: `tmux.conf` clones catppuccin at start and copies a theme file out of nvim's
  plugin dir. Works only after nvim ran once. Decide keep/replace.
- **Extend Ctrl+hjkl out to River windows (full WM-level seamless nav).**
  Today: nvim split <-> tmux pane on `Ctrl+hjkl` (smart-splits), River windows on `Super+arrows`.
  Goal: at the edge of the outermost tmux pane, hand off to `riverctl focus-view next/prev`.
  Needs a bespoke edge-detection wrapper (`#{pane_at_left}` etc.), River is prev/next not spatial.

## Resolved
- `dots` CLI cut to `./drift`, XDG app-state routing dropped, 2026-09-02.
- vim<->tmux seamless navigation via smart-splits.nvim (Ctrl+hjkl move, Alt+hjkl resize).
- oh-my-zsh dropped, 2026-09-02. History showed zero omz git alias usage.
- bootstrap modules replaced by `install` + `pkgs/*.txt`, 2026-09-02.
