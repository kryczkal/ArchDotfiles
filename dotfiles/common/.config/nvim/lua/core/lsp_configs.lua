local M = {}

local lspconfig = require("lspconfig")
local project = require("utils.project")

-- Returns a custom clangd configuration if a compile_commands.json file is found,
-- otherwise returns a default empty configuration.
local function get_clangd_config()
	local root_dir = project.find_root("compile_commands.json")
	if root_dir then
		return {
			cmd = {
				"clangd",
				"--compile-commands-dir=" .. root_dir,
			},
		}
	end
	return {} -- Default settings
end

-- This is the master handler function that mason-lspconfig will call for each server.
-- It applies a custom configuration if one is defined, otherwise uses the default.
function M.setup(server_name)
	local server_configs = {
		clangd = get_clangd_config(),
	}

	local config = server_configs[server_name] or {}
	lspconfig[server_name].setup(config)
end

return M
