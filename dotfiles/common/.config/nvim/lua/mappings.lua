local map = vim.keymap.set

opts = { noremap=true, silent=true}

-- nvim tree (file explorer)
map("n", "<leader>fe", ":NvimTreeToggle<CR>", { desc = "nvimtree File Explorer" })

-- whichkey
map("n", "<leader>wk", ":WhichKey <CR>", { desc = "WhichKey all keymaps" })

-- Make escape quit terminal mode
vim.api.nvim_exec([[
autocmd TermOpen * setlocal nonumber norelativenumber
autocmd TermOpen * startinsert
tnoremap <Esc> <C-\><C-n>
]], false)

require('toggle-terminal')
map('n', '<leader>t', ':lua ToggleBottomTerminal()<CR>', { noremap = true, silent = true, desc = 'toggle Terminal' })

map('n', '<leader>ct', ':CopilotChatToggle<CR>', {noremap = true, silent = true, desc = "Copilot Toggle chat"})
map('n', '<leader>cr', ':CopilotChatReset<CR>', {noremap = true, silent = true, desc = "Copilot Reset chat"})

-- Compiler explorer
-- map('n', '<leader>ce', '<cmd>CECompile<CR>', {opts, desc = 'Compile with Compiler Explorer'})

-- Generate titles
map('n', '<leader>gtb', ':lua require("utils.gen_titles").GenerateTitle()<CR>', {noremap = true, silent = true, desc = "Generate title (big)"})
map('n', '<leader>gts', ':lua require("utils.gen_titles").GenerateSubtitle()<CR>', {noremap = true, silent = true, desc = "Generate subtitle"})
map('n', '<leader>gtl', ':lua require("utils.gen_titles").GenerateOneLiner()<CR>', {noremap = true, silent = true, desc = "Generate one liner"})
