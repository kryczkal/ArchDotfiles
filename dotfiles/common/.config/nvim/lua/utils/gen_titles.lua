local gen_titles = {}

function gen_titles.GenerateBlockTitle()
	local comment_char = vim.fn.input("Enter the comment character: ")
	if comment_char == "" then
		return
	end
	local title = vim.fn.input("Enter the title text: ")
	if title == "" then
		return
	end

	local border_char = vim.fn.input("Enter the border character [=]: ", "=")
	if border_char == "" then
		border_char = "="
	end

	local total_width_str = vim.fn.input("Enter the total width [80]: ", "80")
	local total_width = tonumber(total_width_str) or 80
	if total_width <= 0 then
		total_width = 80
	end

	local border_fill_len = total_width - string.len(comment_char)
	if border_fill_len < 0 then
		border_fill_len = 0
	end
	local border_str = comment_char .. string.rep(border_char, border_fill_len)

	local formatted_title = comment_char .. " " .. title

	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines_to_insert = { border_str, formatted_title, border_str }
	vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, lines_to_insert)
end

function gen_titles.GenerateOneLiner()
	local total_width = 80
	local comment_char = vim.fn.input("Enter the comment character: ")
	if comment_char == "" then
		return
	end
	local title = vim.fn.input("Enter the title text: ")
	if title == "" then
		return
	end

	local text_length = string.len(title)
	local padding_total = total_width - text_length
	if padding_total < 0 then
		padding_total = 0
	end

	local padding_side = math.floor(padding_total / 2)
	local left_padding_chars = string.rep(comment_char, padding_side)

	local right_padding_length = total_width - text_length - string.len(left_padding_chars)
	if right_padding_length < 0 then
		right_padding_length = 0
	end
	local right_padding_chars = string.rep(comment_char, right_padding_length)

	local formatted_title = left_padding_chars .. title .. right_padding_chars

	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, { formatted_title })
end

return gen_titles
