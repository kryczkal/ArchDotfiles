return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- For icons
  opts = require("conf.nvim_tree"),
  -- lazy.nvim calls setup(opts) by default
}
