local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- Import all plugin specs from the 'lua/plugins' directory
		{ import = "plugins" },
	},
	-- Configure lazy.nvim options
	install = {
		-- Default colorscheme while installing plugins
		colorscheme = { "cyberdream", "habamax" },
	},
	checker = {
		enabled = true, -- Automatically check for plugin updates
		notify = true, -- Notify when updates are available
	},
	performance = {
		rtp = {
			-- Disable some rtp plugins, true to disable
			disabled_plugins = {
				"gzip",
				-- "matchit", -- Consider keeping if you use % extensively
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
