vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "终端模式退出" })

vim.keymap.set("n", "<leader>ga", function()
  local f = vim.fn.expand("%:p:r")
  if f:match("_test$") then
    local source = f:match("(.*)_test") .. ".go"
    if vim.fn.filereadable(source) == 1 then
      vim.cmd("edit " .. source)
    end
  else
    local test = f .. "_test.go"
    if vim.fn.filereadable(test) == 1 then
      vim.cmd("edit " .. test)
    end
  end
end, { desc = "Go 测试/源文件切换" })
