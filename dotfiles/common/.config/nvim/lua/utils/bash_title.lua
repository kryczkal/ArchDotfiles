local bash_title = {}

function bash_title.GenerateBashTitle(title)
    local total_width = 80
    local border = string.rep("#", total_width)
    local text_length = string.len(title)
    local padding_side = (total_width - text_length - 4) / 2 -- Subtract 4 for spaces and # on both sides
    local padding = string.rep(" ", math.floor(padding_side))
    
    -- For odd lengths, adjust the right padding
    local right_padding = padding
    local padding_extra = (total_width - text_length - 4) % 2
    if padding_extra ~= 0 then
        right_padding = padding .. " "
    end

    local formatted_title = "# " .. padding .. title .. right_padding .. " #"

    -- Insert the formatted title into the current buffer
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Adjust to insert above the current line
    local lines_to_insert = {border, formatted_title, border}
    vim.api.nvim_buf_set_lines(0, current_line, current_line, false, lines_to_insert)
end

function bash_title.GenerateBashSubtitle(subtitle)
    local total_width = 80
    local text_length = string.len(subtitle)
    local padding_side = (total_width - text_length - 4) / 2 -- Subtract 4 for the `# ` and ` #`
    local padding = string.rep(" ", math.floor(padding_side))
    
    local right_padding = padding
    local padding_extra = (total_width - text_length - 4) % 2
    if padding_extra ~= 0 then
        right_padding = padding .. " "
    end
    
    local formatted_subtitle = "# " .. padding .. subtitle .. right_padding .. " #"
    
    -- Adjust subtitle border to be smaller, starting and ending with '#'
    local subtitle_border = "#" .. string.rep("-", total_width - 2) .. "#"

    -- Insert the formatted subtitle into the current buffer
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Adjust to insert above the current line
    local lines_to_insert = {subtitle_border, formatted_subtitle, subtitle_border}
    vim.api.nvim_buf_set_lines(0, current_line, current_line, false, lines_to_insert)
end

return bash_title

