local config = {}

local cmp = require('cmp')
local lspkind = require('lspkind')

local formatting_style = {
    format = lspkind.cmp_format()
}

local function border(hl_name)
    return {
        { "╭", hl_name },
        { "─", hl_name },
        { "╮", hl_name },
        { "│", hl_name },
        { "╯", hl_name },
        { "─", hl_name },
        { "╰", hl_name },
        { "│", hl_name },
    }
end

config.setup = {
    formatting = formatting_style,
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    window = {
        completion = {
            border = border "CmpBorder",
            side_padding = 1,
            scrollbar = false,
        },
        documentation = {
            border = border "CmpDocBorder",
        },
    },

    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "path" },
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
    }),
}

return config
