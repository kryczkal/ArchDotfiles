# Backlog

## Open
- **Extend Ctrl+hjkl out to River windows (full WM-level seamless nav).**
  Today the layers are: nvim split ↔ tmux pane on `Ctrl+hjkl` (smart-splits),
  and River windows on `Super+arrows`. Goal: when `Ctrl+hjkl` reaches the edge
  of the outermost tmux pane, hand off to River (`riverctl focus-view next/prev`)
  so one chord flows nvim → tmux → River window.
  River has no off-the-shelf multiplexer integration (unlike Hyprland/sway via
  smart-splits), so this needs a bespoke edge-detection wrapper: detect "at edge"
  from tmux (`#{pane_at_left}` etc.) / smart-splits' `at_edge` hook, then shell
  out to `riverctl`. River's directional model is `focus-view previous/next`
  (not spatial L/R/U/D), so the mapping from h/j/k/l → prev/next needs thought.
  Some trial-and-error expected.

## Resolved
- vim↔tmux seamless navigation — replaced christoomey/vim-tmux-navigator with
  **smart-splits.nvim**: `Ctrl+hjkl` move (wrap at edge), `Alt+hjkl` resize
  (focus-aware nvim split / tmux pane), `<leader>w` + `H/J/K/L` swap buffer
  across a split. tmux.conf navigation + resize bindings are now `is_vim`-aware.
  (Earlier confusion: `Ctrl+hjkl` already worked; the friction was reaching for
  `Ctrl+b` / `Ctrl+w` out of habit.)
