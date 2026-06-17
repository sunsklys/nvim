local group = vim.api.nvim_create_augroup("autosave", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    if vim.bo[buf].buftype ~= "" then
      return
    end
    if not vim.bo[buf].modified then
      return
    end
    if vim.bo[buf].readonly then
      return
    end
    if vim.api.nvim_buf_get_name(buf) == "" then
      return
    end
    if vim.fn.pumvisible() == 1 then
      return
    end
    vim.cmd("silent! update")
  end,
})
