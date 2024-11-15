local config = {}

local map = vim.keymap.set
config.on_attach = function(_, bufnr)
  -- command = :ClangdSwitchSourceHeader
  map("n", "<leader>cs", function()
    vim.cmd("ClangdSwitchSourceHeader")
  end, { buffer = bufnr, desc = "Switch between source and header" })
  local default_on_attach = require('config.lspconfig').setup.on_attach
  default_on_attach(_, bufnr)

end

return config
