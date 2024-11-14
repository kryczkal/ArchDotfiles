return {
  {
    "williamboman/mason-lspconfig.nvim",
    requires = {
      "williamboman/mason.nvim",
    },
    after = {
      "mason.nvim",
      "nvim-lspconfig"
    },
    config = function()
      local mason_lspconfig_config = require("config.mason-lspconfig")
      require("mason-lspconfig").setup(mason_lspconfig_config.setup)
      -- automatic han
      require("mason-lspconfig").setup_handlers {
        function(server_name) -- default handler
          local opts = {}
          opts.capabilities = require('cmp_nvim_lsp').default_capabilities()
          --opts.capabilities = require('config.lspconfig').setup.capabilities
          opts.on_attach = require('config.lspconfig').setup.on_attach

          require("lspconfig")[server_name].setup(opts)
        end,

        ["rust_analyzer"] = function ()
          local opts = {}
          opts.capabilities = require('cmp_nvim_lsp').default_capabilities()
          opts.on_attach = require('config.lspconfig').setup.on_attach
          opts.settings = {
            ["rust-analyzer"] = {
              imports = {
                granularity = {
                  group = "module",
                },
                prefix = "self"
              },
              cargo = {
                buildScripts = {
                  enable = true
                },
              },
              procMacro = {
                enable = true
              },
            }
          }

          require("lspconfig").rust_analyzer.setup(opts)
        end,

        ["asm_lsp"] = function ()
          local opts = {}
          opts.capabilities = require('cmp_nvim_lsp').default_capabilities()
          opts.on_attach = require('config.lspconfig').setup.on_attach
          opts.filetypes = { 'asm', 'nasm' }
          require("lspconfig").asm_lsp.setup(opts)
        end,

        ["clangd"] = function ()
          local opts = {}
          opts.capabilities = require('cmp_nvim_lsp').default_capabilities()
          opts.on_attach = require('config.lspconfig').setup.on_attach
          opts.cmd = { "clangd", "--background-index", "--clang-tidy", "--cross-file-rename", "--suggest-missing-includes" }
          opts.root_dir = require("lspconfig/util").root_pattern("compile_commands.json", "compile_flags.txt", ".git")
          opts.single_file_support = true

          require("lspconfig").clangd.setup(opts)
        end
      }
    end
  },
  {
    "neovim/nvim-lspconfig",
    requires = {
      "williamboman/mason.nim",
      "williamboman/mason-lspconfig.nvim"
    },
    after = {
      "mason.nvim",
    },
    config = function()
      local lspconfig_config = require("config.lspconfig")
      require("lspconfig").lua_ls.setup(lspconfig_config.setup)
    end,
  },

}
