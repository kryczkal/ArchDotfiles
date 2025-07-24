return {
	"scottmckendry/cyberdream.nvim",
	lazy = false, -- Ensures the colorscheme is applied on startup
	priority = 1000, -- High priority to load early
	opts = require("conf.ui").cyberdream,
	config = function(_, opts)
		require("cyberdream").setup(opts)
		vim.cmd("colorscheme cyberdream")
	end,
}
