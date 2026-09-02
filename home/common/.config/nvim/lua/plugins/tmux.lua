return {
  -- Seamless navigation + resize + buffer-swap across nvim splits and tmux panes.
  -- Replaces christoomey/vim-tmux-navigator with a unified scheme.
  --
  -- The actual keymaps live in lua/config/keymaps.lua (loaded after LazyVim's
  -- core keymaps) so they reliably override LazyVim's default <C-hjkl> = <C-w>
  -- window-navigation maps instead of racing them on the VeryLazy event.
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false, -- load in every nvim instance so the tmux integration is always live
    opts = {
      -- Wrap around when moving past the outermost split / tmux pane.
      at_edge = "wrap",
      -- Match the tmux resize step (resize-pane ... 2).
      default_amount = 2,
      -- tmux is auto-detected via $TMUX; nothing else to configure.
    },
  },
}
