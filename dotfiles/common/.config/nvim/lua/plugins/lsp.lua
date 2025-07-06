return {
  -- Core LSP client (lazy loads on first file read)
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

  -- Universal installer
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

  -- Mason ↔ LSP bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    opts = {
      ensure_installed = {
        "clangd", "terraformls", "gopls", "pyright",
        "bashls", "lua_ls", "cmakels",
      },
      automatic_installation = true,
      handlers = {
        function(server)
          local caps = require("cmp_nvim_lsp")
                         .default_capabilities(vim.lsp.protocol.make_client_capabilities())

          local function on_attach(_, bufnr)
            local map = function(keys, fn, desc)
              vim.keymap.set("n", keys, fn,
                { buffer = bufnr, desc = "LSP: " .. desc, noremap = true, silent = true })
            end
            map("gd",  vim.lsp.buf.definition,        "Goto definition")
            map("gD",  vim.lsp.buf.declaration,       "Goto declaration")
            map("gr",  vim.lsp.buf.references,        "Goto references")
            map("gI",  vim.lsp.buf.implementation,    "Goto implementation")
            map("<leader>hd",   vim.lsp.buf.hover,             "Hover docs")
            map("[d",  vim.diagnostic.goto_prev,      "Prev diagnostic")
            map("]d",  vim.diagnostic.goto_next,      "Next diagnostic")
            map("<leader>rn", vim.lsp.buf.rename,     "Rename symbol")
            map("<leader>ca", vim.lsp.buf.code_action,"Code action")
          end

          local opts = { capabilities = caps, on_attach = on_attach }

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
