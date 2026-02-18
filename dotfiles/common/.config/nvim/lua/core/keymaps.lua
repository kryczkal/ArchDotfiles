local M = {}
local keymap_helpers = require("utils.keymap_helpers")

-- Flags to ensure context-aware keymaps are only registered once.
local cmake_keys_registered = false

-- Copilot flag
local copilot_toggled = false
if copilot_toggled then
    vim.cmd("Copilot enable")
else
    vim.cmd("Copilot disable")
end

keymap_helpers.register({
	{ "<leader>f", group = "File" },
	{ "<leader>fe", ":NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
	{
		"<leader>ff",
		function()
			require("telescope.builtin").find_files()
		end,
		desc = "Find File",
	},
	{
		"<leader>fg",
		function()
			require("telescope.builtin").live_grep()
		end,
		desc = "Live Grep",
	},
	{
		"<leader>fb",
		function()
			require("telescope.builtin").buffers()
		end,
		desc = "Find Buffer",
	},
	{
		"<leader>fr",
		function()
			if vim.fn.mode():find("[vV]") then
				vim.cmd("normal! \\<esc>")
				require("spectre").open_visual()
			else
				require("spectre").open_visual({ select_word = true })
			end
		end,
		desc = "Replace in Files (Visual Selection)",
		mode = { "n", "v" },
	},

	{ "<leader>q", ":q<CR>", desc = "Quit" },

	{ "<leader>y", '"+y', desc = "Yank to system clipboard", mode = { "n", "v" } },

	{ "<leader>wk", ":WhichKey<CR>", desc = "Which-Key" },

	{ "<leader>u", group = "Utils" },
	{ "<leader>ut", group = "Title" },
	{
		"<leader>utb",
		function()
			require("utils.gen_titles").GenerateBlockTitle()
		end,
		desc = "Generate Block Title",
	},
	{
		"<leader>utl",
		function()
			require("utils.gen_titles").GenerateOneLiner()
		end,
		desc = "Generate one-liner title",
	},

	{ "<leader>t", group = "Toggle" },
	{ "<leader>td", group = "Trouble Diagnostics" },
	{ "<leader>tdt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle Diagnostics" },
	{ "<leader>tdb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
	{ "<leader>ts", group = "Trouble Symbols" },
	{ "<leader>tst", "<cmd>Trouble symbols toggle<cr>", desc = "Toggle Symbols" },
	{ "<leader>tsb", "<cmd>Trouble symbols toggle filter.buf=0<cr>", desc = "Buffer Symbols" },
	{ "<leader>tl", group = "LSP" },
	{ "<leader>tld", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Definitions / References" },
	{ "<leader>tll", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
	{ "<leader>tq", group = "Quickfix" },
	{ "<leader>tql", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
	{
		"<leader>tr",
		function()
			require("spectre").toggle()
		end,
		desc = "Toggle Replace Window",
	},
	{
		"<leader>tc",
		function()
			if copilot_toggled then
				vim.cmd("Copilot enable")
			else
				vim.cmd("Copilot disable")
			end
			copilot_toggled = not copilot_toggled
		end,
		desc = "Toggle Copilot",
	},
})

-- Function to set up buffer-local LSP keymaps
function M.setup_lsp_keymaps(bufnr)
	local lsp_keymaps = {
		{ "<leader>g", group = "Goto" },
		{ "<leader>gd", vim.lsp.buf.definition, desc = "Goto Definition" },
		{ "<leader>gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
		{ "<leader>gr", vim.lsp.buf.references, desc = "Goto References" },
		{ "<leader>gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },

		{ "<leader>c", group = "Code" },
		{ "<leader>cs", vim.lsp.buf.signature_help, desc = "Signature Help" },
		{ "<leader>ch", vim.lsp.buf.hover, desc = "Hover Docs" },
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "Action" },
		{ "<leader>cr", vim.lsp.buf.rename, desc = "Rename", mode = { "n", "v" } },
	}

	local diagnostics_keymaps = {
		{ "[d", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
		{ "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
	}

	keymap_helpers.register(lsp_keymaps, { buffer = bufnr })
	keymap_helpers.register(diagnostics_keymaps, { buffer = bufnr })
end

-- Function to set up context-aware CMake keymaps.
function M.setup_cmake_keymaps()
	if cmake_keys_registered then
		return
	end

	keymap_helpers.register({
		{ "<leader>p", group = "Project" },
		{ "<leader>pg", "<cmd>CMakeGenerate<cr>", desc = "Generate" },
		{ "<leader>pb", "<cmd>CMakeBuild<cr>", desc = "Build" },
		{ "<leader>pr", "<cmd>CMakeRun<cr>", desc = "Run" },
		{ "<leader>pd", "<cmd>CMakeDebug<cr>", desc = "Debug" },
		{ "<leader>pc", "<cmd>CMakeClean<cr>", desc = "Clean" },
		{ "<leader>pS", "<cnd>CMakeTargetSettings<cr>", desc = "Target Settings" },
		{ "<leader>pD", "<cmd>CMakeSelectCwd<cr>", desc = "Select CMakeLists.txt" },
	})

	cmake_keys_registered = true
end

return M
