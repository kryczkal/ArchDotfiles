-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ──────────────────────────────────────────────────────────────
-- SEAMLESS NVIM ↔ TMUX (smart-splits.nvim)
-- Defined here (after LazyVim core keymaps) so they override
-- LazyVim's default <C-hjkl> = <C-w> window-navigation maps.
-- ──────────────────────────────────────────────────────────────
local ss = function(fn)
  return function()
    require("smart-splits")[fn]()
  end
end

-- Move between splits / tmux panes (wraps at the outer edge)
vim.keymap.set("n", "<C-h>", ss("move_cursor_left"), { desc = "Move to left split/pane" })
vim.keymap.set("n", "<C-j>", ss("move_cursor_down"), { desc = "Move to below split/pane" })
vim.keymap.set("n", "<C-k>", ss("move_cursor_up"), { desc = "Move to above split/pane" })
vim.keymap.set("n", "<C-l>", ss("move_cursor_right"), { desc = "Move to right split/pane" })

-- Resize splits (focus-aware: resizes the tmux pane when at the nvim edge)
vim.keymap.set("n", "<A-h>", ss("resize_left"), { desc = "Resize split left" })
vim.keymap.set("n", "<A-j>", ss("resize_down"), { desc = "Resize split down" })
vim.keymap.set("n", "<A-k>", ss("resize_up"), { desc = "Resize split up" })
vim.keymap.set("n", "<A-l>", ss("resize_right"), { desc = "Resize split right" })

-- Swap buffers across splits (mnemonic: like vim's <C-w>H to move a window)
vim.keymap.set("n", "<leader>wH", ss("swap_buf_left"), { desc = "Swap buffer left" })
vim.keymap.set("n", "<leader>wJ", ss("swap_buf_down"), { desc = "Swap buffer down" })
vim.keymap.set("n", "<leader>wK", ss("swap_buf_up"), { desc = "Swap buffer up" })
vim.keymap.set("n", "<leader>wL", ss("swap_buf_right"), { desc = "Swap buffer right" })
