local M = {}

-- Gets the LSP keymaps from keymaps.lua and sets them up for the buffer when LSP attaches
function M.on_attach(_, bufnr)
	require("core.keymaps").setup_lsp_keymaps(bufnr)
end

M.capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

return M
