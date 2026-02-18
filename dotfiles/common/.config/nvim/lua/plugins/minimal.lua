return {
  -----------------------------------------------------------------------------
  -- Disable the "Bar Below" (Statusline)
  -----------------------------------------------------------------------------
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "akinsho/bufferline.nvim", enabled = false },

  -----------------------------------------------------------------------------
  -- Disable Snacks related UI - changes
  -----------------------------------------------------------------------------
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            layout = {
              hidden = { "input" },
            },
          },
        },
      },
      indent = { enabled = false },
      dashboard = { enabled = false },
      scroll = { enabled = false },
      scope = { enabled = false },
    },
  },

  { "folke/noice.nvim", enabled = false },

  -----------------------------------------------------------------------------
  -- Bordered completion menu + docs
  -----------------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
      },
    },
  },

  -----------------------------------------------------------------------------
  -- Enable colorscheme
  -----------------------------------------------------------------------------
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      saturation = 1.0,
      borderless_pickers = false,
    },
  },

  -- Configure LazyVim to load cyberdream
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },
}
