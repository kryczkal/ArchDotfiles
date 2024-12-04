local config = {}
local map = vim.keymap.set
config.setup = {
  -- map function dapui open
  map("n", "<leader>duo", function()
    require("dapui").open()
    vim.cmd[[DapContinue]]
  end, { desc = "Dap UI Open" }),
}

return config
