local config = {}

config.init = {
  symbol_map = {
    Copilot = "",
  },
}

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})

return config
