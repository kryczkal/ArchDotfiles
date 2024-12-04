local config = {}

local map = vim.keymap.set
config.on_attach = function(_, bufnr)
  -- command = :ClangdSwitchSourceHeader
  map("n", "<leader>cs", function()
    vim.cmd("ClangdSwitchSourceHeader")
  end, { buffer = bufnr, desc = "Switch between source and header" })

  -- CMakeBuild
  map("n", "<leader>cb", function()
    vim.cmd("CMakeBuild")
  end, { buffer = bufnr, desc = "Build the project" })
  -- CMakeRun
  map("n", "<leader>cr", function()
    vim.cmd("CMakeRun")
  end, { buffer = bufnr, desc = "Run the project" })
  -- CMakeClean
  map("n", "<leader>cc", function()
    vim.cmd("CMakeClean")
  end, { buffer = bufnr, desc = "Clean the project" })
  local default_on_attach = require('config.lspconfig').setup.on_attach
  default_on_attach(_, bufnr)

end

return config
