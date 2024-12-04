return {
    "rcarriga/nvim-dap-ui",
    requires = { "mfussenegger/nvim-dap" },
    config = function ()
      local map = vim.keymap.set
  map("n", "<leader>duo", function()
    require("dapui").open()
    vim.cmd[[DapContinue]]
  end, { desc = "Dap UI Open" })
    end,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap",
    },
}
