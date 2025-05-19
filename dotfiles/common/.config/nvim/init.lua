-- Global toggle for Copilot (set to false to disable all Copilot sources)
vim.g.copilot_enabled = true

-- Disable netrw for nvim-tree for a cleaner experience
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set leader keys BEFORE loading lazy.nvim or any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load core configuration modules
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lazy") -- This will setup and load all plugins
