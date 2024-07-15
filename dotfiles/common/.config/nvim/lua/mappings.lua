local map = vim.keymap.set

-- nvim tree (file explorer)
map("n", "<leader>fe", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- whichkey
map("n", "<leader>wk", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

-- Make escape quit terminal mode
vim.api.nvim_exec([[
autocmd TermOpen * setlocal nonumber norelativenumber
autocmd TermOpen * startinsert
tnoremap <Esc> <C-\><C-n>
]], false)

require('toggle-terminal')
map('n', '<leader>t', '<cmd>lua ToggleBottomTerminal()<CR>', { noremap = true, silent = true, desc = 'Toggle terminal' })
