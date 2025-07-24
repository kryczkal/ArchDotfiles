return {
  -- Core LSP client (lazy loads on first file read)
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

  -- Universal installer
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

  -- Mason ↔ LSP bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },
    },
    opts = {
      ensure_installed = {
        "clangd", "terraformls", "gopls", "pyright",
        "bashls", "lua_ls", "cmakels",
      },
      automatic_installation = true,
      handlers = {
        function(server)
          local lsp_helpers = require("utils.lsp_helpers")

          local opts = {
            capabilities = lsp_helpers.capabilities,
            on_attach = lsp_helpers.on_attach,
          }

          if server == "lua_ls" then
            opts.settings = {
              Lua = { diagnostics = { globals = { "vim" } },
                      workspace   = { checkThirdParty = false } }
            }
          end

          require("lspconfig")[server].setup(opts)
        end,
      },
    },
  },

  -- External formatters / linters
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "jay-babu/mason-null-ls.nvim",
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.clang_format,
          nls.builtins.formatting.goimports,
          nls.builtins.formatting.black,
          nls.builtins.formatting.terraform_fmt,
          nls.builtins.diagnostics.shellcheck,
        },
      }
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "clang-format", "goimports", "black",
        "terraform-fmt", "shellcheck",
      },
      automatic_installation = true,
    },
  },
}
