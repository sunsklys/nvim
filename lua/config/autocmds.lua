local save_timer = nil
local group = vim.api.nvim_create_augroup("autosave", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    if save_timer then
      save_timer:close()
    end
    save_timer = vim.uv.new_timer()
    save_timer:start(1000, 0, function()
      save_timer:close()
      save_timer = nil
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if vim.bo[buf].buftype ~= "" then
          return
        end
        if not vim.bo[buf].modified then
          return
        end
        if vim.api.nvim_buf_get_name(buf) == "" then
          return
        end
        if vim.fn.pumvisible() == 1 then
          return
        end
        vim.cmd("silent! update")
      end)
    end)
  end,
})
