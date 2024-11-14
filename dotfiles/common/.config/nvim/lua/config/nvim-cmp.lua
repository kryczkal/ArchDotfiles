local config = {}

local cmp = require('cmp')
local lspkind = require('lspkind')

local formatting_style = {
  format = lspkind.cmp_format()
}

config.setup = {
  formatting = formatting_style,
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
    completion = {
      border = "rounded",
      side_padding = 1,
      scrollbar = false,
    },
    documentation = {
      border = "rounded",
    },
  },

  sources = {
    { name = "nvim_lsp", group_index = 2 },
    { name = "luasnip", group_index = 2 },
    { name = "buffer", group_index = 2 },
    { name = "nvim_lua", group_index = 2 },
    { name = "path", group_index = 2},
    { name = "copilot", group_index = 2}

  },

  sorting = {
    priority_weight = 3,
    comparators = {
      cmp.config.compare.exact,
      require("copilot_cmp.comparators").prioritize,

      cmp.config.compare.offset,
      -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },

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
