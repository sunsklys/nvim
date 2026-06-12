vim.opt.scrolloff = 8
vim.g.lazyvim_eslint_auto_format = false
vim.g.lazyvim_ts_lsp = "vtsls"

-- iTerm2 标签页显示：项目名/当前文件夹
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}/%{expand('%:h:t')}"
