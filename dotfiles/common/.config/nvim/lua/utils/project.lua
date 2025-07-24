local M = {}

-- Finds the project root by searching upwards for a specific marker file.
function M.find_root(marker)
	local current_buf_path = vim.api.nvim_buf_get_name(0)
	if current_buf_path == "" then
		return nil
	end
	local current_dir = vim.fn.fnamemodify(current_buf_path, ":h")
	if not current_dir or current_dir == "" then
		return nil
	end

	local root_marker = vim.fs.find(marker, { path = current_dir, upward = true })
	if #root_marker > 0 then
		return vim.fn.fnamemodify(root_marker[1], ":h")
	end
	return nil
end

return M
