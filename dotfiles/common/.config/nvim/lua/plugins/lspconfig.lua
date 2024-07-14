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
