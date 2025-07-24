return {
	-- Copilot engine (no inline ghost-text)
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "VeryLazy",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<C-a>",
					next = "<C-l>",
					prev = "<C-h>",
					dismiss = "<C-d>",
				},
			},
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					accept = "<CR>",
					jump_prev = "[[",
					jump_next = "]]",
				},
			},
		},
	},
	-- nvim-cmp with LuaSnip and Copilot source
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"onsails/lspkind-nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			-- Load and configure LuaSnip
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			local lspkind = require("lspkind")

			-- Configure nvim-cmp
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered({
						border = "rounded",
						winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
						col_offset = -3,
						side_padding = 0,
						scrollbar = false,
					}),
					documentation = cmp.config.window.bordered({
						border = "rounded",
						max_width = 60,
						max_height = 15,
					}),
				},
				performance = { max_view_entries = 8 },
				completion = { keyword_length = 2 },
				formatting = {
					format = function(entry, vim_item)
						local abbr = vim_item.abbr
						if #abbr > 45 then
							vim_item.abbr = vim.fn.strcharpart(abbr, 0, 45) .. "..."
						end
						if
							lspkind
							and lspkind.presets
							and lspkind.presets.default
							and lspkind.presets.default[vim_item.kind]
						then
							vim_item.kind = lspkind.presets.default[vim_item.kind] .. " " .. vim_item.kind
						else
						end
						return vim_item
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-e>"] = cmp.mapping.abort(),
				}),
				sources = cmp.config.sources({
					{ name = "copilot", max_item_count = 2, group_index = 0 },
					{ name = "nvim_lsp", max_item_count = 6, group_index = 1 },
					{ name = "luasnip", max_item_count = 4, group_index = 1 },
				}, {
					{ name = "buffer", max_item_count = 5 },
					{ name = "path", max_item_count = 3 },
				}),
			})

			-- clamp pumheight
			vim.opt.pumheight = 10
			vim.opt.completeopt = "menuone,noselect"

			-- Enable completions in command-line
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},
}
