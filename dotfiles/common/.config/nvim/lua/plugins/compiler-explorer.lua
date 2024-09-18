return {
  {
    "krady21/compiler-explorer.nvim",
    config = function ()
      compiler_explorer_config = require("config.compiler-explorer")
      require("compiler-explorer").setup(compiler_explorer_config.setup)
    end
  }
}
