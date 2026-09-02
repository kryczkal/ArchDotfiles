-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Readable prose ------------------------------------------------------------
-- LazyVim's `lazyvim_wrap_spell` autocmd already sets wrap+spell for
-- text/markdown/gitcommit; add breakindent so wrapped bullets/indented
-- paragraphs hang correctly instead of snapping to column 0.
local prose = vim.api.nvim_create_augroup("prose", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = prose,
  pattern = { "text", "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.breakindent = true
  end,
})

-- Files with no extension get no filetype, so LazyVim's wrap autocmd never
-- fires and lines run off-screen. Treat extensionless regular files as prose.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = prose,
  callback = function(ev)
    if vim.bo[ev.buf].buftype == "" and vim.bo[ev.buf].filetype == "" then
      vim.opt_local.wrap = true
      vim.opt_local.breakindent = true
    end
  end,
})
