-- nvim-tree requires this to be set before it is loaded
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.general")
require("config.lazy-package-manager")
require("mappings")
