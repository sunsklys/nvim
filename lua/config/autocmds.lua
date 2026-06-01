vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
    end
  end,
})
