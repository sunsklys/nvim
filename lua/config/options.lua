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

-- 光标上下保留 8 行上下文（LazyVim 默认 4，增加到 8 提升编辑体验）
vim.opt.scrolloff = 8

-- 长行软换行的视觉优化（适用于 markdown 长段落等 wrap=true 场景）
-- 配合 LazyVim markdown extra 的 wrap=true + linebreak=true 生效
-- - breakindent: 延续行与上一行缩进对齐，层次清晰
-- - showbreak: 延续行前缀标识，明确区分“延续”与“新行”
-- - breakat: 中文标点也可作为断行点（默认仅英文标点和空格）
--
-- 长表格超出窗口宽度时：按 <leader>uw 临时切换为 nowrap，
-- 再用 zL/zH/zh/zl 水平滚动查看完整表格（sidescrolloff 默认 8）。
vim.opt.breakindent = true
vim.opt.showbreak = "↳ "
vim.opt.breakat = " \t,.;:!?，。、；：！？"
