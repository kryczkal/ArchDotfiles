return {
  "lukas-reineke/indent-blankline.nvim",
  main  = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    scope = { enabled = false },
    exclude = {
      filetypes = {
        "help", "alpha", "dashboard", "neo-tree", "trouble",
        "lazy", "mason", "notify", "toggleterm", "terminal",
      },
    },
  },
}
