local M = {}
local keymap_helpers = require("utils.keymap_helpers")

-- Flags to ensure context-aware keymaps are only registered once.
local cmake_keys_registered = false

keymap_helpers.register({
	f = {
		name = "+File",
		e = { ":NvimTreeToggle<CR>", "Toggle File Explorer" },
		f = {
			function()
				require("telescope.builtin").find_files()
			end,
			"Find File",
		},
		g = {
			function()
				require("telescope.builtin").live_grep()
			end,
			"Live Grep",
		},
		b = {
			function()
				require("telescope.builtin").buffers()
			end,
			"Find Buffer",
		},
	},
	q = { ":q<CR>", "Quit" },
	y = { '"+y', "Yank to system clipboard", mode = { "n", "v" } },
	w = {
		k = { ":WhichKey<CR>", "Which-Key" },
	},
	u = {
		name = "+Utils",
		t = {
			name = "+Title",
			b = {
				function()
					require("utils.gen_titles").GenerateTitle()
				end,
				"Generate title (big)",
			},
			s = {
				function()
					require("utils.gen_titles").GenerateSubtitle()
				end,
				"Generate subtitle",
			},
			l = {
				function()
					require("utils.gen_titles").GenerateOneLiner()
				end,
				"Generate one-liner title",
			},
		},
	},
	t = {
		name = "+Toggle",
		d = {
			name = "+Trouble Diagnostics",
			t = { "<cmd>Trouble diagnostics toggle<cr>", "Toggle Diagnostics" },
			b = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics" },
		},
		s = {
			name = "+Trouble Symbols",
			t = { "<cmd>Trouble symbols toggle<cr>", "Toggle Symbols" },
			b = { "<cmd>Trouble symbols toggle filter.buf=0<cr>", "Buffer Symbols" },
		},
		l = {
			name = "+LSP",
			d = { "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Definitions / References" },
			l = { "<cmd>Trouble loclist toggle<cr>", "Location List" },
		},
		q = {
			name = "+Quickfix",
			l = { "<cmd>Trouble qflist toggle<cr>", "Quickfix List" },
		},
	},
}, { prefix = "<leader>" })

-- Function to set up buffer-local LSP keymaps
function M.setup_lsp_keymaps(bufnr)
	local lsp_keymaps = {
		g = {
			name = "Goto",
			d = { vim.lsp.buf.definition, "Goto Definition" },
			D = { vim.lsp.buf.declaration, "Goto Declaration" },
			r = { vim.lsp.buf.references, "Goto References" },
			I = { vim.lsp.buf.implementation, "Goto Implementation" },
		},
		c = {
			name = "Code",
			s = { vim.lsp.buf.signature_help, "Signature Help" },
			h = { vim.lsp.buf.hover, "Hover Docs" },
			a = { vim.lsp.buf.code_action, "Action" },
			r = { { vim.lsp.buf.rename, "Rename" }, mode = { "n", "v" } },
		},
	}

	local diagnostics_keymaps = {
		["["] = { d = { vim.diagnostic.goto_prev, "Previous Diagnostic" } },
		["]"] = { d = { vim.diagnostic.goto_next, "Next Diagnostic" } },
	}

	keymap_helpers.register(lsp_keymaps, { prefix = "<leader>", buffer = bufnr })
	keymap_helpers.register(diagnostics_keymaps, { buffer = bufnr })
end

-- Function to set up context-aware CMake keymaps.
function M.setup_cmake_keymaps()
	if cmake_keys_registered then
		return
	end

	keymap_helpers.register({
		p = {
			name = "+Project",
			g = { "<cmd>CMakeGenerate<cr>", "Generate" },
			b = { "<cmd>CMakeBuild<cr>", "Build" },
			r = { "<cmd>CMakeRun<cr>", "Run" },
			d = { "<cmd>CMakeDebug<cr>", "Debug" },
			c = { "<cmd>CMakeClean<cr>", "Clean" },
			S = { "<cnd>CMakeTargetSettings<cr>", "Target Settings" },
			D = { "<cmd>CMakeSelectCwd<cr>", "Select CMakeLists.txt" },
		},
	}, { prefix = "<leader>" })

	cmake_keys_registered = true
end

return M
