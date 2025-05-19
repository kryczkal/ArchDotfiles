local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Define a general autocommand group
local general_augroup = augroup("MyGeneralAutocmds", { clear = true })

-- Terminal settings
autocmd("TermOpen", {
  group = general_augroup,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
    -- Map Escape to exit terminal mode
    -- Using tmap as tnoremap in Lua autocommand callback is tricky, vim.keymap.set is better
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = true, noremap = true, silent = true })
  end,
})

-- Filetype recognition
autocmd({ "BufRead", "BufNewFile" }, {
  group = general_augroup,
  pattern = "*.nasm",
  callback = function()
    vim.bo.filetype = "asm"
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group = general_augroup,
  pattern = "*.tpp",
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
  group = general_augroup,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})
