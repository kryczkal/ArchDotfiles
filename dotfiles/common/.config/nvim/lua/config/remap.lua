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

vim.keymap.set('n', '<leader>bt', function()
    require('utils.bash_title').GenerateBashTitle(vim.fn.input('Enter title: '))
end, {})
vim.keymap.set('n', '<leader>bst', function()
    local subtitle = vim.fn.input('Enter subtitle: ')
    require('utils.bash_title').GenerateBashSubtitle(subtitle)
end, { noremap = true, silent = true })

