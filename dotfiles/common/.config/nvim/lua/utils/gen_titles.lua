local gen_titles = {}

function gen_titles.GenerateTitle()
    local comment_char = vim.fn.input('Enter the comment character: ')
    local title = vim.fn.input('Enter the title text: ')

    local total_width = 80
    local border = string.rep(comment_char, total_width)
    local text_length = string.len(title)
    local padding_side = (total_width - text_length - 4) / 2 -- Subtract 4 for spaces and # on both sides
    local padding = string.rep(" ", math.floor(padding_side))
    
    -- For odd lengths, adjust the right padding
    local right_padding = padding
    local padding_extra = (total_width - text_length - 4) % 2
    if padding_extra ~= 0 then
        right_padding = padding .. " "
    end

    local formatted_title = comment_char .. " " .. padding .. title .. right_padding .. " " .. comment_char

    -- Insert the formatted title into the current buffer
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Adjust to insert above the current line
    local lines_to_insert = {border, formatted_title, border}
    vim.api.nvim_buf_set_lines(0, current_line, current_line, false, lines_to_insert)
end

function gen_titles.GenerateSubtitle()
    local comment_char = vim.fn.input('Enter the comment character: ')
    local subtitle = vim.fn.input('Enter the title text: ')

    local total_width = 80
    local text_length = string.len(subtitle)
    local padding_side = (total_width - text_length - 4) / 2 -- Subtract 4 for the `# ` and ` #`
    local padding = string.rep(" ", math.floor(padding_side))
    
    local right_padding = padding
    local padding_extra = (total_width - text_length - 4) % 2
    if padding_extra ~= 0 then
        right_padding = padding .. " "
    end
    
    local formatted_subtitle = comment_char .. " " .. padding .. subtitle .. right_padding .. " " .. comment_char
    
    -- Adjust subtitle border to be smaller, starting and ending with '#'
    local subtitle_border = comment_char .. string.rep("-", total_width - 2) .. comment_char

    -- Insert the formatted subtitle into the current buffer
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Adjust to insert above the current line
    local lines_to_insert = {subtitle_border, formatted_subtitle, subtitle_border}
    vim.api.nvim_buf_set_lines(0, current_line, current_line, false, lines_to_insert)
end

function gen_titles.GenerateOneLiner()
    local total_width = 80
    local comment_char = vim.fn.input('Enter the comment character: ')
    local title = vim.fn.input('Enter the title text: ')

    local comment_border = string.rep(comment_char, total_width)
    local text_length = string.len(title)
    local padding_side = (total_width - text_length) / 2 -- Calculate padding on both sides

    -- For odd lengths, adjust the right padding
    local left_padding = string.rep(comment_char, math.floor(padding_side - string.len(comment_char)))
    local right_padding = left_padding
    if (total_width - text_length) % 2 ~= 0 then
        right_padding = right_padding .. comment_char
    end

    local formatted_title = left_padding .. title .. right_padding

    -- Insert the formatted title into the current buffer
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Adjust to insert above the current line
    vim.api.nvim_buf_set_lines(0, current_line, current_line, false, {formatted_title})
end


return gen_titles

