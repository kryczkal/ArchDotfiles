local config = {}

config.setup = {
  ensure_installed = {
    "asm-lsp",
    "clangd",
    "ruff",
    "pyright",
  }
}

return config
