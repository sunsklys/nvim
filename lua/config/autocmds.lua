vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "TextChanged" }, {
  callback = function()
    if vim.bo.buftype == "" and vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})
