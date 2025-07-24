local M = {}

local wk = require("which-key")

-- Master table to hold the merged global keymap configuration.
local master_keymaps = {}

-- Recursively merges 'new_keys' into 'original_keys'.
local function deep_merge(original_keys, new_keys)
  for key, new_val in pairs(new_keys) do
    local original_val = original_keys[key]

    if original_val and type(original_val) == "table" and type(new_val) == "table" and not vim.tbl_islist(original_val) and not vim.tbl_islist(new_val) then
      -- Conflict detection: if both define a name and they are different, error out.
      if original_val.name and new_val.name and original_val.name ~= new_val.name then
        error("Keymap conflict: conflicting names for key '" .. key .. "'. Original: '" .. original_val.name .. "', New: '" .. new_val.name .. "'")
      end
      -- If both values are tables, recurse.
      deep_merge(original_val, new_val)
    else
      -- Otherwise, just set/overwrite the value.
      original_keys[key] = new_val
    end
  end
  return original_keys
end

-- Custom register function that merges keymaps before registering.
function M.register(keys, opts)
  -- For buffer-local keymaps, register them directly without merging into the global state.
  if opts and opts.buffer then
    wk.register(keys, opts)
    return
  end

  -- For global keymaps, merge them into the master table first.
  master_keymaps = deep_merge(master_keymaps, keys)

  -- Register the entire, updated master keymap table.
  wk.register(master_keymaps, opts)
end

return M
