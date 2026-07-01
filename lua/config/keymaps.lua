
vim.keymap.set("n", "<leader>ga", function()
  local f = vim.fn.expand("%:p:r")
  if f:match("_test$") then
    local source = f:match("(.*)_test") .. ".go"
    if vim.fn.filereadable(source) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(source))
    end
  else
    local test = f .. "_test.go"
    if vim.fn.filereadable(test) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(test))
    end
  end
end, { desc = "Go 测试/源文件切换" })

-- gitsigns word_diff toggle（LazyVim 默认未开，与 current_line_blame 互补）
-- 注意：hunk text object `ih` 已是 LazyVim 默认（editor.lua gitsigns on_attach），无需重配
vim.keymap.set("n", "<leader>gdw", ":Gitsigns toggle_word_diff<CR>", { desc = "切换行内词级 diff" })
