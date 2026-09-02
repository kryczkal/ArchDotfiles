# Backlog

## Open
- **Adopt hand-edited app configs into home/common** (found by `dots drift` on PipeKiller, 2026-09-02):
  btop, htop, gh, gtk-3.0, gtk-4.0, mpv, flameshot, nextdns, `.config/git/ignore`.
  One at a time: `git mv` into home/common, restow, check the app still reads it.
- **XDG routing for the rest**: env vars in `shell/env.sh` for every tool that supports it
  (see the xdg-ninja run in docs), `dots ignore` for the ones that do not.
- **Extend Ctrl+hjkl out to River windows (full WM-level seamless nav).**
  Today: nvim split <-> tmux pane on `Ctrl+hjkl` (smart-splits), River windows on `Super+arrows`.
  Goal: at the edge of the outermost tmux pane, hand off to `riverctl focus-view next/prev`.
  Needs a bespoke edge-detection wrapper (`#{pane_at_left}` etc.), River is prev/next not spatial.

## Resolved
- vim<->tmux seamless navigation via smart-splits.nvim (Ctrl+hjkl move, Alt+hjkl resize).
- oh-my-zsh dropped, 2026-09-02. History showed zero omz git alias usage.
- bootstrap modules replaced by `install` + `pkgs/*.txt`, 2026-09-02.
