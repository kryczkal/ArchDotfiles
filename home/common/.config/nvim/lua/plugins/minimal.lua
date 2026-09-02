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
      overrides = function(_)
        return {
          -- Default grey (#7b8496) is tuned to recede; too dim on pure black
          Comment = { fg = "#a5b0c4" },
          -- Docstrings are content, not annotation - don't dim them like comments
          ["@string.documentation"] = { fg = "#c9d4e6" },
        }
      end,
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
