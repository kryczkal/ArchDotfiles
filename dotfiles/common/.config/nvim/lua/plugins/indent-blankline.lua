return {
  {
    "lukas-reineke/indent-blankline.nvim",
    --        event = "User FilePost",
    main = "ibl",
    after = "nvim-treesitter",
    config = function(_, opts)
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require("ibl").setup(opts)
    end
  },
}
