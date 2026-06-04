vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "终端模式退出" })
for _, key in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. key, { desc = "终端窗口导航" })
end
