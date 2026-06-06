vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

local save_timer = nil
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
  callback = function()
    if save_timer then
      save_timer:close()
    end
    save_timer = vim.uv.new_timer()
    save_timer:start(1000, 0, function()
      save_timer:close()
      save_timer = nil
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].buftype ~= "" then
          return
        end
        if not vim.bo[buf].modified then
          return
        end
        if vim.fn.expand("%") == "" then
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
