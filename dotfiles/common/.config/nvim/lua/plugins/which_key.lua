return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {},
	config = function(_, opts)
		require("which-key").setup(opts)
	end,
}
