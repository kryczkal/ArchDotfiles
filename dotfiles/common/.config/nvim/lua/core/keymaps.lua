local map  = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ensure the utility modules are loaded
require("utils.toggle_terminal")
require("utils.gen_titles")

-- yank to system clipboard
map({ "n", "v" }, "<leader>y", '"+y',
    vim.tbl_extend("keep", { desc = "Yank to system clipboard" }, opts))

-- quit
map("n", "<leader>q", ":q<CR>",
    vim.tbl_extend("keep", { desc = "Quit window" }, opts))

-- NvimTree
map("n", "<leader>fe", ":NvimTreeToggle<CR>",
    vim.tbl_extend("keep", { desc = "Toggle NvimTree" }, opts))

-- WhichKey
map("n", "<leader>wk", ":WhichKey<CR>",
    vim.tbl_extend("keep", { desc = "Which-Key" }, opts))

-- bottom terminal toggler
map("n", "<leader>t", function() ToggleBottomTerminal() end,
    vim.tbl_extend("keep", { desc = "Toggle bottom terminal" }, opts))

-- title/subtitle/one-liner banners
map("n", "<leader>gtb",
    function() require("utils.gen_titles").GenerateTitle() end,
    vim.tbl_extend("keep", { desc = "Generate title (big)" }, opts))

map("n", "<leader>gts",
    function() require("utils.gen_titles").GenerateSubtitle() end,
    vim.tbl_extend("keep", { desc = "Generate subtitle" }, opts))

map("n", "<leader>gtl",
    function() require("utils.gen_titles").GenerateOneLiner() end,
    vim.tbl_extend("keep", { desc = "Generate one-liner title" }, opts))

