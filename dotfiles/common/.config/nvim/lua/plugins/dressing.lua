return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    select = {
      backend = { "telescope", "builtin" },
      telescope = require("telescope.themes").get_cursor(),
      builtin = {
        win_options = {
          winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
        },
      },
    },
  },
}
