return {
	"nvim-tree/nvim-tree.lua",
	cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = require("conf.nvim_tree"),
}
