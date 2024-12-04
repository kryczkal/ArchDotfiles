return {
  -- Dap
  "mfussenegger/nvim-dap",
  config = function ()
    local map = vim.keymap.set
    require("config.dap")
  --- Keymaps
  -- DapContinue
  map("n", "<leader>dc", function()
    vim.cmd("DapContinue")
  end, { desc = "Dap Continue" })
  -- DapStepOver
  map("n", "<leader>dso", function()
    vim.cmd("DapStepOver")
  end, { desc = "Dap Step Over" })
  -- DapStepInto
  map("n", "<leader<dsi", function()
    vim.cmd("DapStepInto")
  end, { desc = "Dap Step Into" })
  -- DapStepOut
  map("n", "<leader>dso", function()
    vim.cmd("DapStepOut")
  end, { desc = "Dap Step Out" })
  -- Dap restart
  map("n", "<leader>dr", function()
    require("dap").restart()
  end, { desc = "Dap Restart" })
  -- Dap stop (using dap.terminate)
  map("n", "<leader>ds", function()
    require("dap").terminate()
    require("dapui").close()
  end, { desc = "Dap Stop" })
  end,
}
