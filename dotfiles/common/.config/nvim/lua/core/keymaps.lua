local map  = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Utility modules
require("utils.toggle_terminal")
require("utils.gen_titles")

-- Clipboard
map({ "n", "v" }, "<leader>y", '"+y',
    vim.tbl_extend("keep", { desc = "Yank to system clipboard" }, opts))

-- Quit
map("n", "<leader>q", ":q<CR>",
    vim.tbl_extend("keep", { desc = "Quit window" }, opts))

-- NvimTree
map("n", "<leader>fe", ":NvimTreeToggle<CR>",
    vim.tbl_extend("keep", { desc = "Toggle NvimTree" }, opts))

-- Telescope
map("n", "<leader>ff", function() require("telescope.builtin").find_files() end,
    vim.tbl_extend("keep", { desc = "Find files" }, opts))
map("n", "<leader>fg", function() require("telescope.builtin").live_grep() end,
    vim.tbl_extend("keep", { desc = "Live grep" }, opts))
map("n", "<leader>fb", function() require("telescope.builtin").buffers() end,
    vim.tbl_extend("keep", { desc = "Find buffers" }, opts))

-- WhichKey
map("n", "<leader>wk", ":WhichKey<CR>",
    vim.tbl_extend("keep", { desc = "Which-Key" }, opts))

-- Bottom terminal
map("n", "<leader>t", function() ToggleBottomTerminal() end,
    vim.tbl_extend("keep", { desc = "Toggle bottom terminal" }, opts))

-- Title helpers
map("n", "<leader>gtb", function() require("utils.gen_titles").GenerateTitle() end,
    vim.tbl_extend("keep", { desc = "Generate title (big)" }, opts))
map("n", "<leader>gts", function() require("utils.gen_titles").GenerateSubtitle() end,
    vim.tbl_extend("keep", { desc = "Generate subtitle" }, opts))
map("n", "<leader>gtl", function() require("utils.gen_titles").GenerateOneLiner() end,
    vim.tbl_extend("keep", { desc = "Generate one-liner title" }, opts))

-- CMake Tools
map("n", "<leader>cg", function() require("cmake-tools").generate() end,
    vim.tbl_extend("keep", { desc = "CMake: Generate" }, opts))
map("n", "<leader>cb", function() require("cmake-tools").build() end,
    vim.tbl_extend("keep", { desc = "CMake: Build" }, opts))
map("n", "<leader>cr", function() require("cmake-tools").run() end,
    vim.tbl_extend("keep", { desc = "CMake: Run" }, opts))
map("n", "<leader>ct", function() require("cmake-tools").test() end,
    vim.tbl_extend("keep", { desc = "CMake: Test" }, opts))
map("n", "<leader>cd", function() require("cmake-tools").debug() end,
    vim.tbl_extend("keep", { desc = "CMake: Debug" }, opts))
map("n", "<leader>cs", function() require("cmake-tools").select_target() end,
    vim.tbl_extend("keep", { desc = "CMake: Select Target" }, opts))

-- DAP shortcuts
map("n", "<F5>",  function() require("dap").continue()      end,
    vim.tbl_extend("keep", { desc = "Debug: Start/Continue" }, opts))
map("n", "<F10>", function() require("dap").step_over()     end,
    vim.tbl_extend("keep", { desc = "Debug: Step Over" }, opts))
map("n", "<F11>", function() require("dap").step_into()     end,
    vim.tbl_extend("keep", { desc = "Debug: Step Into" }, opts))
map("n", "<F12>", function() require("dap").step_out()      end,
    vim.tbl_extend("keep", { desc = "Debug: Step Out" }, opts))
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end,
    vim.tbl_extend("keep", { desc = "Debug: Toggle Breakpoint" }, opts))
map("n", "<leader>du", function() require("dapui").toggle() end,
    vim.tbl_extend("keep", { desc = "Debug: Toggle UI" }, opts))
