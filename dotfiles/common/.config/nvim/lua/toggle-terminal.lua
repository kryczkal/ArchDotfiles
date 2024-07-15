-- Function to toggle terminal at the bottom
function ToggleBottomTerminal()
    -- Define the terminal buffer height
    local term_height = 10 -- Adjust the height as needed

    -- Find if a terminal buffer is already open
    local buf_found = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            buf_found = true
            break
        end
    end

    -- If terminal buffer is found, toggle it
    if buf_found then
        local win_found = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), 'buftype') == 'terminal' then
                win_found = true
                -- Close the window if it's open
                vim.api.nvim_win_close(win, true)
                break
            end
        end
        if not win_found then
            -- If no window found, open a new terminal in a bottom split
            vim.cmd('botright ' .. term_height .. 'split | terminal')
            vim.cmd('startinsert')
        end
    else
        -- If no terminal buffer found, open a new one at the bottom
        vim.cmd('botright ' .. term_height .. 'split | terminal')
        vim.cmd('startinsert')
    end
end
