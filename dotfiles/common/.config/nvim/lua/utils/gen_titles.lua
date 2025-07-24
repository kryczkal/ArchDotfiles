local gen_titles = {}

function gen_titles.GenerateTitle()
	local comment_char = vim.fn.input("Enter the comment character: ")
	if comment_char == "" then
		return
	end
	local title = vim.fn.input("Enter the title text: ")
	if title == "" then
		return
	end

	local total_width = 80
	local border_str = string.rep(comment_char, total_width)
	local text_length = string.len(title)

	-- Ensure padding is not negative
	local padding_total = total_width - text_length - 4 -- for "# " and " #"
	if padding_total < 0 then
		padding_total = 0
	end

	local padding_side = math.floor(padding_total / 2)
	local padding = string.rep(" ", padding_side)

	local right_padding = padding
	if padding_total % 2 ~= 0 then
		right_padding = padding .. " "
	end

	local formatted_title = comment_char .. " " .. padding .. title .. right_padding .. " " .. comment_char

	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines_to_insert = { border_str, formatted_title, border_str }
	vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, lines_to_insert)
end

function gen_titles.GenerateSubtitle()
	local comment_char = vim.fn.input("Enter the comment character: ")
	if comment_char == "" then
		return
	end
	local subtitle = vim.fn.input("Enter the subtitle text: ")
	if subtitle == "" then
		return
	end

	local total_width = 80
	local text_length = string.len(subtitle)

	local padding_total = total_width - text_length - 4 -- for "# " and " #"
	if padding_total < 0 then
		padding_total = 0
	end

	local padding_side = math.floor(padding_total / 2)
	local padding = string.rep(" ", padding_side)

	local right_padding = padding
	if padding_total % 2 ~= 0 then
		right_padding = padding .. " "
	end

	local formatted_subtitle = comment_char .. " " .. padding .. subtitle .. right_padding .. " " .. comment_char
	local subtitle_border = comment_char .. string.rep("-", total_width - 2) .. comment_char

	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines_to_insert = { subtitle_border, formatted_subtitle, subtitle_border }
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

	-- Calculate remaining characters for the right side to ensure total_width
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
