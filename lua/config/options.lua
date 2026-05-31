-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim 默认值（无需重复设置）:
--   relativenumber, clipboard, splitright, splitbelow, undolevels

vim.opt.scrolloff = 8 -- 光标上下保留8行（默认4）
vim.opt.sidescrolloff = 8 -- 光标左右保留8列
vim.opt.updatetime = 200 -- 更快的诊断响应（默认4000ms）
vim.opt.confirm = true -- 退出未保存文件时弹出确认
