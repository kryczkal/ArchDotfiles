return {
  {
    "samodostal/image.nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        "m00qek/baleia.nvim",
        version = "*",
        config = function()
          vim.g.baleia = require("baleia").setup({ })
          -- Colorize buffer on entry
          vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
            pattern = "*.txt",
            callback = function()
              vim.g.baleia.automatically(vim.api.nvim_get_current_buf())
            end,
          })
          -- Command to show logs 
          vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
        end,
      },
    },
    config = function()
      image_config = require("config.image")
      require("image").setup(image_config.setup)
    end,
  }
}
