local M = {
    "SmiteshP/nvim-navic",
    dependencies = {
        {"neovim/nvim-lspconfig"},
    },
    init = function()
        vim.g.navic_silence = false
    end,
    opts = {
        icons = {
            File = " ",
            Module = " ",
            Namespace = " ",
            Package = " ",
            Class = " ",
            Method = " ",
            Property = " ",
            Field = " ",
            Constructor = " ",
            Enum = " ",
            Interface = " ",
            Function = " ",
            Variable = " ",
            Constant = " ",
            String = " ",
            Number = " ",
            Boolean = " ",
            Array = " ",
            Object = " ",
            Key = " ",
            Null = " ",
            EnumMember = " ",
            Struct = " ",
            Event = " ",
            Operator = " ",
            TypeParameter = " ",
        },
        highlight = true,
        lsp = {
            auto_attach = true,
        },
    },
}

return M
