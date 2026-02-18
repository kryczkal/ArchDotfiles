local M = {}

local wk = require("which-key")

-- Wrapper around which-key's add function.
-- This supports the new which-key v3 spec.
-- Note: conflict detection is now handled by which-key internally (it will overwrite).
function M.register(mappings, opts)
	wk.add(mappings, opts)
end

return M
