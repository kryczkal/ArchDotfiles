return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot_config = require("config.copilot")
      require("copilot").setup(copilot_config.setup)
    end,
    run = ":Copilot auth",
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      local copilot_cmp_config = require("config.copilot-cmp")
      require("copilot_cmp").setup(copilot_cmp_config.setup)
    end
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      debug = true,
    }
  },
}
