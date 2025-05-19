-- Function to toggle terminal at the bottom

-- Ensure the function is globally accessible if called directly by keymaps from core
_G.ToggleBottomTerminal = function()
  local term_height = 10

  -- Find if a terminal buffer is already open and visible in a window
  local term_win_found = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      term_win_found = win
      break
    end
  end

  if term_win_found then
    -- If a terminal window is found, close it
    vim.api.nvim_win_close(term_win_found, true)
  else
    -- If no terminal window found, open a new one
    -- Check if a terminal buffer exists but is not in a window
    local existing_term_buf = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" and vim.fn.bufloaded(buf) == 1 then
            -- Check if this buffer is not associated with any window
            local is_displayed = false
            for _, win_id in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win_id) == buf then
                    is_displayed = true
                    break
                end
            end
            if not is_displayed then
                existing_term_buf = buf
                break
            end
        end
    end

    if existing_term_buf then
        -- Open existing hidden terminal buffer
        vim.cmd('botright ' .. term_height .. 'split')
        vim.api.nvim_set_current_buf(existing_term_buf)
    else
        -- Open a new terminal
        vim.cmd('botright ' .. term_height .. 'split | terminal')
    end
  end
end
