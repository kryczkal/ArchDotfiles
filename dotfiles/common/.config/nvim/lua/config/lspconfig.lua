local config = {}

local map = vim.keymap.set
config.on_attach = function(_, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
  map("n", "gr", vim.lsp.buf.references, opts "Go to references")
  map("n", "<leader>sh", vim.lsp.buf.hover, opts "Show hover information")
  map("n", "<leader>ssh", vim.lsp.buf.signature_help, opts "Show signature help")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

  map("n", "<leader>rn", vim.lsp.buf.rename, opts "Rename")

  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")

  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
  map("n", "gr", vim.lsp.buf.references, opts "Show references")
end

config.on_init = function(client, _)
  --if client.supports_method "textDocument/semanticTokens" then
  --  client.server_capabilities.semanticTokensProvider = nil
  --end
end

config.capabilities = vim.lsp.protocol.make_client_capabilities()

config.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

config.setup = {
  on_attach = config.on_attach,
  on_init = config.on_init,
  capabilities = config.capabilities,
}

-- config.rust.settings = {
--   ["rust-analyzer"] = {
--     imports = {
--       granularity = {
--         group = "module",
--       },
--       prefix = "self"
--     },
--     cargo = {
--       buildScripts = {
--         enable = true
--       },
--     },
--     procMacro = {
--       enable = true
--     },
--   }
-- }


return config
