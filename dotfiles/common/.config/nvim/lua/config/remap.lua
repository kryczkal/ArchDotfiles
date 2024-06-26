-- vim
vim.g.mapleader = " "

-- file explorer
vim.keymap.set("n", "<leader>fe", vim.cmd.Ex)

-- fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git);

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.keymap.set('n', '<leader>gtb', function()
    require('utils.gen_titles').GenerateTitle()
end, {})
vim.keymap.set('n', '<leader>gts', function()
    require('utils.gen_titles').GenerateSubtitle()
end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gtl', function()
    require('utils.gen_titles').GenerateOneLiner()
end, { noremap = true, silent = true })
