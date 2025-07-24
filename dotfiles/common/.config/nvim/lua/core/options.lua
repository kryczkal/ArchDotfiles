-- lua/core/options.lua
local o, opt, g = vim.o, vim.opt, vim.g

-- UI Enhancements
opt.number = true -- Show line numbers
opt.termguicolors = true -- Enable true color support
o.laststatus = 3 -- Global statusline
o.showmode = false -- Don't show mode since lualine will handle it
o.cursorline = true -- Highlight the current line
o.cursorlineopt = "number" -- Highlight only the number column for the current line

-- Search Behaviour
o.ignorecase = true -- Ignore case in search patterns
o.smartcase = true -- Override ignorecase if pattern contains uppercase letters

-- Tabs & Indentation
o.expandtab = true -- Use spaces instead of tabs
o.shiftwidth = 2 -- Number of spaces for autoindent
o.smartindent = true -- Enable smart autoindenting
o.tabstop = 2 -- Number of spaces a tab counts for
o.softtabstop = 2 -- Number of spaces for tab key and backspace

-- Window Splits and Clipboard
o.splitbelow = true -- Horizontal splits open below
o.splitright = true -- Vertical splits open to the right
o.clipboard = "unnamedplus" -- Use system clipboard

-- Performance & Annoyances
opt.shortmess:append("sI") -- Disable nvim intro message, shorten messages
opt.fillchars = { eob = " " } -- Make end-of-buffer characters invisible
o.mouse = "a" -- Enable mouse support in all modes
o.signcolumn = "yes" -- Always show the signcolumn
o.timeoutlen = 400 -- Time in milliseconds to wait for a mapped sequence
o.undofile = true -- Enable persistent undo

-- Disable default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
