vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.nasm",
  callback = function()
    vim.bo.filetype = "asm"
  end,
})
