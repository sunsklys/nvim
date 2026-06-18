vim.opt.scrolloff = 8
vim.g.lazyvim_eslint_auto_format = false
vim.g.lazyvim_ts_lsp = "vtsls"

-- iTerm2 标签页显示：项目名/当前文件夹
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}/%{expand('%:h:t')}"

-- 终端字符宽度：ambiwidth 默认就是 "single"，这里显式写出作为文档。
-- 现代 macOS 终端（iTerm2/Ghostty/Kitty/WezTerm/Terminal.app）对 ambiguous-width
-- 字符（含 box-drawing │─┼、全角标点 ，。等）默认按 1 列渲染，与
-- Neovim 默认一致。不要设为 "double"：box-drawing 字符 EAW 分类为 A，
-- 会被当作 2 列宽 → Neovim 与终端宽度认知不一致 → 表格/光标错位。
-- 若全角标点需要按 2 列展示，使用 vim.fn.setcellwidths() 精确指定。
vim.opt.ambiwidth = "single"

-- render-markdown.nvim 依赖 conceallevel=2 才能把 |---| 这类语法替换成 │ ─ ┼ 边框
vim.opt.conceallevel = 2
vim.opt.concealcursor = ""
