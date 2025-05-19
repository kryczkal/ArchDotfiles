return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", 
  event = { "BufReadPost", "BufNewFile" }, -- Load when a file is read or a new one is created
  opts = {
    auto_install = true, -- Automatically install new parsers
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",    -- Start selection
        node_incremental = "grn",  -- Increment selection to parent node
        scope_incremental = "grc", -- Increment selection to scope
        node_decremental = "grm",  -- Decrement selection
      },
    },
  },
}
