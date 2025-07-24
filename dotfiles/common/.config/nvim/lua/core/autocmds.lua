local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Define a general autocommand group
local general_augroup = augroup("MyGeneralAutocmds", { clear = true })
local contextual_augroup = augroup("MyContextualAutocmds", { clear = true })

-- Filetype recognition
autocmd({ "BufRead", "BufNewFile" }, {
  group = general_augroup,
  pattern = "*.nasm",
  callback = function()
    vim.bo.filetype = "asm"
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group = general_augroup,
  pattern = { "*.tpp", "*.hpp", "*.hxx" },
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
  group = general_augroup,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Contextual Triggers (e.g., for project-specific keymaps)
autocmd({ "VimEnter", "BufEnter" }, {
  group = contextual_augroup,
  pattern = "*",
  callback = function()
    -- Check for CMake project and attach keymaps if found
    local project = require("utils.project")
    if project.find_root("CMakeLists.txt") then
      require("core.keymaps").setup_cmake_keymaps()
    end
  end,
})
