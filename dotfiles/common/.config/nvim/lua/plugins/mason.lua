return {
  {
    "williamboman/mason.nvim",
    config = function()
      local mason_config = require("config.mason")
      require("mason").setup(mason_config.setup)
    end
  },
}
