return {
	-- Core LSP client (lazy loads on first file read)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
	},
	-- Universal installer
	{ "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

	-- Mason ↔ LSP bridge
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{ "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },
		},
		opts = {
			ensure_installed = {
				"clangd",
				"terraformls",
				"gopls",
				"pyright",
				"bashls",
				"lua_ls",
			},
			handlers = {
				require("core.lsp_configs").setup,
			},
		},
	},

	-- External formatters / linters
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"jay-babu/mason-null-ls.nvim",
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvimtools/none-ls.nvim",
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				automatic_installation = true,
			})
		end,
	},
}
